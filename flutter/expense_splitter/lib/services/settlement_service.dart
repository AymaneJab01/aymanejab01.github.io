import '../models/expense.dart';
import '../models/person.dart';

class Settlement {
  final Person from;
  final Person to;
  final double amount;

  const Settlement({
    required this.from,
    required this.to,
    required this.amount,
  });
}

class SettlementService {
  static List<Settlement> calculateSettlements({
    required List<Person> people,
    required List<Expense> expenses,
  }) {
    final balances = <String, double>{};

    for (final person in people) {
      balances[person.id] = 0;
    }

    for (final expense in expenses) {
      if (!balances.containsKey(expense.paidBy)) {
        continue;
      }

      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;

      if (expense.participants.isNotEmpty) {
        final share = expense.amount / expense.participants.length;

        for (final participant in expense.participants) {
          if (!balances.containsKey(participant)) {
            continue;
          }

          balances[participant] =
              (balances[participant] ?? 0) - share;
        }
      }
    }

    final creditors = <MapEntry<String, double>>[];
    final debtors = <MapEntry<String, double>>[];

    balances.forEach((personId, balance) {
      if (balance > 0.01) {
        creditors.add(
          MapEntry(personId, balance),
        );
      } else if (balance < -0.01) {
        debtors.add(
          MapEntry(personId, -balance),
        );
      }
    });

    final settlements = <Settlement>[];

    int creditorIndex = 0;
    int debtorIndex = 0;

    while (
        creditorIndex < creditors.length &&
        debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];

      final amount = creditor.value < debtor.value
          ? creditor.value
          : debtor.value;

      final from = people.firstWhere(
        (person) => person.id == debtor.key,
      );

      final to = people.firstWhere(
        (person) => person.id == creditor.key,
      );

      settlements.add(
        Settlement(
          from: from,
          to: to,
          amount: amount,
        ),
      );

      final remainingCredit = creditor.value - amount;
      final remainingDebt = debtor.value - amount;

      creditors[creditorIndex] = MapEntry(
        creditor.key,
        remainingCredit,
      );

      debtors[debtorIndex] = MapEntry(
        debtor.key,
        remainingDebt,
      );

      if (remainingCredit.abs() < 0.01) {
        creditorIndex++;
      }

      if (remainingDebt.abs() < 0.01) {
        debtorIndex++;
      }
    }

    return settlements;
  }

  static Map<String, double> calculateBalances({
    required List<Person> people,
    required List<Expense> expenses,
  }) {
    final balances = <String, double>{};

    for (final person in people) {
      balances[person.id] = 0;
    }

    for (final expense in expenses) {
      if (!balances.containsKey(expense.paidBy)) {
        continue;
      }

      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;

      if (expense.participants.isEmpty) {
        continue;
      }

      final share =
          expense.amount / expense.participants.length;

      for (final participant in expense.participants) {
        if (!balances.containsKey(participant)) {
          continue;
        }

        balances[participant] =
            (balances[participant] ?? 0) - share;
      }
    }

    return balances;
  }
}
