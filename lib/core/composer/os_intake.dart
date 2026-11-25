// Files the OS hands the composer: dropped from the desktop, or pasted from
// the clipboard as files or an image. Both layouts turn them into attachment
// drafts through their existing pipeline; nothing here sends anything.
import 'dart:async';
import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/l10n.dart';

/// Desktop targets, where windows take OS drops and Cmd/Ctrl+V can carry
/// files or an image. Mobile pastes images through the keyboard instead
/// ([composerImageInsertion]).
bool get composerDesktopIntake =>
    !kIsWeb &&
    const {
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    }.contains(defaultTargetPlatform);

/// Image types a keyboard (or the clipboard) may insert into the composer.
const kComposerImageMimeTypes = [
  'image/png',
  'image/jpeg',
  'image/webp',
  'image/gif',
];

/// A file or folder the OS dropped on the composer.
class OsIntakeFile {
  const OsIntakeFile(this.path, {this.directory = false, this.bookmark});

  final String path;
  final bool directory;

  /// macOS security-scoped bookmark for a file outside the sandbox.
  final Uint8List? bookmark;

  String get name =>
      path.split(RegExp(r'[\\/]')).where((part) => part.isNotEmpty).last;
}

/// Files or an image on the clipboard, besides text.
class ClipboardAttachment {
  const ClipboardAttachment({this.files = const [], this.image});

  final List<String> files;
  final Uint8List? image;
}

/// Test seam for the clipboard read (no platform channel in tests).
@visibleForTesting
Future<ClipboardAttachment?> Function()? debugClipboardAttachmentReader;

/// What the clipboard holds besides text, or null (text, nothing, or a
/// platform without the reader).
Future<ClipboardAttachment?> readClipboardAttachment() async {
  final debug = debugClipboardAttachmentReader;
  if (debug != null) return debug();
  if (!composerDesktopIntake) return null;
  try {
    final files = await Pasteboard.files();
    final usable = [
      for (final path in files)
        if (path.trim().isNotEmpty) path,
    ];
    if (usable.isNotEmpty) return ClipboardAttachment(files: usable);
  } catch (_) {}
  try {
    final image = await Pasteboard.image;
    if (image != null && image.isNotEmpty) {
      return ClipboardAttachment(image: image);
    }
  } catch (_) {}
  return null;
}

/// Writes pasted image bytes into the app's cache, where the draft pipeline
/// reads (and later removes) attachment sources.
Future<String> stageComposerImageBytes(
  Uint8List bytes, {
  String? mimeType,
}) async {
  final extension = switch (mimeType) {
    'image/jpeg' => 'jpg',
    'image/webp' => 'webp',
    'image/gif' => 'gif',
    _ => 'png',
  };
  final root = await getTemporaryDirectory();
  final dir = Directory('${root.path}/composer-paste');
  await dir.create(recursive: true);
  final file = File(
    '${dir.path}/pasted-${DateTime.now().microsecondsSinceEpoch}.$extension',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

/// Runs [body] with read access to a dropped file that lives outside the
/// macOS sandbox (its security-scoped bookmark), then gives it back.
Future<T> withDroppedFileAccess<T>(
  OsIntakeFile file,
  Future<T> Function() body,
) async {
  final bookmark = file.bookmark;
  var started = false;
  if (bookmark != null &&
      bookmark.isNotEmpty &&
      defaultTargetPlatform == TargetPlatform.macOS) {
    try {
      started = await DesktopDrop.instance.startAccessingSecurityScopedResource(
        bookmark: bookmark,
      );
    } catch (_) {}
  }
  try {
    return await body();
  } finally {
    if (started) {
      try {
        await DesktopDrop.instance.stopAccessingSecurityScopedResource(
          bookmark: bookmark!,
        );
      } catch (_) {}
    }
  }
}

/// Takes files dropped from the OS on desktop, showing a hint while a drag
/// is over it. Elsewhere it is just [child].
class OsFileDropTarget extends StatefulWidget {
  const OsFileDropTarget({
    super.key,
    required this.child,
    required this.onFiles,
    this.enabled = true,
  });

  final Widget child;
  final ValueChanged<List<OsIntakeFile>> onFiles;
  final bool enabled;

  @override
  State<OsFileDropTarget> createState() => _OsFileDropTargetState();
}

class _OsFileDropTargetState extends State<OsFileDropTarget> {
  bool _over = false;

  @override
  Widget build(BuildContext context) {
    if (!composerDesktopIntake) return widget.child;
    return DropTarget(
      enable: widget.enabled,
      onDragEntered: (_) => setState(() => _over = true),
      onDragExited: (_) => setState(() => _over = false),
      onDragDone: (details) {
        setState(() => _over = false);
        final files = <OsIntakeFile>[
          for (final item in details.files)
            if (item.path.isNotEmpty)
              OsIntakeFile(
                item.path,
                directory: item is DropItemDirectory,
                bookmark: item.extraAppleBookmark,
              ),
        ];
        if (files.isNotEmpty) widget.onFiles(files);
      },
      child: Stack(
        children: [
          widget.child,
          if (_over)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(context.sharedL10n.composer_drop_attach),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Paste (Cmd/Ctrl+V) that takes files or an image from the clipboard as
/// attachments; plain text pastes as it always did. The editor's paste
/// action is overridable, so this sits above the TextField.
class ClipboardAttachmentPaste extends StatelessWidget {
  const ClipboardAttachmentPaste({
    super.key,
    required this.child,
    required this.onAttachment,
  });

  final Widget child;
  final Future<void> Function(ClipboardAttachment found) onAttachment;

  @override
  Widget build(BuildContext context) {
    if (!composerDesktopIntake && debugClipboardAttachmentReader == null) {
      return child;
    }
    return Actions(
      actions: {PasteTextIntent: _AttachmentPasteAction(onAttachment)},
      child: child,
    );
  }
}

class _AttachmentPasteAction extends Action<PasteTextIntent> {
  _AttachmentPasteAction(this.onAttachment);

  final Future<void> Function(ClipboardAttachment found) onAttachment;

  @override
  Object? invoke(PasteTextIntent intent) {
    // The editor's own paste, captured now: it is only reachable while
    // this override runs.
    final fallback = callingAction;
    unawaited(() async {
      final found = await readClipboardAttachment();
      if (found != null) {
        await onAttachment(found);
        return;
      }
      fallback?.invoke(intent);
    }());
    return null;
  }
}

/// A keyboard's image insertion (Android GBoard stickers, pasted images):
/// the bytes become an attachment draft instead of being refused.
ContentInsertionConfiguration composerImageInsertion(
  Future<void> Function(Uint8List bytes, String mimeType) onImage,
) => ContentInsertionConfiguration(
  allowedMimeTypes: kComposerImageMimeTypes,
  onContentInserted: (content) {
    final data = content.data;
    if (data == null || data.isEmpty) return;
    unawaited(onImage(data, content.mimeType));
  },
);
