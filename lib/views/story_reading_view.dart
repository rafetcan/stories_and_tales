import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../viewmodels/story_reading_viewmodel.dart';
import '../services/settings_service.dart';
import 'settings_view.dart';

class StoryReadingView extends StatefulWidget {
  final Story story;

  const StoryReadingView({super.key, required this.story});

  @override
  State<StoryReadingView> createState() => _StoryReadingViewState();
}

class _StoryReadingViewState extends State<StoryReadingView> {
  final ScrollController _scrollController = ScrollController();
  late StoryReadingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = StoryReadingViewModel(context.read<SettingsService>());
    _viewModel.loadStory(widget.story);

    // Scroll listener ekle
    _scrollController.addListener(_onScroll);

    // İlk yüklemede progress varsa scroll et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Widget'lar render olana kadar bekle
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollToSavedPosition();
      });
    });
  }

  void _scrollToSavedPosition() {
    if (!mounted) return;
    if (_viewModel.currentProgress == null ||
        _viewModel.currentProgress!.currentPosition <= 0) {
      return;
    }

    // ScrollController hazır mı kontrol et
    if (!_scrollController.hasClients) {
      // Hazır değilse tekrar dene
      Future.delayed(const Duration(milliseconds: 100), _scrollToSavedPosition);
      return;
    }

    // maxScrollExtent hesaplanmış mı kontrol et
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) {
      // Henüz hesaplanmamış, tekrar dene
      Future.delayed(const Duration(milliseconds: 100), _scrollToSavedPosition);
      return;
    }

    // Şimdi scroll edebiliriz
    final progress = _viewModel.currentProgress!.progressPercentage;
    final targetScroll = maxScroll * progress;

    // Kullanıcıya bilgi ver
    if (mounted && progress > 0.05) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kaldığınız yerden devam ediliyor... (%${(progress * 100).toInt()})',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF6C63FF),
        ),
      );
    }

    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  void _onScroll() {
    // Scroll pozisyonunu progress olarak kaydet
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final scrollPercentage = maxScroll > 0 ? currentScroll / maxScroll : 0.0;

      final totalLength = widget.story.description.length;
      final estimatedPosition = (totalLength * scrollPercentage).toInt();

      _viewModel.updatePosition(estimatedPosition);

      // Her 5 saniyede bir otomatik kaydet
      if (estimatedPosition % 500 == 0) {
        _viewModel.saveProgress(estimatedPosition);
      }
    }
  }

  @override
  void dispose() {
    // Sayfa kapanırken progress'i kaydet
    _viewModel.saveProgress(_viewModel.currentPosition, force: true);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Consumer<StoryReadingViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              );
            }

            if (vm.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hikaye yüklenemedi',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, vm),
                  // Progress bar
                  _buildProgressBar(vm),
                  // Content
                  Expanded(child: _buildContent(vm)),
                  // Bottom controls
                  _buildBottomControls(vm),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StoryReadingViewModel vm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.story.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${vm.getRemainingMinutes()} dk kaldı',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
            onSelected: (value) {
              if (value == 'reset') {
                _showResetDialog(context, vm);
              } else if (value == 'settings') {
                _navigateToSettings(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Baştan Başla'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.text_fields, size: 20),
                    SizedBox(width: 8),
                    Text('Yazı Ayarları'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(StoryReadingViewModel vm) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return LinearProgressIndicator(
          value: vm.getProgressPercentage(),
          backgroundColor: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : const Color(0xFFE2E8F0),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
          minHeight: 3,
        );
      },
    );
  }

  Widget _buildContent(StoryReadingViewModel vm) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          final theme = Theme.of(context);

          return SelectableText(
            widget.story.description,
            style: TextStyle(
              fontSize: settings.currentSettings?.fontSize ?? 16.0,
              height: settings.currentSettings?.lineHeight ?? 1.5,
              color: theme.colorScheme.onSurface,
              fontFamily: settings.currentSettings?.fontFamily,
            ),
            textAlign: TextAlign.justify,
          );
        },
      ),
    );
  }

  Widget _buildBottomControls(StoryReadingViewModel vm) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Font size decrease
              IconButton(
                onPressed: () => _changeFontSize(-1),
                icon: const Icon(Icons.text_decrease),
                color: const Color(0xFF6C63FF),
              ),
              // Font size increase
              IconButton(
                onPressed: () => _changeFontSize(1),
                icon: const Icon(Icons.text_increase),
                color: const Color(0xFF6C63FF),
              ),
              // Progress info
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '%${(vm.getProgressPercentage() * 100).toInt()}',
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
      },
    );
  }

  void _changeFontSize(int delta) {
    final settings = context.read<SettingsService>();
    final currentSize = settings.currentSettings?.fontSize ?? 16.0;
    final newSize = (currentSize + delta).clamp(12.0, 32.0);
    settings.updateFontSize(newSize);
  }

  void _showResetDialog(BuildContext context, StoryReadingViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Baştan Başla'),
        content: const Text(
          'Okuma ilerlemenizi sıfırlamak istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              vm.resetProgress();
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
              Navigator.pop(context);
            },
            child: const Text(
              'Sıfırla',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsView()),
    );
  }
}
