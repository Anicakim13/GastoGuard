import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';

/// SAMPLE transactions for the History screen. Nothing here is saved.
///
/// The dates are built from [today], so "This Month" always has data.
/// The four expenses in the current month are the ones from the Canva design.
List<TransactionEntry> buildDemoTransactions(DateTime today) {
  var count = 0;

  /// [monthsAgo]: 0 = this month, 1 = last month, and so on.
  TransactionEntry make({
    required int monthsAgo,
    required int day,
    required int hour,
    required int minute,
    required TransactionCategory category,
    required double amount,
    bool isExpense = true,
  }) {
    count++;
    return TransactionEntry(
      id: 'demo-$count',
      category: category,
      amount: amount,
      isExpense: isExpense,
      dateTime: DateTime(today.year, today.month - monthsAgo, day, hour, minute),
    );
  }

  const food = TransactionCategory.food;
  const transportation = TransactionCategory.transportation;
  const data = TransactionCategory.data;
  const schoolSupplies = TransactionCategory.schoolSupplies;
  const entertainment = TransactionCategory.entertainment;
  const others = TransactionCategory.others;

  return [
    // This month (matches the Canva design, plus the Income from the Dashboard)
    make(monthsAgo: 0, day: 1, hour: 8, minute: 0, category: others, amount: 1000, isExpense: false),
    make(monthsAgo: 0, day: 8, hour: 8, minute: 0, category: food, amount: 150),
    make(monthsAgo: 0, day: 13, hour: 13, minute: 0, category: transportation, amount: 50),
    make(monthsAgo: 0, day: 17, hour: 10, minute: 0, category: schoolSupplies, amount: 210),
    make(monthsAgo: 0, day: 28, hour: 15, minute: 0, category: data, amount: 60),

    // Last month
    make(monthsAgo: 1, day: 1, hour: 8, minute: 0, category: others, amount: 1000, isExpense: false),
    make(monthsAgo: 1, day: 3, hour: 9, minute: 0, category: data, amount: 100),
    make(monthsAgo: 1, day: 9, hour: 7, minute: 30, category: transportation, amount: 40),
    make(monthsAgo: 1, day: 18, hour: 19, minute: 0, category: entertainment, amount: 200),
    make(monthsAgo: 1, day: 25, hour: 12, minute: 30, category: food, amount: 85),

    // Two months ago
    make(monthsAgo: 2, day: 1, hour: 8, minute: 0, category: others, amount: 1000, isExpense: false),
    make(monthsAgo: 2, day: 10, hour: 14, minute: 0, category: schoolSupplies, amount: 300),
    make(monthsAgo: 2, day: 20, hour: 12, minute: 0, category: food, amount: 120),

    // Three months ago (only shown by "All Time")
    make(monthsAgo: 3, day: 14, hour: 18, minute: 0, category: entertainment, amount: 150),
  ];
}
