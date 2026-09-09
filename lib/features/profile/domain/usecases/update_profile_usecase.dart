import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<void> call({
    required String userId,
    required String name,
    required String themeMode,
  }) {
    return _repository.updateProfile(
      userId: userId,
      name: name,
      themeMode: themeMode,
    );
  }
}
