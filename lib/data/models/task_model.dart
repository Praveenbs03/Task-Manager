import 'package:hive/hive.dart';
import 'package:task_manager/domain/entities/task.dart' as domain;

part 'task_model.g.dart';

@HiveType(typeId: 0)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 1)
class TaskModel extends HiveObject {
  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
  });

  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime? dueDate;

  @HiveField(4)
  TaskPriority priority;

  @HiveField(5)
  bool isCompleted;

  domain.Task toDomain() {
    return domain.Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: _mapPriorityToDomain(priority),
      isCompleted: isCompleted,
    );
  }

  static TaskModel fromDomain(domain.Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      priority: _mapPriorityFromDomain(task.priority),
      isCompleted: task.isCompleted,
    );
  }

  static domain.TaskPriority _mapPriorityToDomain(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return domain.TaskPriority.low;
      case TaskPriority.medium:
        return domain.TaskPriority.medium;
      case TaskPriority.high:
        return domain.TaskPriority.high;
    }
  }

  static TaskPriority _mapPriorityFromDomain(domain.TaskPriority priority) {
    switch (priority) {
      case domain.TaskPriority.low:
        return TaskPriority.low;
      case domain.TaskPriority.medium:
        return TaskPriority.medium;
      case domain.TaskPriority.high:
        return TaskPriority.high;
    }
  }
}

