class Expense {
  final String id;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> participants;

  const Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.participants,
  });

  double get sharePerPerson {
    if (participants.isEmpty) {
      return 0;
    }

    return amount / participants.length;
  }

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    String? paidBy,
    List<String>? participants,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      participants: participants ?? this.participants,
    );
  }
}
