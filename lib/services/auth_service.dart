// File: lib/services/auth_service.dart
// Kaam: Login, Register, Google Sign In, Logout sab yahan handle hota hai
// Firebase Auth ke saath Firebase Database sync karta hai

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'firebase_service.dart';
import 'security_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseService _firebaseService = FirebaseService();
  final SecurityService _security = SecurityService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Register ──────────────────────────────────────────────────────────────

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    String? referralCode,
  }) async {
    try {
      // 1. Validate inputs
      if (!Helpers.isValidUsername(username)) {
        return AuthResult.error(AppStrings.usernameInvalid);
      }
      if (!Helpers.isValidEmail(email)) {
        return AuthResult.error('Invalid email address');
      }
      if (!Helpers.isValidPassword(password)) {
        return AuthResult.error(AppStrings.weakPassword);
      }

      // 2. Username uniqueness check
      final taken = await _firebaseService.isUsernameTaken(username);
      if (taken) return AuthResult.error(AppStrings.usernameTaken);

      // 3. Firebase Auth mein user banao
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      // 4. Device limit check
      final canCreate = await _security.canCreateAccountOnDevice(uid);
      if (!canCreate) {
        await credential.user!.delete();
        return AuthResult.error(AppStrings.deviceLimit);
      }

      // 5. Referrer dhundo
      String referredBy = '';
      String referredByUid = '';
      if (referralCode != null && referralCode.isNotEmpty) {
        // TODO: Backend call to validate referral code
        // For now, store the code and verify later
        referredBy = referralCode;
      }

      // 6. UserModel banao
      final user = UserModel(
        uid: uid,
        username: username,
        email: email,
        coins: CoinValues.newUserBonus,
        referralCode: Helpers.generateReferralCode(username),
        referredBy: referredBy,
        referredByUid: referredByUid,
        joinedDate: Helpers.todayString(),
      );

      // 7. Firebase Database mein save karo
      await _firebaseService.saveUser(user);

      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_handleFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.error(AppStrings.genericError);
    }
  }

  // ─── Login ─────────────────────────────────────────────────────────────────

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_handleFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.error(AppStrings.genericError);
    }
  }

  // ─── Google Sign In ────────────────────────────────────────────────────────

  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.error('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Check karo kya user already exists
      final existingUser = await _firebaseService.getUser(user.uid);
      if (existingUser == null) {
        // New Google user — save to database
        final deviceOk = await _security.canCreateAccountOnDevice(user.uid);
        if (!deviceOk) {
          await _auth.signOut();
          return AuthResult.error(AppStrings.deviceLimit);
        }

        final username = _generateUsernameFromEmail(googleUser.email);
        final newUser = UserModel(
          uid: user.uid,
          username: username,
          email: user.email ?? googleUser.email,
          coins: CoinValues.newUserBonus,
          referralCode: Helpers.generateReferralCode(username),
          joinedDate: Helpers.todayString(),
        );
        await _firebaseService.saveUser(newUser);
      }

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Google sign in failed: $e');
    }
  }

  // ─── Logout ────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ─── Change Password ───────────────────────────────────────────────────────

  Future<AuthResult> changePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return AuthResult.error('Not logged in');

      // Re-authenticate first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_handleFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.error(AppStrings.genericError);
    }
  }

  // ─── Delete Account ────────────────────────────────────────────────────────

  Future<AuthResult> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return AuthResult.error('Not logged in');

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      await user.delete();
      return AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_handleFirebaseAuthError(e.code));
    } catch (e) {
      return AuthResult.error(AppStrings.genericError);
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _generateUsernameFromEmail(String email) {
    final base = email.split('@')[0].replaceAll(RegExp(r'[^a-z0-9]'), '');
    final trimmed = base.length > 16 ? base.substring(0, 16) : base;
    return '${trimmed.toLowerCase()}${Helpers.random4Digits()}';
  }

  String _handleFirebaseAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'network-request-failed':
        return AppStrings.noInternet;
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return AppStrings.genericError;
    }
  }
}

// ─── AuthResult wrapper ────────────────────────────────────────────────────

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.user, this.errorMessage});

  factory AuthResult.success(User? user) =>
      AuthResult._(isSuccess: true, user: user);

  factory AuthResult.error(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}
