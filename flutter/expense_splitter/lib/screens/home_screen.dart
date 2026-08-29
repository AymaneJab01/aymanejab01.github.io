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
  final TextEditingController _personController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _amountController =
      TextEditingController();

  final FocusNode _personFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  List<Person> _people = [];
  List<Expense> _expenses = [];

  int _nextPersonId = 1;
  int _nextExpenseId = 1;

  int? _selectedPayerId;

  String? _message;

  static const purple = Color(0xFFA476FF);
  static const green = Color(0xFF6EE7B7);

  @override
  void dispose() {
    _personController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();

    _personFocus.dispose();
    _descriptionFocus.dispose();

    super.dispose();
  }

  String _formatCents(int cents) {
    return '\$${(cents / 100).toStringAsFixed(2)}';
  }

  int get _totalCents {
    return SettlementService.calculateTotal(_expenses);
  }

  List<Transfer> get _transfers {
    return SettlementService.calculateTransfers(
      people: _people,
      expenses: _expenses,
    );
  }

  void _showMessage(String? message) {
    setState(() {
      _message = message;
    });
  }

  void _addPerson() {
    final name = _personController.text.trim();

    if (name.isEmpty) {
      _showMessage('Enter a person\'s name.');
      _personFocus.requestFocus();
      return;
    }

    final alreadyExists = _people.any(
      (person) =>
          person.name.toLowerCase() == name.toLowerCase(),
    );

    if (alreadyExists) {
      _showMessage('That person is already in the group.');
      _personController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _personController.text.length,
      );
      return;
    }

    setState(() {
      _people = [
        ..._people,
        Person(
          id: _nextPersonId++,
          name: name,
        ),
      ];

      _personController.clear();
      _message = null;

      _selectedPayerId ??= _people.first.id;
    });

    _personFocus.requestFocus();
  }

  int? _parseAmount(String value) {
    final normalized = value.trim().replaceAll(',', '.');

    if (normalized.isEmpty) {
      return null;
    }

    final regex = RegExp(r'^\d+(\.\d{1,2})?$');

    if (!regex.hasMatch(normalized)) {
      return null;
    }

    final amount = double.tryParse(normalized);

    if (amount == null || !amount.isFinite || amount <= 0) {
      return null;
    }

    return (amount * 100).round();
  }

  void _addExpense() {
    if (_people.isEmpty) {
      _showMessage('Add at least one person first.');
      return;
    }

    final description =
        _descriptionController.text.trim();

    final amountCents =
        _parseAmount(_amountController.text);

    if (description.isEmpty) {
      _showMessage('Enter a description.');
      _descriptionFocus.requestFocus();
      return;
    }

    if (amountCents == null) {
      _showMessage(
        'Enter a valid amount, for example 24.50.',
      );
      return;
    }

    final payerId = _selectedPayerId;

    if (payerId == null ||
        !_people.any((person) => person.id == payerId)) {
      _showMessage('Choose who paid the expense.');
      return;
    }

    setState(() {
      _expenses = [
        ..._expenses,
        Expense(
          id: _nextExpenseId++,
          description: description,
          amountCents: amountCents,
          payerId: payerId,
        ),
      ];

      _descriptionController.clear();
      _amountController.clear();
      _message = null;
    });

    _descriptionFocus.requestFocus();
  }

  void _removePerson(Person person) {
    setState(() {
      _people =
          _people.where((p) => p.id != person.id).toList();

      _expenses = _expenses
          .where((expense) => expense.payerId != person.id)
          .toList();

      if (_selectedPayerId == person.id) {
        _selectedPayerId =
            _people.isEmpty ? null : _people.first.id;
      }
    });
  }

  void _reset() {
    setState(() {
      _people = [];
      _expenses = [];

      _nextPersonId = 1;
      _nextExpenseId = 1;

      _selectedPayerId = null;

      _personController.clear();
      _descriptionController.clear();
      _amountController.clear();

      _message = null;
    });
  }

  void _loadExample() {
    setState(() {
      _people = const [
        Person(id: 1, name: 'Alex'),
        Person(id: 2, name: 'Sam'),
        Person(id: 3, name: 'Jo'),
        Person(id: 4, name: 'Mia'),
      ];

      _expenses = const [
        Expense(
          id: 1,
          description: 'Dinner',
          amountCents: 6000,
          payerId: 1,
        ),
        Expense(
          id: 2,
          description: 'Taxi',
          amountCents: 1800,
          payerId: 2,
        ),
        Expense(
          id: 3,
          description: 'Tickets',
          amountCents: 4000,
          payerId: 3,
        ),
      ];

      _nextPersonId = 5;
      _nextExpenseId = 4;
      _selectedPayerId = 1;

      _personController.clear();
      _descriptionController.clear();
      _amountController.clear();

      _message = null;
    });
  }

  Widget _sectionTitle(
    String number,
    String title,
  ) {
    return Row(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: purple,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 35,
          height: 1,
          color: purple.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 9,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _panel({
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x263F3F3F),
        ),
      ),
      child: child,
    );
  }

  Widget _buildPeoplePanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PEOPLE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _personController,
                  focusNode: _personFocus,
                  maxLength: 18,
                  onSubmitted: (_) => _addPerson(),
                  decoration: const InputDecoration(
                    hintText: 'name',
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _primaryButton(
                label: 'Add',
                icon: Icons.add,
                onPressed: _addPerson,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_people.isEmpty)
            _emptyBox('No one added yet.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _people
                  .map(
                    (person) => PersonChip(
                      name: person.name,
                      onRemove: () => _removePerson(person),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildExpensePanel() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEW EXPENSE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descriptionController,
            focusNode: _descriptionFocus,
            maxLength: 30,
            onSubmitted: (_) => _addExpense(),
            decoration: const InputDecoration(
              hintText: 'what was it for',
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 430) {
                return Column(
                  children: [
                    TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'amount',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _payerDropdown(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'amount',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _payerDropdown(),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          _primaryButton(
            label: 'Add expense',
            icon: Icons.add,
            onPressed: _addExpense,
          ),
          if (_message != null) ...[
            const SizedBox(height: 10),
            Text(
              _message!,
              style: const TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _payerDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedPayerId,
      isExpanded: true,
      decoration: const InputDecoration(
        hintText: 'payer',
      ),
      items: _people
          .map(
            (person) => DropdownMenuItem<int>(
              value: person.id,
              child: Text(
                person.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedPayerId = value;
        });
      },
    );
  }

  Widget _buildExpenses() {
    if (_expenses.isEmpty) {
      return _emptyBox('No expenses logged yet.');
    }

    return Column(
      children: _expenses.map((expense) {
        final payer = _people.cast<Person?>().firstWhere(
              (person) => person?.id == expense.payerId,
              orElse: () => null,
            );

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ExpenseCard(
            expense: expense,
            payerName: payer?.name ?? 'Unknown',
            formatCents: _formatCents,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettlement() {
    if (_people.isEmpty) {
      return _emptyBox(
        'Add people to calculate a settlement.',
      );
    }

    if (_expenses.isEmpty) {
      return _emptyBox(
        'Add an expense to calculate a settlement.',
      );
    }

    if (_transfers.isEmpty) {
      return _emptyBox(
        'Everyone is even — no transfers needed.',
      );
    }

    return Column(
      children: _transfers.map((transfer) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SettlementCard(
            transfer: transfer,
            formatCents: _formatCents,
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0x33444444),
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: purple,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }

  Widget _outlineButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white70,
        side: const BorderSide(
          color: Color(0x33444444),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1100,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 35,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'PROJECT 07',
                'Flutter Mobile',
              ),
              const SizedBox(height: 18),
              const Text(
                'Splitting the bill,\nfairly.',
                style: TextStyle(
                  fontSize: 42,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'A Flutter expense splitting application. '
                'Add people, record expenses, and calculate '
                'who owes whom with the minimum number of transfers.',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _tag('Flutter & Dart'),
                  _tag('State Management'),
                  _tag('Expense Tracking'),
                  _tag('Settlement Algorithm'),
                ],
              ),
              const SizedBox(height: 35),

              // Summary
              GridView.count(
                crossAxisCount:
                    MediaQuery.of(context).size.width < 550
                        ? 2
                        : 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  SummaryCard(
                    label: 'Total spent',
                    value: _formatCents(_totalCents),
                    icon: Icons.payments_outlined,
                  ),
                  SummaryCard(
                    label: 'People',
                    value: '${_people.length}',
                    icon: Icons.groups_outlined,
                  ),
                  SummaryCard(
                    label: 'Expenses',
                    value: '${_expenses.length}',
                    icon: Icons.receipt_long_outlined,
                  ),
                  SummaryCard(
                    label: 'Transfers',
                    value: '${_transfers.length}',
                    icon: Icons.swap_horiz_rounded,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              _panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      '01',
                      'Interactive Expense Splitter',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Manage your group expenses',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add people and expenses. The settlement engine '
                      'will automatically calculate the required payments.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 750) {
                          return Column(
                            children: [
                              _buildPeoplePanel(),
                              const SizedBox(height: 12),
                              _buildExpensePanel(),
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildPeoplePanel(),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: _buildExpensePanel(),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 25),

                    const Text(
                      'EXPENSES',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildExpenses(),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'SETTLEMENT',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'MINIMUM TRANSFERS',
                          style: TextStyle(
                            color: green.withValues(alpha: 0.65),
                            fontSize: 9,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildSettlement(),

                    const SizedBox(height: 22),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _outlineButton(
                          label: 'Reset',
                          icon: Icons.refresh_rounded,
                          onPressed: _reset,
                        ),
                        _outlineButton(
                          label: 'Load example',
                          icon: Icons.auto_awesome_outlined,
                          onPressed: _loadExample,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _buildConcepts(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConcepts() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            '02',
            'How it works',
          ),
          const SizedBox(height: 15),
          const Text(
            'From expenses to balances.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    _concept(
                      '01',
                      'Equal share',
                      'Total expenses are divided equally '
                          'between all active people.',
                    ),
                    const SizedBox(height: 8),
                    _concept(
                      '02',
                      'Calculate balances',
                      'People who paid more than their share '
                          'are owed money. People who paid less owe money.',
                    ),
                    const SizedBox(height: 8),
                    _concept(
                      '03',
                      'Settle efficiently',
                      'Debtors are matched with creditors until '
                          'every balance reaches zero.',
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _concept(
                      '01',
                      'Equal share',
                      'Total expenses are divided equally '
                          'between all active people.',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _concept(
                      '02',
                      'Calculate balances',
                      'People who paid more than their share '
                          'are owed money. People who paid less owe money.',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _concept(
                      '03',
                      'Settle efficiently',
                      'Debtors are matched with creditors until '
                          'every balance reaches zero.',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _concept(
    String number,
    String title,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0x263F3F3F),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              color: purple,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0x33444444),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 9,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: _buildContent(),
        ),
      ),
    );
  }
}