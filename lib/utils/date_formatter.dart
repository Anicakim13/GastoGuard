const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date like the design does: "Nov 09, 2026".
String formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  return '${_monthNames[date.month - 1]} $day, ${date.year}';
}

const List<String> _fullMonthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Writes a month and year, for example "August 2026".
String formatMonthYear(DateTime date) {
  return '${_fullMonthNames[date.month - 1]} ${date.year}';
}

/// Writes a date and time like the History screen, for example
/// "August 08, 8:00 AM".
String formatDateTime(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  final amPm = date.hour < 12 ? 'AM' : 'PM';
  return '${_fullMonthNames[date.month - 1]} $day, $hour12:$minute $amPm';
}
