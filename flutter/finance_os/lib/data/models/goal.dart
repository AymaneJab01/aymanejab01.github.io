class SavingsGoal {
  final String id;
  final String name;
  final double target;
  final double saved;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.target,
    required this.saved,
  });

  double get progress {
    if (target <= 0) return 0;
    return (saved / target).clamp(0.0, 1.0);
  }

  double get remaining => (target - saved).clamp(0, target);
}
