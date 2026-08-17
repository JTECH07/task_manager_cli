import 'package:test/test.dart';
import '../lib/models/task.dart';
import '../lib/models/urgent_task.dart';
import '../lib/models/task_priority.dart';

void main() {
  group('Task Tests', () {
    test('Should create a task with default values', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
      );
      
      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.priority, TaskPriority.medium);
      expect(task.isCompleted, false);
      expect(task.dueDate, isNull);
    });

    test('Should create a task with custom priority', () {
      final task = Task(
        id: '2',
        title: 'High Priority Task',
        priority: TaskPriority.high,
      );
      
      expect(task.priority, TaskPriority.high);
    });

    test('Should mark task as completed', () {
      final task = Task(
        id: '3',
        title: 'Task to complete',
      );
      
      expect(task.isCompleted, false);
      task.markAsCompleted();
      expect(task.isCompleted, true);
    });

    test('Should serialize to JSON and deserialize back', () {
      final originalTask = Task(
        id: '4',
        title: 'JSON Task',
        priority: TaskPriority.high,
        dueDate: DateTime(2024, 12, 25),
      );
      
      final json = originalTask.toJson();
      final restoredTask = Task.fromJson(json);
      
      expect(restoredTask.id, originalTask.id);
      expect(restoredTask.title, originalTask.title);
      expect(restoredTask.priority, originalTask.priority);
      expect(restoredTask.dueDate?.year, originalTask.dueDate?.year);
      expect(restoredTask.dueDate?.month, originalTask.dueDate?.month);
      expect(restoredTask.dueDate?.day, originalTask.dueDate?.day);
    });
  });

  group('UrgentTask Tests', () {
    test('Should create an urgent task', () {
      final urgentTask = UrgentTask(
        id: '5',
        title: 'Urgent Task',
        escalationContact: 'manager@company.com',
      );
      
      expect(urgentTask.priority, TaskPriority.high);
      expect(urgentTask.escalationContact, 'manager@company.com');
    });

    test('Should serialize UrgentTask to JSON', () {
      final urgentTask = UrgentTask(
        id: '6',
        title: 'Urgent JSON Task',
        escalationContact: 'admin@company.com',
        dueDate: DateTime(2024, 12, 31),
      );
      
      final json = urgentTask.toJson();
      expect(json['type'], 'UrgentTask');
      expect(json['escalationContact'], 'admin@company.com');
      
      final restored = UrgentTask.fromJson(json);
      expect(restored.id, urgentTask.id);
      expect(restored.escalationContact, urgentTask.escalationContact);
    });
  });
}
