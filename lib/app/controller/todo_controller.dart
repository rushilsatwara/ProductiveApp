import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/utils/notification.dart';
import 'package:zest/main.dart';

// Controller to manage tasks and todos using GetX state management
class TodoController extends GetxController {
  // List of all tasks stored in the app (observable)
  final tasks = <Tasks>[].obs;

  // List of all todos stored in the app (observable)
  final todos = <Todos>[].obs;

  // List of selected tasks when multi-selection is enabled (observable)
  final selectedTask = <Tasks>[].obs;

  // Boolean to check if multiple task selection mode is active (observable)
  final isMultiSelectionTask = false.obs;

  // List of selected todos when multi-selection is enabled (observable)
  final selectedTodo = <Todos>[].obs;

  // Boolean to check if multiple todo selection mode is active (observable)
  final isMultiSelectionTodo = false.obs;

  // Boolean to determine if a popup should be closed (observable)
  RxBool isPop = true.obs;

  // Animation duration (500ms) for smooth UI transitions
  final duration = const Duration(milliseconds: 500);

  // Stores the current date and time when the controller is initialized
  var now = DateTime.now();

  // Lifecycle method: Called when the controller is first created
  @override
  void onInit() {
    super.onInit();
    tasks.assignAll(isar.tasks.where().findAllSync());
    todos.assignAll(isar.todos.where().findAllSync());
  }

  // Function to add a new task to the database
  Future<void> addTask(String title, String desc, Color myColor) async {
    // Step 1: Search for an existing task with the same title
    List<Tasks> searchTask;
    searchTask = isar.tasks.filter().titleEqualTo(title).findAllSync();

    // Step 2: Create a new task object
    final taskCreate = Tasks(
      title: title, // Task title
      description: desc, // Task description
      taskColor: myColor.value, // Convert color to an integer value for storage
    );

    // Step 3: Check if a task with the same title already exists
    if (searchTask.isEmpty) {
      // If no duplicate task exists, add it to the list and database
      tasks.add(taskCreate);

      // Write to the database inside a transaction (for safety)
      isar.writeTxnSync(() => isar.tasks.putSync(taskCreate));

      // Show a success message using EasyLoading (UI feedback)
      EasyLoading.showSuccess('createCategory'.tr, duration: duration);
    } else {
      // If a task with the same title exists, show an error message
      EasyLoading.showError('duplicateCategory'.tr, duration: duration);
    }
  }

  // Function to update an existing task in the database
  Future<void> updateTask(
    Tasks task, // Task to be updated
    String title, // New title
    String desc, // New description
    Color myColor, // New color
  ) async {
    // Step 1: Update the task inside a database transaction
    isar.writeTxnSync(() {
      task.title = title; // Update title
      task.description = desc; // Update description
      task.taskColor = myColor.value; // Update color
      isar.tasks.putSync(task); // Save updated task to database
    });

    // Step 2: Replace the old task with the updated task in the list
    var newTask = task; // Store updated task
    int oldIdx = tasks.indexOf(task); // Find index of old task
    tasks[oldIdx] = newTask; // Replace old task with updated task

    // Step 3: Refresh task and todo lists to reflect changes in UI
    tasks.refresh();
    todos.refresh();

    // Step 4: Show success message to user
    EasyLoading.showSuccess('editCategory'.tr, duration: duration);
  }

  // Function to delete a list of tasks from the database
  Future<void> deleteTask(List<Tasks> taskList) async {
    // Step 1: Create a copy of the task list to avoid modifying the original list during iteration
    List<Tasks> taskListCopy = List.from(taskList);

    // Step 2: Iterate through each task in the copied list
    for (var task in taskListCopy) {
      // Step 3: Find all todos (sub-tasks) related to the current task
      List<Todos> getTodo;
      getTodo =
          isar.todos
              .filter()
              .task(
                (q) => q.idEqualTo(task.id),
              ) // Filter todos that belong to this task
              .findAllSync(); // Get them synchronously

      // Step 4: Iterate through all found todos to check for active notifications
      for (var todo in getTodo) {
        // Step 5: Check if the todo has a completion time
        if (todo.todoCompletedTime != null) {
          // Step 6: If the completion time is in the future, cancel the notification
          if (todo.todoCompletedTime!.isAfter(now)) {
            await flutterLocalNotificationsPlugin.cancel(todo.id);
          }
        }
      }

      // Delete Todos
      todos.removeWhere((todo) => todo.task.value?.id == task.id);
      isar.writeTxnSync(
        () =>
            isar.todos
                .filter()
                .task((q) => q.idEqualTo(task.id))
                .deleteAllSync(),
      );

      // Delete Task
      tasks.remove(task);
      isar.writeTxnSync(() => isar.tasks.deleteSync(task.id));
      EasyLoading.showSuccess('categoryDelete'.tr, duration: duration);
    }
  }

  Future<void> archiveTask(List<Tasks> taskList) async {
    List<Tasks> taskListCopy = List.from(taskList);

    for (var task in taskListCopy) {
      // Delete Notification
      List<Todos> getTodo;
      getTodo =
          isar.todos.filter().task((q) => q.idEqualTo(task.id)).findAllSync();

      for (var todo in getTodo) {
        if (todo.todoCompletedTime != null) {
          if (todo.todoCompletedTime!.isAfter(now)) {
            await flutterLocalNotificationsPlugin.cancel(todo.id);
          }
        }
      }
      // Archive Task
      isar.writeTxnSync(() {
        task.archive = true;
        isar.tasks.putSync(task);
      });
      tasks.refresh();
      todos.refresh();
      EasyLoading.showSuccess('categoryArchive'.tr, duration: duration);
    }
  }

  Future<void> noArchiveTask(List<Tasks> taskList) async {
    List<Tasks> taskListCopy = List.from(taskList);

    for (var task in taskListCopy) {
      // Create Notification
      List<Todos> getTodo;
      getTodo =
          isar.todos.filter().task((q) => q.idEqualTo(task.id)).findAllSync();

      for (var todo in getTodo) {
        if (todo.todoCompletedTime != null) {
          if (todo.todoCompletedTime!.isAfter(now)) {
            NotificationShow().showNotification(
              todo.id,
              todo.name,
              todo.description,
              todo.todoCompletedTime,
            );
          }
        }
      }
      // No archive Task
      isar.writeTxnSync(() {
        task.archive = false;
        isar.tasks.putSync(task);
      });
      tasks.refresh();
      todos.refresh();
      EasyLoading.showSuccess('noCategoryArchive'.tr, duration: duration);
    }
  }

  // Todos
  Future<void> addTodo(
    Tasks task,
    String title,
    String desc,
    String time,
    bool pined,
    Priority priority,
    List<String> tags,
  ) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date =
          timeformat == '12'
              ? DateFormat.yMMMEd(locale.languageCode).add_jm().parse(time)
              : DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }
    List<Todos> getTodos;
    getTodos =
        isar.todos
            .filter()
            .nameEqualTo(title)
            .task((q) => q.idEqualTo(task.id))
            .todoCompletedTimeEqualTo(date)
            .findAllSync();

    final todosCreate = Todos(
      name: title,
      description: desc,
      todoCompletedTime: date,
      fix: pined,
      createdTime: DateTime.now(),
      priority: priority,
      tags: tags,
    )..task.value = task;

    if (getTodos.isEmpty) {
      todos.add(todosCreate);
      isar.writeTxnSync(() {
        isar.todos.putSync(todosCreate);
        todosCreate.task.saveSync();
      });
      if (date != null && now.isBefore(date)) {
        NotificationShow().showNotification(
          todosCreate.id,
          todosCreate.name,
          todosCreate.description,
          date,
        );
      }
      EasyLoading.showSuccess('todoCreate'.tr, duration: duration);
    } else {
      EasyLoading.showError('duplicateTodo'.tr, duration: duration);
    }
  }

  Future<void> updateTodoCheck(Todos todo) async {
    isar.writeTxnSync(() => isar.todos.putSync(todo));
    todos.refresh();
  }

  Future<void> updateTodo(
    Todos todo,
    Tasks task,
    String title,
    String desc,
    String time,
    bool pined,
    Priority priority,
    List<String> tags,
  ) async {
    DateTime? date;
    if (time.isNotEmpty) {
      date =
          timeformat == '12'
              ? DateFormat.yMMMEd(locale.languageCode).add_jm().parse(time)
              : DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
    }
    isar.writeTxnSync(() {
      todo.name = title;
      todo.description = desc;
      todo.todoCompletedTime = date;
      todo.fix = pined;
      todo.priority = priority;
      todo.tags = tags;
      todo.task.value = task;
      isar.todos.putSync(todo);
      todo.task.saveSync();
    });

    var newTodo = todo;
    int oldIdx = todos.indexOf(todo);
    todos[oldIdx] = newTodo;
    todos.refresh();

    if (date != null && now.isBefore(date)) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
      NotificationShow().showNotification(
        todo.id,
        todo.name,
        todo.description,
        date,
      );
    } else {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  Future<void> transferTodos(List<Todos> todoList, Tasks task) async {
    List<Todos> todoListCopy = List.from(todoList);

    for (var todo in todoListCopy) {
      isar.writeTxnSync(() {
        todo.task.value = task;
        isar.todos.putSync(todo);
        todo.task.saveSync();
      });

      var newTodo = todo;
      int oldIdx = todos.indexOf(todo);
      todos[oldIdx] = newTodo;
    }

    todos.refresh();
    tasks.refresh();

    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  Future<void> deleteTodo(List<Todos> todoList) async {
    List<Todos> todoListCopy = List.from(todoList);

    for (var todo in todoListCopy) {
      if (todo.todoCompletedTime != null) {
        if (todo.todoCompletedTime!.isAfter(now)) {
          await flutterLocalNotificationsPlugin.cancel(todo.id);
        }
      }
      todos.remove(todo);
      isar.writeTxnSync(() => isar.todos.deleteSync(todo.id));
      EasyLoading.showSuccess('todoDelete'.tr, duration: duration);
    }
  }

  int createdAllTodos() {
    return todos.where((todo) => todo.task.value?.archive == false).length;
  }

  int completedAllTodos() {
    return todos
        .where((todo) => todo.task.value?.archive == false && todo.done == true)
        .length;
  }

  int createdAllTodosTask(Tasks task) {
    return todos.where((todo) => todo.task.value?.id == task.id).length;
  }

  int completedAllTodosTask(Tasks task) {
    return todos
        .where((todo) => todo.task.value?.id == task.id && todo.done == true)
        .length;
  }

  int countTotalTodosCalendar(DateTime date) {
    return todos
        .where(
          (todo) =>
              todo.done == false &&
              todo.todoCompletedTime != null &&
              todo.task.value?.archive == false &&
              DateTime(
                date.year,
                date.month,
                date.day,
                0,
                -1,
              ).isBefore(todo.todoCompletedTime!) &&
              DateTime(
                date.year,
                date.month,
                date.day,
                23,
                60,
              ).isAfter(todo.todoCompletedTime!),
        )
        .length;
  }

  void doMultiSelectionTask(Tasks tasks) {
    if (isMultiSelectionTask.isTrue) {
      isPop.value = false;
      if (selectedTask.contains(tasks)) {
        selectedTask.remove(tasks);
      } else {
        selectedTask.add(tasks);
      }

      if (selectedTask.isEmpty) {
        isMultiSelectionTask.value = false;
        isPop.value = true;
      }
    }
  }

  void doMultiSelectionTaskClear() {
    selectedTask.clear();
    isMultiSelectionTask.value = false;
    isPop.value = true;
  }

  void doMultiSelectionTodo(Todos todos) {
    if (isMultiSelectionTodo.isTrue) {
      isPop.value = false;
      if (selectedTodo.contains(todos)) {
        selectedTodo.remove(todos);
      } else {
        selectedTodo.add(todos);
      }

      if (selectedTodo.isEmpty) {
        isMultiSelectionTodo.value = false;
        isPop.value = true;
      }
    }
  }

  void doMultiSelectionTodoClear() {
    selectedTodo.clear();
    isMultiSelectionTodo.value = false;
    isPop.value = true;
  }
}
