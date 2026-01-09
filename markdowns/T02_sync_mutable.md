# Riverpod Tutorial: Synchronous Providers (Mutable State)

# 1. Starter Code

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
        appBar: AppBar(title: const Text('Todo List (Sync Mutable)')),
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
                    onPressed: () {},
                    child: Text("Add"),
                  ),
                  ElevatedButton(
                    onPressed: () {},
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

To create a mutable provider, we create a `Notifier` class that manages the state, and then create a `NotifierProvider` to expose it.

`Notifier` class:

```dart
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
}
```

Provider as an instance of `NotifierProvider`:

```dart
final todoProviderMutable = NotifierProvider<TodoNotifier, List<TodoData>>(
  TodoNotifier.new,
);
```

#### `.new`?

- The use of `.new` is to tell Dart to create a new instance of the TodoNotifier class when needed.
- This is a tear-off, which is a way to reference a constructor without calling it immediately.
- If we just wrote `TodoNotifier()`, it would try to create an instance immediately, which is not what we want.

#### Relationship between `Notifier` and `NotifierProvider`?

- The `Notifier` class is where we define the logic for managing our state (in this case, a list of `TodoData`).
- The `NotifierProvider` is what exposes that state to the rest of the application, allowing widgets to read and watch the state managed by the `Notifier`.

#### Where is `ref`?

- The `ref` can be used inside the `Notifier` class to read other providers or manage lifecycle events. (e.g., `ref.read(anotherProvider)`).
- In this case, we are not using `ref` in the `build` method of the `Notifier` class, but it is available if needed in more complex scenarios.

## 5. Consuming a Provider

Change `MyApp` from a `StatelessWidget` to a `ConsumerWidget` to read providers.

```dart
class MyApp extends ConsumerWidget {...}
```

Add the `ref` dependency to the `build` method:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {...}
```

Consuming the provider inside the `build` method:

```dart
final todos = ref.watch(todoProviderMutable);
```

## 6. Add functionality to modify state

Import `dart:math` at the top of the file:

```dart
import 'dart:math';
```

Add methods to the `TodoNotifier` class to add and remove todos:

```dart
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
```

Add the button functionality in `MyApp` by calling these methods in the `onPressed` callbacks:

```dart
ref.read(todoProviderMutable.notifier).addTodo();
```

```dart
ref.read(todoProviderMutable.notifier).removeLastTodo();
```

# 7. Change the constructor

Change the constructor of `MyApp` to be constant:

```dart
const MyApp({super.key});
```

Update the `main` function to use a constant constructor for `MyApp`:

```dart
ProviderScope(child: const MyApp()),
```

This is because `ConsumerWidget` can be a constant widget since it does not hold any mutable state itself. The state is managed by the provider, not the widget itself.
