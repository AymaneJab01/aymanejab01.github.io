import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../models/person.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final List<Person> people;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.people,
    this.onDelete,
  });

  String getPersonName(String id) {
    for (final person in people) {
      if (person.id == id) {
        return person.name;
      }
    }

    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xFF151515),

        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFF292929),
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 46,
            height: 46,

            decoration: BoxDecoration(
              color: const Color(0xFF15803D).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF15803D),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${getPersonName(expense.paidBy)} paid',
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${expense.participants.length} participant${expense.participants.length == 1 ? '' : 's'} · €${expense.sharePerPerson.toStringAsFixed(2)} each',
                  style: const TextStyle(
                    color: Color(0xFF777777),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Text(
                '€${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (onDelete != null) ...[
                const SizedBox(height: 8),

                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                  ),
                  color: const Color(0xFF777777),
                  tooltip: 'Delete',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
