import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/settings_model.dart';

class SettingsService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppSettings? _currentSettings;
  AppSettings? get currentSettings => _currentSettings;

  // Ayarları yükle
  Future<void> loadSettings() async {
    final user = _auth.currentUser;
    if (user == null) {
      _currentSettings = AppSettings.defaultSettings('');
      notifyListeners();
      return;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app_settings')
          .get();

      if (doc.exists) {
        _currentSettings = AppSettings.fromFirestore(doc.data()!);
      } else {
        // Default ayarlar oluştur
        _currentSettings = AppSettings.defaultSettings(user.uid);
        await saveSettings(_currentSettings!);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Ayarlar yüklenemedi: $e');
      _currentSettings = AppSettings.defaultSettings(user.uid);
      notifyListeners();
    }
  }

  // Ayarları kaydet
  Future<void> saveSettings(AppSettings settings) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturum açmamış');
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('app_settings')
          .set(settings.toFirestore());

      _currentSettings = settings;
      notifyListeners();
    } catch (e) {
      throw Exception('Ayarlar kaydedilemedi: $e');
    }
  }

  // Yazı boyutunu güncelle
  Future<void> updateFontSize(double fontSize) async {
    if (_currentSettings == null) return;

    final updatedSettings = _currentSettings!.copyWith(
      fontSize: fontSize,
      updatedAt: DateTime.now(),
    );

    await saveSettings(updatedSettings);
  }

  // Satır yüksekliğini güncelle
  Future<void> updateLineHeight(double lineHeight) async {
    if (_currentSettings == null) return;

    final updatedSettings = _currentSettings!.copyWith(
      lineHeight: lineHeight,
      updatedAt: DateTime.now(),
    );

    await saveSettings(updatedSettings);
  }

  // Karanlık modu güncelle
  Future<void> updateDarkMode(bool darkMode) async {
    if (_currentSettings == null) return;

    final updatedSettings = _currentSettings!.copyWith(
      darkMode: darkMode,
      updatedAt: DateTime.now(),
    );

    await saveSettings(updatedSettings);
  }

  // Font ailesini güncelle
  Future<void> updateFontFamily(String fontFamily) async {
    if (_currentSettings == null) return;

    final updatedSettings = _currentSettings!.copyWith(
      fontFamily: fontFamily,
      updatedAt: DateTime.now(),
    );

    await saveSettings(updatedSettings);
  }

  // Ayarları sıfırla
  Future<void> resetToDefaults() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final defaultSettings = AppSettings.defaultSettings(user.uid);
    await saveSettings(defaultSettings);
  }
}
