import '../../../auth/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity?> getProfile(String userId);
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
