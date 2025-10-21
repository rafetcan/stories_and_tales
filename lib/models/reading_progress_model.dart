import 'package:cloud_firestore/cloud_firestore.dart';

class ReadingProgress {
  final String userId;
  final String storyId;
  final int currentPosition; // Karakterdeki pozisyon
  final double progressPercentage; // 0.0 - 1.0
  final DateTime lastReadAt;
  final bool isCompleted;

  const ReadingProgress({
    required this.userId,
    required this.storyId,
    required this.currentPosition,
    required this.progressPercentage,
    required this.lastReadAt,
    required this.isCompleted,
  });

  factory ReadingProgress.fromFirestore(Map<String, dynamic> data) {
    return ReadingProgress(
      userId: data['userId'] as String? ?? '',
      storyId: data['storyId'] as String? ?? '',
      currentPosition: data['currentPosition'] as int? ?? 0,
      progressPercentage:
          (data['progressPercentage'] as num?)?.toDouble() ?? 0.0,
      lastReadAt:
          (data['lastReadAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'storyId': storyId,
      'currentPosition': currentPosition,
      'progressPercentage': progressPercentage,
      'lastReadAt': Timestamp.fromDate(lastReadAt),
      'isCompleted': isCompleted,
    };
  }

  ReadingProgress copyWith({
    String? userId,
    String? storyId,
    int? currentPosition,
    double? progressPercentage,
    DateTime? lastReadAt,
    bool? isCompleted,
  }) {
    return ReadingProgress(
      userId: userId ?? this.userId,
      storyId: storyId ?? this.storyId,
      currentPosition: currentPosition ?? this.currentPosition,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
