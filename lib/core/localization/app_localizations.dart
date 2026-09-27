import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'ar': {
      'appTitle': 'مشغل الفيديو - المنصة التعليمية',
      'coursesHeader': 'الدورات التدريبية',
      'continueWatching': 'متابعة المشاهدة',
      'resumeLesson': 'متابعة الدرس',
      'instructorPrefix': 'المحاضر: ',
      'totalLessons': 'درس',
      'totalSections': 'وحدة تعليمية',
      'courseProgress': 'إنجاز الدورة',
      'statusNotStarted': 'لم يبدأ',
      'statusInProgress': 'قيد التقدم',
      'statusCompleted': 'مكتمل',
      'statusLocked': 'مغلق',
      'playLesson': 'بدء تشغيل الدرس',
      'nextLesson': 'الدرس التالي',
      'completedCourse': 'تهانينا! أكملت هذه الدورة بالكامل 🎉',
      'lockedLessonMessage': 'عذراً، يجب إكمال الدرس السابق أولاً لتتمكن من فتح هذا الدرس.',
      'retry': 'إعادة المحاولة',
      'speedLabel': 'السرعة',
      'navCourses': 'الدورات',
      'navFavorites': 'المفضلة',
      'navSettings': 'الإعدادات',
      'settingsTitle': 'الإعدادات والتفضيلات',
      'appearance': 'المظهر والسمة',
      'themeMode': 'وضع الشاشة',
      'lightMode': 'الوضع الفاتح',
      'darkMode': 'الوضع الداكن',
      'systemMode': 'تلقائي حسب النظام',
      'language': 'اللغة / Language',
      'selectLanguage': 'اختر لغة التطبيق',
      'arabic': 'العربية (Arabic)',
      'english': 'English (الإنجليزية)',
      'hindi': 'الهندية (Hindi)',
      'chinese': 'الصينية (Chinese)',
      'emptyFavorites': 'لا توجد دورات مفضلة محفوظة بعد.',
      'addToFavorites': 'إضافة إلى المفضلة',
      'removeFromFavorites': 'إزالة من المفضلة',
      'errorLoadingCourses': 'حدث خطأ أثناء تحميل بيانات الدورات.',
      'errorLoadingVideo': 'عذراً، تعذر تحميل الفيديو. يرجى المحاولة لاحقاً.',
      'emptyCourses': 'لا توجد دورات متاحة حالياً.',
      'courseNotFound': 'لم يتم العثور على الدورة المطلوبة.',
      'lessonNotFound': 'لم يتم العثور على الدرس المطلوب.',
      'loading': 'جاري التحميل...',
      'loadingVideo': 'جاري تحميل الفيديو...',
      'completedSummary': 'المكتمل: {completed} من {total} دروس ({remaining} متبقي)',
      'left': 'متبقي',
      'searchCourses': 'البحث عن دورة تعليمية...',
      'noCoursesFound': 'لم يتم العثور على نتائج مطابقة.',
      'lessonNotes': 'ملاحظات الدرس',
      'writeNotesPlaceholder': 'اكتب ملاحظاتك الشخصية لهذا الدرس هنا...',
      'saveNote': 'حفظ الملاحظة',
      'noteSaved': 'تم حفظ الملاحظة بنجاح!',
      'clearNote': 'مسح الملاحظة',
    },
    'en': {
      'appTitle': 'Video Player - LMS Platform',
      'coursesHeader': 'Available Courses',
      'continueWatching': 'Continue Watching',
      'resumeLesson': 'Resume Lesson',
      'instructorPrefix': 'Instructor: ',
      'totalLessons': 'lessons',
      'totalSections': 'sections',
      'courseProgress': 'Course Progress',
      'statusNotStarted': 'Not Started',
      'statusInProgress': 'In Progress',
      'statusCompleted': 'Completed',
      'statusLocked': 'Locked',
      'playLesson': 'Start Lesson',
      'nextLesson': 'Next Lesson',
      'completedCourse': 'Congratulations! You completed this course 🎉',
      'lockedLessonMessage': 'Sorry, you must complete the previous lesson first to unlock this lesson.',
      'retry': 'Retry',
      'speedLabel': 'Speed',
      'navCourses': 'Courses',
      'navFavorites': 'Favorites',
      'navSettings': 'Settings',
      'settingsTitle': 'Settings & Preferences',
      'appearance': 'Appearance & Theme',
      'themeMode': 'Theme Mode',
      'lightMode': 'Light Mode',
      'darkMode': 'Dark Mode',
      'systemMode': 'System Default',
      'language': 'Language',
      'selectLanguage': 'Select Application Language',
      'arabic': 'العربية (Arabic)',
      'english': 'English',
      'hindi': 'हिन्दी (Hindi)',
      'chinese': '中文 (Chinese)',
      'emptyFavorites': 'No favorite courses saved yet.',
      'addToFavorites': 'Add to Favorites',
      'removeFromFavorites': 'Remove from Favorites',
      'errorLoadingCourses': 'Error loading course data.',
      'errorLoadingVideo': 'Sorry, unable to load video. Please try again later.',
      'emptyCourses': 'No courses available at the moment.',
      'courseNotFound': 'Course not found.',
      'lessonNotFound': 'Lesson not found.',
      'loading': 'Loading...',
      'loadingVideo': 'Loading video...',
      'completedSummary': 'Completed: {completed} of {total} lessons ({remaining} remaining)',
      'left': 'left',
      'searchCourses': 'Search courses...',
      'noCoursesFound': 'No matching courses found.',
      'lessonNotes': 'Lesson Notes',
      'writeNotesPlaceholder': 'Write your personal notes for this lesson here...',
      'saveNote': 'Save Note',
      'noteSaved': 'Note saved successfully!',
      'clearNote': 'Clear Note',
    },
    'hi': {
      'appTitle': 'वीडियो प्लेयर - एलएमएस प्लेटफॉर्म',
      'coursesHeader': 'उपलब्ध पाठ्यक्रम',
      'continueWatching': 'देखना जारी रखें',
      'resumeLesson': 'पाठ फिर से शुरू करें',
      'instructorPrefix': 'शिक्षक: ',
      'totalLessons': 'पाठ',
      'totalSections': 'अनुभाग',
      'courseProgress': 'पाठ्यक्रम प्रगति',
      'statusNotStarted': 'शुरू नहीं हुआ',
      'statusInProgress': 'प्रगति में',
      'statusCompleted': 'पूर्ण',
      'statusLocked': 'लॉक किया गया',
      'playLesson': 'पाठ शुरू करें',
      'nextLesson': 'अगला पाठ',
      'completedCourse': 'बधाई हो! आपने यह पाठ्यक्रम पूरा कर लिया है 🎉',
      'lockedLessonMessage': 'क्षमा करें, इस पाठ को अनलॉक करने के लिए आपको पहले पिछला पाठ पूरा करना होगा।',
      'retry': 'पुनः प्रयास करें',
      'speedLabel': 'गति',
      'navCourses': 'पाठ्यक्रम',
      'navFavorites': 'पसंदीदा',
      'navSettings': 'सेटिंग्स',
      'settingsTitle': 'सेटिंग्स और प्राथमिकताएं',
      'appearance': 'उपस्थिति और थीम',
      'themeMode': 'थीम मोड',
      'lightMode': 'लाइट मोड',
      'darkMode': 'डार्क मोड',
      'systemMode': 'सिस्टम डिफ़ॉल्ट',
      'language': 'भाषा',
      'selectLanguage': 'आवेदन भाषा चुनें',
      'arabic': 'العربية (अरबी)',
      'english': 'English (अंग्रेजी)',
      'hindi': 'हिन्दी (Hindi)',
      'chinese': '中文 (चीनी)',
      'emptyFavorites': 'अभी तक कोई पसंदीदा पाठ्यक्रम नहीं सहेजा गया है।',
      'addToFavorites': 'पसंदीदा में जोड़ें',
      'removeFromFavorites': 'पसंदीदा से हटाएं',
      'errorLoadingCourses': 'पाठ्यक्रम डेटा लोड करने में त्रुटि।',
      'errorLoadingVideo': 'क्षमा करें, वीडियो लोड करने में असमर्थ। कृपया बाद में पुनः प्रयास करें।',
      'emptyCourses': 'फिलहाल कोई पाठ्यक्रम उपलब्ध नहीं है।',
      'courseNotFound': 'पाठ्यक्रम नहीं मिला।',
      'lessonNotFound': 'पाठ नहीं मिला।',
      'loading': 'लोड हो रहा है...',
      'loadingVideo': 'वीडियो लोड हो रहा है...',
      'completedSummary': 'पूर्ण: {completed} / {total} पाठ ({remaining} शेष)',
      'left': 'शेष',
      'searchCourses': 'पाठ्यक्रम खोजें...',
      'noCoursesFound': 'कोई मेल खाने वाले पाठ्यक्रम नहीं मिले।',
      'lessonNotes': 'पाठ के नोट्स',
      'writeNotesPlaceholder': 'इस पाठ के लिए अपने व्यक्तिगत नोट्स यहां लिखें...',
      'saveNote': 'नोट सहेजें',
      'noteSaved': 'नोट सफलतापूर्वक सहेजा गया!',
      'clearNote': 'नोट हटाएं',
    },
    'zh': {
      'appTitle': 'Video Player - 在线学习平台',
      'coursesHeader': '可用课程',
      'continueWatching': '继续观看',
      'resumeLesson': '继续学习',
      'instructorPrefix': '讲师: ',
      'totalLessons': '课',
      'totalSections': '章节',
      'courseProgress': '课程进度',
      'statusNotStarted': '未开始',
      'statusInProgress': '进行中',
      'statusCompleted': '已完成',
      'statusLocked': '已锁定',
      'playLesson': '开始学习',
      'nextLesson': '下一课',
      'completedCourse': '恭喜！您已完成本课程 🎉',
      'lockedLessonMessage': '抱歉，您必须先完成上一课才能解锁此课程。',
      'retry': '重试',
      'speedLabel': '倍速',
      'navCourses': '课程',
      'navFavorites': '收藏',
      'navSettings': '设置',
      'settingsTitle': '设置与偏好',
      'appearance': '外观与主题',
      'themeMode': '主题模式',
      'lightMode': '浅色模式',
      'darkMode': '深色模式',
      'systemMode': '跟随系统',
      'language': '语言 / Language',
      'selectLanguage': '选择应用语言',
      'arabic': 'العربية (阿拉伯语)',
      'english': 'English (英语)',
      'hindi': 'हिन्दी (印地语)',
      'chinese': '中文 (Chinese)',
      'emptyFavorites': '暂无收藏的课程。',
      'addToFavorites': '加入收藏',
      'removeFromFavorites': '取消收藏',
      'errorLoadingCourses': '加载课程数据失败。',
      'errorLoadingVideo': '抱歉，无法加载视频，请稍后再试。',
      'emptyCourses': '暂无可用课程。',
      'courseNotFound': '未找到课程。',
      'lessonNotFound': '未找到课时。',
      'loading': '加载中...',
      'loadingVideo': '正在加载视频...',
      'completedSummary': '已完成: {completed}/{total} 课 (剩余 {remaining} 课)',
      'left': '剩余',
      'searchCourses': '搜索课程...',
      'noCoursesFound': '未找到匹配的课程。',
      'lessonNotes': '课程笔记',
      'writeNotesPlaceholder': '在此处写下您的课程笔记...',
      'saveNote': '保存笔记',
      'noteSaved': '笔记保存成功！',
      'clearNote': '清除笔记',
    },
  };

  String get(String key) {
    final langCode = locale.languageCode;
    return _localizedValues[langCode]?[key] ??
        _localizedValues['en']?[key] ??
        _localizedValues['ar']?[key] ??
        key;
  }

  // Helper getters for convenience
  String get appTitle => get('appTitle');
  String get coursesHeader => get('coursesHeader');
  String get continueWatching => get('continueWatching');
  String get resumeLesson => get('resumeLesson');
  String get instructorPrefix => get('instructorPrefix');
  String get totalLessons => get('totalLessons');
  String get totalSections => get('totalSections');
  String get courseProgress => get('courseProgress');
  String get statusNotStarted => get('statusNotStarted');
  String get statusInProgress => get('statusInProgress');
  String get statusCompleted => get('statusCompleted');
  String get statusLocked => get('statusLocked');
  String get playLesson => get('playLesson');
  String get nextLesson => get('nextLesson');
  String get completedCourse => get('completedCourse');
  String get lockedLessonMessage => get('lockedLessonMessage');
  String get retry => get('retry');
  String get speedLabel => get('speedLabel');
  String get navCourses => get('navCourses');
  String get navFavorites => get('navFavorites');
  String get navSettings => get('navSettings');
  String get settingsTitle => get('settingsTitle');
  String get appearance => get('appearance');
  String get themeMode => get('themeMode');
  String get lightMode => get('lightMode');
  String get darkMode => get('darkMode');
  String get systemMode => get('systemMode');
  String get language => get('language');
  String get selectLanguage => get('selectLanguage');
  String get arabic => get('arabic');
  String get english => get('english');
  String get hindi => get('hindi');
  String get chinese => get('chinese');
  String get emptyFavorites => get('emptyFavorites');
  String get addToFavorites => get('addToFavorites');
  String get removeFromFavorites => get('removeFromFavorites');
  String get errorLoadingCourses => get('errorLoadingCourses');
  String get errorLoadingVideo => get('errorLoadingVideo');
  String get emptyCourses => get('emptyCourses');
  String get courseNotFound => get('courseNotFound');
  String get lessonNotFound => get('lessonNotFound');
  String get loading => get('loading');
  String get loadingVideo => get('loadingVideo');
  String get searchCourses => get('searchCourses');
  String get noCoursesFound => get('noCoursesFound');
  String get lessonNotes => get('lessonNotes');
  String get writeNotesPlaceholder => get('writeNotesPlaceholder');
  String get saveNote => get('saveNote');
  String get noteSaved => get('noteSaved');
  String get clearNote => get('clearNote');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en', 'hi', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
