// lib/controllers/reward_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_transaction.dart';
import '../models/coupon.dart';

class RewardController extends GetxController {
  var totalPoints = 0.obs;
  var transactions = <RewardTransaction>[].obs;
  var redeemedCouponIds = <String>[].obs;
  @override
  void onInit() { super.onInit(); loadRewards(); }
  Future<void> loadRewards() async {
    final prefs = await SharedPreferences.getInstance();
    totalPoints.value = prefs.getInt('total_points') ?? 10000;
    final transactionsJson = prefs.getStringList('transactions') ?? [];
    if (transactionsJson.isEmpty) transactions.value = [];
    else transactions.value = transactionsJson.map((t) => RewardTransaction.fromJson(jsonDecode(t))).toList();
    redeemedCouponIds.value = prefs.getStringList('redeemed_coupons') ?? [];
    await saveRewards();
  }
  Future<void> saveRewards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('total_points', totalPoints.value);
    final transactionsJson = transactions.map((t) => jsonEncode(t.toJson())).toList();
    await prefs.setStringList('transactions', transactionsJson);
    await prefs.setStringList('redeemed_coupons', redeemedCouponIds);
  }
  void addTransaction(String note, int points) {
    totalPoints.value += points;
    transactions.insert(0, RewardTransaction(note: note, points: points, date: DateTime.now()));
    saveRewards();
  }
  bool isCouponRedeemed(String couponId) {
    return redeemedCouponIds.contains(couponId);
  }

  void redeemCoupon(Coupon coupon) {
    if (totalPoints.value >= coupon.cost && !isCouponRedeemed(coupon.id) && !coupon.isExpired) {
      addTransaction('Redeemed: ${coupon.title}', -coupon.cost);
      redeemedCouponIds.add(coupon.id);
      saveRewards();
      Get.back();
      Get.snackbar('Success!', 'Coupon for ${coupon.title} redeemed!', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
    }
  }
}


