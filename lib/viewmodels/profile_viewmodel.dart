import 'package:flutter/foundation.dart';
import '../models/story_model.dart';
import '../models/reading_progress_model.dart';
import '../services/reading_progress_service.dart';
import '../services/story_service.dart';
import '../services/favorite_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ReadingProgressService _progressService = ReadingProgressService();
  final StoryService _storyService = StoryService();
  final FavoriteService _favoriteService = FavoriteService();

  List<Story> _completedStories = [];
  List<Story> _continueReadingStories = [];
  int _totalCompletedCount = 0;
  int _totalFavoritesCount = 0;
  bool _isLoading = false;
  String? _error;

  List<Story> get completedStories => _completedStories;
  List<Story> get continueReadingStories => _continueReadingStories;
  int get totalCompletedCount => _totalCompletedCount;
  int get totalFavoritesCount => _totalFavoritesCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Profil verilerini yükle
  Future<void> loadProfileData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Tamamlanan hikayelerin progress'lerini al
      final completedProgress = await _progressService.getCompletedStories();
      _totalCompletedCount = completedProgress.length;

      // Tamamlanan hikayelerin detaylarını çek
      _completedStories = await _getStoriesFromProgress(completedProgress);

      // Devam eden hikayeleri al
      final continueProgress = await _progressService.getContinueReading();
      _continueReadingStories = await _getStoriesFromProgress(continueProgress);

      // Favori sayısını al
      final favoriteIds = await _favoriteService.getFavoriteStoryIds();
      _totalFavoritesCount = favoriteIds.length;

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Profil verileri yüklenirken hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Progress listesinden story detaylarını çek
  Future<List<Story>> _getStoriesFromProgress(
    List<ReadingProgress> progressList,
  ) async {
    final stories = <Story>[];

    for (final progress in progressList) {
      try {
        // Önce tüm hikayeleri çek (cache'lenmiş olabilir)
        final allStories = await _storyService.getAllStories();
        final story = allStories.firstWhere(
          (s) => s.id == progress.storyId,
          orElse: () => throw Exception('Hikaye bulunamadı'),
        );
        stories.add(story);
      } catch (e) {
        debugPrint('Hikaye yüklenemedi: ${progress.storyId} - $e');
        continue;
      }
    }

    return stories;
  }

  // Tamamlanan hikayeyi favorilerden çıkar
  Future<void> removeCompletedStory(String storyId) async {
    try {
      await _progressService.resetProgress(storyId);
      _completedStories.removeWhere((story) => story.id == storyId);
      _totalCompletedCount = _completedStories.length;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Hikaye silinemedi: $e');
      notifyListeners();
    }
  }

  // Yenile
  Future<void> refresh() async {
    await loadProfileData();
  }
}
