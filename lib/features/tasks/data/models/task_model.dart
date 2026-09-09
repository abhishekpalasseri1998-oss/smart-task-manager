import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    super.priority = 'medium',
    super.category = 'Work',
    required super.dueDate,
    super.isCompleted = false,
    super.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      } else if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val);
      }
      return DateTime.now();
    }

    return TaskModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      title: json['title'] as String? ?? 'Untitled Task',
      description: json['description'] as String?,
      priority: (json['priority'] as String? ?? 'medium').toLowerCase(),
      category: json['category'] as String? ?? 'Work',
      dueDate: json['due_date'] != null
          ? parseDate(json['due_date'])
          : (json['dueDate'] != null
              ? parseDate(json['dueDate'])
              : DateTime.now()),
      isCompleted: json['is_completed'] as bool? ??
          json['isCompleted'] as bool? ??
          false,
      createdAt: json['created_at'] != null
          ? parseDate(json['created_at'])
          : (json['createdAt'] != null ? parseDate(json['createdAt']) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'title': title,
      if (description != null) 'description': description,
      'priority': priority,
      'category': category,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      priority: entity.priority,
      category: entity.category,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
    );
  }
}
