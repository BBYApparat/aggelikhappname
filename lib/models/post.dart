class Post {
  final String id;
  final String userId;
  final DateTime dateUtc;
  final DateTime createdAt;
  final bool onTime;
  final int retakes;
  final String? caption;
  final double? locationGeo;
  final String? locationLabel;
  final String mediaRearUrl;
  final String mediaFrontUrl;
  final String mediaCompositeUrl;
  final int lateBySeconds;

  Post({
    required this.id,
    required this.userId,
    required this.dateUtc,
    required this.createdAt,
    required this.onTime,
    required this.retakes,
    this.caption,
    this.locationGeo,
    this.locationLabel,
    required this.mediaRearUrl,
    required this.mediaFrontUrl,
    required this.mediaCompositeUrl,
    required this.lateBySeconds,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      dateUtc: DateTime.parse(json['date_utc']),
      createdAt: DateTime.parse(json['created_at']),
      onTime: json['on_time'],
      retakes: json['retakes'],
      caption: json['caption'],
      locationGeo: json['location_geo']?.toDouble(),
      locationLabel: json['location_label'],
      mediaRearUrl: json['media_rear_url'],
      mediaFrontUrl: json['media_front_url'],
      mediaCompositeUrl: json['media_composite_url'],
      lateBySeconds: json['late_by_seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_utc': dateUtc.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'on_time': onTime,
      'retakes': retakes,
      'caption': caption,
      'location_geo': locationGeo,
      'location_label': locationLabel,
      'media_rear_url': mediaRearUrl,
      'media_front_url': mediaFrontUrl,
      'media_composite_url': mediaCompositeUrl,
      'late_by_seconds': lateBySeconds,
    };
  }

  String get lateLabel {
    if (onTime) return 'On time';
    final hours = lateBySeconds ~/ 3600;
    final minutes = (lateBySeconds % 3600) ~/ 60;
    return 'Late ⏰ +${hours}h${minutes}m';
  }
}