import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserEntity?> getUserProfile(String userId);

  Stream<UserEntity?> get authStateChanges;

  UserEntity? get currentUser;
}
