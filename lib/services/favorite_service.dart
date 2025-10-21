import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/story_model.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Favori hikaye ekle
  Future<void> addToFavorites(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(storyId)
          .set({'storyId': storyId, 'addedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      throw Exception('Favorilere eklenirken hata oluştu: $e');
    }
  }

  // Favori hikayeden çıkar
  Future<void> removeFromFavorites(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(storyId)
          .delete();
    } catch (e) {
      throw Exception('Favorilerden çıkarılırken hata oluştu: $e');
    }
  }

  // Hikaye favorilerde mi kontrol et
  Future<bool> isFavorite(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(storyId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Tüm favori hikaye ID'lerini getir
  Future<List<String>> getFavoriteStoryIds() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Favori hikayeler yüklenemedi: $e');
    }
  }

  // Favori hikayeleri getir (detaylı)
  Future<List<Story>> getFavoriteStories() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      // Önce favori hikaye ID'lerini al
      final favoriteIds = await getFavoriteStoryIds();

      if (favoriteIds.isEmpty) return [];

      // Hikayeleri getir
      final stories = <Story>[];
      for (final storyId in favoriteIds) {
        try {
          final storyDoc = await _firestore
              .collection('stories')
              .doc(storyId)
              .get();

          if (storyDoc.exists) {
            stories.add(Story.fromFirestore(storyDoc.data()!, storyDoc.id));
          }
        } catch (e) {
          // Tek bir hikaye hatası diğerlerini etkilemesin
          continue;
        }
      }

      return stories;
    } catch (e) {
      throw Exception('Favori hikayeler yüklenemedi: $e');
    }
  }

  // Favori hikayeleri stream olarak dinle
  Stream<List<String>> getFavoriteStoryIdsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
