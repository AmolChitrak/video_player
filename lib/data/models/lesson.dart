class Lesson {
  final String id;
  final String title;
  final String? titleAr;
  final String? titleEn;
  final String? titleHi;
  final String? titleZh;
  final int durationSec;
  final String video;

  const Lesson({
    required this.id,
    required this.title,
    this.titleAr,
    this.titleEn,
    this.titleHi,
    this.titleZh,
    required this.durationSec,
    required this.video,
  });

  String getTitle(String langCode) {
    if (langCode == 'ar' && titleAr != null && titleAr!.isNotEmpty) return titleAr!;
    if (langCode == 'hi' && titleHi != null && titleHi!.isNotEmpty) return titleHi!;
    if (langCode == 'zh' && titleZh != null && titleZh!.isNotEmpty) return titleZh!;
    if (langCode == 'en' && titleEn != null && titleEn!.isNotEmpty) return titleEn!;
    return title;
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String?,
      titleEn: json['title_en'] as String?,
      titleHi: json['title_hi'] as String?,
      titleZh: json['title_zh'] as String?,
      durationSec: (json['durationSec'] as num).toInt(),
      video: json['video'] as String,
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
      'durationSec': durationSec,
      'video': video,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lesson &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title;

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}
