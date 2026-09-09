import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetAuthStateUseCase {
  final AuthRepository _repository;

  GetAuthStateUseCase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.authStateChanges;
  }
}
