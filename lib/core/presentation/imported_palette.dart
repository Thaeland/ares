import 'package:flutter/material.dart';

import '../theme/hermes_theme.dart';
import '../../nextgen/nextgen_preferences.dart';
import '../../nextgen/theme/nextgen_theme.dart';
import 'imported_theme.dart';

/// Builds the whole theme for a saved import, in the import's own brightness.
///
/// Recolouring only the scheme and the colour extensions left text styles,
/// app bars, cards, inputs and dividers on the built-in palette of the app's
/// brightness: a dark import over a light app painted dark text on a dark
/// background. The layout's own theme builder now derives every component
/// from the import. Theme extensions other than the two colour sets, and
/// the platform and density settings, are kept from [current].
ThemeData paintImportedTheme(ThemeData current, ImportedTheme imported) {
  final nextGen = current.extension<NgColors>() != null;
  // The surrounding theme animates between brightnesses frame by frame; the
  // import's own theme does not change with it, so build it once.
  final key = [
    nextGen,
    imported.brightness.name,
    for (final role in ImportedThemeColor.values) imported[role].toARGB32(),
  ].join(',');
  final built = _built[key] ??= _build(imported, nextGen: nextGen);
  if (_built.length > 8) _built.remove(_built.keys.first);
  return built.copyWith(
    platform: current.platform,
    visualDensity: current.visualDensity,
    materialTapTargetSize: current.materialTapTargetSize,
    pageTransitionsTheme: current.pageTransitionsTheme,
    extensions: [
      ...current.extensions.values.where(
        (extension) => extension is! HermesTokens && extension is! NgColors,
      ),
      ...built.extensions.values.where(
        (extension) => extension is HermesTokens || extension is NgColors,
      ),
    ],
  );
}

final _built = <String, ThemeData>{};

ThemeData _build(ImportedTheme imported, {required bool nextGen}) {
  final scheme = _importedScheme(imported, nextGen: nextGen);
  return nextGen
      ? nextGenTheme(
          imported.brightness,
          NextGenLook.instance,
          profileScheme: scheme,
          colors: _paintNg(imported, scheme),
        )
      : hermesTheme(imported.brightness, profileScheme: scheme);
}

/// Body text has to clear 4.5:1 on every surface it is drawn on. A theme
/// that falls short keeps its hue and moves toward black or white.
Color _legible(Color ink, List<Color> surfaces) {
  bool passes(Color color) =>
      surfaces.every((surface) => contrastRatio(color, surface) >= 4.5);
  if (passes(ink)) return ink;
  final target = foregroundFor(surfaces.first);
  for (var step = 1; step <= 32; step++) {
    final mixed = Color.lerp(ink, target, step / 32)!;
    if (passes(mixed)) return mixed;
  }
  return target;
}

Color _over(Color tint, double alpha, Color surface) =>
    Color.alphaBlend(tint.withValues(alpha: alpha), surface);

ColorScheme _importedScheme(ImportedTheme t, {required bool nextGen}) {
  final background = t[ImportedThemeColor.background];
  final card = t[ImportedThemeColor.card];
  final raised = t[ImportedThemeColor.raised];
  final accent = t[ImportedThemeColor.accent];
  final error = t[ImportedThemeColor.error];
  final surfaces = [background, card, raised];
  final foreground = _legible(t[ImportedThemeColor.foreground], surfaces);
  final muted = _legible(t[ImportedThemeColor.mutedForeground], surfaces);
  return ColorScheme.fromSeed(
    seedColor: accent,
    brightness: t.brightness,
  ).copyWith(
    primary: accent,
    onPrimary: foregroundFor(accent),
    primaryContainer: _over(accent, 0.16, background),
    onPrimaryContainer: foreground,
    surfaceTint: accent,
    surface: background,
    onSurface: foreground,
    onSurfaceVariant: muted,
    surfaceContainerLowest: background,
    // Classic draws cards, menus and inputs on its raised surface; NextGen
    // draws cards on `surface` and steps up from there.
    surfaceContainerLow: nextGen ? card : raised,
    surfaceContainer: raised,
    surfaceContainerHigh: raised,
    surfaceContainerHighest: raised,
    outline: t[ImportedThemeColor.border],
    outlineVariant: t[ImportedThemeColor.border],
    error: error,
    onError: foregroundFor(error),
    errorContainer: _over(error, 0.16, background),
    onErrorContainer: foreground,
    inverseSurface: foreground,
    onInverseSurface: background,
  );
}

NgColors _paintNg(ImportedTheme imported, ColorScheme scheme) {
  // Status colours follow the import's brightness, not the app's.
  final status = NgColors.build(
    imported.brightness,
    NextGenLook.instance.accent,
    false,
    false,
  );
  final accent = scheme.primary;
  final background = scheme.surface;
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
    onUserBubble: scheme.onPrimary,
    text: scheme.onSurface,
    text2: scheme.onSurface,
    text3: scheme.onSurfaceVariant,
    textMuted: scheme.onSurfaceVariant,
    accent: accent,
    onAccent: scheme.onPrimary,
    accentText: accent,
    accentSoft: accent.withValues(alpha: 0.16),
    inverse: scheme.onSurface,
    onInverse: background,
    stroke: scheme.outlineVariant,
    strokeStrong: scheme.outline,
    danger: scheme.error,
    success: status.success,
    warning: status.warning,
    dangerSoft: scheme.error.withValues(alpha: 0.16),
    successSoft: status.successSoft,
    warningSoft: status.warningSoft,
    glow: false,
  );
}
