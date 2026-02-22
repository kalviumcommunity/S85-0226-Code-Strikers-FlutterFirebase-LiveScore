class Team {
  final String id;
  final String name;
  final String leaderId;
  final int maxPlayers;
  final int currentPlayers;
  final String status;
  final String tournamentId;

  Team({
    required this.id,
    required this.name,
    required this.leaderId,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.status,
    required this.tournamentId,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      leaderId: json["leaderId"] ?? "",
      maxPlayers: json["maxPlayers"] ?? 0,
      currentPlayers: json["currentPlayers"] ?? 0,
      status: json["status"] ?? "",
      tournamentId: json["tournamentId"] ?? "",
    );
  }
}