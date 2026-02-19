## Task Manager – Offline‑First Flutter App

A clean, offline‑first task manager built with Flutter and null‑safety.  
Users can create, edit, complete, delete, search, filter, and sort tasks, all backed by local storage so everything works fully offline.

---

## Setup Instructions

- **Prerequisites**
  - Flutter SDK (3.10+ recommended)
  - Android Studio / VS Code (optional but recommended)
  - For Windows desktop: enable **Developer Mode** (needed for plugins / symlinks)


- **Generate Hive type adapters (if you change models)**
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

- **Run the app**
  - Android / iOS (device or emulator):
    ```bash
    flutter run
    ```
  - Windows desktop:
    ```bash
    flutter run -d windows
    ```

---

## Architecture Overview

The project follows a simple **clean architecture style** with clear separation of concerns:

- **`domain/`**
  - `entities/task.dart`: core `Task` entity and `TaskPriority` enum (business model only, no Flutter/Hive imports).
  - `repositories/task_repository.dart`: abstract `TaskRepository` interface used by higher layers.

- **`data/`**
  - `models/task_model.dart`: Hive‑annotated `TaskModel` and `TaskPriority` enum used for persistence, plus mapping to/from `domain.Task`.
  - `datasources/task_local_data_source.dart`: `TaskLocalDataSource` + Hive‑based implementation that reads/writes a `tasks_box`.
  - `repositories/task_repository_impl.dart`: `TaskRepositoryImpl` that talks to the data source and returns domain entities.

- **`presentation/`**
  - `state/task_provider.dart`: `ChangeNotifier` state holder for tasks (load, add, edit, delete, toggle complete, filter, sort, search).
  - `screens/task_list_screen.dart`: main task list UI, filters, sorting, search, empty/error/loading states, swipe‑to‑delete with undo.
  - `screens/edit_task_screen.dart`: add/edit task form with validation, due date picker, and priority selection.
  - `widgets/priority_chip.dart`: reusable visual indicator for task priority.

- **`main.dart`**
  - Initializes **Hive** (via `hive_flutter`), registers adapters, opens the `tasks_box`.
  - Instantiates `TaskLocalDataSource` + `TaskRepositoryImpl` and wires them into `TaskProvider` via **Provider**.
  - Configures **Material 3** theming with **light & dark** themes and sets `TaskListScreen` as the home screen.

State management is deliberately kept simple using `ChangeNotifier` + `Provider`, which is enough for a single‑feature app while keeping all business logic out of UI widgets.

---

## Key Features

- **Task Management**
  - Create, edit, delete tasks
  - Mark tasks as completed / pending
  - Fields: `title` (required), `description`, `dueDate`, `priority` (low/medium/high), `isCompleted`

- **Offline‑First**
  - All tasks stored locally using **Hive**
  - Data persists across app restarts with no backend required

- **UI / UX**
  - Task list with priority chips and completion status
  - Filters: **All / Pending / Done**
  - Search by title and sort by **priority** or **due date**
  - Empty, loading, and error states
  - Swipe‑to‑delete with **SnackBar undo**
  - Subtle animations (tile highlighting, transitions)
  - System **dark mode** support

---

## Architectural Decisions & Trade‑offs

- **Hive for local storage**
  - **Why:** Very fast, lightweight key‑value storage that works well for offline‑first apps and simple object graphs.
  - **Trade‑offs:** Not as query‑rich as SQLite/Drift. For more complex querying or relations, Drift/SQLite might be preferable.

- **Simple Clean Architecture (domain / data / presentation)**
  - **Why:** Separates pure business logic from Flutter widgets and from persistence details, making the app easier to test and evolve.
  - **Trade‑offs:** Slightly more boilerplate (mappers, repositories) compared to putting everything directly in widgets, but it keeps the codebase scalable.

- **`ChangeNotifier` + Provider for state management**
  - **Why:** Lightweight, built‑in, and easy to understand; more than enough for a single‑screen task app.
  - **Trade‑offs:** For very large apps, more structured solutions (BLoC, Riverpod, Redux, etc.) may scale better, at the cost of extra complexity.

- **Local‑only (no remote sync)**
  - **Why:** Focuses on solid offline‑first behavior and clean local architecture without adding API or sync complexity.
  - **Trade‑offs:** No cross‑device sync or cloud backup; could be added later by implementing a remote data source and a sync layer above the existing repository.

- **Flutter Web support is best‑effort**
  - The app targets **mobile/desktop** primarily; running on web may hit framework‑level issues (e.g. some keyboard assertions).
  - Trade‑off made to optimize for a polished mobile offline experience rather than full web parity.

---

## Extending the App

Ideas for future improvements:

- Add real scheduled **local notifications** for upcoming due tasks.
- Implement remote sync (e.g. with a REST API or Firebase) while keeping Hive as an offline cache.
- Add more views (e.g. calendar view, priority‑focused views) and richer task metadata (tags, attachments, etc.).
 
## Screenshots

![Task List](images/task1.png)
![Add Task](images/task2.png)
![Edit Task](images/task3.png)

