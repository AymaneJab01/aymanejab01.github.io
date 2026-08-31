import '../models/budget.dart';
import '../models/goal.dart';
import '../models/transaction.dart';

class FinanceRepository {
  final List<FinanceTransaction> transactions = [
    FinanceTransaction(
      id: '1',
      title: 'Monthly salary',
      category: 'Income',
      amount: 2400,
      date: DateTime(2026, 8, 1),
      type: TransactionType.income,
    ),
    FinanceTransaction(
      id: '2',
      title: 'Groceries',
      category: 'Food',
      amount: 42.30,
      date: DateTime(2026, 8, 29),
      type: TransactionType.expense,
    ),
    FinanceTransaction(
      id: '3',
      title: 'Transport',
      category: 'Transport',
      amount: 15,
      date: DateTime(2026, 8, 28),
      type: TransactionType.expense,
    ),
    FinanceTransaction(
      id: '4',
      title: 'Netflix',
      category: 'Entertainment',
      amount: 13.99,
      date: DateTime(2026, 8, 27),
      type: TransactionType.expense,
    ),
    FinanceTransaction(
      id: '5',
      title: 'Restaurant',
      category: 'Food',
      amount: 32,
      date: DateTime(2026, 8, 25),
      type: TransactionType.expense,
    ),
  ];

  final List<Budget> budgets = const [
    Budget(
      id: '1',
      category: 'Food',
      limit: 300,
      spent: 182,
    ),
    Budget(
      id: '2',
      category: 'Transport',
      limit: 150,
      spent: 74,
    ),
    Budget(
      id: '3',
      category: 'Entertainment',
      limit: 100,
      spent: 120,
    ),
    Budget(
      id: '4',
      category: 'Bills',
      limit: 400,
      spent: 290,
    ),
  ];

  final List<SavingsGoal> goals = const [
    SavingsGoal(
      id: '1',
      name: 'Emergency Fund',
      target: 3000,
      saved: 1800,
    ),
    SavingsGoal(
      id: '2',
      name: 'New Laptop',
      target: 1800,
      saved: 1120,
    ),
    SavingsGoal(
      id: '3',
      name: 'Vacation',
      target: 1500,
      saved: 620,
    ),
  ];
}
