import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config.dart';
import '../providers/finance_provider.dart';

class FinanceTab extends StatefulWidget {
  const FinanceTab({super.key});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
  // Fetch from Mar 2025 onward, applying rules in provider (exclude current month; show last month only after the 9th)
  context.read<FinanceProvider>().fetchFromPublicSpreadsheetInput(
    kFinanceSpreadsheetInput,
    startMonth: DateTime(2025, 3),
  );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        if (finance.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (finance.error != null) {
          return Center(child: Text('Error: ${finance.error}'));
        }
        final totals = finance.monthlyTotals;
        if (totals.isEmpty) {
          return Center(
            child: Text('No data found', style: Theme.of(context).textTheme.titleMedium),
          );
        }
  final keys = totals.keys.toList()..sort();
  final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);
  return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, i) {
            final ym = keys[i];
            final amount = totals[ym] ?? 0;
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.white,
              title: Text(ym, style: Theme.of(context).textTheme.titleMedium),
              trailing: Text(
                fmt.format(amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF00B386)),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: keys.length,
        );
      },
    );
  }
}
