import 'package:flutter/material.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/utils/currency_formatter.dart';
import 'package:gastoguard/utils/date_formatter.dart';
import 'package:gastoguard/widgets/category_icon_tile.dart';

/// One row in the transaction history: category icon, category name,
/// date and time, and the amount (red for expenses, green for income).
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction});

  final TransactionEntry transaction;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final amountText = isExpense
        ? formatPeso(-transaction.amount) // -₱150.00
        : '+${formatPeso(transaction.amount)}'; // +₱1,000.00
    final amountColor = isExpense ? AppColors.expense : AppColors.primaryDark;

    return LayoutBuilder(
      builder: (context, constraints) {
        // A smaller icon tile on narrow phones leaves more room for the text.
        final compact = constraints.maxWidth < 300;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CategoryIconTile(
                category: transaction.category,
                width: compact ? 64 : 80,
                height: compact ? 54 : 68,
              ),
              SizedBox(width: compact ? 10 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatDateTime(transaction.dateTime),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // The amount shrinks a little if it is very long.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    amountText,
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
