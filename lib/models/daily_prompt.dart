class DailyPrompt {
  final String id;
  final String region;
  final DateTime dateUtc;
  final DateTime promptAtUtc;

  DailyPrompt({
    required this.id,
    required this.region,
    required this.dateUtc,
    required this.promptAtUtc,
  });

  factory DailyPrompt.fromJson(Map<String, dynamic> json) {
    return DailyPrompt(
      id: json['id'],
      region: json['region'],
      dateUtc: DateTime.parse(json['date_utc']),
      promptAtUtc: DateTime.parse(json['prompt_at_utc']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'date_utc': dateUtc.toIso8601String(),
      'prompt_at_utc': promptAtUtc.toIso8601String(),
    };
  }

  Duration get timeUntilPrompt {
    return promptAtUtc.difference(DateTime.now().toUtc());
  }

  Duration get timeSincePrompt {
    return DateTime.now().toUtc().difference(promptAtUtc);
  }

  bool get isActive {
    final now = DateTime.now().toUtc();
    return now.isAfter(promptAtUtc);
  }

  bool get isOnTime {
    final now = DateTime.now().toUtc();
    final windowEnd = promptAtUtc.add(const Duration(minutes: 2));
    return now.isBefore(windowEnd);
  }
}