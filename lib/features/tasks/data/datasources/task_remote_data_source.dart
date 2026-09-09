import '../../../../core/network/dio_client.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  });

  Future<TaskModel> createTask({
    required String userId,
    required TaskModel task,
  });

  Future<TaskModel> updateTask({
    required String userId,
    required TaskModel task,
  });

  Future<void> deleteTask({
    required String userId,
    required String taskId,
  });
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final DioClient _dioClient;

  TaskRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<TaskModel>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  }) async {
    final response = await _dioClient.get(
      '/tasks/',
      queryParameters: {
        'user_id': userId,
        'skip': skip,
        'limit': limit,
      },
    );

    final data = response.data;
    List taskJsonList = [];

    if (data is Map<String, dynamic> && data.containsKey('data')) {
      final inner = data['data'];
      if (inner is List) {
        taskJsonList = inner;
      }
    } else if (data is List) {
      taskJsonList = data;
    }

    return taskJsonList
        .map((json) => TaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TaskModel> createTask({
    required String userId,
    required TaskModel task,
  }) async {
    final response = await _dioClient.post(
      '/tasks/',
      queryParameters: {
        'user_id': userId,
      },
      data: task.toCreateJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      final taskData = data['data'];
      if (taskData is Map<String, dynamic>) {
        return TaskModel.fromJson(taskData);
      }
    } else if (data is Map<String, dynamic>) {
      return TaskModel.fromJson(data);
    }

    return task;
  }

  @override
  Future<TaskModel> updateTask({
    required String userId,
    required TaskModel task,
  }) async {
    final response = await _dioClient.put(
      '/tasks/${task.id}',
      queryParameters: {
        'user_id': userId,
      },
      data: task.toCreateJson(),
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      final taskData = data['data'];
      if (taskData is Map<String, dynamic>) {
        return TaskModel.fromJson(taskData);
      }
    } else if (data is Map<String, dynamic>) {
      return TaskModel.fromJson(data);
    }

    return task;
  }

  @override
  Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await _dioClient.delete(
      '/tasks/$taskId',
      queryParameters: {
        'user_id': userId,
      },
    );
  }
}
