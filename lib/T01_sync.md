# Riverpod Tutorial: Synchronous Providers (Immutable State)

## 1. Starter Code

This is the starter code for this tutorial:

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
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
  MyApp({super.key});

  // ! Sample static todo list.  We will change this.
  final List<TodoData> todos = [
    TodoData(id: 0, title: 'Todo 0'),
    TodoData(id: 1, title: 'Todo 1'),
    TodoData(id: 2, title: 'Todo 2'),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Todo List')),
        body: Center(
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
        ),
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
    ProviderScope(child: MyApp()),
  );
}
```

## 4. Creating a Provider

```dart
// An immutable provider that provides a list of TodoData.
final todoProvider = Provider(
  (Ref ref) => <TodoData>[
    TodoData(id: 0, title: 'Todo 0'),
    TodoData(id: 1, title: 'Todo 1'),
    TodoData(id: 2, title: 'Todo 2'),
  ],
);
```

What is `ref`?

- The `ref` parameter is an instance of the `Ref` class provided by Riverpod.
- It allows you to interact with other providers, read their values, and manage the lifecycle of the provider you are defining.
- In this case, we are not using `ref` to read other providers, but it is available if needed in more complex scenarios.

## 5. Consuming a Provider

Change `MyApp` from a `StatelessWidget` to a `ConsumerWidget` to read providers.

```dart
// Modify MyApp to be a ConsumerWidget to read providers
class MyApp extends ConsumerWidget {...}
```

Add the `ref` dependency to the `build` method:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
...
}
```

What is a `ConsumerWidget`?

- A `ConsumerWidget` is a special type of widget provided by Riverpod that allows you to easily read and watch providers.

Consuming the provider inside the `build` method:

```dart
// ? We read the value exposed by the provider using ref.watch.
final todos = ref.watch(todoProvider);
```

## Update the constructor

Change the constructor of `MyApp` to be constant:

```dart
const MyApp({super.key});
```

Update the `main` function to use a constant constructor for `MyApp`:

```dart
ProviderScope(child: const MyApp()),
```
