import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

enum TaskFilter { all, completed, pending }

enum TaskSort { none, priority, dueDate }

class TaskProvider extends ChangeNotifier {
  TaskProvider(this.repository);

  final TaskRepository repository;

  final _uuid = const Uuid();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.none;
  String _searchQuery = '';

  List<Task> get tasks => applyView(_tasks);
  bool get isLoading => _isLoading;
  String? get error => _error;
  TaskFilter get filter => _filter;
  TaskSort get sort => _sort;
  String get searchQuery => _searchQuery;

  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await repository.getAllTasks();
    } catch (e) {
      _error = 'Failed to load tasks';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
    );
    _tasks = [..._tasks, task];
    notifyListeners();
    await repository.saveTask(task);
  }

  Future<void> updateTask(Task updated) async {
    _tasks = [
      for (final t in _tasks)
        if (t.id == updated.id) updated else t,
    ];
    notifyListeners();
    await repository.saveTask(updated);
  }

  Future<void> toggleCompleted(Task task) {
    return updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<Task?> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) return null;

    final removed = _tasks[index];
    _tasks = [..._tasks.sublist(0, index), ..._tasks.sublist(index + 1)];
    notifyListeners();
    await repository.deleteTask(id);
    return removed;
  }

  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSort(TaskSort sort) {
    _sort = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Task> applyView(List<Task> source) {
    Iterable<Task> result = source;

    switch (_filter) {
      case TaskFilter.completed:
        result = result.where((t) => t.isCompleted);
        break;
      case TaskFilter.pending:
        result = result.where((t) => !t.isCompleted);
        break;
      case TaskFilter.all:
        break;
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q));
    }

    final list = result.toList();

    switch (_sort) {
      case TaskSort.priority:
        list.sort((a, b) => a.priority.index.compareTo(b.priority.index));
        break;
      case TaskSort.dueDate:
        list.sort((a, b) {
          final ad = a.dueDate;
          final bd = b.dueDate;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return ad.compareTo(bd);
        });
        break;
      case TaskSort.none:
        break;
    }

    return list;
  }
}
