import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_sqlite/models/task.dart';
import 'package:todo_sqlite/services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final databaseService = DatabaseService.instance;
  bool multiSelection = false;
  List<int> selectedIds = [];
  String? _task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("To Do List"),
        actions: [
          multiSelection
              ? IconButton(
                  onPressed: () {
                    if (selectedIds.isNotEmpty) {
                      for (int i = 0; i < selectedIds.length; i++) {
                        databaseService.deleteTask(selectedIds[i]);
                        multiSelection = false;
                        setState(() {});
                      }
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red))
              : const SizedBox(),
          IconButton(
              onPressed: () {
                multiSelection = !multiSelection;
                if (!multiSelection) selectedIds.clear();
                setState(() {});
              },
              icon: const Icon(Icons.done_all)),
        ],
      ),
      body: FutureBuilder(
        future: databaseService.getTasks(),
        builder: (context, snapshot) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: () {
                    if (multiSelection) {
                      if (selectedIds.contains(task.id)) {
                        selectedIds.remove(task.id);
                      } else {
                        selectedIds.add(task.id);
                      }
                      setState(() {});
                    }
                  },
                  onLongPress: () {
                    if (!multiSelection) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: ElevatedButton(
                              onPressed: () {
                                databaseService.deleteTask(task.id);
                                setState(() {});
                                Navigator.pop(context);
                              },
                              child: const Text("Delete")),
                        ),
                      );
                    }
                  },
                  title: Text(task.content),
                  leading: multiSelection
                      ? Checkbox(
                          shape: const CircleBorder(),
                          value: selectedIds.contains(task.id),
                          onChanged: (value) {
                            if (selectedIds.contains(task.id)) {
                              selectedIds.remove(task.id);
                            } else {
                              selectedIds.add(task.id);
                            }
                            setState(() {});
                          },
                        )
                      : null,
                  trailing: !multiSelection
                      ? Checkbox(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          value: task.status == 1,
                          onChanged: (value) {
                            databaseService.updateTaskStatus(task.id, value == true ? 1 : 0);
                            setState(() {});
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: !multiSelection
          ? FloatingActionButton(
              onPressed: () {
                showAddTaskDialog(context);
              },
              child: const Icon(CupertinoIcons.add_circled),
            )
          : null,
    );
  }

  Future<dynamic> showAddTaskDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enter your task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  hintText: "Enter Task.."),
              onChanged: (value) {
                _task = value;
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_task == null || _task == "") return;
                  databaseService.addTask(_task!);
                  _task = null;
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text("Add Task"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
