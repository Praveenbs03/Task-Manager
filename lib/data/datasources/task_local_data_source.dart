import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_manager/data/models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getTasks();
  Future<void> upsertTask(TaskModel task);
  Future<void> deleteTask(String id);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(this.box);

  final Box<TaskModel> box;

  @override
  Future<List<TaskModel>> getTasks() async {
    return box.values.toList(growable: false);
  }

  @override
  Future<void> upsertTask(TaskModel task) async {
    await box.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await box.delete(id);
  }
}

