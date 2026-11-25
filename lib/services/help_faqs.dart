import 'package:flutter/material.dart';

/// One question and answer on the Help & Support screen.
class FaqEntry {
  const FaqEntry({
    required this.question,
    required this.answer,
    required this.icon,
  });

  final String question;
  final String answer;

  /// A small icon shown at the start of the question.
  final IconData icon;
}

/// The questions on the Help & Support screen, in order.
///
/// To change or add a question, edit this list. Keep the answers true: if a
/// feature changes (for example when budgets start being saved), update the
/// answer too.
const List<FaqEntry> helpFaqs = [
  FaqEntry(
    icon: Icons.add_circle_outline,
    question: 'How do I add an expense or income?',
    answer: 'Tap the + (Add) button in the bottom bar. Choose Expense or '
        'Income at the top, type the amount, and pick a category. Check the '
        'date (tap it to change it) and add a note if you like. Then tap Save '
        'Transaction. An amount above zero and a category are needed before '
        'it can be saved. In this early version, transactions are only kept '
        'while the app is open.',
  ),
  FaqEntry(
    icon: Icons.history,
    question: 'How do I see my transaction history?',
    answer: 'Tap History in the bottom bar. Your transactions are grouped by '
        'month, with expenses shown in red. Type in the search box to find a '
        'transaction, use the All, Income, and Expense buttons to filter by '
        'type, and use the two drop-down menus to pick a category or a time '
        'period. If you cannot find a transaction, check the time period: it '
        'starts on This Month, so older transactions appear under Last '
        'Month, Last 3 Months, or All Time.',
  ),
  FaqEntry(
    icon: Icons.bar_chart_rounded,
    question: 'What does the Spending Summary show?',
    answer: 'Tap Summary in the bottom bar, or View Details on the '
        'Dashboard. Switch between Weekly and Monthly at the top. The chart '
        'shows how much you spent: day by day for this week (Monday to '
        'Sunday), or week by week for this month (Week 1 is days 1 to 7, '
        'Week 2 is days 8 to 14, and so on). Total Spent adds up your '
        'expenses only. Income is never counted. Top Category is the '
        'category you spent the most on.',
  ),
  FaqEntry(
    icon: Icons.track_changes,
    question: 'How do I set a weekly or monthly budget?',
    answer: 'Open the menu with the menu icon at the top left of the '
        'Dashboard, then tap Budget Settings. Choose Weekly or Monthly, type '
        'the budget you want, and tap Save Changes. Each tab keeps its own '
        'amount. Please note that in this early version Budget Settings is a '
        'preview: the amounts are not saved yet, and the Dashboard and '
        'Spending Summary still show sample budget limits.',
  ),
  FaqEntry(
    icon: Icons.notifications_active_outlined,
    question: 'What are budget alerts?',
    answer: 'Budget alerts are meant to warn you when your spending gets '
        'close to your budget. In Budget Settings you can switch two alerts '
        'on or off: one at 80% of your budget and one at 100%. Each alert '
        'shows the peso amount where it would go off. For example, 80% of a '
        '₱1,000 budget is ₱800. In this early version the switches only '
        'change how the screen looks. No notifications are sent yet.',
  ),
];
