import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager/domain/entities/task.dart';
import 'package:task_manager/presentation/screens/edit_task_screen.dart';
import 'package:task_manager/presentation/state/task_provider.dart';
import 'package:task_manager/presentation/widgets/priority_chip.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  Future<void> openAddTask() async {
    final created = await Navigator.of(
      context,
    ).push<Task>(MaterialPageRoute(builder: (_) => const EditTaskScreen()));
    if (created != null) {
      await context.read<TaskProvider>().addTask(
        title: created.title,
        description: created.description,
        dueDate: created.dueDate,
        priority: created.priority,
      );
    }
  }

  Future<void> openEditTask(Task task) async {
    final updated = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => EditTaskScreen(initial: task)),
    );
    if (updated != null) {
      await context.read<TaskProvider>().updateTask(
        task.copyWith(
          title: updated.title,
          description: updated.description,
          dueDate: updated.dueDate,
          priority: updated.priority,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final tasks = provider.tasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks'),
            actions: [
              IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: TaskSearchDelegate(provider),
                  );
                },
                icon: const Icon(Icons.search),
              ),
              PopupMenuButton<TaskSort>(
                initialValue: provider.sort,
                onSelected: provider.setSort,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: TaskSort.none,
                    child: Text('No sorting'),
                  ),
                  PopupMenuItem(
                    value: TaskSort.priority,
                    child: Text('Sort by priority'),
                  ),
                  PopupMenuItem(
                    value: TaskSort.dueDate,
                    child: Text('Sort by due date'),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SegmentedButton<TaskFilter>(
                      segments: const [
                        ButtonSegment(
                          value: TaskFilter.all,
                          label: Text('All'),
                          icon: Icon(Icons.list),
                        ),
                        ButtonSegment(
                          value: TaskFilter.pending,
                          label: Text('Pending'),
                          icon: Icon(Icons.radio_button_unchecked),
                        ),
                        ButtonSegment(
                          value: TaskFilter.completed,
                          label: Text('Done'),
                          icon: Icon(Icons.check_circle),
                        ),
                      ],
                      selected: {provider.filter},
                      onSelectionChanged: (value) {
                        provider.setFilter(value.first);
                      },
                    ),
                    if (provider.isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.loadTasks,
                  child: Builder(
                    builder: (context) {
                      if (provider.error != null) {
                        return ListView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    provider.error!,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: provider.loadTasks,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      if (!provider.isLoading && tasks.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 72,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tasks yet',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap the + button to create your first task.',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                        itemCount: tasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 4),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Dismissible(
                            key: ValueKey(task.id),
                            background: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 24),
                              child: Icon(
                                Icons.delete,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            secondaryBackground: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              child: Icon(
                                Icons.delete,
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              final removed = await context
                                  .read<TaskProvider>()
                                  .deleteTask(task.id);
                              if (!context.mounted || removed == null) {
                                return false;
                              }
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Task "${task.title}" deleted'),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () async {
                                      await context
                                          .read<TaskProvider>()
                                          .addTask(
                                            title: removed.title,
                                            description: removed.description,
                                            dueDate: removed.dueDate,
                                            priority: removed.priority,
                                          );
                                    },
                                  ),
                                ),
                              );
                              return true;
                            },
                            child: TaskTile(
                              task: task,
                              onToggle: () => context
                                  .read<TaskProvider>()
                                  .toggleCompleted(task),
                              onTap: () => openEditTask(task),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: openAddTask,
            icon: const Icon(Icons.add),
            label: const Text('New task'),
          ),
        );
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, 
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 1,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: task.isCompleted
                    ? theme.colorScheme.outlineVariant
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Checkbox(value: task.isCompleted, onChanged: (_) => onToggle()),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? theme.colorScheme.outline
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PriorityChip(priority: task.priority),
                        ],
                      ),
                      if (task.description != null &&
                          task.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, right: 8),
                          child: Text(
                            task.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (task.dueDate != null)
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 14,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  MaterialLocalizations.of(
                                    context,
                                  ).formatMediumDate(task.dueDate!),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          Text(
                            task.isCompleted ? 'Completed' : 'Pending',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: task.isCompleted
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskSearchDelegate extends SearchDelegate<void> {
  TaskSearchDelegate(this.provider);

  final TaskProvider provider;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () {
            query = '';
            provider.setSearchQuery('');
          },
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        provider.setSearchQuery('');
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    provider.setSearchQuery(query);
    final tasks = provider.tasks;

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: task.description != null
              ? Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    provider.setSearchQuery(query);
    final tasks = provider.tasks;

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          onTap: () {
            query = task.title;
            showResults(context);
          },
        );
      },
    );
  }
}
