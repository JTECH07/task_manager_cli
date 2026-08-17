import 'dart:io';
import 'package:task_manager_cli/repository/task_repository.dart';
import 'package:task_manager_cli/services/task_service.dart';
import 'package:task_manager_cli/models/task_priority.dart';
import 'package:task_manager_cli/utils/helpers.dart';

Future<void> main() async {
  try {
    final repository = TaskRepository();
    final service = TaskService(repository);
    await runApp(service);
  } catch (e) {
    print('Erreur: $e');
  }
}

Future<void> runApp(TaskService service) async {
  while (true) {
    DisplayHelper.displayMenu();
    final choice = InputHelper.readLine('Votre choix: ');

    try {
      switch (choice?.trim()) {
        case '1':
          await addTask(service, false);
          break;
        case '2':
          await addTask(service, true);
          break;
        case '3':
          await viewAllTasks(service);
          break;
        case '4':
          await viewTasksByPriority(service);
          break;
        case '5':
          await viewTasksByDueDate(service);
          break;
        case '6':
          await markTaskAsCompleted(service);
          break;
        case '7':
          await deleteTask(service);
          break;
        case '8':
          await updateTask(service);
          break;
        case '9':
          print('Au revoir!');
          return;
        default:
          print('x Option invalide. Veuillez réessayer.');
      }
    } on TaskException catch (e) {
      print('x Erreur de tâche: ${e.message}');
    } catch (e, s) {
      print('x Une erreur inattendue est survenue: $e');
    }

    print('\nAppuyez sur Entrée pour continuer...');
    stdin.readLineSync();
  }
}

Future<void> addTask(TaskService service, bool isUrgent) async {
  print('\n➕ ${isUrgent ? 'Ajouter une tâche urgente' : 'Ajouter une tâche'}');

  final title = InputHelper.readLine('Titre: ');
  if (title == null || title.trim().isEmpty) {
    print('x Le titre est requis');
    return;
  }

  TaskPriority priority = TaskPriority.medium;
  if (!isUrgent) {
    priority = InputHelper.readPriority('Priorité');
  }

  DateTime? dueDate;
  final hasDueDate = InputHelper.readBool(
    'Voulez-vous ajouter une date d\'échéance?',
  );
  if (hasDueDate) {
    dueDate = InputHelper.readDate('Date d\'échéance (JJ/MM/AAAA): ');
  }

  String? escalationContact;
  if (isUrgent) {
    escalationContact = InputHelper.readLine(
      'Contact d\'escalade (optionnel): ',
    );
  }

  try {
    final task = await service.addTask(
      title: title,
      priority: priority,
      dueDate: dueDate,
      isUrgent: isUrgent,
      escalationContact: escalationContact,
    );
    print('✓ Tâche ajoutée avec succès! ID: ${task.id}');
  } catch (e) {
    print('x Erreur lors de l\'ajout de la tâche: $e');
  }
}

Future<void> viewAllTasks(TaskService service) async {
  final tasks = await service.getAllTasks();
  DisplayHelper.displayTasks(tasks);
}

Future<void> viewTasksByPriority(TaskService service) async {
  final priority = InputHelper.readPriority('Priorité');
  final tasks = await service.getTasksByPriority(priority);
  DisplayHelper.displayTasks(
    tasks,
    title: 'Tâches prioritaires ${priority.displayName}',
  );
}

Future<void> viewTasksByDueDate(TaskService service) async {
  final tasks = await service.getTasksSortedByDueDate();
  DisplayHelper.displayTasks(
    tasks,
    title: 'Tâches triées par date d\'échéance',
  );
}

Future<void> markTaskAsCompleted(TaskService service) async {
  final tasks = await service.getAllTasks();
  DisplayHelper.displayTasks(tasks);

  if (tasks.isEmpty) return;

  final index = InputHelper.readInt(
    'Numéro de la tâche à marquer comme terminée: ',
  );
  if (index == null || index < 1 || index > tasks.length) {
    print('x Numéro invalide');
    return;
  }

  final task = tasks[index - 1];
  try {
    await service.markTaskAsCompleted(task.id);
    print('✓ Tâche marquée comme terminée!');
  } catch (e) {
    print('x Erreur: $e');
  }
}

Future<void> updateTask(TaskService service) async {
  final tasks = await service.getAllTasks();
  DisplayHelper.displayTasks(tasks, title: 'Modifier une tâche');

  if (tasks.isEmpty) return;

  final index = InputHelper.readInt('Numéro de la tâche à modifier: ');
  if (index == null || index < 1 || index > tasks.length) {
    print('x Numéro invalide');
    return;
  }

  final taskToUpdate = tasks[index - 1];

  print('\nLaissez vide pour ne pas modifier.');

  final newTitle = InputHelper.readLine(
    'Nouveau titre (${taskToUpdate.title}): ',
  );

  final newPriority = taskToUpdate is! UrgentTask
      ? InputHelper.readPriority(
          'Nouvelle priorité (${taskToUpdate.priority.displayName})',
        )
      : taskToUpdate.priority;

  final newDueDate = InputHelper.readDate(
    'Nouvelle date d\'échéance (JJ/MM/AAAA): ',
  );

  try {
    await service.updateTask(
      id: taskToUpdate.id,
      title: newTitle?.trim().isEmpty ?? true ? null : newTitle,
      priority: newPriority,
      dueDate: newDueDate,
    );
    print('✓ Tâche modifiée avec succès!');
  } catch (e) {
    print('x Erreur lors de la modification: $e');
  }
}

Future<void> deleteTask(TaskService service) async {
  final tasks = await service.getAllTasks();
  DisplayHelper.displayTasks(tasks);

  if (tasks.isEmpty) return;

  final index = InputHelper.readInt('Numéro de la tâche à supprimer: ');
  if (index == null || index < 1 || index > tasks.length) {
    print('x Numéro invalide');
    return;
  }

  final confirm = InputHelper.readBool('Confirmer la suppression?');
  if (!confirm) {
    print('Suppression annulée');
    return;
  }

  final task = tasks[index - 1];
  try {
    await service.deleteTask(task.id);
    print('✓ Tâche supprimée!');
  } catch (e) {
    print('x Erreur: $e');
  }
}
