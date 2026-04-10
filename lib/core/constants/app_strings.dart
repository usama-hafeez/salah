import '../services/storage_service.dart';

class AppStrings {
  static String get(String key) {
    final lang = StorageService.language;
    return _strings[key]?[lang] ?? _strings[key]?['en'] ?? key;
  }

  static const _strings = <String, Map<String, String>>{
    // ── Prayer names ──────────────────────────────────────────────────────────
    'fajr':    {'en': 'Fajr',    'ur': 'فجر',           'ar': 'الفجر'},
    'dhuhr':   {'en': 'Dhuhr',   'ur': 'ظہر',           'ar': 'الظهر'},
    'asr':     {'en': 'Asr',     'ur': 'عصر',           'ar': 'العصر'},
    'maghrib': {'en': 'Maghrib', 'ur': 'مغرب',          'ar': 'المغرب'},
    'isha':    {'en': 'Isha',    'ur': 'عشاء',          'ar': 'العشاء'},
    'sunrise': {'en': 'Sunrise', 'ur': 'طلوع آفتاب',    'ar': 'الشروق'},

    // ── Navigation ────────────────────────────────────────────────────────────
    'home':     {'en': 'Prayer',   'ur': 'نماز',     'ar': 'الصلاة'},
    'quran':    {'en': 'Quran',    'ur': 'قرآن',     'ar': 'القرآن'},
    'qibla':    {'en': 'Qibla',    'ur': 'قبلہ',     'ar': 'القبلة'},
    'calendar': {'en': 'Calendar', 'ur': 'کیلنڈر',   'ar': 'التقويم'},
    'settings': {'en': 'Settings', 'ur': 'ترتیبات',  'ar': 'الإعدادات'},

    // ── Home screen ───────────────────────────────────────────────────────────
    'next_prayer':  {'en': 'Next Prayer',   'ur': 'اگلی نماز',          'ar': 'الصلاة القادمة'},
    'prayer_times': {'en': 'Prayer Times',  'ur': 'نماز کے اوقات',      'ar': 'مواقيت الصلاة'},
    'remaining':    {'en': 'remaining',     'ur': 'باقی',               'ar': 'متبقي'},

    // ── Settings screen ───────────────────────────────────────────────────────
    'settings_more':       {'en': 'Settings & More',         'ur': 'ترتیبات اور مزید',      'ar': 'الإعدادات والمزيد'},
    'islamic_tools':       {'en': 'Islamic Tools',           'ur': 'اسلامی ٹولز',           'ar': 'الأدوات الإسلامية'},
    'app_settings':        {'en': 'Settings',                'ur': 'ترتیبات',               'ar': 'الإعدادات'},
    'about_section':       {'en': 'About',                   'ur': 'معلومات',               'ar': 'حول التطبيق'},
    'language':            {'en': 'Language',                'ur': 'زبان',                  'ar': 'اللغة'},
    'calc_method':         {'en': 'Calculation Method',      'ur': 'حساب کا طریقہ',         'ar': 'طريقة الحساب'},
    'madhab':              {'en': 'Madhab',                  'ur': 'مذہب',                  'ar': 'المذهب'},
    'notifications':       {'en': 'Notifications',           'ur': 'اطلاعات',               'ar': 'الإشعارات'},
    'azaan_sound':         {'en': 'Azaan Sound',             'ur': 'اذان کی آواز',          'ar': 'صوت الأذان'},
    'themes':              {'en': 'Themes',                  'ur': 'تھیمز',                 'ar': 'السمات'},
    'upgrade_pro':         {'en': 'Upgrade to Pro',          'ur': 'پرو میں اپ گریڈ کریں',  'ar': 'الترقية إلى برو'},
    'pro_active':          {'en': 'Pro Active',              'ur': 'پرو فعال ہے',           'ar': 'برو مفعّل'},
    'restore_purchase':    {'en': 'Restore Purchase',        'ur': 'خریداری بحال کریں',     'ar': 'استعادة الشراء'},
    'privacy_policy':      {'en': 'Privacy Policy',          'ur': 'رازداری کی پالیسی',     'ar': 'سياسة الخصوصية'},
    'rate_app':            {'en': 'Rate the App',            'ur': 'ایپ کو ریٹ کریں',       'ar': 'قيّم التطبيق'},
    'version':             {'en': 'Version',                 'ur': 'ورژن',                  'ar': 'الإصدار'},
    'contact_support':     {'en': 'Contact Support',         'ur': 'سپورٹ سے رابطہ',        'ar': 'التواصل مع الدعم'},

    // ── Language options ──────────────────────────────────────────────────────
    'lang_en': {'en': 'English',  'ur': 'English',  'ar': 'English'},
    'lang_ur': {'en': 'Urdu',     'ur': 'اردو',     'ar': 'اردو'},
    'lang_ar': {'en': 'Arabic',   'ur': 'عربی',     'ar': 'العربية'},

    // ── Calculation method options ────────────────────────────────────────────
    'method_karachi': {'en': 'Karachi (HEC)',       'ur': 'کراچی',         'ar': 'كراتشي'},
    'method_isna':    {'en': 'ISNA (North America)','ur': 'ISNA',          'ar': 'ISNA'},
    'method_mwl':     {'en': 'Muslim World League', 'ur': 'مسلم ورلڈ لیگ','ar': 'رابطة العالم الإسلامي'},
    'method_egypt':   {'en': 'Egyptian Authority',  'ur': 'مصری',          'ar': 'الهيئة المصرية'},
    'method_tehran':  {'en': 'Tehran',              'ur': 'تہران',         'ar': 'طهران'},
    'method_gulf':    {'en': 'Gulf Region (Kuwait)','ur': 'خلیج',          'ar': 'منطقة الخليج'},

    // ── Madhab options ────────────────────────────────────────────────────────
    'madhab_hanafi': {'en': 'Hanafi',  'ur': 'حنفی',  'ar': 'حنفي'},
    'madhab_shafi':  {'en': 'Shafi\'i','ur': 'شافعی',  'ar': 'شافعي'},

    // ── Azaan sound options ───────────────────────────────────────────────────
    'sound_mecca':    {'en': 'Mecca',    'ur': 'مکہ',     'ar': 'مكة'},
    'sound_egypt':    {'en': 'Egypt',    'ur': 'مصر',     'ar': 'مصر'},
    'sound_pakistan': {'en': 'Pakistan', 'ur': 'پاکستان', 'ar': 'باكستان'},
    'sound_turkey':   {'en': 'Turkey',   'ur': 'ترکی',    'ar': 'تركيا'},
    'sound_short':    {'en': 'Short tone','ur': 'مختصر',  'ar': 'نغمة قصيرة'},

    // ── Notification settings ─────────────────────────────────────────────────
    'notif_per_prayer':    {'en': 'Prayer Notifications',        'ur': 'نماز کی اطلاعات',          'ar': 'إشعارات الصلاة'},
    'notif_pre_reminder':  {'en': 'Pre-Prayer Reminder',         'ur': '10 منٹ پہلے یاددہانی',     'ar': 'تذكير قبل الصلاة'},
    'notif_pre_sub':       {'en': '10 minutes before each prayer','ur': 'ہر نماز سے 10 منٹ پہلے', 'ar': 'قبل كل صلاة بـ 10 دقائق'},
    'notif_jumua':         {'en': "Jumu'a Reminder",             'ur': 'جمعہ یاددہانی',            'ar': 'تذكير الجمعة'},
    'notif_jumua_sub':     {'en': 'Every Friday before Dhuhr',   'ur': 'ہر جمعہ ظہر سے پہلے',     'ar': 'كل جمعة قبل الظهر'},
    'notif_verse':         {'en': 'Daily Verse',                 'ur': 'روزانہ آیت',               'ar': 'آية اليوم'},
    'notif_verse_sub':     {'en': 'Verse of the Day at 8 AM',    'ur': 'صبح 8 بجے آیت',            'ar': 'آية في الساعة 8 صباحاً'},
    'notif_events':        {'en': 'Islamic Events',              'ur': 'اسلامی تہوار',             'ar': 'المناسبات الإسلامية'},
    'notif_events_sub':    {'en': 'Alerts for Islamic dates',    'ur': 'اسلامی تاریخوں کی اطلاع', 'ar': 'تنبيهات المناسبات الإسلامية'},

    // ── General UI ────────────────────────────────────────────────────────────
    'save':    {'en': 'Save',    'ur': 'محفوظ کریں', 'ar': 'حفظ'},
    'cancel':  {'en': 'Cancel',  'ur': 'منسوخ',      'ar': 'إلغاء'},
    'done':    {'en': 'Done',    'ur': 'مکمل',       'ar': 'تم'},
    'tasbih':  {'en': 'Tasbih',  'ur': 'تسبیح',      'ar': 'التسبيح'},
    'ramadan': {'en': 'Ramadan', 'ur': 'رمضان',      'ar': 'رمضان'},
    'qaza':    {'en': 'Qaza Tracker', 'ur': 'قضا ٹریکر', 'ar': 'متابعة القضاء'},
  };
}
