import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  const AuthService._();

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithProvider(GoogleAuthProvider());

      final User? user = userCredential.user;
      if (user != null) {
        final DocumentReference<Map<String, dynamic>> userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc
            .get();

        if (!snapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'displayName': user.displayName,
            'email': user.email,
            'photoURL': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'provider': 'google',
          });
        } else {
          await userDoc.update({'lastLoginAt': FieldValue.serverTimestamp()});
        }
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  static Future<UserCredential?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInAnonymously();

      final User? user = userCredential.user;
      if (user != null) {
        final DocumentReference<Map<String, dynamic>> userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);

        final DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc
            .get();

        if (!snapshot.exists) {
          await userDoc.set({
            'uid': user.uid,
            'displayName': 'Misafir Kullanıcı',
            'email': null,
            'photoURL': null,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'provider': 'anonymous',
            'isAnonymous': true,
          });
        } else {
          await userDoc.update({'lastLoginAt': FieldValue.serverTimestamp()});
        }
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  static Future<UserCredential?> linkAnonymousAccountWithGoogle() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null || !currentUser.isAnonymous) {
        throw Exception('Geçerli bir misafir hesabı bulunamadı');
      }

      // Google ile giriş yap ve mevcut anonim hesabı bağla
      final UserCredential linkedCredential = await currentUser
          .linkWithProvider(GoogleAuthProvider());

      // Firestore'daki kullanıcı bilgilerini güncelle
      final User? linkedUser = linkedCredential.user;
      if (linkedUser != null) {
        final DocumentReference<Map<String, dynamic>> userDoc =
            FirebaseFirestore.instance.collection('users').doc(linkedUser.uid);

        await userDoc.update({
          'displayName': linkedUser.displayName,
          'email': linkedUser.email,
          'photoURL': linkedUser.photoURL,
          'provider': 'google',
          'isAnonymous': false,
          'linkedAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }

      return linkedCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
