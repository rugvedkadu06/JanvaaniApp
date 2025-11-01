import 'package:flutter/material.dart';

// lib/models/point_transaction.dart
class PointTransaction {
  final String id;
  final String description;
  final int pointsChange;
  final DateTime date;

  PointTransaction({
    required this.id,
    required this.description,
    required this.pointsChange,
    required this.date,
  });

  // Add fromJson and toJson methods for persistence
  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'],
      description: json['description'],
      pointsChange: json['pointsChange'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'pointsChange': pointsChange,
      'date': date.toIso8601String(),
    };
  }
}