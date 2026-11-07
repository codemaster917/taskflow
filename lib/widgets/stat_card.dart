import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title; // example: "Total"
  final int count; // example: 8
  final IconData icon; // the small picture
  final Color color; // the color of the icon

  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        // Column = icon on top, number in the middle, title at the bottom.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Round colored box with the icon inside.
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // maxLines: 1 keeps the label on ONE line (no extra height).
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}