class Expense {
  final int id;
  final String description;

  /// Amount stored in cents.
  final int amountCents;

  final int payerId;

  const Expense({
    required this.id,
    required this.description,
    required this.amountCents,
    required this.payerId,
  });
}