import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

enum TaskFilter { all, completed, pending }

enum TaskSort { dueDate, priority, createdDate }

class TasksState extends Equatable {
  final List<TaskEntity> rawTasks;
  final String searchQuery;
  final TaskFilter filter;
  final TaskSort sort;
  final int skip;
  final int limit;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isActionLoading;
  final String? errorMessage;

  const TasksState({
    this.rawTasks = const [],
    this.searchQuery = '',
    this.filter = TaskFilter.all,
    this.sort = TaskSort.dueDate,
    this.skip = 0,
    this.limit = 10,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isActionLoading = false,
    this.errorMessage,
  });

  List<TaskEntity> get filteredTasks {
    var result = List<TaskEntity>.from(rawTasks);

    // 1. Client-side Search by Title
    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.trim().toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(query) ||
              (t.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // 2. Client-side Filtering by Status (All / Completed / Pending)
    switch (filter) {
      case TaskFilter.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      case TaskFilter.pending:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.all:
        break;
    }

    // 3. Client-side Sorting (Due Date / Priority / Created Date)
    switch (sort) {
      case TaskSort.dueDate:
        result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case TaskSort.priority:
        int priorityValue(String p) {
          switch (p.toLowerCase()) {
            case 'high':
              return 3;
            case 'medium':
              return 2;
            case 'low':
              return 1;
            default:
              return 0;
          }
        }
        result.sort(
            (a, b) => priorityValue(b.priority).compareTo(priorityValue(a.priority)));
        break;
      case TaskSort.createdDate:
        result.sort((a, b) {
          final dateA = a.createdAt ?? a.dueDate;
          final dateB = b.createdAt ?? b.dueDate;
          return dateB.compareTo(dateA); // Newest first
        });
        break;
    }

    return result;
  }

  TasksState copyWith({
    List<TaskEntity>? rawTasks,
    String? searchQuery,
    TaskFilter? filter,
    TaskSort? sort,
    int? skip,
    int? limit,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isActionLoading,
    String? errorMessage,
  }) {
    return TasksState(
      rawTasks: rawTasks ?? this.rawTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      skip: skip ?? this.skip,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        rawTasks,
        searchQuery,
        filter,
        sort,
        skip,
        limit,
        hasMore,
        isLoading,
        isLoadingMore,
        isActionLoading,
        errorMessage,
      ];
}
