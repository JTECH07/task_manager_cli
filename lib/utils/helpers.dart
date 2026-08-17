import 'dart:io';
import '../models/task.dart';
import '../models/task_priority.dart';

/// Aide pour les interactions utilisateur
class InputHelper {
  static String? readLine(String prompt) {
    stdout.write(prompt);
    return stdin.readLineSync();
  }

  static int? readInt(String prompt) {
    while (true) {
      final input = readLine(prompt);
      if (input == null || input.trim().isEmpty) return null;
      try {
        return int.parse(input.trim());
      } catch (_) {
        print('Veuillez entrer un nombre valide.');
      }
    }
  }

  static DateTime? readDate(String prompt) {
    while (true) {
      final input = readLine(prompt);
      if (input == null || input.trim().isEmpty) return null;
      try {
        final parts = input.trim().split('/');
        if (parts.length != 3) {
          print('Format invalide. Utilisez JJ/MM/AAAA');
          continue;
        }
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      } catch (_) {
        print('Format invalide. Utilisez JJ/MM/AAAA');
      }
    }
  }

  static TaskPriority readPriority(String prompt) {
    while (true) {
      final input = readLine('$prompt (1: Basse, 2: Moyenne, 3: Élevée): ');
      if (input == null || input.trim().isEmpty) return TaskPriority.medium;
      
      switch (input.trim()) {
        case '1':
          return TaskPriority.low;
        case '2':
          return TaskPriority.medium;
        case '3':
          return TaskPriority.high;
        default:
          print('Option invalide. Choisissez 1, 2 ou 3.');
      }
    }
  }

  static bool readBool(String prompt) {
    while (true) {
      final input = readLine('$prompt (o/n): ');
      if (input == null) return false;
      final response = input.trim().toLowerCase();
      if (response == 'o' || response == 'oui') return true;
      if (response == 'n' || response == 'non') return false;
      print('Veuillez répondre par oui (o) ou non (n)');
    }
  }
}

/// Formateur d'affichage
class DisplayHelper {
  static void displayTasks(List<Task> tasks, {String title = 'Tâches'}) {
    if (tasks.isEmpty) {
      print('\nAucune tâche trouvée');
      return;
    }

    print('\n$title (${tasks.length})');
    print('─' * 60);
    
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      print('${i + 1}. ${task.toString()}');
    }
    print('─' * 60);
  }

  static void displayMenu() {
    print('\n${'=' * 50}');
    print('GESTIONNAIRE DE TÂCHES');
    print('=' * 50);
    print('1. Ajouter une tâche');
    print('2. Ajouter une tâche urgente');
    print('3. Voir toutes les tâches');
    print('4. Voir les tâches par priorité');
    print('5. Voir les tâches par date d\'échéance');
    print('6. Marquer une tâche comme terminée');
    print('7. Supprimer une tâche');
    print('8. Quitter');
    print('=' * 50);
  }
}