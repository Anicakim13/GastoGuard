import 'package:flutter_test/flutter_test.dart';
import 'package:gastoguard/utils/date_formatter.dart';

void main() {
  test('formatMonthYear writes the full month name and the year', () {
    expect(formatMonthYear(DateTime(2026, 8, 5)), 'August 2026');
    expect(formatMonthYear(DateTime(2027, 1, 31)), 'January 2027');
  });

  test('formatDateTime writes a date and a 12-hour time', () {
    expect(formatDateTime(DateTime(2026, 8, 8, 8, 0)), 'August 08, 8:00 AM');
    expect(formatDateTime(DateTime(2026, 8, 13, 13, 0)), 'August 13, 1:00 PM');
    expect(formatDateTime(DateTime(2026, 8, 17, 10, 0)), 'August 17, 10:00 AM');
    expect(formatDateTime(DateTime(2026, 8, 28, 15, 0)), 'August 28, 3:00 PM');
    expect(formatDateTime(DateTime(2026, 8, 1, 0, 5)), 'August 01, 12:05 AM');
    expect(formatDateTime(DateTime(2026, 8, 1, 12, 0)), 'August 01, 12:00 PM');
  });
}
