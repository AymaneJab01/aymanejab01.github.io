import 'package:flutter/material.dart';

import '../main.dart' show AppColors;
import '../models/person.dart';

class PersonChip extends StatelessWidget {
  final Person person;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const PersonChip({
    super.key,
    required this.person,
    this.selected = false,
    this.onTap,
    this.onDelete,
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
              ? AppColors.accent.withValues(alpha: 0.16)
              : AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: selected ? AppColors.accent : AppColors.border,
              child: Text(
                person.name.isEmpty ? '?' : person.name[0].toUpperCase(),
                style: TextStyle(
                  color:
                      selected ? AppColors.background : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              person.name,
              style: TextStyle(
                color: selected ? AppColors.accent : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(
                  Icons.close_rounded,
                  size: 15,
                  color: AppColors.textFaint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
