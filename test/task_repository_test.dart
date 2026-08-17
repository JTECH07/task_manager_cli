import 'package:test/test.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../lib/repository/task_repository.dart';
import '../lib/models/task.dart';
import '../lib/models/task_priority.dart';
import '../lib/exceptions/task_exceptions.dart';

void main() {
  late TaskRepository repository;
  late String testDir;
  late String testFilePath;

  setUp(() async {
    testDir = await Directory.systemTemp.createTemp('task_test_').path;
    testFilePath = path.join(testDir, 'tasks.json');
    repository = TaskRepository(filePath: testFilePath);
  });

  tearDown(() async {
    final file = File(testFilePath);
    if (await file.exists()) {
      await file.delete();
    }
    await Directory(testDir).delete();
  });

  group('TaskRepository Tests', () {
    test('Should save and retrieve a task', () async {
      final task = Task(
        id: '1',
        title: 'Test Task',
        priority: TaskPriority.high,
      );
      
      await repository.save(task);
      final tasks = await repository.getAll();
      
      expect(tasks.length, 1);
      expect(tasks[0].id, task.id);
      expect(tasks[0].title, task.title);
    });

    test('Should get a task by ID', () async {
      final task = Task(
        id: '2',
        title: 'Find Me',
      );
      
      await repository.save(task);
      final found = await repository.getById('2');
      
      expect(found, isNotNull);
      expect(found?.id, '2');
      expect(found?.title, 'Find Me');
    });

    test('Should update a task', () async {
      final task = Task(
        id: '3',
        title: 'Original Title',
      );
      
      await repository.save(task);
      
      final updatedTask = Task(
        id: '3',
        title: 'Updated Title',
        priority: TaskPriority.high,
      );
      
      await repository.update(updatedTask);
      final found = await repository.getById('3');
      
      expect(found?.title, 'Updated Title');
      expect(found?.priority, TaskPriority.high);
    });

    test('Should delete a task', () async {
      final task = Task(
        id: '4',
        title: 'Delete Me',
      );
      
      await repository.save(task);
      await repository.delete('4');
      
      final tasks = await repository.getAll();
      expect(tasks.isEmpty, true);
    });

    test('Should throw TaskNotFoundException when deleting non-existent task', () async {
      expect(
        () async => await repository.delete('999'),
        throwsA(isA<TaskNotFoundException>())
      );
    });

    test('Should filter tasks by priority', () async {
      final task1 = Task(id: '5', title: 'Low Task', priority: TaskPriority.low);
      final task2 = Task(id: '6', title: 'High Task', priority: TaskPriority.high);
      
      await repository.save(task1);
      await repository.save(task2);
      
      final highTasks = await repository.getTasksByPriority(TaskPriority.high);
      expect(highTasks.length, 1);
      expect(highTasks[0].id, '6');
    });
  });
}