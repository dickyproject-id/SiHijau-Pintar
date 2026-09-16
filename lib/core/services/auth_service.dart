import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream untuk memantau status login
  Stream<User?> get userStream => _auth.authStateChanges();

  // Mendapatkan user saat ini
  User? get currentUser => _auth.currentUser;

  // Sign In
  Future<UserCredential?> signIn({
    required String loginId,
    required String password,
  }) async {
    try {
      String emailToLogin = loginId;
      
      // Jika yang dimasukkan bukan email (tidak mengandung @), maka anggap sebagai username
      if (!loginId.contains('@')) {
        final querySnapshot = await _db
            .collection('users')
            .where('username', isEqualTo: loginId)
            .limit(1)
            .get();
            
        if (querySnapshot.docs.isEmpty) {
          throw Exception('Username tidak ditemukan.');
        }
        
        emailToLogin = querySnapshot.docs.first.data()['email'];
      }

      return await _auth.signInWithEmailAndPassword(
        email: emailToLogin,
        password: password,
      );
    } catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Sign Up & Save to Firestore
  Future<UserCredential?> signUp({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // 1. Buat User di Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan Data Tambahan ke Firestore (sesuai schema)
      if (userCredential.user != null) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'namaLengkap': name,
          'username': username,
          'email': email,
          'nomorHp': phone,
          'fotoProfil': '',
          'role': email == 'admin@sihijau.com' ? 'admin' : 'user', // Otomatis set role admin
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset Password
  Future<void> resetPassword({required String email}) async {
    try {
      var acs = ActionCodeSettings(
        url: 'https://sihijau-app.firebaseapp.com/__/auth/action',
        handleCodeInApp: true,
        androidPackageName: 'com.sihijau.app',
        androidInstallApp: true,
        androidMinimumVersion: '1',
      );
      await _auth.sendPasswordResetEmail(email: email, actionCodeSettings: acs);
    } catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  // Helper untuk pesan error yang lebih rapi
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email atau kata sandi salah.';
        case 'email-already-in-use':
          return 'Email sudah terdaftar. Silakan gunakan email lain.';
        case 'weak-password':
          return 'Kata sandi terlalu lemah. Minimal 6 karakter.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        default:
          return e.message ?? 'Terjadi kesalahan autentikasi.';
      }
    }
    return e.toString();
  }
}
