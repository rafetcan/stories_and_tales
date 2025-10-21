import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reading_progress_model.dart';

class ReadingProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Okuma ilerlemesini kaydet
  Future<void> saveProgress({
    required String storyId,
    required int currentPosition,
    required double progressPercentage,
    required bool isCompleted,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    try {
      final progress = ReadingProgress(
        userId: user.uid,
        storyId: storyId,
        currentPosition: currentPosition,
        progressPercentage: progressPercentage,
        lastReadAt: DateTime.now(),
        isCompleted: isCompleted,
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading_progress')
          .doc(storyId)
          .set(progress.toFirestore());
    } catch (e) {
      throw Exception('Okuma ilerlemesi kaydedilemedi: $e');
    }
  }

  // Hikayenin okuma ilerlemesini getir
  Future<ReadingProgress?> getProgress(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading_progress')
          .doc(storyId)
          .get();

      if (!doc.exists) return null;

      return ReadingProgress.fromFirestore(doc.data()!);
    } catch (e) {
      throw Exception('Okuma ilerlemesi yüklenemedi: $e');
    }
  }

  // Tamamlanan hikayeleri getir
  Future<List<ReadingProgress>> getCompletedStories() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading_progress')
          .where('isCompleted', isEqualTo: true)
          .orderBy('lastReadAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReadingProgress.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Tamamlanan hikayeler yüklenemedi: $e');
    }
  }

  // Devam eden hikayeleri getir
  Future<List<ReadingProgress>> getContinueReading() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading_progress')
          .where('isCompleted', isEqualTo: false)
          .where('progressPercentage', isGreaterThan: 0)
          .orderBy('progressPercentage')
          .orderBy('lastReadAt', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => ReadingProgress.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Devam eden hikayeler yüklenemedi: $e');
    }
  }

  // Okuma ilerlemesini sıfırla
  Future<void> resetProgress(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading_progress')
          .doc(storyId)
          .delete();
    } catch (e) {
      throw Exception('Okuma ilerlemesi sıfırlanamadı: $e');
    }
  }

  // Okuma ilerlemesini stream olarak dinle
  Stream<ReadingProgress?> getProgressStream(String storyId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('reading_progress')
        .doc(storyId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return ReadingProgress.fromFirestore(doc.data()!);
        });
  }
}
