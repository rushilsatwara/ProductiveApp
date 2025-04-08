import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'db.g.dart';

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
