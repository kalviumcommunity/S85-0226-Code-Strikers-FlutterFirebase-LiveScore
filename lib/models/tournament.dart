class Tournament {
  final String id;
  final String name;
  final String location;
  final String sports;        // ✅ added
  final String startDate;
  final String endDate;
  final int totalTeams;
  final int registeredTeams;
  final int requiredPlayer;
  final String registeration; // backend spelling

  Tournament({
    required this.id,
    required this.name,
    required this.location,
    required this.sports,        // ✅ added
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
      name: json["Name"] ?? "",
      location: json["Location"] ?? "",
      sports: json["Sports"] ?? "",   // ✅ added
      startDate: json["StartDate"] ?? "",
      endDate: json["EndDate"] ?? "",
      totalTeams: json["TotalTeams"] ?? 0,
      registeredTeams: json["registeredTeams"] ?? 0,
      requiredPlayer: json["requiredPlayer"] ?? 0,
      registeration: json["registeration"] ?? "",
    );
  }
}