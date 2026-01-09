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
