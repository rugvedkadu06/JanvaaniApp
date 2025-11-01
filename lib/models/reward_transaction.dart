// lib/models/reward_transaction.dart

class RewardTransaction {
  final String note;
  final int points;
  final DateTime date;
  RewardTransaction({required this.note, required this.points, required this.date});
  Map<String, dynamic> toJson() => {'note': note, 'points': points, 'date': date.toIso8601String()};
  factory RewardTransaction.fromJson(Map<String, dynamic> json) => RewardTransaction(note: json['note'], points: json['points'], date: DateTime.parse(json['date']));
}


