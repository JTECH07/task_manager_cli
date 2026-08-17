import 'task_priority.dart';

/// Interface pour les tâches
abstract class ITask {
  String get id;
  String get title;
  TaskPriority get priority;
  DateTime? get dueDate;
  bool get isCompleted;
  DateTime get createdAt;

  Map<String, dynamic> toJson();
  void markAsCompleted();
}

/// Classe de base pour les tâches
class Task implements ITask {
  final String id;
  final String title;
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.toString(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'type': 'Task',
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Task copyWith({
    String? title,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
    );
  }

  @override
  void markAsCompleted() {
    isCompleted = true;
  }

  @override
  String toString() {
    final status = isCompleted ? '✓' : '□';
    final priorityEmoji = _getPriorityEmoji();
    final dueDateStr = dueDate != null
        ? ' | Échéance: ${_formatDate(dueDate!)}'
        : '';
    return '$status $priorityEmoji $title (${priority.displayName})$dueDateStr';
  }

  String _getPriorityEmoji() {
    switch (priority) {
      case TaskPriority.low:
        return '🟢';
      case TaskPriority.medium:
        return '🟡';
      case TaskPriority.high:
        return '🔴';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
