import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<UserEntity?> call(String userId) {
    return _repository.getUserProfile(userId);
  }
}
