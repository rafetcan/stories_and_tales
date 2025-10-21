import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  final String userId;
  final double fontSize; // 12.0 - 32.0
  final String fontFamily;
  final double lineHeight; // 1.2 - 2.0
  final bool darkMode;
  final DateTime updatedAt;

  const AppSettings({
    required this.userId,
    this.fontSize = 16.0,
    this.fontFamily = 'Default',
    this.lineHeight = 1.5,
    this.darkMode = false,
    required this.updatedAt,
  });

  factory AppSettings.defaultSettings(String userId) {
    return AppSettings(
      userId: userId,
      fontSize: 16.0,
      fontFamily: 'Default',
      lineHeight: 1.5,
      darkMode: false,
      updatedAt: DateTime.now(),
    );
  }

  factory AppSettings.fromFirestore(Map<String, dynamic> data) {
    return AppSettings(
      userId: data['userId'] as String? ?? '',
      fontSize: (data['fontSize'] as num?)?.toDouble() ?? 16.0,
      fontFamily: data['fontFamily'] as String? ?? 'Default',
      lineHeight: (data['lineHeight'] as num?)?.toDouble() ?? 1.5,
      darkMode: data['darkMode'] as bool? ?? false,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'lineHeight': lineHeight,
      'darkMode': darkMode,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  AppSettings copyWith({
    String? userId,
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    bool? darkMode,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      userId: userId ?? this.userId,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      lineHeight: lineHeight ?? this.lineHeight,
      darkMode: darkMode ?? this.darkMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
