import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/story_model.dart';
import '../story_reading_view.dart';
import 'story_card_widget.dart';

class FavoritesTabWidget extends StatelessWidget {
  final HomeViewModel vm;

  const FavoritesTabWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Color(0xFF6C63FF), size: 28),
          const SizedBox(width: 12),
          Text(
            'Favorilerim',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (vm.favoriteStories.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${vm.favoriteStories.length} Hikaye',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (vm.isLoadingFavorites) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (vm.favoriteError != null) {
      return Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Favoriler yüklenemedi',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.favoriteError ?? '',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => vm.loadFavorites(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        },
      );
    }

    if (vm.favoriteStories.isEmpty) {
      return Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Henüz favori hikaye yok',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Beğendiğin hikayeleri favorilere ekleyerek\nburada görebilirsin',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => vm.setIndex(1), // Keşfet sayfasına git
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.explore),
                  label: const Text(
                    'Hikayeleri Keşfet',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: vm.favoriteStories
          .map(
            (story) => Builder(
              builder: (context) => StoryCardWidget(
                title: story.title,
                subtitle: story.description,
                imagePath: story.imageUrl,
                duration: '${story.duration} dk',
                isFavorite: true,
                onFavoriteTap: () => vm.toggleFavorite(story.id),
                onTap: () => _navigateToReading(context, story),
              ),
            ),
          )
          .toList(),
    );
  }

  void _navigateToReading(BuildContext context, Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryReadingView(story: story)),
    );
  }
}
