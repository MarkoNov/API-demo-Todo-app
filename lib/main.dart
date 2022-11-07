import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const num = 20;

Future<List<ToDoItem>> _fetchToDoItems(int br) async {
  final toDos = <ToDoItem>[];

  for (var i = 1; i <= br; i++) {
    final response = await http
        .get(Uri.parse('https://jsonplaceholder.typicode.com/todos/$i'));

    if (response.statusCode == 200) {
      toDos.add(ToDoItem.fromJson(jsonDecode(response.body)));
    } else {
      throw Exception('HTTP error');
    }
  }
  return toDos;
}

class ToDoItem {
  final int userId;
  final int id;
  final String title;
  bool completed;

  ToDoItem({
    required this.userId,
    required this.id,
    required this.title,
    required this.completed,
  });

  factory ToDoItem.fromJson(Map<String, dynamic> json) {
    return ToDoItem(
        userId: json['userId'],
        id: json['id'],
        title: json['title'],
        completed: json['completed']);
  }
}

void main() {
  runApp(const APIDemoApp());
}

class APIDemoApp extends StatelessWidget {
  const APIDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ToDoList();
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  late Future<List<ToDoItem>> _futureToDoItems;

  @override
  void initState() {
    super.initState();
    _futureToDoItems = _fetchToDoItems(num);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'API demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text('API demo'),
            ),
            body: Center(
              child: FutureBuilder<List<ToDoItem>>(
                  future: _futureToDoItems,
                  builder: (context, snapshot) {
                    return ListView.builder(
                        itemCount: num,
                        itemBuilder: (context, i) {
                          if (snapshot.hasData) {
                            return ListTile(
                              title: Text(
                                snapshot.data![i].title,
                                style: snapshot.data![i].completed
                                    ? const TextStyle(
                                        decoration: TextDecoration.lineThrough)
                                    : null,
                              ),
                              onTap: () {
                                setState(() {
                                  snapshot.data![i].completed =
                                      !snapshot.data![i].completed;
                                });
                              },
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          return const ListTile(
                              title: Center(
                            heightFactor: 1,
                            widthFactor: 1,
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            ),
                          ));
                        });
                  }),
            )));
  }
}
