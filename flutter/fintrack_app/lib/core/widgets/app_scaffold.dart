import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

/// Wraps the 4 main tabs (Home / Activity / Banking / Account) with a
/// bottom navigation bar. This is what `ShellRoute` renders.
class MainShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({super.key, required this.child, required this.currentIndex});

  static const _tabs = [
    (route: '/', icon: Icons.home_rounded, label: 'Home'),
    (route: '/transactions', icon: Icons.show_chart_rounded, label: 'Activity'),
    (route: '/accounts', icon: Icons.account_balance_rounded, label: 'Banking'),
    (route: '/settings', icon: Icons.person_rounded, label: 'Account'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => context.go(_tabs[i].route),
        items: _tabs
            .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}

/// Every "sub" screen (add transaction, edit account, profile, etc.)
/// uses this instead of a plain Scaffold. It always shows:
///   • a Back button (pops the current screen)
///   • a Home button (jumps straight back to the dashboard)
/// so the user is never stuck without a way back — on phone, tablet
/// or a resized desktop window.
class DetailScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const DetailScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(title),
        actions: [
          ...?actions,
          IconButton(
            tooltip: 'Go to Home',
            icon: const Icon(Icons.home_rounded, color: AppColors.darkGreen),
            onPressed: () => context.go('/'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
