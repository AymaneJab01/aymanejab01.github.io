import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/repositories/repositories.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<GoalRepository>();
    final money = NumberFormat.currency(symbol: AppConstants.currencySymbol);

    return DetailScaffold(
      title: 'Savings goals',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/goals/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add goal'),
      ),
      body: repo.items.isEmpty
          ? const Center(child: Text('No goals yet — add one to start saving toward it.', style: TextStyle(color: AppColors.mutedText)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              children: repo.items.map((g) {
                final progress = g.target == 0 ? 0.0 : (g.saved / g.target).clamp(0, 1).toDouble();
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push('/goals/edit', extra: g),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: progress,
                                  strokeWidth: 5,
                                  backgroundColor: AppColors.divider,
                                  color: AppColors.olive,
                                ),
                                Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${money.format(g.saved)} of ${money.format(g.target)}',
                                    style: const TextStyle(color: AppColors.mutedText, fontSize: 13)),
                                if (g.deadline != null)
                                  Text('Target: ${DateFormat.yMMMd().format(g.deadline!)}',
                                      style: const TextStyle(color: AppColors.mutedText, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
