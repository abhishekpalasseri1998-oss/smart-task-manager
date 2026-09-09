import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String priority; // 'low', 'medium', 'high'
  final String category; // 'Work', 'Personal', 'Shopping', 'Health', 'Other'
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? createdAt;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.priority = 'medium',
    this.category = 'Work',
    required this.dueDate,
    this.isCompleted = false,
    this.createdAt,
  });

  TaskEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? priority,
    String? category,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        priority,
        category,
        dueDate,
        isCompleted,
        createdAt,
      ];
}
