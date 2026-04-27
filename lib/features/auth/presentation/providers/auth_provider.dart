import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/services/secure_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Representasi kondisi autentikasi
enum AuthStatus {
  initial,          // Belum ada action
  loading,          // Proses berlangsung
  authenticated,    // Login berhasil + token backend ada
  unauthenticated,  // Belum login / logout
  emailNotVerified, // Login tapi email belum dikonfirmasi
  error,            // Ada error
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ─── State ───────────────────────────────────────────────
  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;
  String? _tempEmail;
  String? _tempPassword;

  // ─── Getters ─────────────────────────────────────────────
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  // ─── Register dengan Email & Password ────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      // STEP 1: Buat akun di Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = credential.user;

      // STEP 2: Simpan nama di profil Firebase
      await _firebaseUser?.updateDisplayName(name);

      // STEP 3: Firebase kirim email verifikasi
      await _firebaseUser?.sendEmailVerification();

      // STEP 4: Simpan sementara untuk re-login nanti
      _tempEmail = email;
      _tempPassword = password;

      _status = AuthStatus.emailNotVerified;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    }
  }

  // ─── Login Setelah Email Verifikasi ──────────────────────
  Future<bool> loginAfterEmailVerification() async {
    _setLoading();
    try {
      // STEP 1: Reload status user dari server Firebase
      await _firebaseUser?.reload();
      _firebaseUser = _auth.currentUser;

      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      // STEP 2: Re-login untuk dapat fresh session & token
      final credential = await _auth.signInWithEmailAndPassword(
        email: _tempEmail!,
        password: _tempPassword!,
      );
      _firebaseUser = credential.user;
      _tempEmail = null;
      _tempPassword = null;

      // STEP 3: Kirim Firebase token ke backend → dapat JWT
      return await _verifyTokenToBackend();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    }
  }

  // ─── Verify Token ke Backend ──────────────────────────────
  // Update (1)
  // Future<bool> _verifyTokenToBackend() async {
  //   try {
  //     // Ambil Firebase ID Token
  //     final firebaseToken = await _firebaseUser?.getIdToken();

  //     // POST ke backend
  //     final response = await DioClient.instance.post(
  //       ApiConstants.verifyToken,
  //       data: {'firebase_token': firebaseToken},
  //     );

  //     // Backend return JWT
  //     final data = response.data['data'] as Map<String, dynamic>;
  //     final backendToken = data['access_token'] as String;

  //     // Simpan aman di device
  //     await SecureStorageService.saveToken(backendToken);

  //     _status = AuthStatus.authenticated;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _setError('Gagal verifikasi token: $e');
  //     return false;
  //   }
  // }

  // Update (2)
  // Pastikan Anda sudah mengimport file repository-nya di atas:
// import '../../data/repositories/auth_repository_impl.dart';

  Future<bool> _verifyTokenToBackend() async {
    try {
      final firebaseToken = await _firebaseUser?.getIdToken() ?? '';
      
      // Mengambil token dari data palsu di repository
      final backendToken = await AuthRepositoryImpl().verifyFirebaseToken(firebaseToken);
      
      await SecureStorageService.saveToken(backendToken);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Gagal verifikasi: $e');
      return false;
    }
  }

  // ─── Login dengan Email & Password ───────────────────────
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _firebaseUser = credential.user;

      // Cek apakah email sudah diverifikasi
      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        notifyListeners();
        return false;
      }

      return await _verifyTokenToBackend();
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    }
  }

  // ─── Login dengan Google ──────────────────────────────────
  Future<bool> loginWithGoogle() async {
    _setLoading();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setError('Login Google dibatalkan');
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      _firebaseUser = userCred.user;

      // Google login → email otomatis terverifikasi
      return await _verifyTokenToBackend();
    } catch (e) {
      _setError('Gagal login dengan Google: $e');
      return false;
    }
  }

  // ─── Kirim ulang email verifikasi ────────────────────────
  Future<void> resendVerificationEmail() async {
    await _firebaseUser?.sendEmailVerification();
  }

  // ─── Cek status verifikasi email (polling) ────────────────
  Future<bool> checkEmailVerified() async {
    await _firebaseUser?.reload();
    _firebaseUser = _auth.currentUser;

    if (_firebaseUser?.emailVerified ?? false) {
      return await _verifyTokenToBackend();
    }
    return false;
  }

  // ─── Logout ───────────────────────────────────────────────
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    await SecureStorageService.clearAll();
    _firebaseUser = null;
    _backendToken = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ─── Private Helpers ──────────────────────────────────────
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(String code) => switch (code) {
        'email-already-in-use' => 'Email sudah terdaftar. Gunakan email lain.',
        'user-not-found' => 'Akun tidak ditemukan. Silakan daftar.',
        'wrong-password' => 'Password salah. Coba lagi.',
        'invalid-email' => 'Format email tidak valid.',
        'weak-password' => 'Password terlalu lemah. Minimal 6 karakter.',
        'network-request-failed' => 'Tidak ada koneksi internet.',
        _ => 'Terjadi kesalahan. Coba lagi.',
      };
}