import 'package:flutter/material.dart';

class AdminMatchControlScreen extends StatelessWidget {
  final Map match;

  const AdminMatchControlScreen({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${match["teamAName"]} vs ${match["teamBName"]}"),
      ),
      body: Center(
        child: Text(
          "Match Control Coming Soon",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}