class LessonProgress {
  final String lessonId;
  final int lastPositionSec;
  final bool isCompleted;
  final double playbackSpeed;
  final DateTime lastUpdated;

  const LessonProgress({
    required this.lessonId,
    this.lastPositionSec = 0,
    this.isCompleted = false,
    this.playbackSpeed = 1.0,
    required this.lastUpdated,
  });

  LessonProgress copyWith({
    String? lessonId,
    int? lastPositionSec,
    bool? isCompleted,
    double? playbackSpeed,
    DateTime? lastUpdated,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      lastPositionSec: lastPositionSec ?? this.lastPositionSec,
      isCompleted: isCompleted ?? this.isCompleted,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: (json['lessonId'] ?? json['id'] ?? '').toString(),
      lastPositionSec: (json['lastPositionSec'] as num? ?? 0).toInt(),
      isCompleted: json['isCompleted'] == true || json['isCompleted'] == 'true',
      playbackSpeed: (json['playbackSpeed'] as num? ?? 1.0).toDouble(),
      lastUpdated: json['lastUpdated'] != null
          ? (DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'lastPositionSec': lastPositionSec,
      'isCompleted': isCompleted,
      'playbackSpeed': playbackSpeed,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
