// Classic composer intake (from the c830319a re-check's probes, CR1-CR6).
// Intake races at 9 drafts: drop + Ctrl+V, keyboard image insertion + drop;
// a failed prepare releases its slot; the queue survives an exception; a
// chat switch mid-intake never stages a draft in the other chat, keyed or
// not (CR6: the intake belongs to the chat it started in). (Attach picker +
// drop needs a Desktop gateway: see classic_intake_wire_race_test.dart.)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes_android/core/composer/os_intake.dart';
import 'package:hermes_android/core/screens/chat_screen.dart';
import 'package:hermes_android/core/services/attachment_draft_service.dart';
import 'package:hermes_android/core/services/connection_manager.dart';
import 'package:hermes_android/core/theme/hermes_theme.dart';
import 'package:hermes_android/core/widgets/attachment_draft_tile.dart';
import 'package:hermes_android/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image/image.dart' as image_lib;
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/completed_stock_turn.dart';
import 'support/fake_voice_composer_adapter.dart';
import 'support/pump_chat_updates.dart';

const _composerKey = Key('chat-message-composer');

Session _session(String id) => Session(
  id: id,
  title: 'Chat $id',
  model: 'fixture',
  source: 'api_server',
  messageCount: 2,
  isActive: true,
  preview: '',
  startedAt: 1,
);

SavedConnection _conn(String id) => SavedConnection(
  id: id,
  label: id,
  host: 'race.fixture',
  port: 8642,
  apiKey: 'fixture',
);

class _Paths extends PathProviderPlatform {
  _Paths(this.dir);
  final Directory dir;
  @override
  Future<String?> getTemporaryPath() async => dir.path;
}

Future<void> _drain(WidgetTester tester, {bool Function()? done}) async {
  var quiet = 0;
  for (var i = 0; i < 400 && quiet < 4; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
    await tester.pump();
    if (done == null ? i >= 20 : done()) quiet++;
  }
}

int _tiles() => find.byType(AttachmentDraftTile).evaluate().length;
List<String> _names() => [
  for (final t in find.byType(AttachmentDraftTile).evaluate())
    (t.widget as AttachmentDraftTile).draft.name,
];

void _log(String s) {
  // ignore: avoid_print
  print(s);
}

void main() {
  late Directory root;
  late Directory cache;
  late PathProviderPlatform previousPaths;
  late Uint8List png;
  ClipboardAttachment? clip;

  setUp(() {
    SharedPreferences.setMockInitialValues({'verbose_mode': true});
    mockChatImageRecovery();
    root = Directory.systemTemp.createTempSync('classic-race');
    cache = Directory('${root.path}/cache')..createSync();
    previousPaths = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(root);
    png = image_lib.encodePng(image_lib.Image(width: 4, height: 4));
    clip = null;
    debugClipboardAttachmentReader = () async => clip;
  });

  tearDown(() {
    PathProviderPlatform.instance = previousPaths;
    debugClipboardAttachmentReader = null;
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  ChatScreen chat(String id, List<String> sent) => ChatScreen(
    connection: _conn('race-$id'),
    session: _session(id),
    testApiClient: ApiClient(
      baseUrl: 'http://race.fixture',
      apiKey: 'fixture',
      httpClient: MockClient((_) async => http.Response('{"data":[]}', 200)),
    ),
    testVoiceComposerAdapter: FakeVoiceComposerAdapter(),
    testAttachmentDraftService: AttachmentDraftService(
      cacheDirectoryProvider: () async => cache,
    ),
    testRemotePromptSubmit: completedStockTurn(({
      required sessionId,
      required text,
      required onEvent,
      required onSent,
    }) async {
      sent.add(text);
      onSent();
    }),
    testRemoteAttachmentUpload: ({required draft, required dataUrl}) async =>
        AttachmentUploadReceipt(refText: '@file:/attachments/${draft.name}'),
  );

  Widget app(Widget home) => MaterialApp(
    theme: hermesTheme(Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );

  List<OsIntakeFile> make(int n, String prefix) => [
    for (var i = 0; i < n; i++)
      OsIntakeFile(
        (File('${root.path}/$prefix$i.txt')..writeAsStringSync('n$i')).path,
      ),
  ];

  OsFileDropTarget target(WidgetTester tester) =>
      tester.widget<OsFileDropTarget>(find.byType(OsFileDropTarget));

  Future<void> nine(WidgetTester tester) async {
    target(tester).onFiles(make(maxRemoteAttachmentDrafts - 1, 'base'));
    await _drain(tester, done: () => _tiles() >= maxRemoteAttachmentDrafts - 1);
    expect(_tiles(), maxRemoteAttachmentDrafts - 1);
  }

  void insertImage(WidgetTester tester, Uint8List bytes) {
    final field = tester.widget<TextField>(find.byKey(_composerKey));
    field.contentInsertionConfiguration!.onContentInserted(
      KeyboardInsertedContent(
        mimeType: 'image/png',
        uri: 'content://keyboard/sticker.png',
        data: bytes,
      ),
    );
  }

  Future<void> ctrlV(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  }

  Future<void> big(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  for (final order in ['drop-first', 'paste-first']) {
    for (final kind in ['files', 'image']) {
      testWidgets('CR1 drop + Ctrl+V ($kind, $order) at 9 drafts give 10', (
        tester,
      ) async {
        await big(tester);
        await tester.pumpWidget(app(chat('cr1', [])));
        await pumpChatUpdates(tester);
        await nine(tester);
        final pasted = File('${root.path}/clip.txt')..writeAsStringSync('c');
        clip = kind == 'files'
            ? ClipboardAttachment(files: [pasted.path])
            : ClipboardAttachment(image: png);
        await tester.showKeyboard(find.byKey(_composerKey));
        await tester.pump();
        final drop = make(1, 'drop');
        if (order == 'drop-first') target(tester).onFiles(drop);
        await ctrlV(tester);
        if (order == 'paste-first') target(tester).onFiles(drop);
        await _drain(tester);
        final errors = <Object>[];
        Object? e;
        while ((e = tester.takeException()) != null) {
          errors.add(e!);
        }
        _log('CR1 $kind $order tiles=${_names()} errors=$errors');
        expect(errors, isEmpty);
        expect(_tiles(), maxRemoteAttachmentDrafts);
      });
    }
  }

  for (final order in ['insert-first', 'drop-first']) {
    testWidgets('CR3 keyboard image + drop ($order) at 9 drafts give 10', (
      tester,
    ) async {
      await big(tester);
      await tester.pumpWidget(app(chat('cr3', [])));
      await pumpChatUpdates(tester);
      await nine(tester);
      final drop = make(1, 'drop');
      if (order == 'drop-first') target(tester).onFiles(drop);
      insertImage(tester, png);
      if (order == 'insert-first') target(tester).onFiles(drop);
      await _drain(tester);
      _log('CR3 $order tiles=${_names()}');
      expect(tester.takeException(), isNull);
      expect(_tiles(), maxRemoteAttachmentDrafts);
    });
  }

  testWidgets('CR4 failed prepares release their slot: oversize, missing, '
      'directory-as-file and bad image bytes, then a good drop at 9 give 10', (
    tester,
  ) async {
    await big(tester);
    await tester.pumpWidget(app(chat('cr4', [])));
    await pumpChatUpdates(tester);
    await nine(tester);
    final f = File('${root.path}/big.bin');
    final raf = f.openSync(mode: FileMode.write);
    raf.truncateSync(maxGenericAttachmentBytes + 1);
    raf.closeSync();
    final dir = Directory('${root.path}/adir')..createSync();
    target(tester).onFiles([OsIntakeFile(f.path)]);
    target(tester).onFiles([OsIntakeFile('${root.path}/missing.txt')]);
    target(tester).onFiles([OsIntakeFile(dir.path)]);
    insertImage(tester, Uint8List.fromList([1, 2, 3, 4, 5]));
    target(tester).onFiles(make(1, 'good'));
    await _drain(tester);
    final errors = <Object>[];
    Object? e;
    while ((e = tester.takeException()) != null) {
      errors.add(e!);
    }
    _log('CR4 tiles=${_names()} errors=$errors');
    expect(errors, isEmpty);
    expect(_tiles(), maxRemoteAttachmentDrafts);
    expect(_names(), contains('good0.txt'));
  });

  testWidgets('CR5 the queue keeps running after refused/throwing jobs: a '
      'removed draft frees a slot the next drop takes', (tester) async {
    await big(tester);
    await tester.pumpWidget(app(chat('cr5', [])));
    await pumpChatUpdates(tester);
    target(tester).onFiles(make(maxRemoteAttachmentDrafts, 'full'));
    await _drain(tester, done: () => _tiles() >= maxRemoteAttachmentDrafts);
    target(tester).onFiles(make(1, 'over'));
    target(tester).onFiles([OsIntakeFile('${root.path}/nope/none.txt')]);
    await _drain(tester);
    expect(_tiles(), maxRemoteAttachmentDrafts);
    final tile = tester.widget<AttachmentDraftTile>(
      find.byType(AttachmentDraftTile).first,
    );
    tile.onRemove();
    await _drain(tester);
    expect(_tiles(), maxRemoteAttachmentDrafts - 1);
    target(tester).onFiles(make(1, 'after'));
    await _drain(tester, done: () => _names().contains('after0.txt'));
    _log('CR5 tiles=${_names()}');
    expect(_names(), contains('after0.txt'));
    expect(_tiles(), maxRemoteAttachmentDrafts);
  });

  for (final keyed in [true, false]) {
    testWidgets(
      'CR6 switching chat mid-intake (${keyed ? 'keyed by session, '
                'as the workspace and session list' : 'unkeyed didUpdateWidget'}) '
      'never stages the draft in the other chat',
      (tester) async {
        await big(tester);
        final which = ValueNotifier('cr6-a');
        await tester.pumpWidget(
          app(
            ValueListenableBuilder<String>(
              valueListenable: which,
              builder: (context, id, _) => keyed
                  ? KeyedSubtree(key: ValueKey(id), child: chat(id, []))
                  : chat(id, []),
            ),
          ),
        );
        await pumpChatUpdates(tester);
        target(tester).onFiles(make(3, 'a'));
        insertImage(tester, png);
        which.value = 'cr6-b';
        await tester.pump();
        await _drain(tester);
        _log('CR6 keyed=$keyed tiles in B=${_names()}');
        expect(_tiles(), 0);
      },
    );
  }
}
