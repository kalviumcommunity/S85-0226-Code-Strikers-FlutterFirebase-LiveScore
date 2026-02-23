class Team {
  final String id;
  final String name;
  final String? leaderId;
  final int maxPlayers;
  final int currentPlayers;
  final String status;
  final String? tournamentId;
  final String? sports;

  Team({
    required this.id,
    required this.name,
    this.leaderId,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.status,
    this.tournamentId,
    this.sports,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json["id"]?.toString() ?? "",
      name: json["name"] ?? "",
      leaderId: json["leaderId"],
      maxPlayers: json["maxPlayers"] ?? 0,
      currentPlayers: json["currentPlayers"] ?? 0,
      status: json["status"] ?? "OPEN",
      tournamentId: json["tournamentId"],
      sports: json["sports"],
    );
  }
}