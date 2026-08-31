import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionRepository>();
    final money = NumberFormat.currency(symbol: AppConstants.currencySymbol);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Activity'),
        actions: [
          IconButton(
            tooltip: 'View analytics',
            icon: const Icon(Icons.pie_chart_outline_rounded),
            onPressed: () => context.push('/analytics'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transactions/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total spend', style: TextStyle(color: AppColors.mutedText)),
                const SizedBox(height: 4),
                Text(
                  money.format(repo.totalExpense),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(height: 140, child: _WeeklyChart(items: repo.items)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryChip(label: 'Income', value: money.format(repo.totalIncome), color: AppColors.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryChip(label: 'Expenses', value: money.format(repo.totalExpense), color: AppColors.danger),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Recent transaction', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (repo.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Nothing here yet — tap "Add" to log your first transaction.',
                    style: TextStyle(color: AppColors.mutedText)),
              ),
            )
          else
            ...repo.items.map((t) => _SwipeableTransaction(t: t)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<TransactionModel> items;
  const _WeeklyChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('Add transactions to see your trend', style: TextStyle(color: AppColors.mutedText)));
    }
    // Sum expenses per weekday for the last 7 days.
    final now = DateTime.now();
    final days = List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
    final spots = <FlSpot>[];
    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final total = items
          .where((t) => !t.isIncome && t.date.year == day.year && t.date.month == day.month && t.date.day == day.day)
          .fold(0.0, (s, t) => s + t.amount);
      spots.add(FlSpot(i.toDouble(), total));
    }
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.olive,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: AppColors.olive.withOpacity(0.12)),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.9), fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

/// Swipe left to delete, tap to edit — that's the whole "manage my
/// data" interaction for a transaction.
class _SwipeableTransaction extends StatelessWidget {
  final TransactionModel t;
  const _SwipeableTransaction({required this.t});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: AppConstants.currencySymbol);
    final repo = context.read<TransactionRepository>();

    return Dismissible(
      key: ValueKey(t.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) => repo.delete(t.id!),
      child: Card(
        child: ListTile(
          onTap: () => context.push('/transactions/edit', extra: t),
          leading: CircleAvatar(
            backgroundColor: t.isIncome ? AppColors.success.withOpacity(0.15) : AppColors.danger.withOpacity(0.15),
            child: Icon(
              t.isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: t.isIncome ? AppColors.success : AppColors.danger,
              size: 18,
            ),
          ),
          title: Text(t.title),
          subtitle: Text('${t.category} · ${DateFormat.MMMd().format(t.date)}'),
          trailing: Text(
            '${t.isIncome ? '+' : '-'}${money.format(t.amount)}',
            style: TextStyle(fontWeight: FontWeight.w600, color: t.isIncome ? AppColors.success : AppColors.danger),
          ),
        ),
      ),
    );
  }
}
