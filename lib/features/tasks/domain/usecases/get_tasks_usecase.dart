import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository _repository;

  GetTasksUseCase(this._repository);

  Future<List<TaskEntity>> call({
    required String userId,
    int skip = 0,
    int limit = 10,
  }) {
    return _repository.getTasks(
      userId: userId,
      skip: skip,
      limit: limit,
    );
  }
}
