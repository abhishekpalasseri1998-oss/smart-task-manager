import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTasks({
    required String userId,
    required List<TaskModel> tasks,
  });

  Future<List<TaskModel>> getCachedTasks({
    required String userId,
  });

  Future<void> saveTask({
    required String userId,
    required TaskModel task,
  });

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  });

  Future<void> clearCache({
    required String userId,
  });
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String boxName = 'tasks_cache_box';

  Box get _box => Hive.box(boxName);

  String _getKey(String userId) => '${userId}_tasks';

  @override
  Future<void> cacheTasks({
    required String userId,
    required List<TaskModel> tasks,
  }) async {
    try {
      final jsonList = tasks.map((t) => t.toJson()).toList();
      await _box.put(_getKey(userId), jsonList);
    } catch (e) {
      throw CacheException(
        message: 'Failed to write tasks to local cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasks({
    required String userId,
  }) async {
    try {
      final raw = _box.get(_getKey(userId));
      if (raw == null || raw is! List) {
        return [];
      }

      return raw
          .map((item) => TaskModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      throw CacheException(
        message: 'Failed to read tasks from local cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveTask({
    required String userId,
    required TaskModel task,
  }) async {
    try {
      final cached = await getCachedTasks(userId: userId);
      final index = cached.indexWhere((t) => t.id == task.id);

      final updatedList = List<TaskModel>.from(cached);
      if (index != -1) {
        updatedList[index] = task;
      } else {
        updatedList.insert(0, task);
      }

      await cacheTasks(userId: userId, tasks: updatedList);
    } catch (e) {
      throw CacheException(
        message: 'Failed to save task to local cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    try {
      final cached = await getCachedTasks(userId: userId);
      final updatedList = cached.where((t) => t.id != taskId).toList();
      await cacheTasks(userId: userId, tasks: updatedList);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete task from local cache: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCache({
    required String userId,
  }) async {
    try {
      await _box.delete(_getKey(userId));
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear local task cache: ${e.toString()}',
      );
    }
  }
}
