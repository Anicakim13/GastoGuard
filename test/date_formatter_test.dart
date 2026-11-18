import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/utils/date_formatter.dart';

void main() {
  test('formatShortDate writes dates like the design', () {
    expect(formatShortDate(DateTime(2026, 11, 9)), 'Nov 09, 2026');
    expect(formatShortDate(DateTime(2026, 1, 31)), 'Jan 31, 2026');
    expect(formatShortDate(DateTime(2027, 12, 5)), 'Dec 05, 2027');
  });
}
