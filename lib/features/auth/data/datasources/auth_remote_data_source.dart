import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getUserProfile(String userId);

  Stream<UserModel?> get authStateChanges;

  UserModel? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'User registration failed. Please try again.');
      }

      await user.updateDisplayName(name.trim());

      final now = DateTime.now();
      final userModel = UserModel(
        id: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: now,
        themeMode: 'system',
      );

      // Create document in Firestore users/{userId}
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore());
      } catch (_) {
        // Ignore Firestore permission-denied on sign up so Auth succeeds
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException(message: 'User login failed. Please try again.');
      }

      // Fetch user profile from Firestore users/{userId}
      UserModel? profile;
      try {
        profile = await getUserProfile(user.uid);
      } catch (_) {}

      if (profile == null) {
        // Fallback: create default profile if doc missing
        profile = UserModel(
          id: user.uid,
          name: user.displayName ?? email.split('@').first,
          email: email.trim(),
          createdAt: DateTime.now(),
          themeMode: 'system',
        );
        try {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(profile.toFirestore());
        } catch (_) {
          // Ignore Firestore permission errors on login
        }
      }

      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e),
        code: e.code,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(message: 'An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: 'Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return null;
      }
      throw AuthException(
        message: e.message ?? 'Failed to fetch user profile.',
        code: e.code,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      try {
        final profile = await getUserProfile(firebaseUser.uid);
        if (profile != null) return profile;

        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          themeMode: 'system',
        );
      } catch (_) {
        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          themeMode: 'system',
        );
      }
    });
  }

  @override
  UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? firebaseUser.email?.split('@').first ?? 'User',
      email: firebaseUser.email ?? '',
      createdAt: DateTime.now(),
      themeMode: 'system',
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled in Firebase.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection error. Please check your connection.';
      default:
        return e.message ?? 'Authentication error occurred (${e.code}).';
    }
  }
}
