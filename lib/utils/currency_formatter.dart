/// Formats an amount as Philippine pesos, with thousands separators.
///
///   formatPeso(1000)                  -> "₱1,000.00"
///   formatPeso(850, withSpace: true)  -> "₱ 850.00"
///   formatPeso(-150)                  -> "-₱150.00"
String formatPeso(double amount, {bool withSpace = false}) {
  final sign = amount < 0 ? '-' : '';
  final parts = amount.abs().toStringAsFixed(2).split('.');
  // Put a comma before every group of three digits: 1234567 -> 1,234,567
  final whole = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
  final symbol = withSpace ? '₱ ' : '₱';
  return '$sign$symbol$whole.${parts[1]}';
}

/// Writes a whole number with thousands separators: 1000 -> "1,000".
/// (Used for the labels on the Spending Summary chart.)
String formatWholeNumber(num value) {
  return value.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}
