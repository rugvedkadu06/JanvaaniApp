// lib/models/user.dart
class User {
  // ...existing code...
  final int points;

  User({
    // ...existing parameters...
    this.points = 0,
  });

  // ...existing code...

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // ...existing fields...
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ...existing fields...
      'points': points,
    };
  }

  User copyWith({
    // ...existing parameters...
    int? points,
  }) {
    return User(
      // ...existing fields...
      points: points ?? this.points,
    );
  }
}

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String type; // 'coupon' or 'gprc'

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.type,
  });
}

class RedeemedReward {
  final String id;
  final String rewardId;
  final String userId;
  final String code;
  final DateTime redeemedAt;
  final String title;

  RedeemedReward({
    required this.id,
    required this.rewardId,
    required this.userId,
    required this.code,
    required this.redeemedAt,
    required this.title,
  });
}
