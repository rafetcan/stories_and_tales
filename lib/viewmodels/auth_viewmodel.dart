import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser ?? FirebaseAuth.instance.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final credential = await AuthService.signInWithGoogle();
      _currentUser = credential?.user;
      return credential;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Bilinmeyen bir hata oluştu';
      rethrow;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final credential = await AuthService.signInAnonymously();
      _currentUser = credential?.user;
      return credential;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Bilinmeyen bir hata oluştu';
      rethrow;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential?> linkAnonymousAccountWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final credential = await AuthService.linkAnonymousAccountWithGoogle();
      _currentUser = credential?.user;
      return credential;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Hesap bağlanamadı';
      rethrow;
    } catch (e) {
      _errorMessage = 'Bir hata oluştu';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
