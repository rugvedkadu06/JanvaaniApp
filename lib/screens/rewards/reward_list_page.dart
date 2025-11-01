// lib/screens/rewards/reward_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reward_controller.dart';
import '../../widgets/rewards_panel_widget.dart';
// FIX: Assuming your RewardTransaction model is here:
import '../../models/reward_transaction.dart';
import 'redeem_rewards_page.dart';
import 'package:intl/intl.dart';

class RewardListPage extends StatelessWidget {
  const RewardListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RewardsPanelWidget(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.card_giftcard),
              label: Text('redeemRewards'.tr),
              onPressed: () => Get.to(() => const RedeemRewardsPage()),
              // --- STYLED ELEVATED BUTTON ---
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor, // Use the primary color
                foregroundColor: Colors.white, // Ensure text/icon is white
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ------------------------------
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'transactions'.tr,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GetX<RewardController>(
            builder: (rewardCtrl) {
              if (rewardCtrl.transactions.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text('noTransactions'.tr, style: const TextStyle(color: Colors.grey)),
                  ),
                );
              }

              // Group transactions by month and year
              final groupedTransactions = _groupTransactionsByMonth(rewardCtrl.transactions);

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: groupedTransactions.keys.length,
                itemBuilder: (context, sectionIndex) {
                  final monthYear = groupedTransactions.keys.elementAt(sectionIndex);
                  final transactionsInMonth = groupedTransactions[monthYear]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Header
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(
                          monthYear,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      // List of transactions for the month
                      ...transactionsInMonth.map((transaction) => _TransactionTile(transaction: transaction)).toList(),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to group transactions by Month Year string
  Map<String, List<RewardTransaction>> _groupTransactionsByMonth(List<RewardTransaction> transactions) {
    final Map<String, List<RewardTransaction>> grouped = {};
    final dateFormat = DateFormat('MMMM yyyy');

    // Sort by date descending before grouping
    final sortedTransactions = transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var transaction in sortedTransactions) {
      final monthYear = dateFormat.format(transaction.date);
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(transaction);
    }
    return grouped;
  }
}

// --- Dedicated Transaction Tile Widget ---
class _TransactionTile extends StatelessWidget {
  final RewardTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.points > 0;
    final color = isCredit ? Colors.green.shade700 : Colors.red.shade700;
    final icon = isCredit ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_down_rounded;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            transaction.note,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            DateFormat.yMMMd().add_jm().format(transaction.date),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          trailing: Text(
            '${isCredit ? '+' : ''}${transaction.points}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}