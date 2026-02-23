class Fixture {
  final String id;
  final String teamAName;
  final String teamBName;
  final int round;
  final String status;

  /// optional future fields
  final int scoreA;
  final int scoreB;
  final String scheduledAt;

  Fixture({
    required this.id,
    required this.teamAName,
    required this.teamBName,
    required this.round,
    required this.status,
    required this.scoreA,
    required this.scoreB,
    required this.scheduledAt,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      id: json["id"],
      teamAName: json["teamAName"] ?? "TBD",
      teamBName: json["teamBName"] ?? "TBD",
      round: json["round"] ?? 1,
      status: json["status"] ?? "PENDING",

      /// safe defaults
      scoreA: json["scoreA"] ?? 0,
      scoreB: json["scoreB"] ?? 0,
      scheduledAt: json["scheduledAt"] ?? "Not scheduled",
    );
  }
}