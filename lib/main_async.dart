import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire application in a "ProviderScope" widget. This is where the state of our providers will be stored.
    ProviderScope(
      child: MyApp(),
      // Customize the error handling behavior of providers in this scope.
      // Here, we specify that if a provider fails, it should not retry.
      retry: (retryCount, error) => null,
    ),
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

final todoFutureProvider = FutureProvider<List<TodoData>>(
  (ref) async {
    await Future.delayed(Duration(seconds: 1));

    double rand = Random().nextDouble();
    // Simulate a success or failure based on random value
    if (rand > 0) {
      return <TodoData>[
        TodoData(id: 0, title: 'Todo 0'),
        TodoData(id: 1, title: 'Todo 1'),
        TodoData(id: 2, title: 'Todo 2'),
      ];
    } else {
      throw Exception("Something went wrong!");
    }
  },
);

class TodoAsyncNotifier extends AsyncNotifier<List<TodoData>> {
  @override
  Future<List<TodoData>> build() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate a network delay
    return <TodoData>[
      TodoData(id: 0, title: 'Todo 0'),
      TodoData(id: 1, title: 'Todo 1'),
      TodoData(id: 2, title: 'Todo 2'),
    ];
  }

  void addTodo() async {
    state = AsyncLoading(); // Optionally set loading state
    await Future.delayed(Duration(milliseconds: 500));
    state = await AsyncValue.guard(() async {
      final List<TodoData> todos = state.value ?? [];
      int id = todos.map((todo) => todo.id).reduce(max) + 1;
      final newTodos = [...todos, TodoData(id: id, title: "Todo $id")];
      return newTodos;
    });
  }

  void removeLastTodo() async {
    state = AsyncLoading(); // Optionally set loading state
    await Future.delayed(Duration(milliseconds: 500));
    final List<TodoData> todos = state.value ?? [];
    if (todos.length > 1) {
      state = AsyncData(todos.sublist(0, todos.length - 1));
    } else {
      state = AsyncData(todos);
    }
  }
}

final todoAsyncNotifierProvider = AsyncNotifierProvider(TodoAsyncNotifier.new);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("My Todo (Async)")),
        body: TodoDisplayHandler(),
      ),
    );
  }
}

class TodoDisplayHandler extends ConsumerWidget {
  const TodoDisplayHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ? To read from the FutureProvider, we would use:
    // final todos = ref.watch(todoFutureProvider);

    // ? To read from the AsyncNotifierProvider, we use:
    final todos = ref.watch(todoAsyncNotifierProvider);

    // ? Using the when method to handle different states
    // return todos.when(
    //   data: (data) => TodoDisplay(todos: data),
    //   error: (error, stackTrace) => ErrorDisplay(error: error),
    //   loading: () => LoadingDisplay(),
    // );

    // ? Manually handling different states
    return Column(
      spacing: 10,
      children: [
        // ? Show data when available
        if (todos.hasValue)
          TodoDisplay(todos: todos.value!)
        else if (todos.hasError)
          ErrorDisplay(error: todos.error)
        else
          LoadingDisplay(),
        // ? Show loading indicator when in loading state
        if (todos.isLoading) LoadingDisplay(),
      ],
    );
  }
}

class TodoDisplay extends ConsumerWidget {
  const TodoDisplay({super.key, required this.todos});

  final List<TodoData> todos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
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
                  ref.read(todoAsyncNotifierProvider.notifier).addTodo();
                },
                child: Text("Add"),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(todoAsyncNotifierProvider.notifier).removeLastTodo();
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
    );
  }
}

class LoadingDisplay extends StatelessWidget {
  const LoadingDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: const CircularProgressIndicator());
  }
}

class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("An error occurred: ${error.toString()}"));
  }
}
