class Tournament {
  final String id;
  final String name;
  final String location;
  final String startDate;
  final String endDate;
  final int totalTeams;
  final int registeredTeams;
  final int requiredPlayer;
  final String registeration; // 👈 backend spelling

  Tournament({
    required this.id,
    required this.name,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.totalTeams,
    required this.registeredTeams,
    required this.requiredPlayer,
    required this.registeration,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      location: json["location"] ?? "",
      startDate: json["startDate"] ?? "",
      endDate: json["endDate"] ?? "",
      totalTeams: json["totalTeams"] ?? 0,
      registeredTeams: json["registeredTeams"] ?? 0,
      requiredPlayer: json["requiredPlayer"] ?? 0,
      registeration: json["registeration"] ?? "", // 👈 FIX
    );
  }
}