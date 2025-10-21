import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/story_model.dart';
import '../story_reading_view.dart';
import 'story_card_widget.dart';
import 'category_card_widget.dart';

class HomeTabWidget extends StatelessWidget {
  final HomeViewModel vm;
  final Function(String categoryId) onCategoryTap;

  const HomeTabWidget({
    super.key,
    required this.vm,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 20),

            // Misafir Kullanıcı Bilgilendirme Banner'ı
            _buildAnonymousUserInfo(context),

            const SizedBox(height: 20),

            // Kategoriler
            Text(
              'Kategoriler',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(height: 120, child: _buildCategoryList()),

            const SizedBox(height: 30),

            // Popüler Hikayeler
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popüler Hikayeler',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: const Color(0xFF6C63FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Hikaye Listesi
            Expanded(child: _buildStoryList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF8B7CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.auto_stories, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hoş Geldiniz!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Text(
                'Bugün hangi hikayeyi okumak istersiniz?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnonymousUserInfo(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    // Misafir kullanıcı değilse banner gösterme
    if (user?.isAnonymous != true) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        // Profil sekmesine geç (index 3)
        vm.setIndex(3);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF6C63FF).withValues(alpha: 0.15)
              : const Color(0xFF6C63FF).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Misafir olarak geziniyorsunuz',
                    style: TextStyle(
                      color: Color(0xFF6C63FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tıklayarak hesap oluşturabilirsiniz',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF6C63FF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    if (vm.isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (vm.categoryError != null) {
      return Builder(
        builder: (context) => Center(
          child: Text(
            'Kategoriler yüklenemedi',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    if (vm.categories.isEmpty) {
      return Builder(
        builder: (context) => Center(
          child: Text(
            'Henüz kategori bulunmuyor',
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: vm.categories.length,
      itemBuilder: (context, index) {
        final category = vm.categories[index];
        final color = _parseColor(category.color);
        final icon = _getIconData(category.icon);
        return CategoryCardWidget(
          title: category.name,
          icon: icon,
          color: color,
          onTap: () => onCategoryTap(category.id),
        );
      },
    );
  }

  Widget _buildStoryList() {
    if (vm.isLoadingStories) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (vm.storyError != null) {
      return Builder(
        builder: (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 12),
              Text(
                'Hikayeler yüklenemedi',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      children: [
        ...vm.popularStories.map(
          (story) => Builder(
            builder: (context) => StoryCardWidget(
              title: story.title,
              subtitle: story.description,
              imagePath: story.imageUrl,
              duration: '${story.duration} dk',
              isFavorite: vm.isFavorite(story.id),
              onFavoriteTap: () => vm.toggleFavorite(story.id),
              onTap: () => _navigateToReading(context, story),
            ),
          ),
        ),
        if (vm.popularStories.isEmpty)
          Builder(
            builder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Text(
                  'Henüz hikaye bulunmuyor',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 20),
        // Banner Ad
        if (vm.isBannerAdReady && vm.bannerAd != null)
          Container(
            alignment: Alignment.center,
            width: vm.bannerAd!.size.width.toDouble(),
            height: vm.bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: vm.bannerAd!),
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return const Color(0xFF6C63FF); // Default color
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'favorite':
        return Icons.favorite;
      case 'pets':
        return Icons.pets;
      case 'explore':
        return Icons.explore;
      case 'school':
        return Icons.school;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'music_note':
        return Icons.music_note;
      case 'bedtime':
        return Icons.bedtime;
      case 'stars':
        return Icons.stars;
      case 'gift':
        return Icons.card_giftcard;
      case 'cake':
        return Icons.cake;
      case 'rocket':
        return Icons.rocket_launch;
      case 'palette':
        return Icons.palette;
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.category;
    }
  }

  void _navigateToReading(BuildContext context, Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryReadingView(story: story)),
    );
  }
}
