import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../providers/task_providers.dart';
import '../providers/task_state.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/task_item_widget.dart';

class TasksScreen extends ConsumerStatefulWidget {
  final UserEntity user;

  const TasksScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(tasksNotifierProvider);
      if (state.rawTasks.isEmpty && !state.isLoading) {
        ref.read(tasksNotifierProvider.notifier).loadInitialTasks(widget.user.id);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(tasksNotifierProvider.notifier).loadMoreTasks(widget.user.id);
    }
  }

  void _showCreateTaskDialog() {
    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(
        userId: widget.user.id,
        onSubmit: ({
          required String title,
          String? description,
          required String priority,
          required String category,
          required DateTime dueDate,
        }) async {
          final success =
              await ref.read(tasksNotifierProvider.notifier).addTask(
                    userId: widget.user.id,
                    title: title,
                    description: description,
                    priority: priority,
                    category: category,
                    dueDate: dueDate,
                  );

          if (!success && mounted) {
            final error = ref.read(tasksNotifierProvider).errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error ?? 'Failed to create task.'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return success;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final tasksNotifier = ref.read(tasksNotifierProvider.notifier);
    final displayedTasks = tasksState.filteredTasks;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          PopupMenuButton<TaskSort>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Tasks',
            onSelected: (sort) => tasksNotifier.setSort(sort),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TaskSort.dueDate,
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: tasksState.sort == TaskSort.dueDate
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sort by Due Date',
                      style: TextStyle(
                        fontWeight: tasksState.sort == TaskSort.dueDate
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskSort.priority,
                child: Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: tasksState.sort == TaskSort.priority
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sort by Priority',
                      style: TextStyle(
                        fontWeight: tasksState.sort == TaskSort.priority
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: TaskSort.createdDate,
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: tasksState.sort == TaskSort.createdDate
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sort by Created Date',
                      style: TextStyle(
                        fontWeight: tasksState.sort == TaskSort.createdDate
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => tasksNotifier.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search tasks by title...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          tasksNotifier.setSearchQuery('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Tasks'),
                  selected: tasksState.filter == TaskFilter.all,
                  onSelected: (_) => tasksNotifier.setFilter(TaskFilter.all),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: tasksState.filter == TaskFilter.pending,
                  onSelected: (_) =>
                      tasksNotifier.setFilter(TaskFilter.pending),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: tasksState.filter == TaskFilter.completed,
                  onSelected: (_) =>
                      tasksNotifier.setFilter(TaskFilter.completed),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Task List Body
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => tasksNotifier.refreshTasks(widget.user.id),
              child: tasksState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayedTasks.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.task_alt_outlined,
                                      size: 64,
                                      color: theme.colorScheme.outline,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      tasksState.searchQuery.isNotEmpty
                                          ? 'No tasks match "${tasksState.searchQuery}"'
                                          : 'No tasks found',
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Tap "+ Add Task" to create one',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: displayedTasks.length +
                              (tasksState.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == displayedTasks.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                ),
                              );
                            }

                            final task = displayedTasks[index];
                            return TaskItemWidget(
                              task: task,
                              onToggleCompletion: (_) =>
                                  tasksNotifier.toggleTaskCompletion(
                                userId: widget.user.id,
                                task: task,
                              ),
                              onEdit: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => TaskFormDialog(
                                    initialTask: task,
                                    userId: widget.user.id,
                                    onSubmit: ({
                                      required String title,
                                      String? description,
                                      required String priority,
                                      required String category,
                                      required DateTime dueDate,
                                    }) async {
                                      final updated = task.copyWith(
                                        title: title,
                                        description: description,
                                        priority: priority,
                                        category: category,
                                        dueDate: dueDate,
                                      );
                                      return await tasksNotifier.updateTask(
                                        userId: widget.user.id,
                                        task: updated,
                                      );
                                    },
                                  ),
                                );
                              },
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Task'),
                                    content: Text(
                                        'Are you sure you want to delete "${task.title}"?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          tasksNotifier.deleteTask(
                                            userId: widget.user.id,
                                            taskId: task.id,
                                          );
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
