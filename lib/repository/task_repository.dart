import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:task_manager_cli/models/task_priority.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../exceptions/task_exceptions.dart';

/// Interface générique pour un repository
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
  Future<void> update(T item);
}

/// Repository pour les tâches avec stockage JSON
class TaskRepository implements Repository<Task> {
  final String _filePath;
  List<Task> _tasks = [];
  bool _initialized = false;

  TaskRepository({String? filePath})
      : _filePath = filePath ?? _getDefaultPath();

  static String _getDefaultPath() {
    return path.join(Directory.current.path, 'data', 'tasks.json');
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _loadFromFile();
    _initialized = true;
  }

  Future<void> _loadFromFile() async {
    try {
      final file = File(_filePath);
      if (!await file.exists()) {
        _tasks = [];
        return;
      }

      final content = await file.readAsString();
      if (content.isEmpty) {
        _tasks = [];
        return;
      }

      final List<dynamic> jsonList = jsonDecode(content);
      _tasks = jsonList.map((json) {
        final type = json['type'] ?? 'Task';
        if (type == 'UrgentTask') {
          return UrgentTask.fromJson(json);
        }
        return Task.fromJson(json);
      }).toList();
    } catch (e) {
      throw TaskStorageException('Impossible de charger les tâches: $e');
    }
  }

  Future<void> _saveToFile() async {
    try {
      final file = File(_filePath);
      await file.create(recursive: true);
      final jsonList = _tasks.map((task) => task.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      throw TaskStorageException('Impossible de sauvegarder les tâches: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    await _ensureInitialized();
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw TaskNotFoundException(id);
    }
    _tasks.removeAt(index);
    await _saveToFile();
  }

  @override
  Future<List<Task>> getAll() async {
    await _ensureInitialized();
    return List.unmodifiable(_tasks);
  }

  @override
  Future<Task?> getById(String id) async {
    await _ensureInitialized();
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(Task task) async {
    await _ensureInitialized();
    
    // Vérifier si la tâche existe déjà
    final existingIndex = _tasks.indexWhere((t) => t.id == task.id);
    if (existingIndex != -1) {
      throw TaskException('Une tâche avec cet ID existe déjà');
    }
    
    _tasks.add(task);
    await _saveToFile();
  }

  @override
  Future<void> update(Task task) async {
    await _ensureInitialized();
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw TaskNotFoundException(task.id);
    }
    _tasks[index] = task;
    await _saveToFile();
  }

  // Méthodes supplémentaires
  Future<List<Task>> getTasksByPriority(TaskPriority priority) async {
    await _ensureInitialized();
    return _tasks.where((task) => task.priority == priority).toList();
  }

  Future<List<Task>> getTasksByStatus(bool completed) async {
    await _ensureInitialized();
    return _tasks.where((task) => task.isCompleted == completed).toList();
  }

  Future<void> clearAllTasks() async {
    await _ensureInitialized();
    _tasks.clear();
    await _saveToFile();
  }
}