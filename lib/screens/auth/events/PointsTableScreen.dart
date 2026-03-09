import 'package:flutter/material.dart';
import '../../../services/tournament_service.dart';

class PointsTableScreen extends StatefulWidget {
  final String tournamentId;

  const PointsTableScreen({super.key, required this.tournamentId});

  @override
  State<PointsTableScreen> createState() => _PointsTableScreenState();
}

class _PointsTableScreenState extends State<PointsTableScreen> {
  late Future<List<Map<String, dynamic>>> pointsFuture;

  final Color darkBg = const Color(0xFF020617);
  final Color cardBg = const Color(0xFF1E293B);
  final Color purple = const Color(0xFF8B5CF6);
  final Color cyan = const Color(0xFF22D3EE);

  @override
  void initState() {
    super.initState();
    pointsFuture = TournamentService.getPointsTable(widget.tournamentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "STANDINGS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: pointsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: cyan));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final teams = snapshot.data!;

          return Column(
            children: [
              _buildTableHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: teams.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildTeamRow(teams[index], index);
                  },
                ),
              ),
              _buildLegend(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _tableText("#", flex: 1, isHeader: true),
          _tableText("TEAM", flex: 4, isHeader: true, align: TextAlign.left),
          _tableText("P", flex: 1, isHeader: true),
          _tableText("W", flex: 1, isHeader: true),
          _tableText("L", flex: 1, isHeader: true),
          _tableText("NRR", flex: 2, isHeader: true),
          _tableText("PTS", flex: 2, isHeader: true, color: cyan),
        ],
      ),
    );
  }

  Widget _buildTeamRow(Map<String, dynamic> team, int index) {
    // Top 4 teams usually qualify, let's highlight them
    bool isQualified = index < 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: index % 2 == 0 ? Colors.transparent : Colors.white.withOpacity(0.02),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          // Rank with Qualify Indicator
          Expanded(
            flex: 1,
            child: Row(
              children: [
                if (isQualified)
                  Container(width: 3, height: 15, color: cyan.withOpacity(0.5)),
                const SizedBox(width: 4),
                Text("${index + 1}", style: const TextStyle(color: Colors.white60, fontSize: 13)),
              ],
            ),
          ),

          // Team Name & Icon
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: purple.withOpacity(0.2),
                  child: Text(team["teamName"][0], style: TextStyle(color: purple, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    team["teamName"].toString().toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Stats Columns
          _tableText("${team["played"]}", flex: 1),
          _tableText("${team["won"]}", flex: 1),
          _tableText("${team["lost"]}", flex: 1),
          _tableText("${team["nrr"] ?? "0.00"}", flex: 2, color: Colors.white70),
          _tableText("${team["points"]}", flex: 2, color: cyan, isBold: true),
        ],
      ),
    );
  }

  Widget _tableText(String text, {required int flex, bool isHeader = false, TextAlign align = TextAlign.center, Color? color, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          color: color ?? (isHeader ? Colors.white38 : Colors.white),
          fontSize: isHeader ? 10 : 13,
          fontWeight: (isBold || isHeader) ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(width: 12, height: 12, color: cyan.withOpacity(0.5)),
          const SizedBox(width: 8),
          const Text("Top 4 Qualify for Semi-Finals", style: TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard_outlined, color: purple.withOpacity(0.3), size: 60),
          const SizedBox(height: 16),
          const Text("No data available yet", style: TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }
}