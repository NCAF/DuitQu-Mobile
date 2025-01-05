// lib/widgets/recent_transactions_list.dart

import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../controllers/summary_controller.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<dynamic> transactions;
  final SummaryController summaryController;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.summaryController,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No recent transactions',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = Transaction.fromJson(transactions[index]);

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: transaction.category?.type == 'income'
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
              transaction.category?.type == 'income'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: transaction.category?.type == 'income'
                  ? Colors.green
                  : Colors.red,
            ),
          ),
          title: Text(transaction.category?.name ?? 'Unknown Category'),
          subtitle:
              Text(summaryController.formatDate(transaction.transactionDate)),
          trailing: Text(
            summaryController.formatCurrency(transaction.amount),
            style: TextStyle(
              color: transaction.category?.type == 'income'
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
