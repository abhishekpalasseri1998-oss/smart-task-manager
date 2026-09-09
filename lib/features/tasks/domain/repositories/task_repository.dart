import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  });

  Future<TaskEntity> createTask({
    required String userId,
    required TaskEntity task,
  });

  Future<TaskEntity> updateTask({
    required String userId,
    required TaskEntity task,
  });

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  });
}
