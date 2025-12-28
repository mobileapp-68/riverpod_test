import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import 'package:riverpod_test/main_sync.dart';

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

final totoFutureProvider = FutureProvider<List<TodoData>>(
  (ref) async {
    await Future.delayed(Duration(seconds: 1));
    return <TodoData>[
      TodoData(id: 0, title: 'Todo 0'),
      TodoData(id: 1, title: 'Todo 1'),
      TodoData(id: 2, title: 'Todo 2'),
    ];
  },
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(totoFutureProvider);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("My Todo (Async)")),
        body: Column(
          children: [
            Row(
              children: [],
            ),
          ],
        ),
      ),
    );
  }
}
