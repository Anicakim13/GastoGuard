import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/utils/currency_formatter.dart';

void main() {
  test('formatPeso adds the peso sign, commas, and two decimals', () {
    expect(formatPeso(1000), '₱1,000.00');
    expect(formatPeso(850, withSpace: true), '₱ 850.00');
    expect(formatPeso(1234567.5), '₱1,234,567.50');
    expect(formatPeso(0), '₱0.00');
  });

  test('formatPeso puts the minus sign before the peso sign', () {
    expect(formatPeso(-150), '-₱150.00');
  });
}
