import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signUpWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _remoteDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<UserEntity?> getUserProfile(String userId) async {
    return await _remoteDataSource.getUserProfile(userId);
  }

  @override
  Stream<UserEntity?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  UserEntity? get currentUser => _remoteDataSource.currentUser;
}
