import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _firebaseAuth;

  TaskRemoteDataSourceImpl(this._dioClient, {FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  String _getEffectiveUserId(String userId) {
    if (userId.trim().isNotEmpty) return userId.trim();
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid != null && uid.isNotEmpty) return uid;
    return userId;
  }

  @override
  Future<List<TaskModel>> getTasks({
    required String userId,
    int skip = 0,
    int limit = 10,
  }) async {
    final effectiveUid = _getEffectiveUserId(userId);
    final response = await _dioClient.get(
      '/tasks/',
      queryParameters: {
        'user_id': effectiveUid,
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
    final effectiveUid = _getEffectiveUserId(userId);
    final response = await _dioClient.post(
      '/tasks/',
      queryParameters: {
        'user_id': effectiveUid,
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
    final effectiveUid = _getEffectiveUserId(userId);
    final response = await _dioClient.put(
      '/tasks/${task.id}',
      queryParameters: {
        'user_id': effectiveUid,
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
    final effectiveUid = _getEffectiveUserId(userId);
    await _dioClient.delete(
      '/tasks/$taskId',
      queryParameters: {
        'user_id': effectiveUid,
      },
    );
  }
}
