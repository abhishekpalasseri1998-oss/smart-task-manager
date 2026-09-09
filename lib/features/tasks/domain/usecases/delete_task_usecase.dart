import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository _repository;

  DeleteTaskUseCase(this._repository);

  Future<void> call({
    required String userId,
    required String taskId,
  }) {
    return _repository.deleteTask(
      userId: userId,
      taskId: taskId,
    );
  }
}
