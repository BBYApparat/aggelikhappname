class User {
  final String id;
  final String handle;
  final String displayName;
  final String? avatarUrl;
  final String? phoneOrEmail;
  final String country;
  final String timezone;
  final UserSettings settings;
  final DateTime createdAt;

  User({
    required this.id,
    required this.handle,
    required this.displayName,
    this.avatarUrl,
    this.phoneOrEmail,
    required this.country,
    required this.timezone,
    required this.settings,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      handle: json['handle'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      phoneOrEmail: json['phone_or_email'],
      country: json['country'],
      timezone: json['tz'],
      settings: UserSettings.fromJson(json['settings']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'handle': handle,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'phone_or_email': phoneOrEmail,
      'country': country,
      'tz': timezone,
      'settings': settings.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserSettings {
  final bool locationOptIn;
  final String whoCanFriend;

  UserSettings({
    required this.locationOptIn,
    required this.whoCanFriend,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      locationOptIn: json['location_opt_in'] ?? false,
      whoCanFriend: json['who_can_friend'] ?? 'everyone',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_opt_in': locationOptIn,
      'who_can_friend': whoCanFriend,
    };
  }
}