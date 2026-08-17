import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../lib/repository/task_repository.dart';
import '../lib/services/task_service.dart';
import '../lib/models/task_priority.dart';
import '../lib/exceptions/task_exceptions.dart';

void main() {
  late TaskService service;
  late String? testDir;
  late String testFilePath;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('task_service_test_');
    testDir = tempDir.path;
    testFilePath = path.join(testDir!, 'tasks.json');
    final repository = TaskRepository(filePath: testFilePath);
    service = TaskService(repository);
  });

  tearDown(() async {
    final dir = Directory(testDir!);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  group('TaskService Tests', () {
    test('Should add a task', () async {
      final task = await service.addTask(
        title: 'Service Test Task',
        priority: TaskPriority.medium,
      );

      expect(task.title, 'Service Test Task');
      expect(task.priority, TaskPriority.medium);

      final tasks = await service.getAllTasks();
      expect(tasks.length, 1);
    });

    test('Should add an urgent task', () async {
      final task = await service.addTask(
        title: 'Urgent Service Task',
        isUrgent: true,
        escalationContact: 'admin@test.com',
      );

      expect(task.priority, TaskPriority.high);
      expect(task.title, 'Urgent Service Task');

      final tasks = await service.getAllTasks();
      expect(tasks.length, 1);
    });

    test('Should mark task as completed', () async {
      final task = await service.addTask(title: 'Task to Complete');

      expect(task.isCompleted, false);

      final completed = await service.markTaskAsCompleted(task.id);
      expect(completed.isCompleted, true);
    });

    test('Should throw exception when adding task with empty title', () async {
      expect(
        () async => await service.addTask(title: ''),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });

    test('Should sort tasks by priority', () async {
      await service.addTask(title: 'Low Task', priority: TaskPriority.low);
      await service.addTask(title: 'High Task', priority: TaskPriority.high);
      await service.addTask(
        title: 'Medium Task',
        priority: TaskPriority.medium,
      );

      final sorted = await service.getTasksSortedByPriority();
      expect(sorted[0].priority, TaskPriority.high);
      expect(sorted[1].priority, TaskPriority.medium);
      expect(sorted[2].priority, TaskPriority.low);
    });

    test('Should get tasks by status', () async {
      final task1 = await service.addTask(title: 'Task 1');
      final task2 = await service.addTask(title: 'Task 2');

      await service.markTaskAsCompleted(task1.id);

      final completed = await service.getTasksByStatus(true);
      final pending = await service.getTasksByStatus(false);

      expect(completed.length, 1);
      expect(completed[0].id, task1.id);
      expect(pending.length, 1);
      expect(pending[0].id, task2.id);
    });
  });
}
