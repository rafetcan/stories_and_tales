import 'package:flutter/foundation.dart' hide Category;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/category_model.dart';
import '../models/story_model.dart';
import '../services/category_service.dart';
import '../services/story_service.dart';
import '../services/favorite_service.dart';

class HomeViewModel extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  final StoryService _storyService = StoryService();
  final FavoriteService _favoriteService = FavoriteService();

  int _selectedIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  List<Category> _categories = [];
  bool _isLoadingCategories = false;
  String? _categoryError;

  // Story related
  List<Story> _popularStories = [];
  List<Story> _allStories = [];
  List<Story> _filteredStories = [];
  bool _isLoadingStories = false;
  String? _storyError;
  String _selectedCategoryFilter = 'all';
  String _selectedAgeFilter = 'all';
  String _searchQuery = '';

  // Favorites related
  List<Story> _favoriteStories = [];
  Set<String> _favoriteStoryIds = {};
  bool _isLoadingFavorites = false;
  String? _favoriteError;

  int get selectedIndex => _selectedIndex;
  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdReady => _isBannerAdReady;
  List<Category> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get categoryError => _categoryError;

  // Story getters
  List<Story> get popularStories => _popularStories;
  List<Story> get allStories => _allStories;
  List<Story> get filteredStories => _filteredStories;
  bool get isLoadingStories => _isLoadingStories;
  String? get storyError => _storyError;
  String get selectedCategoryFilter => _selectedCategoryFilter;
  String get selectedAgeFilter => _selectedAgeFilter;
  String get searchQuery => _searchQuery;

  // Favorites getters
  List<Story> get favoriteStories => _favoriteStories;
  Set<String> get favoriteStoryIds => _favoriteStoryIds;
  bool get isLoadingFavorites => _isLoadingFavorites;
  String? get favoriteError => _favoriteError;

  bool isFavorite(String storyId) => _favoriteStoryIds.contains(storyId);

  void initAds() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-4634689499659793/5891565120', // Test ID
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  void disposeAds() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;
  }

  void setIndex(int index) {
    if (index == _selectedIndex) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    _categoryError = null;
    notifyListeners();

    try {
      _categories = await _categoryService.getCategories();
      _categoryError = null;
    } catch (e) {
      _categoryError = e.toString();
      debugPrint('Kategoriler yüklenirken hata: $e');
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  // Popüler hikayeleri yükle
  Future<void> loadPopularStories() async {
    // Tüm hikayeler zaten yükleniyorsa tekrar yükleme
    if (_allStories.isNotEmpty) {
      _popularStories = _allStories.take(10).toList();
      return;
    }

    _isLoadingStories = true;
    _storyError = null;
    notifyListeners();

    try {
      _popularStories = await _storyService.getPopularStories(limit: 10);
      _storyError = null;
    } catch (e) {
      _storyError = e.toString();
      debugPrint('Popüler hikayeler yüklenirken hata: $e');
    } finally {
      _isLoadingStories = false;
      notifyListeners();
    }
  }

  // Tüm hikayeleri yükle (Keşfet sayfası için)
  Future<void> loadAllStories() async {
    _isLoadingStories = true;
    _storyError = null;
    notifyListeners();

    try {
      _allStories = await _storyService.getAllStories();
      _filteredStories = _allStories;

      // Popüler hikayeleri de güncelle
      if (_allStories.isNotEmpty) {
        _popularStories = _allStories.take(10).toList();
      }

      _storyError = null;
    } catch (e) {
      _storyError = e.toString();
      debugPrint('Hikayeler yüklenirken hata: $e');
    } finally {
      _isLoadingStories = false;
      notifyListeners();
    }
  }

  // Arama fonksiyonu
  void searchStories(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Kategori filtresi
  void setCategoryFilter(String categoryId) {
    _selectedCategoryFilter = categoryId;
    _applyFilters();
  }

  // Yaş filtresi
  void setAgeFilter(String ageRange) {
    _selectedAgeFilter = ageRange;
    _applyFilters();
  }

  // Filtreleri uygula
  void _applyFilters() {
    _filteredStories = _allStories;

    // Arama filtresi
    if (_searchQuery.isNotEmpty) {
      _filteredStories = _filteredStories
          .where(
            (story) =>
                story.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                story.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Kategori filtresi
    if (_selectedCategoryFilter != 'all') {
      _filteredStories = _filteredStories
          .where((story) => story.categoryId == _selectedCategoryFilter)
          .toList();
    }

    // Yaş filtresi
    if (_selectedAgeFilter != 'all') {
      _filteredStories = _filteredStories
          .where((story) => story.ageRange == _selectedAgeFilter)
          .toList();
    }

    notifyListeners();
  }

  // Filtreleri temizle
  void clearFilters() {
    _selectedCategoryFilter = 'all';
    _selectedAgeFilter = 'all';
    _searchQuery = '';
    _filteredStories = _allStories;
    notifyListeners();
  }

  // Favori hikayeleri yükle
  Future<void> loadFavorites() async {
    _isLoadingFavorites = true;
    _favoriteError = null;
    notifyListeners();

    try {
      // Favori hikaye ID'lerini yükle
      _favoriteStoryIds = (await _favoriteService.getFavoriteStoryIds())
          .toSet();

      // Favori hikayeleri detaylı olarak yükle
      _favoriteStories = await _favoriteService.getFavoriteStories();

      _favoriteError = null;
    } catch (e) {
      _favoriteError = e.toString();
      debugPrint('Favoriler yüklenirken hata: $e');
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  // Favorilere ekle
  Future<void> toggleFavorite(String storyId) async {
    try {
      if (_favoriteStoryIds.contains(storyId)) {
        // Favorilerden çıkar
        await _favoriteService.removeFromFavorites(storyId);
        _favoriteStoryIds.remove(storyId);
        _favoriteStories.removeWhere((story) => story.id == storyId);
      } else {
        // Favorilere ekle
        await _favoriteService.addToFavorites(storyId);
        _favoriteStoryIds.add(storyId);

        // Hikayeyi favoriler listesine ekle
        final story = _allStories.firstWhere(
          (s) => s.id == storyId,
          orElse: () => _popularStories.firstWhere((s) => s.id == storyId),
        );
        _favoriteStories.add(story);
      }
      notifyListeners();
    } catch (e) {
      _favoriteError = e.toString();
      debugPrint('Favori işlemi sırasında hata: $e');
      notifyListeners();
    }
  }
}
