import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tournament Dashboard"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLargeScreen
            ? Row(
          children: [
            Expanded(child: buildPanel(
              title: "Live Matches",
              content: "⚽ Team A vs Team B\nScore: 2 - 1",
              color: Colors.lightBlueAccent,
            )),
            const SizedBox(width: 16),
            Expanded(child: buildPanel(
              title: "Top Player Stats",
              content: "🏏 Player: Rahul\nRuns: 85\nWickets: 2",
              color: Colors.greenAccent,
            )),
          ],
        )
            : Column(
          children: [
            Expanded(child: buildPanel(
              title: "Live Matches",
              content: "⚽ Team A vs Team B\nScore: 2 - 1",
              color: Colors.lightBlueAccent,
            )),
            const SizedBox(height: 16),
            Expanded(child: buildPanel(
              title: "Top Player Stats",
              content: "🏏 Player: Rahul\nRuns: 85\nWickets: 2",
              color: Colors.greenAccent,
            )),
          ],
        ),
      ),
    );
  }

  Widget buildPanel({
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}