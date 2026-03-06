import 'package:flutter/material.dart';
import '../../../services/tournament_service.dart';
import '../teams/team_members_picker_screen.dart';

class CricketScoringScreen extends StatefulWidget {
  final Map match;

  const CricketScoringScreen({super.key, required this.match});

  @override
  State<CricketScoringScreen> createState() => _CricketScoringScreenState();
}

class _CricketScoringScreenState extends State<CricketScoringScreen> {
  bool loading = false;
  bool needsStriker = false;
  bool needsBowler = false;
  bool matchEnded = false;

  List<String> ballHistory = [];
  int currentInnings = 1;

  String? winnerTeamId;
  int? scoreA;
  int? scoreB;

  final Color darkBg = const Color(0xFF0F172A);
  final Color cardBg = const Color(0xFF1E293B);
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);

  String? _getId(Map? p) => p?["playerId"] ?? p?["userId"];

  String getBattingTeamId() =>
      currentInnings == 1 ? widget.match["teamAId"] : widget.match["teamBId"];

  String getBowlingTeamId() =>
      currentInnings == 1 ? widget.match["teamBId"] : widget.match["teamAId"];

  Future<void> recordBall(
      int runs,
      bool wicket, {
        bool wide = false,
        bool noBall = false,
      }) async {
    if (loading || needsStriker || needsBowler || matchEnded) return;

    setState(() {
      loading = true;

      if (wide) {
        ballHistory.insert(0, "Wd");
      } else if (noBall) {
        ballHistory.insert(0, "Nb");
      } else {
        ballHistory.insert(0, wicket ? "W" : runs.toString());
      }

      if (ballHistory.length > 6) ballHistory.removeLast();
    });

    try {
      await TournamentService.updateBall(
        tournamentId: widget.match["tournamentId"],
        matchId: widget.match["id"],
        runs: runs,
        wicket: wicket,
        wide: wide,
        noBall: noBall,
      );

      final matchData = await TournamentService.getMatch(
        widget.match["tournamentId"],
        widget.match["id"],
      );

      if (matchData["status"] == "COMPLETED") {
        setState(() {
          matchEnded = true;
          winnerTeamId = matchData["winnerTeamId"];
          scoreA = matchData["scoreA"];
          scoreB = matchData["scoreB"];
          loading = false;
        });
        return;
      }

      final newInnings = matchData["liveData"]["innings"] ?? currentInnings;

      if (newInnings != currentInnings) {
        setState(() {
          currentInnings = newInnings;
          ballHistory.clear();
          loading = false;
        });

        await _startNewInnings();
        return;
      }

      if (wicket) {
        setState(() => needsStriker = true);
        await _pickNewStriker();
      }

      if (!wide && !noBall && ballHistory.length == 6) {
        setState(() {
          ballHistory.clear();
          needsBowler = true;
        });

        await _pickNewBowler();
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> _startNewInnings() async {
    final battingTeamId = getBattingTeamId();
    final bowlingTeamId = getBowlingTeamId();

    final striker = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TeamMembersPickerScreen(teamId: battingTeamId)),
    );
    if (striker == null) return;

    final nonStriker = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TeamMembersPickerScreen(teamId: battingTeamId)),
    );
    if (nonStriker == null) return;

    final bowler = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => TeamMembersPickerScreen(teamId: bowlingTeamId)),
    );
    if (bowler == null) return;

    final strikerId = _getId(striker);
    final nonStrikerId = _getId(nonStriker);
    final bowlerId = _getId(bowler);

    if (strikerId == null || nonStrikerId == null || bowlerId == null) return;

    await TournamentService.startInnings(
      tournamentId: widget.match["tournamentId"],
      matchId: widget.match["id"],
      strikerId: strikerId,
      nonStrikerId: nonStrikerId,
      bowlerId: bowlerId,
    );

    setState(() {
      needsStriker = false;
      needsBowler = false;
      loading = false;
    });
  }

  Future<void> _pickNewStriker() async {
    final batsmen = await TournamentService.getAvailableBatsmen(
      tournamentId: widget.match["tournamentId"],
      matchId: widget.match["id"],
    );

    final player = await showModalBottomSheet<Map>(
      context: context,
      backgroundColor: darkBg,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: batsmen
            .map((p) => ListTile(
          title: Text(p["name"] ?? "Player",
              style: const TextStyle(color: Colors.white)),
          onTap: () => Navigator.pop(context, p),
        ))
            .toList(),
      ),
    );

    final strikerId = _getId(player);
    if (strikerId == null) return;

    await TournamentService.selectNewStriker(
      tournamentId: widget.match["tournamentId"],
      matchId: widget.match["id"],
      strikerId: strikerId,
    );

    setState(() => needsStriker = false);
  }

  Future<void> _pickNewBowler() async {
    final player = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              TeamMembersPickerScreen(teamId: getBowlingTeamId())),
    );

    final bowlerId = _getId(player);
    if (bowlerId == null) return;

    await TournamentService.selectBowler(
      tournamentId: widget.match["tournamentId"],
      matchId: widget.match["id"],
      bowlerId: bowlerId,
    );

    setState(() => needsBowler = false);
  }

  String getWinMessage() {
    if (!matchEnded || scoreA == null || scoreB == null) return "";

    final teamAId = widget.match["teamAId"];
    final teamAName = widget.match["teamAName"];
    final teamBName = widget.match["teamBName"];

    if (winnerTeamId == teamAId) {
      final margin = scoreA! - scoreB!;
      return "$teamAName won by $margin runs";
    } else {
      return "$teamBName won by wickets";
    }
  }

  @override
  Widget build(BuildContext context) {
    final battingTeam =
    currentInnings == 1 ? widget.match["teamAName"] : widget.match["teamBName"];

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        title: Text("$battingTeam Innings",
            style: const TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildScoreboard(battingTeam),
          _buildRecentBalls(),
          _buildControlPad(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreboard(String battingTeam) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryPurple.withOpacity(0.2),
            accentCyan.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text("$battingTeam Batting",
              style: TextStyle(
                  color: accentCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 10),
          Text("Innings $currentInnings",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900)),
          if (matchEnded)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                getWinMessage(),
                style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentBalls() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("THIS OVER:",
              style: TextStyle(color: Colors.white24, fontSize: 10)),
          const SizedBox(width: 10),
          ...ballHistory.map((b) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: b == "W"
                  ? Colors.redAccent
                  : (b == "4" || b == "6"
                  ? primaryPurple
                  : Colors.white10),
            ),
            child: Text(b,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }

  Widget _buildControlPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(children: [
            _scoreBtn(0, "Dot"),
            _scoreBtn(1, "1"),
            _scoreBtn(2, "2"),
            _scoreBtn(3, "3"),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _scoreBtn(4, "FOUR", isBoundary: true),
            _scoreBtn(6, "SIX", isBoundary: true),
            _extraBtn("WD", wide: true),
            _extraBtn("NB", noBall: true),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _wicketBtn(),
          ]),
        ],
      ),
    );
  }

  Widget _scoreBtn(int r, String label, {bool isBoundary = false}) {
    final disabled = loading || needsStriker || needsBowler || matchEnded;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: isBoundary ? primaryPurple : cardBg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: disabled ? null : () => recordBall(r, false),
            child: SizedBox(
              height: 75,
              child: Center(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _extraBtn(String label, {bool wide = false, bool noBall = false}) {
    final disabled = loading || needsStriker || needsBowler || matchEnded;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: disabled
                ? null
                : () => recordBall(
              0,
              false,
              wide: wide,
              noBall: noBall,
            ),
            child: SizedBox(
              height: 75,
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wicketBtn() {
    final disabled = loading || needsStriker || needsBowler || matchEnded;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Material(
          color: Colors.redAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: disabled ? null : () => recordBall(0, true),
            child: Container(
              height: 75,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                Border.all(color: Colors.redAccent.withOpacity(0.5)),
              ),
              child: const Text("WKT",
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ),
    );
  }
}