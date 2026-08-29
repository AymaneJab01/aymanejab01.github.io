import 'package:flutter/material.dart';

class PersonChip extends StatelessWidget {
  final String name;
  final VoidCallback onRemove;

  const PersonChip({
    super.key,
    required this.name,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0x33444444),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.person_outline,
            size: 16,
            color: Color(0xFFA476FF),
          ),
          const SizedBox(width: 7),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 15,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}