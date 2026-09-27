import 'lesson.dart';

class Section {
  final String id;
  final String title;
  final String? titleAr;
  final String? titleEn;
  final String? titleHi;
  final String? titleZh;
  final List<Lesson> lessons;

  const Section({
    required this.id,
    required this.title,
    this.titleAr,
    this.titleEn,
    this.titleHi,
    this.titleZh,
    required this.lessons,
  });

  String getTitle(String langCode) {
    if (langCode == 'ar' && titleAr != null && titleAr!.isNotEmpty) return titleAr!;
    if (langCode == 'hi' && titleHi != null && titleHi!.isNotEmpty) return titleHi!;
    if (langCode == 'zh' && titleZh != null && titleZh!.isNotEmpty) return titleZh!;
    if (langCode == 'en' && titleEn != null && titleEn!.isNotEmpty) return titleEn!;
    return title;
  }

  factory Section.fromJson(Map<String, dynamic> json) {
    final lessonsJson = json['lessons'] as List<dynamic>? ?? [];
    return Section(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String?,
      titleEn: json['title_en'] as String?,
      titleHi: json['title_hi'] as String?,
      titleZh: json['title_zh'] as String?,
      lessons: lessonsJson
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
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
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Section &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
