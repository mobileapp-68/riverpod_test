# Stale Closure

Stale closures occur when a function captures variables from its surrounding scope, but those variables change after the function is created. This can lead to unexpected behavior if the function is called later and uses the updated values instead of the original ones.

This example shows that stale closures is less likely to happen in Flutter Riverpod due to the way class members are accessed directly. However, in React, stale closures can easily occur when using hooks like `useState`.

## Starter Code

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

void main() {
  runApp(
    // Wrap the entire app in ProviderScope
    ProviderScope(
      child: MyApp(),
      retry: (retryCount, error) => null,
    ),
  );
}

class TodoAsyncNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate a network delay
    return 0;
  }

  Future<void> add() async {
    state = AsyncLoading(); // Optionally set loading state
    await Future.delayed(Duration(milliseconds: 500));
    final int currentCount = state.value ?? 0;
    state = AsyncData(currentCount + 1);
  }

  Future<void> periodicAdd() async {}
}

final todoAsyncNotifierProvider = AsyncNotifierProvider(TodoAsyncNotifier.new);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Counter (Async Mutable)")),
        body: TodoDisplayHandler(),
      ),
    );
  }
}

class TodoDisplayHandler extends ConsumerWidget {
  const TodoDisplayHandler({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(todoAsyncNotifierProvider);
    return count.when(
      data: (data) => CountDisplay(count: data),
      error: (error, stackTrace) => ErrorDisplay(error: error),
      loading: () => LoadingDisplay(),
    );
  }
}

class CountDisplay extends ConsumerWidget {
  const CountDisplay({super.key, required this.count});

  final int count;

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
                  ref.read(todoAsyncNotifierProvider.notifier).add();
                },
                child: Text("Add"),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(todoAsyncNotifierProvider.notifier).periodicAdd();
                },
                child: Text("Periodic Add"),
              ),
            ],
          ),
          Text(
            "Count: $count",
            style: TextStyle(fontSize: 24),
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

## 1. `periodicAdd` Method (Flutter)

```dart
Future<void> periodicAdd() async {
    while (true) {
        await Future.delayed(Duration(seconds: 1));
        print("Before add: ${state.value}");
        state = AsyncData(state.value! + 1);
        print("After add: ${state.value}");
        if (state.value! >= 10) {
        break;
        }
    }
}
```

This works correctly because we access `state.value` directly within the loop, ensuring we always get the latest value.

## 2. Try similar logic in React.

```ts
import { useState } from "react";

function App() {
  const [count, setCount] = useState(0);
  async function periodicAdd() {
    while (true) {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      console.log(`Before: Count: ${count}`);
      setCount((c) => c + 1);
      console.log(`After: Count: ${count}`);
      if (count >= 10) {
        break;
      }
    }
  }

  return (
    <>
      <h1>Count: {count}</h1>
      <div style={{ display: "flex", gap: "8px" }}>
        <button onClick={() => setCount(count + 1)}>Add</button>
        <button onClick={periodicAdd}>Periodic Add</button>
      </div>
    </>
  );
}

export default App;
```

You will notice that the count does not increment as expected in the periodicAdd function due to stale closure.

## 3. Fix the stale closure issue in React

Import `useRef` and create a ref to hold the latest count value.

```ts
import { useState, useRef } from "react";
```

Initialize the ref with the current count.

```ts
const countRef = useRef(count);
```

Modify the state update function to also update the ref.

```ts
async function periodicAdd() {
  while (true) {
    await new Promise((resolve) => setTimeout(resolve, 1000));
    console.log(`Before: Count: ${countRef.current}`);
    setCount((c) => c + 1);
    countRef.current += 1;
    console.log(`After: Count: ${countRef.current}`);
    if (countRef.current >= 10) {
      break;
    }
  }
}
```

### 4. Final thoughts

In flutter, the use of class members allows direct access to the latest state, avoiding stale closures.
In React, the hook system requires careful management of state and closures to ensure the latest values are used.
