import 'package:flutter/material.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../models/story_model.dart';
import '../story_reading_view.dart';
import 'story_grid_card_widget.dart';

class ExploreTabWidget extends StatelessWidget {
  final HomeViewModel vm;

  const ExploreTabWidget({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header with search
          _buildHeader(context),

          // Filter chips
          _buildFilterChips(),

          // Stories grid
          Expanded(child: _buildStoriesGrid()),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Color(0xFF6C63FF), size: 28),
              const SizedBox(width: 12),
              Text(
                'Keşfet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          TextField(
            onChanged: (value) => vm.searchStories(value),
            style: TextStyle(color: theme.colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Hikaye ara...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
              filled: true,
              fillColor: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : const Color(0xFFFAFBFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? theme.colorScheme.outline.withValues(alpha: 0.3)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6C63FF),
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              'Tümü',
              vm.selectedCategoryFilter == 'all',
              () => vm.setCategoryFilter('all'),
            ),
            const SizedBox(width: 8),
            ...vm.categories.map(
              (category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildFilterChip(
                  category.name,
                  vm.selectedCategoryFilter == category.id,
                  () => vm.setCategoryFilter(category.id),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _buildAgeFilterChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6C63FF)
                  : (isDark ? theme.colorScheme.surface : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : (isDark
                          ? theme.colorScheme.outline.withValues(alpha: 0.3)
                          : const Color(0xFFE2E8F0)),
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgeFilterChip() {
    return PopupMenuButton<String>(
      onSelected: (value) => vm.setAgeFilter(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'all', child: Text('Tüm Yaşlar')),
        const PopupMenuItem(value: '3-5', child: Text('3-5 Yaş')),
        const PopupMenuItem(value: '6-8', child: Text('6-8 Yaş')),
        const PopupMenuItem(value: '9-12', child: Text('9-12 Yaş')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: vm.selectedAgeFilter != 'all'
              ? const Color(0xFF6C63FF)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: vm.selectedAgeFilter != 'all'
                ? const Color(0xFF6C63FF)
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cake,
              size: 16,
              color: vm.selectedAgeFilter != 'all'
                  ? Colors.white
                  : const Color(0xFF6C63FF),
            ),
            const SizedBox(width: 4),
            Text(
              vm.selectedAgeFilter == 'all' ? 'Yaş' : vm.selectedAgeFilter,
              style: TextStyle(
                color: vm.selectedAgeFilter != 'all'
                    ? Colors.white
                    : const Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesGrid() {
    if (vm.isLoadingStories) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    if (vm.storyError != null) {
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
                  'Hikayeler yüklenemedi',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  vm.storyError ?? '',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    }

    if (vm.filteredStories.isEmpty) {
      return Builder(
        builder: (context) {
          final theme = Theme.of(context);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hikaye bulunamadı',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Farklı bir arama veya filtre deneyin',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => vm.clearFilters(),
                  child: const Text('Filtreleri Temizle'),
                ),
              ],
            ),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: vm.filteredStories.length,
      itemBuilder: (context, index) {
        final story = vm.filteredStories[index];
        return StoryGridCardWidget(
          story: story,
          isFavorite: vm.isFavorite(story.id),
          onFavoriteTap: () => vm.toggleFavorite(story.id),
          onTap: () => _navigateToReading(context, story),
        );
      },
    );
  }

  void _navigateToReading(BuildContext context, Story story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => StoryReadingView(story: story)),
    );
  }
}
