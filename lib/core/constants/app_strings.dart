import '../services/storage_service.dart';

class AppStrings {
  static String get(String key) {
    final lang = StorageService.language;
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }

  static const _strings = <String, Map<String, String>>{
    'fajr': {'en': 'Fajr', 'ur': 'فجر', 'ar': 'الفجر'},
    'dhuhr': {'en': 'Dhuhr', 'ur': 'ظہر', 'ar': 'الظهر'},
    'asr': {'en': 'Asr', 'ur': 'عصر', 'ar': 'العصر'},
    'maghrib': {'en': 'Maghrib', 'ur': 'مغرب', 'ar': 'المغرب'},
    'isha': {'en': 'Isha', 'ur': 'عشاء', 'ar': 'العشاء'},
    'sunrise': {'en': 'Sunrise', 'ur': 'طلوع آفتاب', 'ar': 'الشروق'},
    'home': {'en': 'Prayer', 'ur': 'نماز', 'ar': 'الصلاة'},
    'quran': {'en': 'Quran', 'ur': 'قرآن', 'ar': 'القرآن'},
    'qibla': {'en': 'Qibla', 'ur': 'قبلہ', 'ar': 'القبلة'},
    'calendar': {'en': 'Calendar', 'ur': 'کیلنڈر', 'ar': 'التقويم'},
    'settings': {'en': 'Settings', 'ur': 'ترتیبات', 'ar': 'الإعدادات'},
    'next_prayer': {'en': 'Next Prayer', 'ur': 'اگلی نماز', 'ar': 'الصلاة القادمة'},
    'prayer_times': {'en': 'Prayer Times', 'ur': 'نماز کے اوقات', 'ar': 'مواقيت الصلاة'},
    'remaining': {'en': 'remaining', 'ur': 'باقی', 'ar': 'متبقي'},
    'upgrade_pro': {'en': 'Upgrade to Pro', 'ur': 'پرو میں اپ گریڈ کریں', 'ar': 'الترقية إلى برو'},
    'restore_purchase': {'en': 'Restore Purchase', 'ur': 'خریداری بحال کریں', 'ar': 'استعادة الشراء'},
  };
}
