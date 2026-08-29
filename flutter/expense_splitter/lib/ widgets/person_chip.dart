import 'package:flutter/material.dart';

import '../models/person.dart';

class PersonChip extends StatelessWidget {
  final Person person;
  final bool selected;
  final VoidCallback? onTap;

  const PersonChip({
    super.key,
    required this.person,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF15803D).withOpacity(0.18)
              : const Color(0xFF151515),

          borderRadius: BorderRadius.circular(30),

          border: Border.all(
            color: selected
                ? const Color(0xFF15803D)
                : const Color(0xFF303030),
          ),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,

              backgroundColor: selected
                  ? const Color(0xFF15803D)
                  : const Color(0xFF292929),

              child: Text(
                person.name.isEmpty
                    ? '?'
                    : person.name[0].toUpperCase(),

                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 8),

            Text(
              person.name,
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}