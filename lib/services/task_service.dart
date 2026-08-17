import 'package:task_manager_cli/models/task.dart';
import 'package:task_manager_cli/models/urgent_task.dart';
import 'package:task_manager_cli/models/task_priority.dart';
import 'package:task_manager_cli/repository/task_repository.dart';
import 'package:task_manager_cli/exceptions/task_exceptions.dart';

/// Service de gestion des tâches
class TaskService {
  final TaskRepository _repository;

  TaskService(this._repository);

  Future<Task> addTask({
    required String title,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    bool isUrgent = false,
    String? escalationContact,
  }) async {
    if (title.trim().isEmpty) {
      throw InvalidTaskDataException('Le titre ne peut pas être vide');
    }

    final id = _generateId();
    Task task;

    if (isUrgent) {
      task = UrgentTask(
        id: id,
        title: title.trim(),
        priority: TaskPriority.high,
        dueDate: dueDate,
        escalationContact: escalationContact,
      );
    } else {
      task = Task(
        id: id,
        title: title.trim(),
        priority: priority,
        dueDate: dueDate,
      );
    }

    await _repository.save(task);
    return task;
  }

  Future<List<Task>> getAllTasks() async {
    return await _repository.getAll();
  }

  Future<List<Task>> getTasksSortedByPriority() async {
    final tasks = await _repository.getAll();
    // Crée une nouvelle liste modifiable pour le tri
    final sortedTasks = List.of(tasks);
    sortedTasks.sort(
      (a, b) => b.priority.priorityValue.compareTo(a.priority.priorityValue),
    );
    return sortedTasks;
  }

  Future<List<Task>> getTasksSortedByDueDate() async {
    final tasks = await _repository.getAll();
    final sortedTasks = List.of(tasks);
    sortedTasks.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sortedTasks;
  }

  Future<Task> markTaskAsCompleted(String id) async {
    final task = await _repository.getById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }

    task.markAsCompleted();
    await _repository.update(task);
    return task;
  }

  Future<void> deleteTask(String id) async {
    await _repository.delete(id);
  }

  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    return await _repository.getTasksByPriority(priority);
  }

  Future<List<Task>> getTasksByStatus(bool completed) async {
    return await _repository.getTasksByStatus(completed);
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
