import 'package:flutter/material.dart';

import '../services/settlement_service.dart';

class SettlementCard extends StatelessWidget {
  final Transfer transfer;
  final String Function(int) formatCents;

  const SettlementCard({
    super.key,
    required this.transfer,
    required this.formatCents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0x0A6EE7B7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0x336EE7B7),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_forward_rounded,
            color: Color(0xFF6EE7B7),
            size: 19,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: transfer.from,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const TextSpan(
                    text: ' pays ',
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                  TextSpan(
                    text: transfer.to,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            formatCents(transfer.cents),
            style: const TextStyle(
              color: Color(0xFF6EE7B7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}