class AppStrings {
  static const String appTitle = 'مشغل الفيديو - المنصة التعليمية';
  static const String coursesHeader = 'الدورات التدريبية';
  static const String continueWatching = 'متابعة المشاهدة';
  static const String resumeLesson = 'متابعة الدرس الحاضر';
  static const String instructorPrefix = 'المحاضر: ';
  static const String totalLessons = 'درس';
  static const String totalSections = 'وحدة تعليمية';
  static const String courseProgress = 'إنجاز الدورة';
  static const String lessonDurationMinutes = 'دقيقة';
  static const String lessonDurationSeconds = 'ثانية';

  // Lesson Statuses
  static const String statusNotStarted = 'لم يبدأ';
  static const String statusInProgress = 'قيد التقدم';
  static const String statusCompleted = 'مكتمل';
  static const String statusLocked = 'مغلق';

  // Actions
  static const String playLesson = 'بدء تشغيل الدرس';
  static const String nextLesson = 'الدرس التالي';
  static const String completedCourse = 'تهانينا! أكملت هذه الدورة بالكامل 🎉';
  static const String lockedLessonMessage = 'عذراً، يجب إكمال الدرس السابق أولاً لتتمكن من فتح هذا الدرس.';
  static const String retry = 'إعادة المحاولة';
  static const String backToCourse = 'العودة لصفحة الدورة';

  // Speed controls
  static const String speedLabel = 'السرعة';

  // Errors & Empty states
  static const String errorLoadingCourses = 'حدث خطأ أثناء تحميل بيانات الدورات.';
  static const String errorLoadingVideo = 'عذراً، تعذر تحميل الفيديو. يرجى المحاولة لاحقاً.';
  static const String emptyCourses = 'لا توجد دورات متاحة حالياً.';
  static const String courseNotFound = 'لم يتم العثور على الدورة المطلوبة.';
  static const String lessonNotFound = 'لم يتم العثور على الدرس المطلوب.';
}
