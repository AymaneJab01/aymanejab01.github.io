import 'package:flutter/material.dart';

import '../main.dart' show AppColors;
import '../models/expense.dart';
import '../models/person.dart';
import '../services/settlement_service.dart';
import '../widgets/expense_card.dart';
import '../widgets/person_chip.dart';
import '../widgets/settlement_card.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Person> _people = [
    const Person(
      id: '1',
      name: 'Aymane',
    ),
    const Person(
      id: '2',
      name: 'Alex',
    ),
    const Person(
      id: '3',
      name: 'Sarah',
    ),
  ];

  final List<Expense> _expenses = [];

  final TextEditingController _personController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _amountController = TextEditingController();

  String? _selectedPayer;

  final Set<String> _selectedParticipants = {};

  @override
  void initState() {
    super.initState();

    _selectedPayer = _people.firstOrNull?.id;

    _selectedParticipants.addAll(
      _people.map((person) => person.id),
    );
  }

  @override
  void dispose() {
    _personController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get totalExpenses {
    return _expenses.fold<double>(
      0.0,
      (total, expense) => total + expense.amount,
    );
  }

  List<Settlement> get settlements {
    return SettlementService.calculateSettlements(
      people: _people,
      expenses: _expenses,
    );
  }

  void _addPerson() {
    final name = _personController.text.trim();

    if (name.isEmpty) {
      return;
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();

    setState(() {
      final person = Person(
        id: id,
        name: name,
      );

      _people.add(person);
      _selectedParticipants.add(id);

      _selectedPayer ??= id;

      _personController.clear();
    });

    Navigator.of(context).pop();
  }

  void _showAddPersonDialog() {
    _personController.clear();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: AppColors.border,
            ),
          ),
          title: const Text(
            'Add person',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: _personController,
            autofocus: true,
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Person name',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.accent,
              ),
              filled: true,
              fillColor: AppColors.surfaceRaised,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
              ),
            ),
            onSubmitted: (_) => _addPerson(),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _addPerson,
              child: const Text('Add person'),
            ),
          ],
        );
      },
    );
  }

  void _removePerson(Person person) {
    if (_people.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'You need at least one person in the group.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
      );
      return;
    }

    final hasExpenses = _expenses.any(
      (expense) =>
          expense.paidBy == person.id ||
          expense.participants.contains(person.id),
    );

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: AppColors.border,
            ),
          ),
          title: const Text(
            'Remove person',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            hasExpenses
                ? '${person.name} will be removed from the group. '
                    'Expenses they paid will be deleted, and they will '
                    'be dropped from any expenses they were splitting.'
                : '${person.name} will be removed from the group.',
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePerson(person);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _deletePerson(Person person) {
    setState(() {
      _people.removeWhere(
        (item) => item.id == person.id,
      );

      _expenses.removeWhere(
        (expense) => expense.paidBy == person.id,
      );

      for (var i = 0; i < _expenses.length; i++) {
        final expense = _expenses[i];

        if (expense.participants.contains(person.id)) {
          _expenses[i] = expense.copyWith(
            participants:
                expense.participants.where((id) => id != person.id).toList(),
          );
        }
      }

      _expenses.removeWhere(
        (expense) => expense.participants.isEmpty,
      );

      _selectedParticipants.remove(person.id);

      if (_selectedPayer == person.id) {
        _selectedPayer = _people.firstOrNull?.id;
      }
    });
  }

  void _addExpense() {
    final description = _descriptionController.text.trim();

    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    if (description.isEmpty ||
        amount == null ||
        amount <= 0 ||
        _selectedPayer == null ||
        _selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Enter a description, a valid amount, a payer and at least one participant.',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
      );
      return;
    }

    final expense = Expense(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      paidBy: _selectedPayer!,
      participants: List<String>.from(_selectedParticipants),
    );

    setState(() {
      _expenses.add(expense);
      _descriptionController.clear();
      _amountController.clear();
    });

    FocusScope.of(context).unfocus();
  }

  void _deleteExpense(Expense expense) {
    setState(() {
      _expenses.removeWhere(
        (item) => item.id == expense.id,
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1210),
            Color(0xFF0A0D0B),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderGlow,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.14),
            blurRadius: 40,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderGlow,
                      ),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.accent,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          AppColors.accent,
                          Color(0xFFB6FFD1),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'Expense Splitter',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 24 : 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Split expenses. Track balances. Settle simply.',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Keep track of shared expenses and calculate the minimum number of transfers needed to settle the group.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummary() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 3
            : constraints.maxWidth >= 560
                ? 2
                : 1;

        final ratio = columns == 3
            ? 1.65
            : columns == 2
                ? 1.7
                : 2.7;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: ratio,
          children: [
            SummaryCard(
              title: 'TOTAL EXPENSES',
              value: '€${totalExpenses.toStringAsFixed(2)}',
              icon: Icons.euro_rounded,
              subtitle:
                  '${_expenses.length} expense${_expenses.length == 1 ? '' : 's'}',
            ),
            SummaryCard(
              title: 'PEOPLE',
              value: '${_people.length}',
              icon: Icons.people_outline_rounded,
              subtitle: 'in this group',
            ),
            SummaryCard(
              title: 'TRANSFERS',
              value: '${settlements.length}',
              icon: Icons.swap_horiz_rounded,
              subtitle: 'needed to settle',
            ),
          ],
        );
      },
    );
  }

  Widget _buildPeopleSection() {
    return _section(
      icon: Icons.people_outline_rounded,
      title: 'People',
      subtitle: 'Everyone included in the group. Tap × to remove.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ..._people.map(
            (person) => PersonChip(
              person: person,
              onDelete: () => _removePerson(person),
            ),
          ),
          ActionChip(
            avatar: const Icon(
              Icons.add_rounded,
              size: 18,
              color: AppColors.accent,
            ),
            label: const Text('Add person'),
            labelStyle: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
            backgroundColor: AppColors.accentDeep.withValues(
              alpha: 0.18,
            ),
            side: const BorderSide(
              color: AppColors.borderGlow,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onPressed: _showAddPersonDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    return _section(
      icon: Icons.add_card_rounded,
      title: 'Add expense',
      subtitle: 'Record who paid and who should share the cost.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _descriptionController,
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Dinner, hotel, groceries...',
              prefixIcon: Icon(
                Icons.receipt_long_outlined,
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 13),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: '0.00',
              prefixIcon: Icon(
                Icons.euro_rounded,
              ),
            ),
            onSubmitted: (_) => _addExpense(),
          ),
          const SizedBox(height: 22),
          const Text(
            'Paid by',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _people.map((person) {
              return PersonChip(
                person: person,
                selected: _selectedPayer == person.id,
                onTap: () {
                  setState(() {
                    _selectedPayer = person.id;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 22),
          const Text(
            'Split between',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Select everyone who should share this expense.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _people.map((person) {
              return PersonChip(
                person: person,
                selected: _selectedParticipants.contains(person.id),
                onTap: () {
                  setState(() {
                    if (_selectedParticipants.contains(person.id)) {
                      _selectedParticipants.remove(person.id);
                    } else {
                      _selectedParticipants.add(person.id);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _addExpense,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Add expense',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenses() {
    return _section(
      icon: Icons.receipt_long_outlined,
      title: 'Expenses',
      subtitle: 'Everything spent by the group.',
      child: _expenses.isEmpty
          ? _emptyState(
              icon: Icons.receipt_long_outlined,
              text: 'No expenses yet. Add your first expense above.',
            )
          : Column(
              children: _expenses
                  .map(
                    (expense) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ExpenseCard(
                        expense: expense,
                        people: _people,
                        onDelete: () => _deleteExpense(expense),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildSettlements() {
    return _section(
      icon: Icons.swap_horiz_rounded,
      title: 'Settlement',
      subtitle: 'The minimum transfers needed to settle everyone.',
      child: settlements.isEmpty
          ? _emptyState(
              icon: Icons.check_circle_outline_rounded,
              text: _expenses.isEmpty
                  ? 'Add expenses to calculate the settlement.'
                  : 'Everyone is already settled.',
            )
          : Column(
              children: settlements
                  .map(
                    (settlement) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: SettlementCard(
                        settlement: settlement,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _section({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.35,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: AppColors.borderGlow,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.borderGlow,
              ),
            ),
            child: Icon(
              icon,
              size: 27,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 13),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildSummary(),
                  const SizedBox(height: 18),
                  _buildPeopleSection(),
                  const SizedBox(height: 18),
                  _buildExpenseForm(),
                  const SizedBox(height: 18),
                  _buildExpenses(),
                  const SizedBox(height: 18),
                  _buildSettlements(),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      'Expense Splitter  ·  Flutter & Dart',
                      style: TextStyle(
                        color: AppColors.textFaint,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
