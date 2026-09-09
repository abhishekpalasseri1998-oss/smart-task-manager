import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository _repository;

  CreateTaskUseCase(this._repository);

  Future<TaskEntity> call({
    required String userId,
    required TaskEntity task,
  }) {
    return _repository.createTask(
      userId: userId,
      task: task,
    );
  }
}
