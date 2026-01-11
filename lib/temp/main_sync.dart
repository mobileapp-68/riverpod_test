import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire application in a "ProviderScope" widget. This is where the state of our providers will be stored.
    ProviderScope(child: MyApp()),
  );
}

// A simple data class to represent a Todo item.
class TodoData {
  int id;
  final String title;

  TodoData({
    required this.id,
    required this.title,
  });
}

// An immutable provider that provides a list of TodoData.
final todoProvider = Provider(
  (Ref ref) => <TodoData>[
    TodoData(id: 0, title: 'Todo 0'),
    TodoData(id: 1, title: 'Todo 1'),
    TodoData(id: 2, title: 'Todo 2'),
  ],
);

// A mutable notifier that manages a list of TodoData.
class TodoNotifier extends Notifier<List<TodoData>> {
  @override
  List<TodoData> build() {
    // Initial state
    return [
      TodoData(id: 0, title: 'Todo 0'),
      TodoData(id: 1, title: 'Todo 1'),
      TodoData(id: 2, title: 'Todo 2'),
    ];
  }

  void addTodo() {
    int id = state.map((todo) => todo.id).reduce(max) + 1;
    state = [...state, TodoData(id: id, title: "Todo $id")];
    // Note that since state is immutable, we cannot do:
    // state.add(TodoData(id: id, title: title));
  }

  void removeLastTodo() {
    if (state.length > 1) {
      state = state.sublist(0, state.length - 1);
    }
  }
}

// A mutable provider that uses the TodoNotifier to manage its state.
final todoProviderMutable = NotifierProvider<TodoNotifier, List<TodoData>>(
  // The use if `.new` is to tell Dart to create a new instance of the TodoNotifier class when needed.
  // This is a tear-off, which is a way to reference a constructor without calling it immediately.
  // If we just wrote `TodoNotifier()`, it would try to create an instance immediately, which is not what we want.
  TodoNotifier.new,
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ? We read the value exposed by the provider using ref.watch.
    // final todos = ref.watch(todoProvider);

    // ? If we wanted to read the mutable version, we would use:
    final todos = ref.watch(todoProviderMutable);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Todo List')),

        // ? Note: The below code reads from the immutable provider.
        // body: Center(
        //   child: Column(
        //     mainAxisAlignment: .start,
        //     crossAxisAlignment: .start,
        //     spacing: 10,
        //     children: todos
        //         .map(
        //           (todo) => Row(
        //             mainAxisSize: .min,
        //             spacing: 10,
        //             children: [
        //               Text(todo.title),
        //             ],
        //           ),
        //         )
        //         .toList(),
        //   ),
        // ),

        // ? Note: The below code reads from the mutable provider.
        body: Center(
          child: Column(
            mainAxisAlignment: .start,
            crossAxisAlignment: .start,
            spacing: 10,
            children: [
              Row(
                mainAxisSize: .min,
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref.read(todoProviderMutable.notifier).addTodo();
                    },
                    child: Text("Add"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(todoProviderMutable.notifier).removeLastTodo();
                    },
                    child: Text("Remove Last"),
                  ),
                ],
              ),
              ...todos.map(
                (todo) => Row(
                  mainAxisSize: .min,
                  spacing: 10,
                  children: [
                    Text("(${todo.id})"),
                    Text(todo.title),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
