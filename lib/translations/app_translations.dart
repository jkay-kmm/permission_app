import 'package:brainrot/translations/en_us.dart';
import 'package:brainrot/translations/vi_vn.dart';

class AppTranslations {
  static String get(
    String key, {
    required String languageCode,
  }) {
    final translations = languageCode == 'en' ? en : vi;

    return translations[key] ?? vi[key] ?? key;
  }
}
