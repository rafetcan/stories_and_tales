import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/story_model.dart';

class StoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Popüler hikayeleri getir (viewCount'a göre)
  Future<List<Story>> getPopularStories({int limit = 10}) async {
    try {
      final snapshot = await _firestore.collection('stories').get();

      final stories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();

      // viewCount'a göre sırala
      stories.sort((a, b) => b.viewCount.compareTo(a.viewCount));

      // Limit uygula
      return stories.take(limit).toList();
    } catch (e) {
      throw Exception('Popüler hikayeler yüklenemedi: $e');
    }
  }

  // Tüm hikayeleri getir
  Future<List<Story>> getAllStories() async {
    try {
      final snapshot = await _firestore.collection('stories').get();

      final stories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();

      // createdAt'a göre sırala (en yeni önce)
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return stories;
    } catch (e) {
      throw Exception('Hikayeler yüklenemedi: $e');
    }
  }

  // Öne çıkan hikayeleri getir
  Future<List<Story>> getFeaturedStories() async {
    try {
      final snapshot = await _firestore.collection('stories').get();

      final stories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .where((story) => story.isFeatured)
          .toList();

      // createdAt'a göre sırala
      stories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return stories;
    } catch (e) {
      throw Exception('Öne çıkan hikayeler yüklenemedi: $e');
    }
  }

  // Kategoriye göre hikayeleri getir
  Future<List<Story>> getStoriesByCategory(String categoryId) async {
    try {
      final snapshot = await _firestore.collection('stories').get();

      final stories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .where((story) => story.categoryId == categoryId)
          .toList();

      // viewCount'a göre sırala
      stories.sort((a, b) => b.viewCount.compareTo(a.viewCount));

      return stories;
    } catch (e) {
      throw Exception('Kategori hikayeleri yüklenemedi: $e');
    }
  }

  // Hikaye ara
  Future<List<Story>> searchStories(String query) async {
    try {
      final snapshot = await _firestore.collection('stories').get();

      final allStories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .toList();

      // Basit arama - başlık ve açıklamada ara
      return allStories
          .where(
            (story) =>
                story.title.toLowerCase().contains(query.toLowerCase()) ||
                story.description.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      throw Exception('Hikaye araması başarısız: $e');
    }
  }

  // Yaş aralığına göre hikayeler
  Future<List<Story>> getStoriesByAgeRange(String ageRange) async {
    try {
      final snapshot = await _firestore.collection('stories').get();

      final stories = snapshot.docs
          .map((doc) => Story.fromFirestore(doc.data(), doc.id))
          .where((story) => story.ageRange == ageRange)
          .toList();

      // viewCount'a göre sırala
      stories.sort((a, b) => b.viewCount.compareTo(a.viewCount));

      return stories;
    } catch (e) {
      throw Exception('Yaş aralığı hikayeleri yüklenemedi: $e');
    }
  }
}
