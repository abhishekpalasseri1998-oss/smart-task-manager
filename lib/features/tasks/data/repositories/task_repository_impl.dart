import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TaskEntity>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  }) async {
    return await _remoteDataSource.getTasks(
      userId: userId,
      skip: skip,
      limit: limit,
    );
  }

  @override
  Future<TaskEntity> createTask({
    required String userId,
    required TaskEntity task,
  }) async {
    final model = TaskModel.fromEntity(task);
    return await _remoteDataSource.createTask(
      userId: userId,
      task: model,
    );
  }

  @override
  Future<TaskEntity> updateTask({
    required String userId,
    required TaskEntity task,
  }) async {
    final model = TaskModel.fromEntity(task);
    return await _remoteDataSource.updateTask(
      userId: userId,
      task: model,
    );
  }

  @override
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await _remoteDataSource.deleteTask(
      userId: userId,
      taskId: taskId,
    );
  }
}
