import '../../../../core/network/network_info.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../datasources/task_remote_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  final TaskLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  TaskRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<List<TaskEntity>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  }) async {
    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      try {
        final remoteTasks = await _remoteDataSource.getTasks(
          userId: userId,
          skip: skip,
          limit: limit,
        );

        if (skip == 0) {
          await _localDataSource.cacheTasks(
            userId: userId,
            tasks: remoteTasks,
          );
        }
        return remoteTasks;
      } catch (_) {
        // Fallback to local cache on remote failure
        final cachedTasks = await _localDataSource.getCachedTasks(userId: userId);
        if (cachedTasks.isNotEmpty) {
          return cachedTasks;
        }
        rethrow;
      }
    } else {
      // Offline mode: load directly from Hive cache
      return await _localDataSource.getCachedTasks(userId: userId);
    }
  }

  @override
  Future<TaskEntity> createTask({
    required String userId,
    required TaskEntity task,
  }) async {
    final model = TaskModel.fromEntity(task);
    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      final created = await _remoteDataSource.createTask(
        userId: userId,
        task: model,
      );
      await _localDataSource.saveTask(userId: userId, task: created);
      return created;
    } else {
      await _localDataSource.saveTask(userId: userId, task: model);
      return model;
    }
  }

  @override
  Future<TaskEntity> updateTask({
    required String userId,
    required TaskEntity task,
  }) async {
    final model = TaskModel.fromEntity(task);
    final isOnline = await _networkInfo.isConnected;

    if (isOnline) {
      final updated = await _remoteDataSource.updateTask(
        userId: userId,
        task: model,
      );
      await _localDataSource.saveTask(userId: userId, task: updated);
      return updated;
    } else {
      await _localDataSource.saveTask(userId: userId, task: model);
      return model;
    }
  }

  @override
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    final isOnline = await _networkInfo.isConnected;
    await _localDataSource.deleteTask(userId: userId, taskId: taskId);

    if (isOnline) {
      await _remoteDataSource.deleteTask(
        userId: userId,
        taskId: taskId,
      );
    }
  }
}
