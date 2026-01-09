# Riverpod Tutorial: Asynchronous Providers (Mutable State)

# Starter Code

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
        appBar: AppBar(title: Text("My Todo (Async Mutable)")),
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

## 4. Creating a Provider

Import `dart:math` at the top of the file:

```dart
import 'dart:math';
```

Create an `AsyncNotifier` to manage the list of todos:

```dart
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
}
```

Then create an `AsyncNotifierProvider` for the `TodoAsyncNotifier`:

```dart
final todoAsyncNotifierProvider = AsyncNotifierProvider(TodoAsyncNotifier.new);
```

#### Relationship between `AsyncNotifier` and `AsyncNotifierProvider`

- The `AsyncNotifier` is a class that contains the logic for managing the state (in this case, the list of todos).
- The `AsyncNotifierProvider` is a provider that exposes the state managed by the `AsyncNotifier` to the rest of the application.

## 5. Reading the Provider

Change TodoDisplayHandler to a ConsumerWidget

```dart
class TodoDisplayHandler extends ConsumerWidget {
  const TodoDisplayHandler({super.key});
}
```

- Note the addition of `const` constructor.

Add `ref` parameter to the build method

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {...}
```

Inside the build method, read the provider's state

```dart
final todos = ref.watch(todoAsyncNotifierProvider);
```

Change the return statement to handle loading, error, and data states

```dart
return todos.when(
    data: (data) => TodoDisplay(todos: data),
    error: (error, stackTrace) => ErrorDisplay(error: error),
    loading: () => LoadingDisplay(),
);
```

## 6. Add and Remove Functionality

Import `dart:math` at the top of the file:

```dart
import 'dart:math';
```

Add methods to the `TodoAsyncNotifier` class to add and remove todos:

```dart
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
```

```dart
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
```

#### Note

- `AsyncLoading()` is used to indicate that a loading operation is in progress.
- `AsyncValue.guard` is a utility method that helps handle exceptions and loading states when performing asynchronous operations.

Update the onPressed callbacks of the buttons in `TodoDisplay` to call the new methods:

## 7. Update Buttons

Change `TodoDisplay` to a `ConsumerWidget`:

```dart
class TodoDisplay extends ConsumerWidget {...}
```

Add `ref` parameter to the build method:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {...}
```

Add the following code to the onPressed callbacks:

```dart
ref.read(todoAsyncNotifierProvider.notifier).addTodo();
```

```dart
ref.read(todoAsyncNotifierProvider.notifier).removeLastTodo();
```

## 8. Change UI

Replace the return statement in `TodoDisplayHandler` with the following code to show loading indicator while adding/removing todos:

```dart
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
```

#### Note

- `todos.hasValue` checks if the provider has data.
- `todos.hasError` checks if the provider has encountered an error.
- `todos.isLoading` checks if the provider is currently loading data.
