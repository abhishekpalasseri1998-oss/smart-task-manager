import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskUseCase {
  final TaskRepository _repository;

  UpdateTaskUseCase(this._repository);

  Future<TaskEntity> call({
    required String userId,
    required TaskEntity task,
  }) {
    return _repository.updateTask(
      userId: userId,
      task: task,
    );
  }
}
