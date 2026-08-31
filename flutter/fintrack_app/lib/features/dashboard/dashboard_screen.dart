import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accounts = context.watch<AccountRepository>();
    final transactions = context.watch<TransactionRepository>();
    final money = NumberFormat.currency(symbol: AppConstants.currencySymbol);

    return ListView(
      padding: const EdgeInsets.all(AppConstants.pagePadding),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 22, backgroundColor: AppColors.divider, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Text('Welcome back', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            IconButton(
              tooltip: 'Manage your info',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings/profile'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // --- Balance card ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.darkGreen, AppColors.forest],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cash balance', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(
                money.format(accounts.totalBalance),
                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _PillButton(
                      label: 'Add Money',
                      icon: Icons.add_rounded,
                      onTap: () => _showAddMoneySheet(context, isAdd: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillButton(
                      label: 'Withdraw',
                      icon: Icons.arrow_downward_rounded,
                      onTap: () => _showAddMoneySheet(context, isAdd: false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your accounts', style: Theme.of(context).textTheme.titleMedium),
            TextButton.icon(
              onPressed: () => context.go('/accounts'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        SizedBox(
          height: 96,
          child: accounts.items.isEmpty
              ? _EmptyRowHint(onTap: () => context.push('/accounts/add'))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: accounts.items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, i) => _AccountAvatar(account: accounts.items[i]),
                ),
        ),

        const SizedBox(height: 24),
        Text('Overview', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _OverviewCard(
                label: 'Income',
                value: money.format(transactions.totalIncome),
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _OverviewCard(
                label: 'Expenses',
                value: money.format(transactions.totalExpense),
                icon: Icons.trending_down_rounded,
                color: AppColors.danger,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent transactions', style: Theme.of(context).textTheme.titleMedium),
            TextButton(onPressed: () => context.go('/transactions'), child: const Text('View all')),
          ],
        ),
        if (transactions.items.isEmpty)
          _EmptyState(
            message: 'No transactions yet. Add your first one to get started.',
            actionLabel: 'Add transaction',
            onTap: () => context.push('/transactions/add'),
          )
        else
          ...transactions.items.take(4).map((t) => _TransactionTile(t: t)),

        const SizedBox(height: 90),
      ],
    );
  }

  void _showAddMoneySheet(BuildContext context, {required bool isAdd}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddMoneySheet(isAdd: isAdd),
    );
  }
}

/// Quick-amount bottom sheet — the fastest way to add or take out money
/// without leaving the dashboard.
class _AddMoneySheet extends StatefulWidget {
  final bool isAdd;
  const _AddMoneySheet({required this.isAdd});

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _controller = TextEditingController();
  static const quickAmounts = [10, 25, 50, 100, 200];

  @override
  Widget build(BuildContext context) {
    final accounts = context.read<AccountRepository>();
    final transactions = context.read<TransactionRepository>();

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isAdd ? 'Add money' : 'Withdraw money',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isAdd ? 'Instantly top up your cash balance.' : 'Move money out of your balance.',
            style: const TextStyle(color: AppColors.mutedText),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(prefixText: '\$ ', hintText: 'Amount'),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickAmounts
                .map((a) => ChoiceChip(
                      label: Text('\$$a'),
                      selected: _controller.text == a.toString(),
                      onSelected: (_) => setState(() => _controller.text = a.toString()),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_controller.text);
                if (amount == null || amount <= 0 || accounts.items.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(accounts.items.isEmpty
                          ? 'Add an account first, then try again.'
                          : 'Enter a valid amount.'),
                    ),
                  );
                  return;
                }
                final signedAmount = widget.isAdd ? amount : -amount;
                await accounts.adjustBalance(accounts.items.first.id!, signedAmount);
                await transactions.add(TransactionModel(
                  title: widget.isAdd ? 'Money added' : 'Money withdrawn',
                  amount: amount,
                  category: widget.isAdd ? 'Deposit' : 'Withdrawal',
                  isIncome: widget.isAdd,
                  date: DateTime.now(),
                  accountId: accounts.items.first.id,
                ));
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(widget.isAdd ? 'Add' : 'Withdraw'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PillButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white24),
        backgroundColor: Colors.white.withOpacity(0.08),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  final AccountModel account;
  const _AccountAvatar({required this.account});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/accounts/edit', extra: account),
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Color(account.colorValue),
            child: Text(
              account.name.isNotEmpty ? account.name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Text(account.name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _OverviewCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: AppColors.mutedText, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel t;
  const _TransactionTile({required this.t});

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: AppConstants.currencySymbol);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: t.isIncome ? AppColors.success.withOpacity(0.15) : AppColors.danger.withOpacity(0.15),
        child: Icon(
          t.isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
          color: t.isIncome ? AppColors.success : AppColors.danger,
          size: 18,
        ),
      ),
      title: Text(t.title),
      subtitle: Text(t.category),
      trailing: Text(
        '${t.isIncome ? '+' : '-'}${money.format(t.amount)}',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: t.isIncome ? AppColors.success : AppColors.danger,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onTap;
  const _EmptyState({required this.message, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppConstants.cardRadius)),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.mutedText)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _EmptyRowHint extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyRowHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Text('+ Add account', style: TextStyle(color: AppColors.mutedText)),
      ),
    );
  }
}
