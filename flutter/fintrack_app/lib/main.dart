import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/repositories/repositories.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final transactionRepo = TransactionRepository();
  final accountRepo = AccountRepository();
  final budgetRepo = BudgetRepository();
  final goalRepo = GoalRepository();
  final profileRepo = ProfileRepository();

  // Load anything already saved on disk before the first frame,
  // so the dashboard never flashes empty state on startup.
  await Future.wait([
    transactionRepo.load(),
    accountRepo.load(),
    budgetRepo.load(),
    goalRepo.load(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: transactionRepo),
        ChangeNotifierProvider.value(value: accountRepo),
        ChangeNotifierProvider.value(value: budgetRepo),
        ChangeNotifierProvider.value(value: goalRepo),
        ChangeNotifierProvider.value(value: profileRepo),
      ],
      child: const FinTrackApp(),
    ),
  );
}

class FinTrackApp extends StatelessWidget {
  const FinTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
