import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/repositories/repositories.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const _palette = [
    AppColors.olive,
    AppColors.oliveDark,
    AppColors.danger,
    Color(0xFF3B5BA5),
    Color(0xFFB7791F),
    Color(0xFF8B5CF6),
    Color(0xFF319795),
    AppColors.mutedText,
  ];

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<TransactionRepository>();
    final money = NumberFormat.currency(symbol: AppConstants.currencySymbol);

    final byCategory = <String, double>{};
    for (final t in repo.items.where((t) => !t.isIncome)) {
      byCategory[t.category] = (byCategory[t.category] ?? 0) + t.amount;
    }
    final entries = byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return DetailScaffold(
      title: 'Analytics',
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          Text('Spending by category', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text('Add a few expenses to see your breakdown here.', style: TextStyle(color: AppColors.mutedText))),
            )
          else ...[
            SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    for (var i = 0; i < entries.length; i++)
                      PieChartSectionData(
                        value: entries[i].value,
                        color: _palette[i % _palette.length],
                        title: '${((entries[i].value / total) * 100).round()}%',
                        radius: 60,
                        titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(entries.length, (i) {
              final e = entries[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    CircleAvatar(radius: 5, backgroundColor: _palette[i % _palette.length]),
                    const SizedBox(width: 10),
                    Expanded(child: Text(e.key)),
                    Text(money.format(e.value), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
