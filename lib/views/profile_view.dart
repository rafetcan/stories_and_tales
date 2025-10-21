import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/feedback_service.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/story_model.dart';
import 'login_view.dart';
import 'settings_view.dart';
import 'story_reading_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel();
    _viewModel.loadProfileData();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Misafir kullanıcı banner'ı
              if (user?.isAnonymous == true) _buildAnonymousUserBanner(context),

              const SizedBox(height: 12),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                ),
                child: ClipOval(
                  child: user?.photoURL != null
                      ? Image.network(user!.photoURL!, fit: BoxFit.cover)
                      : const Icon(
                          Icons.person,
                          size: 56,
                          color: Color(0xFF6C63FF),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Kullanıcı',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              if (user?.email != null)
                Text(
                  user!.email!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              const SizedBox(height: 32),

              // İstatistikler
              Consumer<ProfileViewModel>(
                builder: (context, vm, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.menu_book,
                          title: 'Okunan',
                          value: '${vm.totalCompletedCount}',
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.favorite,
                          title: 'Favoriler',
                          value: '${vm.totalFavoritesCount}',
                          color: Colors.red,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Okumaya Devam Et Bölümü
              SizedBox(height: 200, child: _buildContinueReadingSection()),

              const SizedBox(height: 16),

              // Okunan Hikayeler Bölümü
              SizedBox(height: 300, child: _buildCompletedStoriesSection()),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surface
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: theme.brightness == Brightness.dark ? 0.3 : 0.05,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hesap',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.settings,
                        color: Color(0xFF6C63FF),
                      ),
                      title: const Text('Okuma Ayarları'),
                      subtitle: const Text('Yazı boyutu ve görünüm ayarları'),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF718096),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsView(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.feedback,
                        color: Color(0xFF6C63FF),
                      ),
                      title: const Text('Hata/Öneri Bildir'),
                      subtitle: const Text(
                        'Geri bildiriminizi bizimle paylaşın',
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF718096),
                      ),
                      onTap: () => _showFeedbackDialog(context),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.logout,
                        color: Color(0xFFEF4444),
                      ),
                      title: const Text('Çıkış Yap'),
                      subtitle: Text(
                        user?.isAnonymous == true
                            ? '⚠️ Verileriniz silinecek!'
                            : 'Hesabınızdan güvenle çıkış yapın',
                      ),
                      onTap: () => _handleSignOut(context, user),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueReadingSection() {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        if (vm.continueReadingStories.isEmpty) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
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
                  Row(
                    children: [
                      const Icon(
                        Icons.play_circle_outline,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Okumaya Devam Et',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${vm.continueReadingStories.length}',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.continueReadingStories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final story = vm.continueReadingStories[index];
                    return _buildContinueReadingCard(story);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContinueReadingCard(Story story) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryReadingView(story: story),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF8B7CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.auto_stories, color: Colors.white, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${story.duration} dk',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                story.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                const Text(
                  'Devam Et',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedStoriesSection() {
    return Consumer<ProfileViewModel>(
      builder: (context, vm, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          width: double.infinity,
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
                    'Okuduklarım',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (vm.completedStories.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${vm.completedStories.length}',
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: vm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      )
                    : vm.completedStories.isEmpty
                    ? _buildEmptyCompletedState()
                    : _buildCompletedStoriesList(vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCompletedState() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Henüz tamamlanan hikaye yok',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedStoriesList(ProfileViewModel vm) {
    return ListView.separated(
      itemCount: vm.completedStories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final story = vm.completedStories[index];
        return _buildCompletedStoryItem(story);
      },
    );
  }

  Widget _buildCompletedStoryItem(Story story) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoryReadingView(story: story),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : const Color(0xFFFAFBFF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? theme.colorScheme.outline.withValues(alpha: 0.3)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6C63FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        story.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${story.duration} dk',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnonymousUserBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8B7CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Misafir Hesap',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Verileriniz sadece bu cihazda saklanıyor. Hesabınızı Google ile bağlayarak tüm cihazlarınızdan erişebilir ve verilerinizi kaybetmezsiniz.',
            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleLinkAccount(context),
              icon: const Icon(Icons.link, size: 18),
              label: const Text(
                'Google ile Bağla',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLinkAccount(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();

    try {
      final UserCredential? credential = await authViewModel
          .linkAnonymousAccountWithGoogle();

      if (!mounted) return;

      if (credential != null && credential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hesabınız ${credential.user!.displayName ?? 'Google hesabınıza'} başarıyla bağlandı! 🎉',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Profil verilerini yenile
        _viewModel.loadProfileData();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'credential-already-in-use') {
        // Google hesabı zaten kullanımda - kullanıcıya seçenek sun
        await _showAccountAlreadyExistsDialog(context);
      } else if (e.code == 'provider-already-linked') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu Google hesabı zaten başka bir hesaba bağlı'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hesap bağlanamadı: ${e.message ?? e.code}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bir hata oluştu: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAccountAlreadyExistsDialog(BuildContext context) async {
    final bool? switchAccount = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info, color: Color(0xFF6C63FF)),
              SizedBox(width: 8),
              Expanded(child: Text('Google Hesabı Bulundu')),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bu Google hesabı zaten kayıtlı.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Ne yapmak istersiniz?',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text('• Mevcut Google hesabınızla giriş yapın'),
              SizedBox(height: 4),
              Text('• Misafir hesaptaki verileriniz kaybolacak'),
              SizedBox(height: 4),
              Text('• Google hesabınızdaki eski verilerinize erişebilirsiniz'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Google ile Giriş Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (switchAccount == true && context.mounted) {
      await _switchToGoogleAccount(context);
    }
  }

  Future<void> _switchToGoogleAccount(BuildContext context) async {
    try {
      // Önce çıkış yap (anonim hesaptan)
      await AuthService.signOut();

      if (!mounted) return;

      // Google ile giriş yap
      final authViewModel = context.read<AuthViewModel>();
      final UserCredential? credential = await authViewModel.signInWithGoogle();

      if (!mounted) return;

      if (credential != null && credential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hoş geldiniz, ${credential.user!.displayName ?? 'Kullanıcı'}! 🎉',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Profil verilerini yenile
        _viewModel.loadProfileData();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş yapılamadı: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSignOut(BuildContext context, User? user) async {
    // Misafir kullanıcı için uyarı göster
    if (user?.isAnonymous == true) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Color(0xFFEF4444)),
                SizedBox(width: 8),
                Text('Dikkat!'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Misafir hesaptan çıkış yapıyorsunuz.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Çıkış yaptığınızda:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text('• Okuma geçmişiniz silinecek'),
                Text('• Favorileriniz kaybolacak'),
                Text('• Ayarlarınız sıfırlanacak'),
                SizedBox(height: 12),
                Text(
                  'Verilerinizi korumak için önce "Google ile Bağla" butonuna tıklayarak hesabınızı kaydedin.',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                ),
                child: const Text('Yine de Çıkış Yap'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;
    }

    // Çıkış yap
    await AuthService.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginView()),
        (route) => false,
      );
    }
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    final FeedbackService feedbackService = FeedbackService();
    String feedbackType = 'Öneri';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Geri Bildirim'),
          content: isSubmitting
              ? const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Geri bildirim türü:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('Öneri'),
                            selected: feedbackType == 'Öneri',
                            selectedColor: const Color(0xFF6C63FF),
                            labelStyle: TextStyle(
                              color: feedbackType == 'Öneri'
                                  ? Colors.white
                                  : const Color(0xFF2D3748),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => feedbackType = 'Öneri');
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Hata'),
                            selected: feedbackType == 'Hata',
                            selectedColor: const Color(0xFFEF4444),
                            labelStyle: TextStyle(
                              color: feedbackType == 'Hata'
                                  ? Colors.white
                                  : const Color(0xFF2D3748),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => feedbackType = 'Hata');
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('Diğer'),
                            selected: feedbackType == 'Diğer',
                            selectedColor: const Color(0xFF718096),
                            labelStyle: TextStyle(
                              color: feedbackType == 'Diğer'
                                  ? Colors.white
                                  : const Color(0xFF2D3748),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => feedbackType = 'Diğer');
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: feedbackController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Mesajınızı buraya yazın...',
                          filled: true,
                          fillColor: const Color(0xFFFAFBFF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
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
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setState(() => isSubmitting = true);

                      try {
                        await _submitFeedback(
                          context,
                          feedbackService,
                          feedbackType,
                          feedbackController.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ Geri bildiriminiz başarıyla gönderildi. Teşekkürler!',
                              ),
                              backgroundColor: Color(0xFF6C63FF),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() => isSubmitting = false);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Hata: ${e.toString()}'),
                              backgroundColor: const Color(0xFFEF4444),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitFeedback(
    BuildContext context,
    FeedbackService feedbackService,
    String type,
    String message,
  ) async {
    // FeedbackService üzerinden gönder (tüm güvenlik kontrolleri orada)
    await feedbackService.sendFeedback(type: type, message: message);
  }
}
