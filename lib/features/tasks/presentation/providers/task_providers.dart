import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/task_remote_data_source.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import 'task_state.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

final taskRemoteDataSourceProvider = Provider<TaskRemoteDataSource>((ref) {
  return TaskRemoteDataSourceImpl(ref.watch(dioClientProvider));
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(ref.watch(taskRemoteDataSourceProvider));
});

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTaskUseCase>((ref) {
  return UpdateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

class TasksNotifier extends Notifier<TasksState> {
  @override
  TasksState build() {
    return const TasksState();
  }

  Future<void> loadInitialTasks(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, skip: 0);
    try {
      final getTasks = ref.read(getTasksUseCaseProvider);
      final tasks = await getTasks(userId: userId, skip: 0, limit: state.limit);
      state = state.copyWith(
        rawTasks: tasks,
        isLoading: false,
        skip: 0,
        hasMore: tasks.length >= state.limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMoreTasks(String userId) async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;

    final nextSkip = state.skip + state.limit;
    state = state.copyWith(isLoadingMore: true);

    try {
      final getTasks = ref.read(getTasksUseCaseProvider);
      final newTasks = await getTasks(userId: userId, skip: nextSkip, limit: state.limit);

      final updatedTasks = List<TaskEntity>.from(state.rawTasks)..addAll(newTasks);
      state = state.copyWith(
        rawTasks: updatedTasks,
        isLoadingMore: false,
        skip: nextSkip,
        hasMore: newTasks.length >= state.limit,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
      );
    }
  }

  Future<void> refreshTasks(String userId) async {
    try {
      final getTasks = ref.read(getTasksUseCaseProvider);
      final tasks = await getTasks(userId: userId, skip: 0, limit: state.limit);
      state = state.copyWith(
        rawTasks: tasks,
        skip: 0,
        hasMore: tasks.length >= state.limit,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setFilter(TaskFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSort(TaskSort sort) {
    state = state.copyWith(sort: sort);
  }

  Future<bool> addTask({
    required String userId,
    required String title,
    String? description,
    required String priority,
    required String category,
    required DateTime dueDate,
  }) async {
    state = state.copyWith(isActionLoading: true);
    try {
      final createTaskUseCase = ref.read(createTaskUseCaseProvider);
      final newTask = TaskEntity(
        id: '', // Server assigns ID
        userId: userId,
        title: title,
        description: description,
        priority: priority,
        category: category,
        dueDate: dueDate,
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      final created = await createTaskUseCase(userId: userId, task: newTask);
      final updatedList = [created, ...state.rawTasks];

      state = state.copyWith(
        rawTasks: updatedList,
        isActionLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isActionLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateTask({
    required String userId,
    required TaskEntity task,
  }) async {
    final originalTasks = List<TaskEntity>.from(state.rawTasks);
    // Optimistic update
    final index = state.rawTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final updatedList = List<TaskEntity>.from(state.rawTasks);
      updatedList[index] = task;
      state = state.copyWith(rawTasks: updatedList);
    }

    try {
      final updateTaskUseCase = ref.read(updateTaskUseCaseProvider);
      final updated = await updateTaskUseCase(userId: userId, task: task);

      if (index != -1) {
        final confirmedList = List<TaskEntity>.from(state.rawTasks);
        confirmedList[index] = updated;
        state = state.copyWith(rawTasks: confirmedList);
      }
      return true;
    } catch (e) {
      // Revert optimistic update on failure
      state = state.copyWith(rawTasks: originalTasks, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> toggleTaskCompletion({
    required String userId,
    required TaskEntity task,
  }) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(userId: userId, task: updatedTask);
  }

  Future<bool> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    final originalTasks = List<TaskEntity>.from(state.rawTasks);
    // Optimistic removal
    final updatedList = state.rawTasks.where((t) => t.id != taskId).toList();
    state = state.copyWith(rawTasks: updatedList);

    try {
      final deleteTaskUseCase = ref.read(deleteTaskUseCaseProvider);
      await deleteTaskUseCase(userId: userId, taskId: taskId);
      return true;
    } catch (e) {
      // Revert on error
      state = state.copyWith(rawTasks: originalTasks, errorMessage: e.toString());
      return false;
    }
  }
}

final tasksNotifierProvider =
    NotifierProvider<TasksNotifier, TasksState>(
  TasksNotifier.new,
);
