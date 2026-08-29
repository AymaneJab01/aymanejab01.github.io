import '../models/expense.dart';
import '../models/person.dart';

class Balance {
  final int personId;
  final String name;

  /// Positive = person should receive money.
  /// Negative = person owes money.
  int cents;

  Balance({
    required this.personId,
    required this.name,
    required this.cents,
  });
}

class Transfer {
  final String from;
  final String to;
  final int cents;

  const Transfer({
    required this.from,
    required this.to,
    required this.cents,
  });
}

class SettlementService {
  static int calculateTotal(List<Expense> expenses) {
    return expenses.fold(
      0,
      (sum, expense) => sum + expense.amountCents,
    );
  }

  static List<Balance> calculateBalances({
    required List<Person> people,
    required List<Expense> expenses,
  }) {
    if (people.isEmpty) {
      return [];
    }

    final totalCents = calculateTotal(expenses);

    final baseShare = totalCents ~/ people.length;
    final remainder = totalCents % people.length;

    final paidByPerson = <int, int>{
      for (final person in people) person.id: 0,
    };

    for (final expense in expenses) {
      paidByPerson[expense.payerId] =
          (paidByPerson[expense.payerId] ?? 0) +
              expense.amountCents;
    }

    return List.generate(
      people.length,
      (index) {
        final person = people[index];

        // Distribute remaining cents deterministically.
        final share = baseShare + (index < remainder ? 1 : 0);

        return Balance(
          personId: person.id,
          name: person.name,
          cents: (paidByPerson[person.id] ?? 0) - share,
        );
      },
    );
  }

  static List<Transfer> calculateTransfers({
    required List<Person> people,
    required List<Expense> expenses,
  }) {
    final balances = calculateBalances(
      people: people,
      expenses: expenses,
    );

    final creditors = balances
        .where((balance) => balance.cents > 0)
        .map(
          (balance) => Balance(
            personId: balance.personId,
            name: balance.name,
            cents: balance.cents,
          ),
        )
        .toList();

    final debtors = balances
        .where((balance) => balance.cents < 0)
        .map(
          (balance) => Balance(
            personId: balance.personId,
            name: balance.name,
            cents: balance.cents,
          ),
        )
        .toList();

    creditors.sort(
      (a, b) => b.cents.compareTo(a.cents),
    );

    debtors.sort(
      (a, b) => a.cents.compareTo(b.cents),
    );

    final transfers = <Transfer>[];

    var creditorIndex = 0;
    var debtorIndex = 0;

    while (
        creditorIndex < creditors.length &&
        debtorIndex < debtors.length) {
      final creditor = creditors[creditorIndex];
      final debtor = debtors[debtorIndex];

      final amount = creditor.cents < -debtor.cents
          ? creditor.cents
          : -debtor.cents;

      if (amount > 0) {
        transfers.add(
          Transfer(
            from: debtor.name,
            to: creditor.name,
            cents: amount,
          ),
        );
      }

      creditor.cents -= amount;
      debtor.cents += amount;

      if (creditor.cents == 0) {
        creditorIndex++;
      }

      if (debtor.cents == 0) {
        debtorIndex++;
      }
    }

    return transfers;
  }
}