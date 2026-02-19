import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/data/datasources/task_local_data_source.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/repositories/task_repository_impl.dart';
import 'package:task_manager/domain/repositories/task_repository.dart';
import 'package:task_manager/presentation/screens/task_list_screen.dart';
import 'package:task_manager/presentation/state/task_provider.dart';

final _notifications = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive
    ..registerAdapter(TaskPriorityAdapter())
    ..registerAdapter(TaskModelAdapter());

  final taskBox = await Hive.openBox<TaskModel>('tasks_box');

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );
  await _notifications.initialize(initializationSettings);

  final localDataSource = TaskLocalDataSourceImpl(taskBox);
  final repository = TaskRepositoryImpl(localDataSource);

  runApp(TaskManagerApp(repository: repository));
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key, required this.repository});

  final TaskRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(repository),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const TaskListScreen(),
      ),
    );
  }
}

