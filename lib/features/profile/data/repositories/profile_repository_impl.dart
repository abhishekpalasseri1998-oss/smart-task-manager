import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity?> getProfile(String userId) async {
    return await _remoteDataSource.getProfile(userId);
  }

  @override
  Future<void> updateProfile({
    required String userId,
    required String name,
    required String themeMode,
  }) async {
    await _remoteDataSource.updateProfile(
      userId: userId,
      name: name,
      themeMode: themeMode,
    );
  }

  @override
  Future<void> updateThemeMode({
    required String userId,
    required String themeMode,
  }) async {
    await _remoteDataSource.updateThemeMode(
      userId: userId,
      themeMode: themeMode,
    );
  }
}
