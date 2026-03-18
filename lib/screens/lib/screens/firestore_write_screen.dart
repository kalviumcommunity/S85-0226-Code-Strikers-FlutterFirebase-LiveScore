import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreWriteScreen extends StatefulWidget {
  const FirestoreWriteScreen({super.key});

  @override
  State<FirestoreWriteScreen> createState() => _FirestoreWriteScreenState();
}

class _FirestoreWriteScreenState extends State<FirestoreWriteScreen> {

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  /// ADD TASK
  Future<void> _addTask() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': title,
        'description': desc,
        'isCompleted': false,
        'createdAt': Timestamp.now(),
      });

      _titleController.clear();
      _descController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// UPDATE TASK
  Future<void> _updateTask(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(id)
          .update({
        'title': 'Updated Title',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Firestore Write"),
      ),

      body: Column(
        children: [

          /// INPUT FORM
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [

                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                  ),
                ),

                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text("Add Task"),
                ),
              ],
            ),
          ),

          const Divider(),

          /// LIST VIEW (REAL-TIME)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tasks')
                  .snapshots(),
              builder: (context, snapshot) {

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final tasks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {

                    final task = tasks[index];

                    return ListTile(
                      title: Text(task['title']),
                      subtitle: Text(task['description']),

                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _updateTask(task.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}