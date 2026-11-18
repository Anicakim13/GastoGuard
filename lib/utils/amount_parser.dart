/// Turns the text typed in the Amount field into a number.
/// Returns null if the text is empty or is not a number.
///
///   parseAmount('75.50') -> 75.5
///   parseAmount('.5')    -> 0.5
///   parseAmount('12.')   -> 12.0
///   parseAmount('')      -> null
double? parseAmount(String text) {
  var cleaned = text.trim();
  if (cleaned.isEmpty) return null;
  if (cleaned.startsWith('.')) cleaned = '0$cleaned';
  if (cleaned.endsWith('.')) cleaned = '${cleaned}0';
  return double.tryParse(cleaned);
}
