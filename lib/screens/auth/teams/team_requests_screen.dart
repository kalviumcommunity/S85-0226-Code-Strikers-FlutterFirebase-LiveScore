import 'package:flutter/material.dart';
import '../../../models/team/team_join_request.dart';
import '../../../services/team_service.dart';

class TeamRequestsScreen extends StatefulWidget {
  final String teamId;

  const TeamRequestsScreen({super.key, required this.teamId});

  @override
  State<TeamRequestsScreen> createState() => _TeamRequestsScreenState();
}

class _TeamRequestsScreenState extends State<TeamRequestsScreen> {
  late Future<List<TeamJoinRequest>> future;

  // Modern Design Palette
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color cardBg = const Color(0xFF1E293B).withOpacity(0.4);

  @override
  void initState() {
    super.initState();
    future = TeamService.getRequests(widget.teamId);
  }

  Future<void> approve(String requestId) async {
    final ok = await TeamService.approveRequest(widget.teamId, requestId);
    if (ok) refresh();
  }

  Future<void> reject(String requestId) async {
    final ok = await TeamService.rejectRequest(widget.teamId, requestId);
    if (ok) refresh();
  }

  void refresh() {
    setState(() {
      future = TeamService.getRequests(widget.teamId);
    });
  }

  String shortId(String id) {
    if (id.length <= 10) return id;
    return "${id.substring(0, 6)}...${id.substring(id.length - 4)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Consistent deep navy
      appBar: AppBar(
        title: const Text(
          "Recruitment Hub",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<TeamJoinRequest>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryPurple));
          }

          if (snap.hasError) {
            return Center(
              child: Text(
                "Error: ${snap.error}",
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }

          final requests = snap.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search_rounded, size: 64, color: Colors.white10),
                  const SizedBox(height: 16),
                  const Text(
                    "No pending recruits",
                    style: TextStyle(color: Colors.white38, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: requests.length,
            itemBuilder: (_, i) {
              final r = requests[i];
              return _RequestCard(
                request: r,
                shortId: shortId(r.userId),
                primaryPurple: primaryPurple,
                accentCyan: accentCyan,
                cardBg: cardBg,
                onApprove: () => approve(r.id),
                onReject: () => reject(r.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TeamJoinRequest request;
  final String shortId;
  final Color primaryPurple;
  final Color accentCyan;
  final Color cardBg;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.shortId,
    required this.primaryPurple,
    required this.accentCyan,
    required this.cardBg,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            /// User Avatar with Neon Border
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [primaryPurple, accentCyan]),
              ),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF0F172A),
                child: Text(
                  request.userId.substring(0, 1).toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shortId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: request.status == "PENDING" ? Colors.amber : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        request.status,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (request.status == "PENDING") ...[
              // Reject Button
              _actionButton(
                icon: Icons.close_rounded,
                color: Colors.redAccent,
                onTap: onReject,
              ),
              const SizedBox(width: 12),
              // Approve Button
              _actionButton(
                icon: Icons.check_rounded,
                color: Colors.greenAccent,
                onTap: onApprove,
                isPrimary: true,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isPrimary ? color.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(isPrimary ? 0.5 : 0.2),
          ),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}