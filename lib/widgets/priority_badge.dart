import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

// StatelessWidget = a widget that never changes by itself.
class PriorityBadge extends StatelessWidget {
  final Priority priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    // Get the color for this priority from our theme file.
    final color = AppTheme.priorityColor(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15), // light see-through background
        borderRadius: BorderRadius.circular(20), // rounded corners
      ),
      child: Text(
        AppTheme.priorityLabel(priority),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}