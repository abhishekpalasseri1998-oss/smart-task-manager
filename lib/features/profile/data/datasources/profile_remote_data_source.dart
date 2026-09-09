import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel?> getProfile(String userId);
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String themeMode,
  });
  Future<void> updateThemeMode({
    required String userId,
    required String themeMode,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  ProfileRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserModel?> getProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AuthException(
        message: e.message ?? 'Failed to fetch user profile.',
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: 'Failed to fetch profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String themeMode,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name.trim(),
        'themeMode': themeMode,
      });

      final user = _firebaseAuth.currentUser;
      if (user != null && user.uid == userId) {
        await user.updateDisplayName(name.trim());
      }
    } on FirebaseException catch (e) {
      throw AuthException(
        message: e.message ?? 'Failed to update user profile in Firestore.',
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> updateThemeMode({
    required String userId,
    required String themeMode,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'themeMode': themeMode,
      });
    } on FirebaseException catch (e) {
      throw AuthException(
        message: e.message ?? 'Failed to update theme mode.',
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: 'Failed to update theme mode: ${e.toString()}');
    }
  }
}
