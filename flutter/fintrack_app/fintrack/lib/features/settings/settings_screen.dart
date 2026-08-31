import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/repositories.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileRepository>().profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.pagePadding),
        children: [
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(radius: 26, backgroundColor: AppColors.divider, child: Icon(Icons.person)),
              title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(profile.email),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/settings/profile'),
            ),
          ),
          const SizedBox(height: 20),
          Text('Manage', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            label: 'Personal information',
            subtitle: 'Name, email, phone',
            onTap: () => context.push('/settings/profile'),
          ),
          _SettingsTile(
            icon: Icons.account_balance_outlined,
            label: 'Accounts & cards',
            subtitle: 'Add or manage linked accounts',
            onTap: () => context.go('/accounts'),
          ),
          _SettingsTile(
            icon: Icons.pie_chart_outline_rounded,
            label: 'Budgets',
            subtitle: 'Set monthly spending limits',
            onTap: () => context.push('/budgets'),
          ),
          _SettingsTile(
            icon: Icons.flag_outlined,
            label: 'Savings goals',
            subtitle: 'Track what you are saving for',
            onTap: () => context.push('/goals'),
          ),
          _SettingsTile(
            icon: Icons.insights_outlined,
            label: 'Analytics',
            subtitle: 'See where your money goes',
            onTap: () => context.push('/analytics'),
          ),
          const SizedBox(height: 20),
          Text('Support', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _SettingsTile(icon: Icons.help_outline_rounded, label: 'Help & FAQ', onTap: () {}),
          _SettingsTile(icon: Icons.logout_rounded, label: 'Log out', color: AppColors.danger, onTap: () {}),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.label, this.subtitle, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.darkGreen),
        title: Text(label, style: TextStyle(color: color)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
