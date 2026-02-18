import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tournament Hub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
      ),
      home: const TournamentDashboard(),
    );
  }
}

class TournamentDashboard extends StatelessWidget {
  const TournamentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🏆 Tournament Hub', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Live"),
              Tab(text: "Upcoming"),
              Tab(text: "Finished"),
            ],
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          ],
        ),
        body: TabBarView(
          children: [
            _buildLiveList(),
            _buildUpcomingList(),
            const Center(child: Text("Past Tournaments")),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text("Host Tournament"),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildLiveList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _sectionHeader("Featured Match"),
        const LiveMatchCard(
          tournament: "Champions Trophy",
          teamA: "Warriors",
          teamB: "Titans",
          scoreA: "145/2",
          scoreB: "Yet to Bat",
          overs: "15.2",
        ),
        const SizedBox(height: 16),
        _sectionHeader("Active Tournaments"),
        tournamentCard("ISL League", "Football", "4 Matches Today", Colors.green),
        tournamentCard("Pro Kabaddi", "Kabaddi", "Semi-Finals", Colors.orange),
      ],
    );
  }

  Widget _buildUpcomingList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        tournamentCard("Summer Open", "Tennis", "Starts in 2 days", Colors.blue),
        tournamentCard("Corporate Cup", "Cricket", "Registration Open", Colors.purple),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget tournamentCard(String name, String sport, String status, Color accent) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.1),
          child: Icon(Icons.sports_score, color: accent),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sport),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(color: accent, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}

class LiveMatchCard extends StatelessWidget {
  final String tournament, teamA, teamB, scoreA, scoreB, overs;
  const LiveMatchCard({super.key, required this.tournament, required this.teamA, required this.teamB, required this.scoreA, required this.scoreB, required this.overs});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.indigo.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(tournament, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.red),
                    SizedBox(width: 4),
                    Text("LIVE", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _teamScore(teamA, scoreA),
                const Text("vs", style: TextStyle(color: Colors.white38, fontSize: 20)),
                _teamScore(teamB, scoreB),
              ],
            ),
            const Divider(color: Colors.white10, height: 24),
            Text("Overs: $overs", style: const TextStyle(color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  Widget _teamScore(String name, String score) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(score, style: const TextStyle(color: Colors.white, fontSize: 18)),
      ],
    );
  }
}