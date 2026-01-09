import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

void main() {
  runApp(
    // Wrap the entire app in ProviderScope
    ProviderScope(
      child: const MyApp(),
      retry: (retryCount, error) => null,
    ),
  );
}

final todoFutureProvider = FutureProvider<List<TodoData>>(
  (ref) async {
    await Future.delayed(Duration(seconds: 1));

    double rand = Random().nextDouble();
    // Simulate a success or failure based on random value
    if (rand > 1) {
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

// A simple data class to represent a Todo item.
class TodoData {
  int id;
  final String title;

  TodoData({
    required this.id,
    required this.title,
  });
}

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
    final todos = ref.watch(todoFutureProvider);
    return todos.when(
      data: (data) => TodoDisplay(todos: data),
      error: (error, stackTrace) => ErrorDisplay(error: error),
      loading: () => LoadingDisplay(),
    );
  }
}

class TodoDisplay extends StatelessWidget {
  const TodoDisplay({super.key, required this.todos});

  final List<TodoData> todos;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: .start,
        crossAxisAlignment: .start,
        spacing: 10,
        children: todos
            .map(
              (todo) => Row(
                mainAxisSize: .min,
                spacing: 10,
                children: [
                  Text(todo.title),
                ],
              ),
            )
            .toList(),
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
