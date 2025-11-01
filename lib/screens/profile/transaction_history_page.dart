import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/user_controller.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userCtrl = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Points History'),
        backgroundColor: Colors.teal,
      ),
      body: Obx(() => userCtrl.transactions.isNotEmpty
          ? ListView.builder(
              itemCount: userCtrl.transactions.length,
              itemBuilder: (context, index) {
                final transaction = userCtrl.transactions[index];
                final isCredit = transaction.pointsChange > 0;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Icon(
                      isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                      color: isCredit ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    title: Text(transaction.description, 
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat.yMMMd().add_jm().format(transaction.date)),
                    trailing: Text(
                      '${isCredit ? '+' : ''}${transaction.pointsChange} pts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('No transactions yet', 
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  Text('Your points history will appear here.', 
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            )),
    );
  }
}
