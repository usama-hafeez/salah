import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// A styled pill badge for displaying Islamic event names.
/// Used in the Hijri Calendar event list.
class IslamicEventBadge extends StatelessWidget {
  final String eventName;
  final AppThemeData theme;

  const IslamicEventBadge({
    super.key,
    required this.eventName,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4CAF50).withAlpha(120),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            eventName,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
