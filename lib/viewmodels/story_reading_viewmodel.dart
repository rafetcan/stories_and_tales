import 'package:flutter/foundation.dart';
import '../models/story_model.dart';
import '../models/reading_progress_model.dart';
import '../services/reading_progress_service.dart';
import '../services/settings_service.dart';

class StoryReadingViewModel extends ChangeNotifier {
  final ReadingProgressService _progressService = ReadingProgressService();
  final SettingsService _settingsService;

  Story? _currentStory;
  ReadingProgress? _currentProgress;
  bool _isLoading = false;
  String? _error;

  int _currentPosition = 0;
  bool _isAutoScrolling = false;

  Story? get currentStory => _currentStory;
  ReadingProgress? get currentProgress => _currentProgress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPosition => _currentPosition;
  bool get isAutoScrolling => _isAutoScrolling;

  // Settings'den yazı boyutu al
  double get fontSize => _settingsService.currentSettings?.fontSize ?? 16.0;
  double get lineHeight => _settingsService.currentSettings?.lineHeight ?? 1.5;

  StoryReadingViewModel(this._settingsService);

  // Hikayeyi yükle
  Future<void> loadStory(Story story) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentStory = story;

      // Okuma ilerlemesini yükle
      _currentProgress = await _progressService.getProgress(story.id);

      // Eğer progress varsa, kaldığı yerden devam et
      if (_currentProgress != null) {
        _currentPosition = _currentProgress!.currentPosition;
      } else {
        _currentPosition = 0;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Hikaye yüklenirken hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Okuma ilerlemesini kaydet
  Future<void> saveProgress(int position, {bool force = false}) async {
    if (_currentStory == null) return;

    try {
      final totalLength = _currentStory!.description.length;
      final progressPercentage = position / totalLength;
      final isCompleted =
          progressPercentage >= 0.95; // %95'e ulaşırsa tamamlanmış say

      // Pozisyon değişikliği yeterli değilse ve force edilmemişse kaydetme
      if (!force && (_currentPosition - position).abs() < 100) {
        return;
      }

      _currentPosition = position;

      await _progressService.saveProgress(
        storyId: _currentStory!.id,
        currentPosition: position,
        progressPercentage: progressPercentage,
        isCompleted: isCompleted,
      );

      // Progress'i güncelle
      _currentProgress = await _progressService.getProgress(_currentStory!.id);
      notifyListeners();
    } catch (e) {
      debugPrint('Progress kaydedilemedi: $e');
    }
  }

  // Okumayı sıfırla (baştan başla)
  Future<void> resetProgress() async {
    if (_currentStory == null) return;

    try {
      await _progressService.resetProgress(_currentStory!.id);
      _currentPosition = 0;
      _currentProgress = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Progress sıfırlanamadı: $e');
      notifyListeners();
    }
  }

  // Pozisyonu güncelle (scroll olaylarında kullanılacak)
  void updatePosition(int position) {
    _currentPosition = position;
    // Notifiers'ı çağırma - performance için
  }

  // Otomatik kaydırma
  void setAutoScrolling(bool value) {
    _isAutoScrolling = value;
    notifyListeners();
  }

  // Progress yüzdesi hesapla
  double getProgressPercentage() {
    if (_currentStory == null) return 0.0;
    return _currentPosition / _currentStory!.description.length;
  }

  // Kalan süre hesapla (dakika)
  int getRemainingMinutes() {
    if (_currentStory == null) return 0;

    final totalLength = _currentStory!.description.length;
    final remainingLength = totalLength - _currentPosition;
    final wordsRemaining = remainingLength / 5; // Ortalama kelime uzunluğu
    final minutesRemaining = (wordsRemaining / 150).ceil(); // 150 kelime/dakika

    return minutesRemaining;
  }
}
