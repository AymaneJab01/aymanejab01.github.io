import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../data/repositories/repositories.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<BudgetRepository>();
    final money = NumberFormat.currency(symbol: AppConstants.currencySymbol);

    return DetailScaffold(
      title: 'Budgets',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/budgets/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add budget'),
      ),
      body: repo.items.isEmpty
          ? const Center(child: Text('No budgets yet — set one to track your spending.', style: TextStyle(color: AppColors.mutedText)))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              children: repo.items.map((b) {
                final progress = b.limit == 0 ? 0.0 : (b.spent / b.limit).clamp(0, 1).toDouble();
                final over = b.spent > b.limit;
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => context.push('/budgets/edit', extra: b),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(b.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('${money.format(b.spent)} / ${money.format(b.limit)}',
                                  style: TextStyle(color: over ? AppColors.danger : AppColors.mutedText, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: AppColors.divider,
                              color: over ? AppColors.danger : AppColors.olive,
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
