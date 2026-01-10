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

  Future<void> periodicAdd() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      print("Before add: ${state.value}");
      final int currentCount = state.value ?? 0;
      state = AsyncData(currentCount + 1);
      print("After add: ${state.value}");
      if (state.value! >= 10) {
        break;
      }
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
