
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/services/transaction_scope.dart';
import 'package:gastoguard/theme/app_colors.dart';
import 'package:gastoguard/theme/app_layout.dart';
import 'package:gastoguard/utils/amount_parser.dart';
import 'package:gastoguard/widgets/app_text_field.dart';
import 'package:gastoguard/widgets/category_card.dart';
import 'package:gastoguard/widgets/date_field.dart';
import 'package:gastoguard/widgets/form_section.dart';
import 'package:gastoguard/widgets/gradient_button.dart';
import 'package:gastoguard/widgets/pill_toggle.dart';

/// Handles both adding and editing transactions.
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.initialDate,
    this.currentTime,
    this.transaction,
  });

  final DateTime? initialDate;
  final DateTime Function()? currentTime;

  /// When provided, the screen opens in edit mode.
  final TransactionEntry? transaction;

  bool get isEditing => transaction != null;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const List<String> _typeLabels = ['Expense', 'Income'];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int _typeIndex = 0;
  TransactionCategory? _selectedCategory;
  late DateTime _date;

  @override
  void initState() {
    super.initState();

    final transaction = widget.transaction;

    _date = widget.initialDate ?? transaction?.dateTime ?? DateTime.now();

    if (transaction != null) {
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _noteController.text = transaction.note ?? '';
      _typeIndex = transaction.isExpense ? 0 : 1;
      _selectedCategory = transaction.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final amount = parseAmount(_amountController.text);

    if (amount == null || amount <= 0) {
      _showMessage('Enter an amount greater than zero');
      return;
    }

    if (amount > maxTransactionAmount) {
      _showMessage('Maximum transaction amount is ₱999,999,999.99');
      return;
    }

    final category = _selectedCategory;

    if (category == null) {
      _showMessage('Choose a category');
      return;
    }

    final transaction = widget.transaction;

    final clockTime = widget.currentTime?.call() ??
        transaction?.dateTime ??
        DateTime.now();

    final dateTime = DateTime(
      _date.year,
      _date.month,
      _date.day,
      clockTime.hour,
      clockTime.minute,
      clockTime.second,
    );

    final note = _noteController.text.trim();
    final store = TransactionScope.maybeRead(context);

    try {
      if (store != null) {
        if (transaction != null) {
          await store.updateTransactionAndSave(
            id: transaction.id,
            category: category,
            amount: amount,
            isExpense: _typeIndex == 0,
            dateTime: dateTime,
            note: note.isEmpty ? null : note,
          );
        } else {
          await store.addTransactionAndSave(
            category: category,
            amount: amount,
            isExpense: _typeIndex == 0,
            dateTime: dateTime,
            note: note.isEmpty ? null : note,
          );
        }
      }
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        widget.isEditing
            ? 'Could not update transaction. Please try again.'
            : 'Could not save transaction. Please try again.',
      );
      return;
    }

    if (!mounted) return;

// Clear the form only after adding a new transaction.
if (transaction == null) {
  _amountController.clear();
  _noteController.clear();

  setState(() {
    _typeIndex = 0;
    _selectedCategory = null;
  });
}

ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Transaction updated'
                : 'Transaction saved',
          ),
        ),
      );

    Navigator.of(context).maybePop();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 120),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(maxWidth: AppLayout.maxContentWidth),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final sideMargin = constraints.maxWidth * 0.10;

                return Column(
                  children: [
                    _Header(
                      title: widget.isEditing
                          ? 'Edit Transaction'
                          : 'Add Transaction',
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          sideMargin,
                          8,
                          sideMargin,
                          16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PillToggle(
                              labels: _typeLabels,
                              selectedIndex: _typeIndex,
                              onChanged: (index) {
                                setState(() => _typeIndex = index);
                              },
                            ),
                            const SizedBox(height: 16),
                            FormSection(
                              label: 'Amount',
                              child: AppTextField(
                                controller: _amountController,
                                hintText: '0.00',
                                prefixText: '\u20B1',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                  LengthLimitingTextInputFormatter(12),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            FormSection(
                              label: 'Category',
                              child: _CategoryGrid(
                                selected: _selectedCategory,
                                onSelected: (category) {
                                  setState(
                                    () => _selectedCategory = category,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 14),
                            FormSection(
                              label: 'Date',
                              child: DateField(
                                date: _date,
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(height: 14),
                            FormSection(
                              label: 'Note (Optional)',
                              child: AppTextField(
                                controller: _noteController,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        sideMargin,
                        8,
                        sideMargin,
                        16,
                      ),
                      child: GradientButton(
                        label: widget.isEditing
                            ? 'Update Transaction'
                            : 'Save Transaction',
                        onPressed: _save,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.selected,
    required this.onSelected,
  });

  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap =
            (constraints.maxWidth * 0.06).clamp(10.0, 24.0).toDouble();

        Widget cell(TransactionCategory category) {
          return Expanded(
            child: CategoryCard(
              category: category,
              selected: category == selected,
              onTap: () => onSelected(category),
            ),
          );
        }

        Widget row(List<TransactionCategory> items) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cell(items[0]),
              SizedBox(width: gap),
              cell(items[1]),
              SizedBox(width: gap),
              cell(items[2]),
            ],
          );
        }

        const all = TransactionCategory.all;

        return Column(
          children: [
            row(all.sublist(0, 3)),
            const SizedBox(height: 12),
            row(all.sublist(3, 6)),
          ],
        );
      },
    );
  }
}


