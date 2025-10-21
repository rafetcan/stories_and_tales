import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        backgroundColor: isDark ? theme.colorScheme.surface : Colors.white,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settings, child) {
          if (settings.currentSettings == null) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Okuma Ayarları Section
              _buildSectionTitle('Okuma Ayarları', context),
              const SizedBox(height: 16),

              // Yazı Boyutu
              _buildSettingCard(
                context: context,
                title: 'Yazı Boyutu',
                subtitle: '${settings.currentSettings!.fontSize.toInt()} px',
                child: Slider(
                  value: settings.currentSettings!.fontSize,
                  min: 12,
                  max: 32,
                  divisions: 20,
                  activeColor: const Color(0xFF6C63FF),
                  label: '${settings.currentSettings!.fontSize.toInt()} px',
                  onChanged: (value) {
                    settings.updateFontSize(value);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Satır Yüksekliği
              _buildSettingCard(
                context: context,
                title: 'Satır Yüksekliği',
                subtitle: settings.currentSettings!.lineHeight.toStringAsFixed(
                  1,
                ),
                child: Slider(
                  value: settings.currentSettings!.lineHeight,
                  min: 1.2,
                  max: 2.0,
                  divisions: 8,
                  activeColor: const Color(0xFF6C63FF),
                  label: settings.currentSettings!.lineHeight.toStringAsFixed(
                    1,
                  ),
                  onChanged: (value) {
                    settings.updateLineHeight(value);
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Önizleme
              _buildPreviewCard(settings, context),

              const SizedBox(height: 24),

              // Genel Ayarlar Section
              _buildSectionTitle('Genel Ayarlar', context),
              const SizedBox(height: 16),

              // Karanlık Mod
              _buildSettingCard(
                context: context,
                title: 'Karanlık Mod',
                subtitle: settings.currentSettings!.darkMode
                    ? 'Açık'
                    : 'Kapalı',
                child: Switch(
                  value: settings.currentSettings!.darkMode,
                  activeTrackColor: const Color(0xFF6C63FF),
                  activeThumbColor: Colors.white,
                  onChanged: (value) {
                    settings.updateDarkMode(value);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Varsayılana Sıfırla
              Center(
                child: TextButton.icon(
                  onPressed: () => _showResetDialog(context, settings),
                  icon: const Icon(Icons.restore),
                  label: const Text('Varsayılan Ayarlara Dön'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6C63FF),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required Widget child,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildPreviewCard(SettingsService settings, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outline.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.visibility, color: Color(0xFF6C63FF), size: 20),
              const SizedBox(width: 8),
              Text(
                'Önizleme',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bir varmış, bir yokmuş. Evvel zaman içinde, kalbur saman içinde, develer tellal iken, bir fakir adam varmış. Bu fakir adamın üç tane oğlu varmış.',
            style: TextStyle(
              fontSize: settings.currentSettings!.fontSize,
              height: settings.currentSettings!.lineHeight,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsService settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ayarları Sıfırla'),
        content: const Text(
          'Tüm ayarları varsayılan değerlere döndürmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              settings.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayarlar varsayılana döndürüldü')),
              );
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
}
