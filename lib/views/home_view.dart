import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import 'profile_view.dart';
import 'widgets/home_tab_widget.dart';
import 'widgets/explore_tab_widget.dart';
import 'widgets/favorites_tab_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HomeViewModel>();
      vm.loadCategories();
      // Tüm hikayeleri yükle - popüler hikayeler otomatik set edilecek
      vm.loadAllStories();
      // Favori hikayeleri yükle
      vm.loadFavorites();
    });
  }

  @override
  void dispose() {
    try {
      context.read<HomeViewModel>().disposeAds();
    } catch (e) {
      // Hata oluşursa logla, uygulamanın çökmesini engelle
      debugPrint('Reklam kaynakları serbest bırakılırken hata oluştu: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: _buildBody(vm),
      bottomNavigationBar: _buildBottomNavigationBar(vm, theme),
    );
  }

  void _onCategoryTap(HomeViewModel vm, String categoryId) {
    // Keşfet sekmesine geç
    vm.setIndex(1);
    // Kategori filtresini uygula
    vm.setCategoryFilter(categoryId);
  }

  Widget _buildBody(HomeViewModel vm) {
    switch (vm.selectedIndex) {
      case 0:
        return HomeTabWidget(
          vm: vm,
          onCategoryTap: (categoryId) => _onCategoryTap(vm, categoryId),
        );
      case 1:
        return ExploreTabWidget(vm: vm);
      case 2:
        return FavoritesTabWidget(vm: vm);
      case 3:
        return const ProfileView();
      default:
        return HomeTabWidget(
          vm: vm,
          onCategoryTap: (categoryId) => _onCategoryTap(vm, categoryId),
        );
    }
  }

  Widget _buildBottomNavigationBar(HomeViewModel vm, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: vm.selectedIndex,
        onTap: (index) => vm.setIndex(index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: isDark
            ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
            : const Color(0xFF718096),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Keşfet'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
