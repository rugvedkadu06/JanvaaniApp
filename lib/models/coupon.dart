// lib/models/coupon.dart (AFTER FIX)
import 'package:flutter/material.dart';
import '../screens/rewards/redeem_rewards_page.dart'; // Import the enum

class Coupon {
  final String id;
  final String title;
  final String description;
  final int cost;
  final IconData icon;
  final Color color;
  final DateTime validTill;
  // ✅ ADDED: The new category field
  final CouponCategory category;

  Coupon({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
    required this.color,
    required this.validTill,
    // ✅ ADDED: Required category parameter
    required this.category,
  });

  bool get isExpired => validTill.isBefore(DateTime.now());
}