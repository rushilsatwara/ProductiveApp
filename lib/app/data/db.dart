import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'db.g.dart';

// ### **Database Setup & Collections**
// 1. **Uses Isar Database:**
//    - `import 'package:isar/isar.dart';` for database operations.
//    - `part 'db.g.dart';` is for Isar-generated code.

// 2. **Settings Collection (`@collection class Settings`)**
//    - Stores user preferences like theme, time format, language, default screen, etc.
//    - `onboard` (bool) determines if onboarding is completed.
//    - `defaultScreen` (String) sets the initial screen (default: 'categories').

// 3. **Tasks Collection (`@collection class Tasks`)**
//    - Represents a task with:
//      - `title` (String) and `description` (String).
//      - `taskColor` (int) for color coding.
//      - `archive` (bool) to mark as archived.
//      - `index` (int?) for ordering.
//    - **Relationship:**
//      - `todos` (IsarLinks<Todos>) → Links multiple `Todos` to a `Task`.

// 4. **Todos Collection (`@collection class Todos`)**
//    - Represents individual to-dos with:
//      - `name`, `description`, `createdTime`, `done` (completion status).
//      - `todoCompletionTime`, `todoCompletedTime` (DateTime).
//      - `fix` (bool) → Indicates pinned tasks.
//      - `priority` (enum) → Sets priority (high, medium, low, none).
//      - `tags` (List<String>) → Labels for categorization.
//    - **Relationship:**
//      - `task` (IsarLink<Tasks>) → Links a `Todo` to a parent `Task`.

// 5. **Priority Enum (`enum Priority`)**
//    - Defines task priority levels:
//      - **High (Red), Medium (Orange), Low (Green), None**.
//    - Each priority has a `name` and optional `color`.

@collection
class Settings {
  Id id = Isar.autoIncrement;
  bool onboard = false;
  String? theme = 'system';
  String timeformat = '24';
  bool materialColor = true;
  bool amoledTheme = false;
  bool? isImage = true;
  String? language;
  String firstDay = 'monday';
  String calendarFormat = 'week';
  String defaultScreen = 'categories';
}

@collection
class Tasks {
  Id id;
  String title;
  String description;
  int taskColor;
  bool archive;
  int? index;

  @Backlink(to: 'task')
  final todos = IsarLinks<Todos>();

  Tasks({
    this.id = Isar.autoIncrement,
    required this.title,
    this.description = '',
    this.archive = false,
    required this.taskColor,
    this.index,
  });
}

@collection
class Todos {
  Id id;
  String name;
  String description;
  DateTime? todoCompletedTime;
  DateTime createdTime;
  DateTime? todoCompletionTime;
  bool done;
  bool fix;
  @enumerated
  Priority priority;
  List<String> tags = [];
  int? index;

  final task = IsarLink<Tasks>();

  Todos({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description = '',
    this.todoCompletedTime,
    this.todoCompletionTime,
    required this.createdTime,
    this.done = false,
    this.fix = false,
    this.priority = Priority.none,
    this.tags = const [],
    this.index,
  });
}

enum Priority {
  high(name: 'highPriority', color: Colors.red),
  medium(name: 'mediumPriority', color: Colors.orange),
  low(name: 'lowPriority', color: Colors.green),
  none(name: 'noPriority');

  const Priority({required this.name, this.color});

  final String name;
  final Color? color;
}
