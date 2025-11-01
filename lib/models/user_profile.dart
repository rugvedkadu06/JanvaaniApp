// lib/models/user_profile.dart

class UserProfile {
  final String name, email, phone, uniqueId;
  String? faceImageUrl;
  final int points;

  UserProfile({ required this.name, required this.email, required this.phone, required this.uniqueId, this.faceImageUrl, this.points = 0 });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      uniqueId: json['_id'] ?? 'N/A',
      faceImageUrl: json['faceImageUrl'],
      points: json['points'] ?? 0
  );
}


