
import 'package:flutter/material.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/screens/add_transaction_screen.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/utils/currency_formatter.dart';
import 'package:gastoguard/utils/date_formatter.dart';
import 'package:gastoguard/widgets/category_icon_tile.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
  });

  final TransactionEntry transaction;

  Future<void> _edit(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          transaction: transaction,
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction?'),
          content: const Text(
            'Are you sure you want to delete this transaction? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.expense,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final store = TransactionScope.maybeRead(context);

    if (store == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete transaction.'),
        ),
      );
      return;
    }

    try {
      await store.deleteTransactionAndSave(transaction.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted'),
          ),
        );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not delete transaction. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;

    final amountText = isExpense
        ? formatPeso(-transaction.amount)
        : '+${formatPeso(transaction.amount)}';

    final amountColor =
        isExpense ? AppColors.expense : AppColors.primaryDark;

    return LayoutBuilder(
      builder: (context, constraints) {
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
                    if (transaction.note != null &&
                        transaction.note!.trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        transaction.note!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
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
              PopupMenuButton<String>(
                tooltip: 'Transaction options',
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textHint,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _edit(context);
                  } else if (value == 'delete') {
                    _delete(context);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.expense,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
