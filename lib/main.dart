import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()..initAds()),
        ChangeNotifierProvider(
          create: (_) => SettingsService()..loadSettings(),
        ),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settingsService, child) {
          return MaterialApp(
            title: 'Hikayeler ve Masallar',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: const Color(0xFFFAFBFF),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6C63FF),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              textTheme: GoogleFonts.poppinsTextTheme(),
              fontFamily: 'Poppins',
              scaffoldBackgroundColor: const Color(0xFF1A1A2E),
            ),
            themeMode: settingsService.currentSettings?.darkMode == true
                ? ThemeMode.dark
                : ThemeMode.light,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.hasData) {
                  return const HomeView();
                }
                return const LoginView();
              },
            ),
          );
        },
      ),
    );
  }
}
