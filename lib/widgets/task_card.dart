import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_helper.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap; // runs when the card is tapped
  final VoidCallback onToggle; // runs when the checkbox is tapped
  final VoidCallback onDelete; // runs when the delete button is tapped

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = AppTheme.priorityColor(task.priority);

    // A task is overdue if it is not done and its date is before today.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = !task.isCompleted && task.dueDate.isBefore(today);

    // ANIMATION: the card fades in and slides up when it appears.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1), // value goes from 0 to 1
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value, // 0 = invisible, 1 = fully visible
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)), // starts 20 pixels lower
            child: child,
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias, // keeps the colored strip inside corners
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: onTap,
          // STACK: widgets placed on top of each other.
          child: Stack(
            children: [
              // Layer 1: a thin colored strip on the left side.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 6, color: color),
              ),
              // Layer 2: the main content of the card.
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                child: Row(
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) => onToggle(),
                    ),
                    // HERO + ANIMATEDCONTAINER: the icon flies to the
                    // details screen, and changes color smoothly when done.
                    Hero(
                      tag: 'task-icon-${task.id}',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (task.isCompleted ? Colors.grey : color)
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          task.isCompleted ? Icons.check : Icons.flag,
                          color: task.isCompleted ? Colors.grey : color,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title, description, badge and date.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              // cross the title out if the task is done
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (task.description.isNotEmpty)
                            Text(
                              task.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          const SizedBox(height: 6),
                          // Wrap moves items to the next line if no space.
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              PriorityBadge(priority: task.priority),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: isOverdue ? Colors.red : null,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatDate(task.dueDate),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isOverdue ? Colors.red : null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete task',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}