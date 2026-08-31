import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AccountRepository>();
    final money = NumberFormat.currency(symbol: AppConstants.currencySymbol);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Banking'),
        actions: [
          IconButton(
            tooltip: 'View budgets',
            icon: const Icon(Icons.pie_chart_outline_rounded),
            onPressed: () => context.push('/budgets'),
          ),
          IconButton(
            tooltip: 'View goals',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => context.push('/goals'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add account'),
      ),
      body: repo.items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.mutedText),
                    const SizedBox(height: 12),
                    const Text('No accounts yet.\nAdd your first card or account to get started.',
                        textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedText)),
                    const SizedBox(height: 16),
                    FilledButton(onPressed: () => context.push('/accounts/add'), child: const Text('Add account')),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
              children: repo.items
                  .map((a) => Dismissible(
                        key: ValueKey(a.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration:
                              BoxDecoration(color: AppColors.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                        ),
                        onDismissed: (_) => repo.delete(a.id!),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _AccountCard(account: a, money: money),
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final NumberFormat money;
  const _AccountCard({required this.account, required this.money});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/accounts/edit', extra: account),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(account.colorValue),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.name, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text('•••• ${account.last4}', style: const TextStyle(color: Colors.white, letterSpacing: 2)),
                  const SizedBox(height: 14),
                  Text(money.format(account.balance),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(account.type, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Colors.white70, size: 18),
          ],
        ),
      ),
    );
  }
}
