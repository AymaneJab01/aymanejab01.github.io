import 'package:flutter/material.dart';

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

  final TextEditingController _personController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  String? _selectedPayer;

  final Set<String> _selectedParticipants = {};

  @override
  void initState() {
    super.initState();

    if (_people.isNotEmpty) {
      _selectedPayer = _people.first.id;

      _selectedParticipants.addAll(
        _people.map((person) => person.id),
      );
    }
  }

  @override
  void dispose() {
    _personController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();

    super.dispose();
  }

  double get totalExpenses {
    return _expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
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

    final id = DateTime.now()
        .microsecondsSinceEpoch
        .toString();

    setState(() {
      final person = Person(
        id: id,
        name: name,
      );

      _people.add(person);
      _selectedParticipants.add(id);

      if (_selectedPayer == null) {
        _selectedPayer = id;
      }

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
          backgroundColor: const Color(0xFF171717),

          title: const Text(
            'Add person',
            style: TextStyle(color: Colors.white),
          ),

          content: TextField(
            controller: _personController,
            autofocus: true,

            style: const TextStyle(
              color: Colors.white,
            ),

            decoration: const InputDecoration(
              hintText: 'Person name',
            ),

            onSubmitted: (_) => _addPerson(),
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
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF15803D),
              ),

              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addExpense() {
    final description =
        _descriptionController.text.trim();

    final amount =
        double.tryParse(_amountController.text.trim());

    if (description.isEmpty ||
        amount == null ||
        amount <= 0 ||
        _selectedPayer == null ||
        _selectedParticipants.isEmpty) {
      return;
    }

    final expense = Expense(
      id: DateTime.now()
          .microsecondsSinceEpoch
          .toString(),

      description: description,

      amount: amount,

      paidBy: _selectedPayer!,

      participants:
          List<String>.from(_selectedParticipants),
    );

    setState(() {
      _expenses.add(expense);

      _descriptionController.clear();
      _amountController.clear();
    });
  }

  void _deleteExpense(Expense expense) {
    setState(() {
      _expenses.removeWhere(
        (item) => item.id == expense.id,
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,

              decoration: BoxDecoration(
                color:
                    const Color(0xFF15803D).withOpacity(0.12),

                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF15803D),
              ),
            ),

            const SizedBox(width: 14),

            const Text(
              'Expense Splitter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        const Text(
          'Track shared expenses and settle balances with the minimum number of transfers.',
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return GridView.count(
      crossAxisCount:
          MediaQuery.of(context).size.width > 800
              ? 3
              : 1,

      shrinkWrap: true,

      physics:
          const NeverScrollableScrollPhysics(),

      mainAxisSpacing: 12,
      crossAxisSpacing: 12,

      childAspectRatio:
          MediaQuery.of(context).size.width > 800
              ? 2.2
              : 3.2,

      children: [
        SummaryCard(
          title: 'TOTAL EXPENSES',
          value:
              '€${totalExpenses.toStringAsFixed(2)}',
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
  }

  Widget _buildPeopleSection() {
    return _section(
      title: 'People',
      subtitle: 'Everyone included in the group.',

      child: Wrap(
        spacing: 8,
        runSpacing: 8,

        children: [
          ..._people.map(
            (person) => PersonChip(
              person: person,
            ),
          ),

          ActionChip(
            avatar: const Icon(
              Icons.add,
              size: 18,
            ),

            label: const Text('Add person'),

            onPressed: _showAddPersonDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseForm() {
    return _section(
      title: 'Add expense',
      subtitle:
          'Record who paid and who should share the cost.',

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          TextField(
            controller: _descriptionController,

            style: const TextStyle(
              color: Colors.white,
            ),

            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Dinner, hotel, groceries...',
              prefixIcon:
                  Icon(Icons.receipt_long_outlined),
            ),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: _amountController,

            keyboardType:
                const TextInputType.numberWithOptions(
              decimal: true,
            ),

            style: const TextStyle(
              color: Colors.white,
            ),

            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: '0.00',
              prefixIcon:
                  Icon(Icons.euro_rounded),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Paid by',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 9),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children: _people.map((person) {
              return PersonChip(
                person: person,

                selected:
                    _selectedPayer == person.id,

                onTap: () {
                  setState(() {
                    _selectedPayer = person.id;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          const Text(
            'Split between',
            style: TextStyle(
              color: Color(0xFF999999),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 9),

          Wrap(
            spacing: 8,
            runSpacing: 8,

            children: _people.map((person) {
              return PersonChip(
                person: person,

                selected: _selectedParticipants
                    .contains(person.id),

                onTap: () {
                  setState(() {
                    if (_selectedParticipants
                        .contains(person.id)) {
                      _selectedParticipants
                          .remove(person.id);
                    } else {
                      _selectedParticipants
                          .add(person.id);
                    }
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,

            child: FilledButton.icon(
              onPressed: _addExpense,

              icon: const Icon(
                Icons.add_rounded,
              ),

              label: const Text(
                'Add expense',
              ),

              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFF15803D),

                foregroundColor: Colors.white,

                padding:
                    const EdgeInsets.symmetric(
                  vertical: 16,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
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
      title: 'Expenses',
      subtitle:
          'Everything spent by the group.',

      child: _expenses.isEmpty
          ? _emptyState(
              icon:
                  Icons.receipt_long_outlined,
              text:
                  'No expenses yet. Add your first expense above.',
            )
          : Column(
              children: _expenses
                  .map(
                    (expense) => Padding(
                      padding:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),

                      child: ExpenseCard(
                        expense: expense,
                        people: _people,

                        onDelete: () =>
                            _deleteExpense(expense),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _buildSettlements() {
    return _section(
      title: 'Settlement',
      subtitle:
          'The minimum transfers needed to settle everyone.',

      child: settlements.isEmpty
          ? _emptyState(
              icon: Icons.check_circle_outline,
              text: _expenses.isEmpty
                  ? 'Add expenses to calculate the settlement.'
                  : 'Everyone is already settled.',
            )
          : Column(
              children: settlements
                  .map(
                    (settlement) => Padding(
                      padding:
                          const EdgeInsets.only(
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
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: const Color(0xFF111111),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: const Color(0xFF282828),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 13,
            ),
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
        vertical: 28,
        horizontal: 20,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: const Color(0xFF555555),
          ),

          const SizedBox(height: 10),

          Text(
            text,
            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 1100,
            ),

            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 40,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  _buildHeader(),

                  const SizedBox(height: 30),

                  _buildSummary(),

                  const SizedBox(height: 18),

                  _buildPeopleSection(),

                  const SizedBox(height: 18),

                  _buildExpenseForm(),

                  const SizedBox(height: 18),

                  _buildExpenses(),

                  const SizedBox(height: 18),

                  _buildSettlements(),

                  const SizedBox(height: 30),

                  Center(
                    child: Text(
                      'Expense Splitter · Flutter & Dart',
                      style: const TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
