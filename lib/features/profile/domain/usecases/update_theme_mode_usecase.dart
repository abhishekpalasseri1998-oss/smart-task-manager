import '../repositories/profile_repository.dart';

class UpdateThemeModeUseCase {
  final ProfileRepository _repository;

  UpdateThemeModeUseCase(this._repository);

  Future<void> call({
    required String userId,
    required String themeMode,
  }) {
    return _repository.updateThemeMode(
      userId: userId,
      themeMode: themeMode,
    );
  }
}
