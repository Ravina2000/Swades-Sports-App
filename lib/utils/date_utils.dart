enum ViewStatus { initial, loading, success, failure }

String formatApiDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime todayDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
