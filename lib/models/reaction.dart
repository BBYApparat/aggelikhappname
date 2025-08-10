class Reaction {
  final String id;
  final String postId;
  final String userId;
  final ReactionType type;
  final String? emoji;
  final String? text;
  final String? selfieUrl;
  final DateTime createdAt;

  Reaction({
    required this.id,
    required this.postId,
    required this.userId,
    required this.type,
    this.emoji,
    this.text,
    this.selfieUrl,
    required this.createdAt,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      type: ReactionType.values.byName(json['type']),
      emoji: json['emoji'],
      text: json['text'],
      selfieUrl: json['selfie_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'type': type.name,
      'emoji': emoji,
      'text': text,
      'selfie_url': selfieUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isRealMoji => type == ReactionType.realmoji;
  bool get isComment => type == ReactionType.comment;
}

enum ReactionType {
  realmoji,
  comment,
}