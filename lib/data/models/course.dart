import 'section.dart';
import 'lesson.dart';

class Course {
  final String id;
  final String title;
  final String? titleAr;
  final String? titleEn;
  final String? titleHi;
  final String? titleZh;
  final String instructor;
  final String? instructorAr;
  final String? instructorEn;
  final String? instructorHi;
  final String? instructorZh;
  final String thumbnail;
  final String description;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? descriptionHi;
  final String? descriptionZh;
  final List<Section> sections;

  const Course({
    required this.id,
    required this.title,
    this.titleAr,
    this.titleEn,
    this.titleHi,
    this.titleZh,
    required this.instructor,
    this.instructorAr,
    this.instructorEn,
    this.instructorHi,
    this.instructorZh,
    required this.thumbnail,
    required this.description,
    this.descriptionAr,
    this.descriptionEn,
    this.descriptionHi,
    this.descriptionZh,
    required this.sections,
  });

  String getTitle(String langCode) {
    if (langCode == 'ar' && titleAr != null && titleAr!.isNotEmpty) return titleAr!;
    if (langCode == 'hi' && titleHi != null && titleHi!.isNotEmpty) return titleHi!;
    if (langCode == 'zh' && titleZh != null && titleZh!.isNotEmpty) return titleZh!;
    if (langCode == 'en' && titleEn != null && titleEn!.isNotEmpty) return titleEn!;
    return title;
  }

  String getInstructor(String langCode) {
    if (langCode == 'ar' && instructorAr != null && instructorAr!.isNotEmpty) return instructorAr!;
    if (langCode == 'hi' && instructorHi != null && instructorHi!.isNotEmpty) return instructorHi!;
    if (langCode == 'zh' && instructorZh != null && instructorZh!.isNotEmpty) return instructorZh!;
    if (langCode == 'en' && instructorEn != null && instructorEn!.isNotEmpty) return instructorEn!;
    return instructor;
  }

  String getDescription(String langCode) {
    if (langCode == 'ar' && descriptionAr != null && descriptionAr!.isNotEmpty) return descriptionAr!;
    if (langCode == 'hi' && descriptionHi != null && descriptionHi!.isNotEmpty) return descriptionHi!;
    if (langCode == 'zh' && descriptionZh != null && descriptionZh!.isNotEmpty) return descriptionZh!;
    if (langCode == 'en' && descriptionEn != null && descriptionEn!.isNotEmpty) return descriptionEn!;
    return description;
  }

  List<Lesson> get allLessons {
    final list = <Lesson>[];
    for (final section in sections) {
      list.addAll(section.lessons);
    }
    return list;
  }

  int get totalLessonsCount => allLessons.length;

  int get totalDurationSec =>
      allLessons.fold(0, (sum, lesson) => sum + lesson.durationSec);

  factory Course.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? [];
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String?,
      titleEn: json['title_en'] as String?,
      titleHi: json['title_hi'] as String?,
      titleZh: json['title_zh'] as String?,
      instructor: json['instructor'] as String,
      instructorAr: json['instructor_ar'] as String?,
      instructorEn: json['instructor_en'] as String?,
      instructorHi: json['instructor_hi'] as String?,
      instructorZh: json['instructor_zh'] as String?,
      thumbnail: json['thumbnail'] as String,
      description: json['description'] as String? ?? '',
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionHi: json['description_hi'] as String?,
      descriptionZh: json['description_zh'] as String?,
      sections: sectionsJson
          .map((e) => Section.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'title_en': titleEn,
      'title_hi': titleHi,
      'title_zh': titleZh,
      'instructor': instructor,
      'instructor_ar': instructorAr,
      'instructor_en': instructorEn,
      'instructor_hi': instructorHi,
      'instructor_zh': instructorZh,
      'thumbnail': thumbnail,
      'description': description,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'description_hi': descriptionHi,
      'description_zh': descriptionZh,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
