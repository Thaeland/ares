import 'package:flutter/material.dart';

import '../theme/hermes_theme.dart';
import '../../nextgen/theme/nextgen_theme.dart';
import 'imported_theme.dart';

/// Paints a saved import over the active theme without dropping the other
/// theme extensions the current layout still reads.
ThemeData paintImportedTheme(ThemeData current, ImportedTheme imported) {
  final hermes = hermesTheme(imported.brightness)
      .extension<HermesTokens>()!
      .copyWith(
        brightness: imported.brightness,
        surface: imported[ImportedThemeColor.background],
        raised: imported[ImportedThemeColor.raised],
        border: imported[ImportedThemeColor.border],
        onSurface: imported[ImportedThemeColor.foreground],
        muted: imported[ImportedThemeColor.mutedForeground],
        accent: imported[ImportedThemeColor.accent],
        onAccent: foregroundFor(imported[ImportedThemeColor.accent]),
        danger: imported[ImportedThemeColor.error],
      );
  final ng = current.extension<NgColors>();
  final extensions = <ThemeExtension<dynamic>>[];
  for (final extension in current.extensions.values) {
    if (extension is! HermesTokens && extension is! NgColors) {
      extensions.add(extension);
    }
  }
  extensions.add(hermes);
  if (ng != null) extensions.add(_paintNg(ng, imported));
  return current.copyWith(
    scaffoldBackgroundColor: imported[ImportedThemeColor.background],
    canvasColor: imported[ImportedThemeColor.background],
    colorScheme: current.colorScheme.copyWith(
      brightness: imported.brightness,
      primary: imported[ImportedThemeColor.accent],
      onPrimary: foregroundFor(imported[ImportedThemeColor.accent]),
      surface: imported[ImportedThemeColor.background],
      onSurface: imported[ImportedThemeColor.foreground],
      error: imported[ImportedThemeColor.error],
      outline: imported[ImportedThemeColor.border],
    ),
    extensions: extensions,
  );
}

NgColors _paintNg(NgColors current, ImportedTheme imported) {
  final accent = imported[ImportedThemeColor.accent];
  final onAccent = foregroundFor(accent);
  final background = imported[ImportedThemeColor.background];
  final foreground = imported[ImportedThemeColor.foreground];
  final muted = imported[ImportedThemeColor.mutedForeground];
  return NgColors(
    background: background,
    surface: imported[ImportedThemeColor.card],
    surface2: imported[ImportedThemeColor.raised],
    surface3: imported[ImportedThemeColor.raised],
    well: imported[ImportedThemeColor.input],
    thumb: imported[ImportedThemeColor.card],
    sheet: imported[ImportedThemeColor.card],
    input: imported[ImportedThemeColor.input],
    sidebar: imported[ImportedThemeColor.sidebar],
    userBubble: accent,
    onUserBubble: onAccent,
    text: foreground,
    text2: foreground,
    text3: muted,
    textMuted: muted,
    accent: accent,
    onAccent: onAccent,
    accentText: accent,
    accentSoft: accent.withValues(alpha: 0.16),
    inverse: foreground,
    onInverse: background,
    stroke: imported[ImportedThemeColor.border],
    strokeStrong: imported[ImportedThemeColor.border],
    danger: imported[ImportedThemeColor.error],
    success: current.success,
    warning: current.warning,
    dangerSoft: imported[ImportedThemeColor.error].withValues(alpha: 0.16),
    successSoft: current.successSoft,
    warningSoft: current.warningSoft,
    glow: false,
  );
}
