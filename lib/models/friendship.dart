class Friendship {
  final String id;
  final String userId;
  final String friendId;
  final FriendshipStatus status;
  final DateTime createdAt;

  Friendship({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.createdAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['id'],
      userId: json['user_id'],
      friendId: json['friend_id'],
      status: FriendshipStatus.values.byName(json['status']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'friend_id': friendId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

enum FriendshipStatus {
  pending,
  accepted,
  blocked,
}