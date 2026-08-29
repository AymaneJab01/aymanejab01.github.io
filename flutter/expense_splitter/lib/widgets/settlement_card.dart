import 'package:flutter/material.dart';

import '../main.dart' show AppColors;
import '../services/settlement_service.dart';

class SettlementCard extends StatelessWidget {
  final Settlement settlement;

  const SettlementCard({
    super.key,
    required this.settlement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accent.withValues(alpha: 0.14),
            child: Text(
              settlement.from.name.isEmpty
                  ? '?'
                  : settlement.from.name[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: settlement.from.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ' pays ',
                  ),
                  TextSpan(
                    text: settlement.to.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '€${settlement.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
