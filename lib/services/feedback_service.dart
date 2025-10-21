import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Güvenlik: Son gönderim zamanını kontrol et (Rate Limiting)
  Future<bool> canSendFeedback() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final lastFeedback = await _firestore
          .collection('feedbacks')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (lastFeedback.docs.isEmpty) return true;

      final lastFeedbackTime =
          (lastFeedback.docs.first.data()['createdAt'] as Timestamp).toDate();
      final now = DateTime.now();
      final difference = now.difference(lastFeedbackTime);

      // 5 dakikada bir geri bildirim gönderebilir
      return difference.inMinutes >= 5;
    } catch (e) {
      debugPrint('Son feedback kontrolü yapılamadı: $e');
      return true; // Hata durumunda izin ver
    }
  }

  // Günlük feedback limiti kontrolü
  Future<bool> checkDailyLimit() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final todayFeedbacks = await _firestore
          .collection('feedbacks')
          .where('userId', isEqualTo: user.uid)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart),
          )
          .get();

      // Günde maksimum 10 feedback
      return todayFeedbacks.docs.length < 10;
    } catch (e) {
      debugPrint('Günlük limit kontrolü yapılamadı: $e');
      return true; // Hata durumunda izin ver
    }
  }

  // Mesaj validasyonu
  String? validateMessage(String message) {
    if (message.trim().isEmpty) {
      return 'Lütfen bir mesaj yazın';
    }

    if (message.trim().length < 10) {
      return 'Mesaj en az 10 karakter olmalıdır';
    }

    if (message.trim().length > 1000) {
      return 'Mesaj en fazla 1000 karakter olabilir';
    }

    // Basit spam kontrolü - aynı karakterden çok fazla tekrar
    final charCount = <String, int>{};
    for (var char in message.split('')) {
      charCount[char] = (charCount[char] ?? 0) + 1;
    }

    for (var count in charCount.values) {
      if (count > message.length * 0.5) {
        return 'Mesaj spam gibi görünüyor';
      }
    }

    return null; // Geçerli
  }

  // Feedback gönder
  Future<void> sendFeedback({
    required String type,
    required String message,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    // Validasyon
    final validationError = validateMessage(message);
    if (validationError != null) {
      throw Exception(validationError);
    }

    // Rate limiting kontrolü
    final canSend = await canSendFeedback();
    if (!canSend) {
      throw Exception(
        'Çok fazla geri bildirim gönderdiniz. Lütfen 5 dakika bekleyin.',
      );
    }

    // Günlük limit kontrolü
    final withinLimit = await checkDailyLimit();
    if (!withinLimit) {
      throw Exception(
        'Günlük geri bildirim limitine ulaştınız. Yarın tekrar deneyebilirsiniz.',
      );
    }

    try {
      await _firestore.collection('feedbacks').add({
        'userId': user.uid,
        'userEmail': user.email ?? 'anonymous',
        'userName': user.displayName ?? 'Anonim',
        'type': type,
        'message': message.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'new',
        'deviceInfo': {'platform': defaultTargetPlatform.toString()},
      });
    } catch (e) {
      throw Exception('Geri bildirim gönderilemedi: $e');
    }
  }

  // Kullanıcının gönderdiği feedback sayısını öğren
  Future<int> getUserFeedbackCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      final feedbacks = await _firestore
          .collection('feedbacks')
          .where('userId', isEqualTo: user.uid)
          .get();

      return feedbacks.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
