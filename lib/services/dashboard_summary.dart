import 'package:gastoguard/models/category_spending.dart';
import 'package:gastoguard/models/transaction_category.dart';
import 'package:gastoguard/models/transaction_entry.dart';
import 'package:gastoguard/theme/app_colors.dart';

/// The numbers shown on the Dashboard, worked out from the transactions.
///
/// Everything is calculated from ALL transactions in the list:
///  - [totalIncome]   = all money received
///  - [totalExpenses] = all money spent
///  - [balance]       = [totalIncome] minus [totalExpenses]
///
/// The pie chart has four slices, like the Canva design: Food, Transport,
/// Data, and Others. "Others" adds up every other expense category (School
/// Supplies, Entertainment, and Others), because the design has no room for
/// six slices.
class DashboardSummary {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.food,
    required this.transport,
    required this.data,
    required this.others,
  });

  /// Works out the summary from a list of transactions.
  factory DashboardSummary.fromTransactions(
    List<TransactionEntry> transactions,
  ) {
    var income = 0.0;
    var expenses = 0.0;
    var foodTotal = 0.0;
    var transportTotal = 0.0;
    var dataTotal = 0.0;
    var othersTotal = 0.0;

    for (final transaction in transactions) {
      if (!transaction.isExpense) {
        income += transaction.amount;
        continue;
      }

      expenses += transaction.amount;
      if (transaction.category == TransactionCategory.food) {
        foodTotal += transaction.amount;
      } else if (transaction.category == TransactionCategory.transportation) {
        transportTotal += transaction.amount;
      } else if (transaction.category == TransactionCategory.data) {
        dataTotal += transaction.amount;
      } else {
        othersTotal += transaction.amount;
      }
    }

    // A category's share of all spending, from 0 to 100.
    double percentOf(double amount) =>
        expenses > 0 ? amount / expenses * 100 : 0;

    return DashboardSummary(
      totalIncome: income,
      totalExpenses: expenses,
      food: CategorySpending(
        name: 'Food',
        percent: percentOf(foodTotal),
        color: AppColors.food,
      ),
      transport: CategorySpending(
        name: 'Transport',
        percent: percentOf(transportTotal),
        color: AppColors.transportation,
      ),
      data: CategorySpending(
        name: 'Data',
        percent: percentOf(dataTotal),
        color: AppColors.data,
      ),
      others: CategorySpending(
        name: 'Others',
        percent: percentOf(othersTotal),
        // The design draws this slice in the primary green.
        color: AppColors.primary,
      ),
    );
  }

  /// The sample values from the Canva design. They are shown when the
  /// Dashboard has no shared transaction list (for example in the preview
  /// file).
  static const DashboardSummary sample = DashboardSummary(
    totalIncome: 1000,
    totalExpenses: 150,
    food: CategorySpending(name: 'Food', percent: 40, color: AppColors.food),
    transport: CategorySpending(
      name: 'Transport',
      percent: 30,
      color: AppColors.transportation,
    ),
    data: CategorySpending(name: 'Data', percent: 20, color: AppColors.data),
    others: CategorySpending(
      name: 'Others',
      percent: 10,
      color: AppColors.primary,
    ),
  );

  /// All money received.
  final double totalIncome;

  /// All money spent.
  final double totalExpenses;

  final CategorySpending food;
  final CategorySpending transport;
  final CategorySpending data;
  final CategorySpending others;

  /// Money left: income minus expenses. Can be negative.
  double get balance => totalIncome - totalExpenses;

  /// How much of the income is left, from 0.0 (nothing) to 1.0 (all of it).
  /// This fills the progress bar on the balance card.
  double get balanceShare {
    if (totalIncome <= 0) return 0;
    return (balance / totalIncome).clamp(0.0, 1.0).toDouble();
  }

  /// The legend lists the categories in this order.
  List<CategorySpending> get legendItems => [food, transport, data, others];

  /// The pie draws its slices in this order (clockwise from the top),
  /// exactly like the Canva design.
  List<CategorySpending> get pieSlices => [transport, data, food, others];
}
