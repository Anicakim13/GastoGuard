/// Maximum amount allowed for a single transaction.
const double maxTransactionAmount = 999999999.99;

/// Turns the text typed in the Amount field into a number.
/// Returns null if the text is empty or is not a number.
double? parseAmount(String text) {
  var cleaned = text.trim();

  if (cleaned.isEmpty) return null;
  if (cleaned.startsWith('.')) cleaned = '0$cleaned';
  if (cleaned.endsWith('.')) cleaned = '${cleaned}0';

  return double.tryParse(cleaned);
}
