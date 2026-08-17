import 'task.dart';
import 'task_priority.dart';

/// Classe héritée pour les tâches urgentes
class UrgentTask extends Task {
  final String? escalationContact;

  UrgentTask({
    required super.id,
    required super.title,
    super.priority = TaskPriority.high,
    super.dueDate,
    super.isCompleted = false,
    super.createdAt,
    this.escalationContact,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['type'] = 'UrgentTask';
    json['escalationContact'] = escalationContact;
    return json;
  }

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    return UrgentTask(
      id: json['id'],
      title: json['title'],
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.high,
      ),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      escalationContact: json['escalationContact'],
    );
  }

  @override
  String toString() {
    final base = super.toString();
    final contact = escalationContact != null 
        ? ' | Contact: $escalationContact' 
        : '';
    return 'URGENT - $base$contact';
  }
}