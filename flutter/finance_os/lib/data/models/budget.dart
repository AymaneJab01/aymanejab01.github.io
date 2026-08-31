class Budget {
  final String id;
  final String category;
  final double limit;
  final double spent;

  const Budget({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
  });

  double get progress {
    if (limit <= 0) return 0;
    return (spent / limit).clamp(0.0, 1.0);
  }

  bool get exceeded => spent > limit;

  double get remaining => limit - spent;
}
