# Riverpod Tutorial: Synchronous Providers (Immutable State)

# Start Code

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    // Wrap the entire app in ProviderScope
    ProviderScope(child: const MyApp()),
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

class TodoDisplayHandler extends StatelessWidget {
  TodoDisplayHandler({super.key});

  // ! Sample static todo list.  We will change this.
  final List<TodoData> todos = [
    TodoData(id: 0, title: 'Todo 0'),
    TodoData(id: 1, title: 'Todo 1'),
    TodoData(id: 2, title: 'Todo 2'),
  ];

  @override
  Widget build(BuildContext context) {
    return TodoDisplay(todos: todos);
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

```

## 2. Install and import Library

Install the Riverpod package:

```bash
flutter pub add flutter_riverpod
```

Import the Riverpod package:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```

## 3. ProviderScope

For widgets to be able to read providers, we need to wrap the entire application in a "ProviderScope" widget. This is where the state of our providers will be stored.

```dart
void main() {
  runApp(
  // Wrap the entire app in ProviderScope
    ProviderScope(
      child: MyApp(),
      retry: (retryCount, error) => null,
    ),
  );
}
```

#### Note on `retry` parameter

- The `retry` parameter in `ProviderScope` allows you to customize the error handling behavior of providers within that scope.
- By default, if a provider throws an error, Riverpod may attempt to retry fetching the value based on its internal logic.
- In this case, we specify that if a provider fails, it should not retry by returning `null`.

## 4. Creating a Provider

Import `dart:math` at the top of the file:

```
import 'package:flutter/material.dart';
```

Create a `FutureProvider` that simulates fetching data asynchronously:

```dart
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
```

- The `FutureProvider` is used to handle asynchronous data fetching.
- Change the number in the if condition to a value greater than 1 to simulate an error.
