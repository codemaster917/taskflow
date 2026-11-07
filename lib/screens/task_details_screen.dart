import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helper.dart';
import '../widgets/empty_state.dart';
import '../widgets/priority_badge.dart';

// This screen only shows data, so it is a StatelessWidget.
// The data comes from the provider, which redraws it when tasks change.
class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key});

  // Ask "Are you sure?" and then delete the task.
  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (yes == true && context.mounted) {
      // Get these BEFORE closing the screen.
      final messenger = ScaffoldMessenger.of(context);
      final provider = context.read<TaskProvider>();
      Navigator.pop(context); // go back to the Home screen
      provider.deleteTask(task.id);
      messenger.showSnackBar(const SnackBar(content: Text('Task deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read the task id that the Home screen sent to us.
    final id = ModalRoute.of(context)?.settings.arguments as String?;

    // watch = redraw when the task changes (for example after Complete).
    final provider = context.watch<TaskProvider>();
    final task = id == null ? null : provider.getTaskById(id);

    // If the task is not found, show a friendly message.
    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const EmptyState(
          icon: Icons.error_outline,
          title: 'Task not found',
          message: 'This task may have been deleted.',
        ),
      );
    }

    final theme = Theme.of(context);
    final color = AppTheme.priorityColor(task.priority);

    // A task is overdue if it is not done and the date is before today.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isOverdue = !task.isCompleted && task.dueDate.isBefore(today);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit task',
            icon: const Icon(Icons.edit),
            onPressed: () =>
                Navigator.pushNamed(context, '/edit', arguments: task.id),
          ),
          IconButton(
            tooltip: 'Delete task',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, task),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HERO: this icon flies here from the task card.
                    // The tag must be the SAME as the one in task_card.dart.
                    Center(
                      child: Hero(
                        tag: 'task-icon-${task.id}',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: (task.isCompleted ? Colors.grey : color)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            task.isCompleted ? Icons.check : Icons.flag,
                            color: task.isCompleted ? Colors.grey : color,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title (crossed out if the task is done).
                    Text(
                      task.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Status banner. It changes color smoothly (animation).
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: (task.isCompleted ? Colors.green : Colors.orange)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.pending_actions,
                            size: 18,
                            color:
                                task.isCompleted ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            task.isCompleted ? 'Completed' : 'Pending',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: task.isCompleted
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),

                    // Information rows (made with our small _InfoTile widget).
                    _InfoTile(
                      icon: Icons.notes,
                      label: 'Description',
                      child: Text(
                        task.description.isEmpty
                            ? 'No description'
                            : task.description,
                      ),
                    ),
                    _InfoTile(
                      icon: Icons.flag,
                      label: 'Priority',
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: PriorityBadge(priority: task.priority),
                      ),
                    ),
                    _InfoTile(
                      icon: Icons.calendar_today,
                      label: 'Due date',
                      child: Text(
                        isOverdue
                            ? '${formatDate(task.dueDate)} (Overdue)'
                            : formatDate(task.dueDate),
                        style: TextStyle(color: isOverdue ? Colors.red : null),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action buttons. Wrap moves them to the next line
                    // when the screen is small.
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () => context
                              .read<TaskProvider>()
                              .toggleComplete(task.id),
                          icon: Icon(
                            task.isCompleted ? Icons.undo : Icons.check,
                          ),
                          label: Text(
                            task.isCompleted
                                ? 'Mark as Pending'
                                : 'Mark as Completed',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/edit',
                            arguments: task.id,
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// A small reusable widget: an icon, a label and a value in one row.
// The underscore (_) means only this file can use it.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child; // the value (can be text, a badge, etc.)

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}