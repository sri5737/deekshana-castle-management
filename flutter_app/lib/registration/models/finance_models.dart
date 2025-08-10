class FinanceEntry {
  final DateTime date;
  final double amount;
  final String source;

  FinanceEntry({required this.date, required this.amount, required this.source});
}

String yearMonthKey(DateTime d) => "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}";
