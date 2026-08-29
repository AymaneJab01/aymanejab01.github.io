import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xFF151515),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: const Color(0xFF303030),
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFAAAAAA),
                  fontSize: 13,
                ),
              ),

              Icon(
                icon,
                color: const Color(0xFF15803D),
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),

          if (subtitle != null) ...[
            const SizedBox(height: 5),

            Text(
              subtitle!,
              style: const TextStyle(
                color: Color(0xFF777777),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}