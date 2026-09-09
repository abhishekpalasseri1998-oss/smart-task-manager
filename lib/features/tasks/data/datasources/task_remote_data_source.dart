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
    if (data is List) {
      return data.map((json) => TaskModel.fromJson(json as Map<String, dynamic>)).toList();
    } else if (data is Map<String, dynamic> && data.containsKey('tasks')) {
      final tasksList = data['tasks'] as List;
      return tasksList.map((json) => TaskModel.fromJson(json as Map<String, dynamic>)).toList();
    } else if (data is Map<String, dynamic> && data.containsKey('data')) {
      final tasksList = data['data'] as List;
      return tasksList.map((json) => TaskModel.fromJson(json as Map<String, dynamic>)).toList();
    }

    return [];
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
      data: task.toJson(),
    );

    if (response.data is Map<String, dynamic>) {
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
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
      data: task.toJson(),
    );

    if (response.data is Map<String, dynamic>) {
      return TaskModel.fromJson(response.data as Map<String, dynamic>);
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
