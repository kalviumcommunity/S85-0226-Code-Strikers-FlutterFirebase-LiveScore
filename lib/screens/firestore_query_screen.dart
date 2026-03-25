import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreQueryScreen extends StatelessWidget {
  const FirestoreQueryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filtered Task"),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')

        /// FILTER
            .where('isCompleted', isEqualTo: false)

        /// SORT
            .orderBy('createdAt', descending: true)

        /// LIMIT
            .limit(10)

            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Tasks Found"));
          }

          final tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {

              final task = tasks[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(task['title']),
                  subtitle: Text(
                    "Created: ${task['createdAt']?.toDate()}",
                  ),
                  trailing: Icon(
                    task['isCompleted']
                        ? Icons.check_circle
                        : Icons.pending,
                    color: task['isCompleted']
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}