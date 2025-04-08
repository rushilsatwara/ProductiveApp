import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/ui/todos/widgets/todo_card.dart';
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'package:zest/app/ui/widgets/list_empty.dart';

class TodosList extends StatefulWidget {
  const TodosList({
    super.key,
    required this.done,
    this.task,
    required this.allTodos,
    required this.calendare,
    this.selectedDay,
    required this.searchTodo,
  });
  final bool done;
  final Tasks? task;
  final bool allTodos;
  final bool calendare;
  final DateTime? selectedDay;
  final String searchTodo;

  @override
  State<TodosList> createState() => _TodosListState();
}

class _TodosListState extends State<TodosList> {
  final todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Obx(() {
        RxList<Todos> todos = <Todos>[].obs;
        List<Todos> filteredList =
            widget.task != null
                ? todoController.todos
                    .where(
                      (todo) =>
                          todo.task.value?.id == widget.task?.id &&
                          todo.done == widget.done &&
                          (widget.searchTodo.isEmpty ||
                              todo.name.toLowerCase().contains(
                                widget.searchTodo,
                              )),
                    )
                    .toList()
                : widget.allTodos
                ? todoController.todos
                    .where(
                      (todo) =>
                          todo.task.value?.archive == false &&
                          todo.done == widget.done &&
                          (widget.searchTodo.isEmpty ||
                              todo.name.toLowerCase().contains(
                                widget.searchTodo,
                              )),
                    )
                    .toList()
                : widget.calendare
                ? todoController.todos
                    .where(
                      (todo) =>
                          todo.task.value?.archive == false &&
                          todo.todoCompletedTime != null &&
                          todo.todoCompletedTime!.isAfter(
                            DateTime(
                              widget.selectedDay!.year,
                              widget.selectedDay!.month,
                              widget.selectedDay!.day,
                              0,
                              0,
                            ),
                          ) &&
                          todo.todoCompletedTime!.isBefore(
                            DateTime(
                              widget.selectedDay!.year,
                              widget.selectedDay!.month,
                              widget.selectedDay!.day,
                              23,
                              59,
                              59,
                              59,
                              59,
                            ),
                          ) &&
                          todo.done == widget.done,
                    )
                    .toList()
                : todoController.todos;

        if (widget.calendare) {
          filteredList.sort(
            (a, b) => a.todoCompletedTime!.compareTo(b.todoCompletedTime!),
          );
        } else {
          filteredList.sort((a, b) {
            if (a.fix && !b.fix) {
              return -1;
            } else if (!a.fix && b.fix) {
              return 1;
            } else {
              return 0;
            }
          });
        }

        todos.value = filteredList.obs;

        return todos.isEmpty
            ? ListEmpty(
              img:
                  widget.calendare
                      ? 'assets/images/Calendar.png'
                      : 'assets/images/Todo.png',
              text: widget.done ? 'completedTodo'.tr : 'addTodo'.tr,
            )
            : ListView(
              children: [
                ...todos.map(
                  (todo) => TodoCard(
                    key: ValueKey(todo),
                    todo: todo,
                    allTodos: widget.allTodos,
                    calendare: widget.calendare,
                    onTap: () {
                      todoController.isMultiSelectionTodo.isTrue
                          ? todoController.doMultiSelectionTodo(todo)
                          : showModalBottomSheet(
                            enableDrag: false,
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return TodosAction(
                                text: 'editing'.tr,
                                edit: true,
                                todo: todo,
                                category: true,
                              );
                            },
                          );
                    },
                    onLongPress: () {
                      todoController.isMultiSelectionTodo.value = true;
                      todoController.doMultiSelectionTodo(todo);
                    },
                  ),
                ),
              ],
            );
      }),
    );
  }
}
