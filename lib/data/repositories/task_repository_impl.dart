import 'package:task_manager/data/datasources/task_local_data_source.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl(this._localDataSource);

  final TaskLocalDataSource _localDataSource;

  @override
  Future<List<Task>> getAllTasks() async {
    final models = await _localDataSource.getTasks();
    return models.map((m) => m.toDomain()).toList(growable: false);
  }

  @override
  Future<void> saveTask(Task task) async {
    final model = TaskModel.fromDomain(task);
    await _localDataSource.upsertTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _localDataSource.deleteTask(id);
  }
}

