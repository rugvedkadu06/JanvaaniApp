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

  factory RedeemedReward.fromJson(Map<String, dynamic> json) {
    return RedeemedReward(
      id: json['id'],
      rewardId: json['rewardId'],
      userId: json['userId'],
      code: json['code'],
      redeemedAt: DateTime.parse(json['redeemedAt']),
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rewardId': rewardId,
      'userId': userId,
      'code': code,
      'redeemedAt': redeemedAt.toIso8601String(),
      'title': title,
    };
  }
}