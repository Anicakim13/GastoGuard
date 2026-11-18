import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastoguard/models/transaction_category.dart';
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

/// The "Add Transaction" screen.
///
/// Pressing Save adds the transaction to the shared TransactionStore, so it
/// shows up in History. It is only kept in memory (no database yet).
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.initialDate, this.currentTime});

  /// The date shown at first. If left out, today's date is used.
  /// (Tests pass a fixed date so their results never change.)
  final DateTime? initialDate;

  /// Tells the screen what time it is when Save is pressed. The saved
  /// transaction gets this clock time on the chosen date. If left out, the
  /// real clock is used. (Tests pass a fixed time.)
  final DateTime Function()? currentTime;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  static const List<String> _typeLabels = ['Expense', 'Income'];

  // Text typed into the Amount and Note fields
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // What the person has chosen so far
  int _typeIndex = 0; // 0 = Expense, 1 = Income
  TransactionCategory? _selectedCategory; // nothing selected at first
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Opens Flutter's built-in date picker and remembers the chosen date.
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

  /// Checks the form and, if it is complete, saves the transaction.
  void _save() {
    final amount = parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      _showMessage('Enter an amount greater than zero');
      return;
    }
    final category = _selectedCategory;
    if (category == null) {
      _showMessage('Choose a category');
      return;
    }

    // The date comes from the Date field; the time is the time of saving.
    final now = widget.currentTime?.call() ?? DateTime.now();
    final dateTime =
        DateTime(_date.year, _date.month, _date.day, now.hour, now.minute);
    final note = _noteController.text.trim();

    // Add it to the shared list. (Without a TransactionScope, for example in
    // the preview file, there is nothing to add it to.)
    TransactionScope.maybeRead(context)?.addTransaction(
      category: category,
      amount: amount,
      isExpense: _typeIndex == 0,
      dateTime: dateTime,
      note: note.isEmpty ? null : note,
    );

    // Empty the form, tell the person, and go back to the previous screen
    // (the Dashboard). If this is the only screen, the form just stays empty.
    _amountController.clear();
    _noteController.clear();
    setState(() {
      _typeIndex = 0;
      _selectedCategory = null;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Transaction saved')));
    Navigator.of(context).maybePop();
  }

  /// Shows a short message. It floats above the Save button, so the button
  /// stays tappable while the message is on the screen.
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
                // About 10% empty space on the left and right, like the design.
                final sideMargin = constraints.maxWidth * 0.10;

                return Column(
                  children: [
                    const _Header(),

                    // The form scrolls, so nothing overflows on small screens
                    // or when the keyboard is open.
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(sideMargin, 8, sideMargin, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            PillToggle(
                              labels: _typeLabels,
                              selectedIndex: _typeIndex,
                              onChanged: (index) =>
                                  setState(() => _typeIndex = index),
                            ),
                            const SizedBox(height: 16),

                            FormSection(
                              label: 'Amount',
                              child: AppTextField(
                                controller: _amountController,
                                hintText: '0.00',
                                prefixText: '₱',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                // Only digits and one decimal point with up
                                // to two decimals, for example 12.50
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            FormSection(
                              label: 'Category',
                              child: _CategoryGrid(
                                selected: _selectedCategory,
                                onSelected: (category) => setState(
                                  () => _selectedCategory = category,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            FormSection(
                              label: 'Date',
                              child: DateField(date: _date, onTap: _pickDate),
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

                    // The Save button stays at the bottom of the screen.
                    Padding(
                      padding: EdgeInsets.fromLTRB(sideMargin, 8, sideMargin, 16),
                      child: GradientButton(
                        label: 'Save Transaction',
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

/// The top row: back arrow and the screen title.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: () {
              // "maybePop" closes this screen and reveals the screen beneath
              // it (the Dashboard). If this screen is the only one (for
              // example in the preview), it safely does nothing.
              Navigator.of(context).maybePop();
            },
            icon: const Icon(
              Icons.arrow_back,
              size: 28,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Add Transaction',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
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

/// The six category cards, three per row.
class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.selected, required this.onSelected});

  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Space between cards: smaller on narrow screens so the names keep
        // their full size.
        final gap = (constraints.maxWidth * 0.06).clamp(10.0, 24.0).toDouble();

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
