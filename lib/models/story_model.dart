import 'package:cloud_firestore/cloud_firestore.dart';

class Story {
  final String id;
  final String title;
  final String description;
  final String categoryId;
  final int duration; // dakika cinsinden
  final String imageUrl;
  final int viewCount; // popülerlik için
  final int likeCount;
  final bool isFeatured;
  final String ageRange; // "3-5", "6-8", "9-12" gibi
  final DateTime createdAt;

  const Story({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.duration,
    required this.imageUrl,
    required this.viewCount,
    required this.likeCount,
    required this.isFeatured,
    required this.ageRange,
    required this.createdAt,
  });

  factory Story.fromFirestore(Map<String, dynamic> data, String id) {
    return Story(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      duration: _parseInt(data['duration']),
      imageUrl: data['imageUrl'] as String? ?? '',
      viewCount: _parseInt(data['viewCount']),
      likeCount: _parseInt(data['likeCount']),
      isFeatured: data['isFeatured'] as bool? ?? false,
      ageRange: data['ageRange'] as String? ?? '3-12',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Güvenli int parse - String veya int olabilir
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'duration': duration,
      'imageUrl': imageUrl,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'isFeatured': isFeatured,
      'ageRange': ageRange,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
