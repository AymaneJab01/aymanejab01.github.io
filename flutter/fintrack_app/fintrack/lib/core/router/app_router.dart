import 'package:go_router/go_router.dart';
import '../widgets/app_scaffold.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/transactions/transactions_screen.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../features/accounts/accounts_screen.dart';
import '../../features/accounts/add_account_screen.dart';
import '../../features/budgets/budgets_screen.dart';
import '../../features/budgets/add_budget_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/goals/add_goal_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/profile_screen.dart';
import '../../data/models/models.dart';

/// One file, one source of truth for every route in the app.
/// `ShellRoute` keeps the bottom nav bar mounted around the 4 main tabs;
/// everything else (add/edit forms, profile, analytics, budgets, goals)
/// is a normal route reached from a tab and always has Back + Home
/// buttons via [DetailScaffold].
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final index = switch (state.uri.path) {
            '/' => 0,
            '/transactions' => 1,
            '/accounts' => 2,
            '/settings' => 3,
            _ => 0,
          };
          return MainShell(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(
            path: '/transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(path: '/accounts', builder: (context, state) => const AccountsScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),

      // --- Add / edit / detail routes (outside the bottom nav shell) ---
      GoRoute(
        path: '/transactions/add',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transactions/edit',
        builder: (context, state) =>
            AddTransactionScreen(existing: state.extra as TransactionModel?),
      ),
      GoRoute(
        path: '/accounts/add',
        builder: (context, state) => const AddAccountScreen(),
      ),
      GoRoute(
        path: '/accounts/edit',
        builder: (context, state) => AddAccountScreen(existing: state.extra as AccountModel?),
      ),
      GoRoute(path: '/budgets', builder: (context, state) => const BudgetsScreen()),
      GoRoute(path: '/budgets/add', builder: (context, state) => const AddBudgetScreen()),
      GoRoute(
        path: '/budgets/edit',
        builder: (context, state) => AddBudgetScreen(existing: state.extra as BudgetModel?),
      ),
      GoRoute(path: '/goals', builder: (context, state) => const GoalsScreen()),
      GoRoute(path: '/goals/add', builder: (context, state) => const AddGoalScreen()),
      GoRoute(
        path: '/goals/edit',
        builder: (context, state) => AddGoalScreen(existing: state.extra as GoalModel?),
      ),
      GoRoute(path: '/analytics', builder: (context, state) => const AnalyticsScreen()),
      GoRoute(path: '/settings/profile', builder: (context, state) => const ProfileScreen()),
    ],
  );
}
