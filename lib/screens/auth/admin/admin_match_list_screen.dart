import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'admin_match_control_screen.dart';

class AdminMatchListScreen extends StatefulWidget {
  final String tournamentId;

  const AdminMatchListScreen({
    super.key,
    required this.tournamentId,
  });

  @override
  State<AdminMatchListScreen> createState() =>
      _AdminMatchListScreenState();
}

class _AdminMatchListScreenState
    extends State<AdminMatchListScreen> {
  List matches = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    final res = await http.get(
      Uri.parse(
        "http://localhost:8080/tournaments/${widget.tournamentId}/matches",
      ),
    );

    final data = jsonDecode(res.body);

    setState(() {
      matches = data;
      loading = false;
    });
  }

  void openMatch(Map match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AdminMatchControlScreen(match: match),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Matches"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final m = matches[index];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            child: ListTile(
              title: Text(
                  "${m["teamAName"]} vs ${m["teamBName"]}"),
              subtitle: Text("Status: ${m["status"]}"),
              trailing: ElevatedButton(
                onPressed: () => openMatch(m),
                child: Text(
                  m["status"] == "UPCOMING"
                      ? "Start"
                      : "Control",
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}