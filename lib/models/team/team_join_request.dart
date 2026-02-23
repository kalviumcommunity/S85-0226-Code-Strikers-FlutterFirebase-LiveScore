class TeamJoinRequest {
  final String id;
  final String teamId;
  final String userId;
  final String status;
  final DateTime createdAt;

  TeamJoinRequest({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.status,
    required this.createdAt,
  });

  factory TeamJoinRequest.fromJson(Map<String, dynamic> json) {
    return TeamJoinRequest(
      id: json['id'],
      teamId: json['teamId'],
      userId: json['userId'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}