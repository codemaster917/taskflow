// Converts a date into readable text like "6 Nov 2026".
String formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  return '${date.day} ${months[date.month - 1]} ${date.year}';
}