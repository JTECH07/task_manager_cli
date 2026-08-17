A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.

# Gestionnaire de Tâches en Ligne de Commande

Une application de gestion de tâches en ligne de commande (CLI) développée en Dart pur.

## 📋 Fonctionnalités

- Ajouter une tâche (titre, priorité, date limite)
- Ajouter des tâches urgentes avec contact d'escalade
- Lister toutes les tâches (triées par priorité ou par date)
- Marquer une tâche comme terminée
- Supprimer une tâche
- Stockage des données dans un fichier JSON local

## 🛠️ Prérequis

- Dart SDK (version 3.0.0 ou supérieure)
- Un terminal pour exécuter les commandes

## 📦 Installation

1. Clonez le dépôt ou créez un nouveau projet :

```bash
dart create task_manager
cd task_manager