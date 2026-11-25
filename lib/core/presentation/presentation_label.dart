import 'package:flutter/widgets.dart';

/// Selects one caller-supplied string from the ambient locale.
///
/// Arabic (`ar`, any region) uses [ar]. Traditional Chinese (`zh-Hant`,
/// `zh_TW`, `zh_HK`, `zh_MO`) uses [zhHant]. Every other locale, including
/// Simplified Chinese, uses [en].
String presentationLabel(
  BuildContext context,
  String en,
  String ar,
  String zhHant,
) {
  final locale = Localizations.localeOf(context);
  switch (locale.languageCode) {
    case 'ar':
      return ar;
    case 'zh':
      final traditional =
          locale.scriptCode == 'Hant' ||
          locale.countryCode == 'TW' ||
          locale.countryCode == 'HK' ||
          locale.countryCode == 'MO';
      return traditional ? zhHant : en;
    default:
      return en;
  }
}
