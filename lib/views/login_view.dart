import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'home_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutBack,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isLoading = authViewModel.isLoading;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              // Logo ve Başlık
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF8B7CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6C63FF,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hikayeler ve Masallar',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Çocuklarınız için eğlenceli hikayeler',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF718096),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni ve Eğlenceli Hikayeler',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF718096),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Giriş Butonları
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildButton(
                        text: 'Google ile Giriş Yap',
                        onPressed: () =>
                            _handleGoogleSignInWithVm(authViewModel),
                        icon: FontAwesomeIcons.google,
                        backgroundColor: Colors.white,
                        textColor: const Color(0xFF2D3748),
                        hasBorder: true,
                        isLoading: isLoading,
                      ),
                      const SizedBox(height: 16),
                      _buildButton(
                        text: 'Üyeliksiz Devam Et',
                        onPressed: () =>
                            _handleAnonymousSignInWithVm(authViewModel),
                        icon: Icons.person_outline,
                        backgroundColor: const Color(0xFF6C63FF),
                        textColor: Colors.white,
                        hasBorder: false,
                        isLoading: isLoading,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Alt Bilgi
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Giriş yaparak kişiselleştirilmiş deneyim yaşayın',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF718096),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    IconData? icon,
    bool hasBorder = false,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: hasBorder ? Border.all(color: const Color(0xFFE2E8F0)) : null,
        boxShadow: [
          BoxShadow(
            color: backgroundColor == Colors.white
                ? Colors.black.withValues(alpha: 0.1)
                : backgroundColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLoading && icon != null) ...[
                  FaIcon(icon, size: 20, color: textColor),
                  const SizedBox(width: 12),
                ],
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                else
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignInWithVm(AuthViewModel vm) async {
    try {
      final UserCredential? userCredential = await vm.signInWithGoogle();
      if (!mounted) return;
      if (userCredential != null && userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hoş geldin, ${userCredential.user!.displayName ?? 'Kullanıcı'}!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _navigateToHome();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş başarısız: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleAnonymousSignInWithVm(AuthViewModel vm) async {
    try {
      final UserCredential? userCredential = await vm.signInAnonymously();
      if (!mounted) return;
      if (userCredential != null && userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Misafir olarak giriş yapıldı!'),
            backgroundColor: Colors.green,
          ),
        );
        _navigateToHome();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş başarısız: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
