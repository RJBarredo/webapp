import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  List<Map<String, dynamic>> tasks = [];
  String selectedDay = "Today";

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString('planner_tasks');
    if (jsonData != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(json.decode(jsonData));
      });
    }
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('planner_tasks', json.encode(tasks));
  }

  void addTask() {
    TextEditingController controller = TextEditingController();
    TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller, decoration: const InputDecoration(labelText: "Task")),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: "Time (e.g. 3:00 PM)")),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  tasks.add({
                    "day": selectedDay,
                    "task": controller.text,
                    "time": timeController.text,
                    "done": false
                  });
                });
                saveTasks();
                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ],
        );
      },
    );
  }

  void editTask(int index) {
    final item = tasks[index];
    TextEditingController controller = TextEditingController(text: item["task"]);
    TextEditingController timeController = TextEditingController(text: item["time"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: controller, decoration: const InputDecoration(labelText: "Task")),
              TextField(controller: timeController, decoration: const InputDecoration(labelText: "Time")),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  tasks[index]["task"] = controller.text;
                  tasks[index]["time"] = timeController.text;
                });
                saveTasks();
                Navigator.pop(context);
              },
              child: const Text("Save"),
            )
          ],
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = tasks.where((t) => t["day"] == selectedDay).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Plan Your Days Ahead"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),

          // Day Selector
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                dayButton("Today"),
                dayButton("Tomorrow"),
                dayButton("Monday"),
                dayButton("Tuesday"),
                dayButton("Wednesday"),
                dayButton("Thursday"),
                dayButton("Friday"),
                dayButton("Saturday"),
                dayButton("Sunday"),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No tasks yet"))
                : ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];

                return ListTile(
                  leading: Checkbox(
                    value: item["done"],
                    onChanged: (value) {
                      setState(() {
                        int realIndex = tasks.indexOf(item);
                        tasks[realIndex]["done"] = value!;
                      });
                      saveTasks();
                    },
                  ),
                  title: Text(
                    item["task"],
                    style: TextStyle(
                      decoration: item["done"] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(item["time"]),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: const Text("Edit"),
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              int realIndex = tasks.indexOf(item);
                              editTask(realIndex);
                            });
                          },
                        ),
                        PopupMenuItem(
                          child: const Text("Delete"),
                          onTap: () {
                            Future.delayed(const Duration(milliseconds: 100), () {
                              int realIndex = tasks.indexOf(item);
                              deleteTask(realIndex);
                            });
                          },
                        ),
                      ];
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget dayButton(String day) {
    final selected = day == selectedDay;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(day),
        selected: selected,
        onSelected: (_) {
          setState(() => selectedDay = day);
        },
      ),
    );
  }
}
