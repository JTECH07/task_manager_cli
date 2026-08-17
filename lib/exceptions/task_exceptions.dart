/// Exception personnalisée pour les erreurs de tâche
class TaskException implements Exception {
  final String message;
  final String? code;

  TaskException(this.message, {this.code});

  @override
  String toString() => 'TaskException: $message${code != null ? ' (Code: $code)' : ''}';
}

class TaskNotFoundException extends TaskException {
  TaskNotFoundException(String id)
      : super('Tâche avec l\'ID "$id" non trouvée', code: 'TASK_NOT_FOUND');
}

class InvalidTaskDataException extends TaskException {
  InvalidTaskDataException(String message)
      : super('Données de tâche invalides: $message', code: 'INVALID_TASK_DATA');
}

class TaskStorageException extends TaskException {
  TaskStorageException(String message)
      : super('Erreur de stockage: $message', code: 'STORAGE_ERROR');
}