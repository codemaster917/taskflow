import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/task_card.dart';

// StatefulWidget = a widget that can change (the search box changes).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // The controller reads and clears the text in the search box.
  final TextEditingController _searchController = TextEditingController();

  // Clean up the controller when the screen closes.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ask "Are you sure?" before deleting a task.
  Future<void> _confirmDelete(Task task) async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // false = cancel
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true), // true = delete
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Only delete if the user pressed Delete and the screen still exists.
    if (yes == true && mounted) {
      context.read<TaskProvider>().deleteTask(task.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task deleted')),
      );
    }
  }

  // Text shown on each filter chip.
  String _filterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.completed:
        return 'Completed';
    }
  }

  // The 3 stat cards in a GridView (always 3 columns).
  Widget _buildStats(TaskProvider provider) {
    return GridView(
      shrinkWrap: true, // grid is only as tall as its content
      physics: const NeverScrollableScrollPhysics(), // page scrolls, not grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisExtent: 150, // height of each card
      ),
      children: [
        StatCard(
          title: 'Total',
          count: provider.totalCount,
          icon: Icons.list_alt,
          color: Theme.of(context).colorScheme.primary,
        ),
        StatCard(
          title: 'Completed',
          count: provider.completedCount,
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        StatCard(
          title: 'Pending',
          count: provider.pendingCount,
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
      ],
    );
  }

  // The search box.
  Widget _buildSearchBox(TaskProvider provider) {
    return TextField(
      controller: _searchController,
      onChanged: (text) {
        provider.setSearchText(text); // tell the provider
        setState(() {}); // redraw so the clear (X) button shows or hides
      },
      decoration: InputDecoration(
        hintText: 'Search tasks...',
        prefixIcon: const Icon(Icons.search),
        // Show the clear button only when there is some text.
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchText('');
                  setState(() {});
                },
              ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // The All / Pending / Completed chips.
  Widget _buildFilterChips(TaskProvider provider) {
    return Wrap(
      spacing: 8,
      children: [
        for (final filter in TaskFilter.values)
          ChoiceChip(
            label: Text(_filterLabel(filter)),
            selected: provider.filter == filter,
            onSelected: (_) => provider.setFilter(filter),
          ),
      ],
    );
  }

  // A heading like "Pending Tasks (3)".
  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  // A GridView of task cards.
  // Columns: mobile = 1, tablet = 2, desktop = 3 (from our Responsive helper).
  Widget _buildTaskGrid(List<Task> tasks) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.columns(context),
        crossAxisSpacing: 12,
        mainAxisExtent: 140, // height of each task card
      ),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          key: ValueKey(task.id),
          task: task,
          // Tap the card -> open the details screen.
          onTap: () => Navigator.pushNamed(
            context,
            '/details',
            arguments: task.id,
          ),
          // Tap the checkbox -> mark done / not done.
          onToggle: () => context.read<TaskProvider>().toggleComplete(task.id),
          // Tap the delete icon -> ask first, then delete.
          onDelete: () => _confirmDelete(task),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // watch = redraw this screen whenever the provider changes.
    final provider = context.watch<TaskProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // Which sections should we show for the chosen filter?
    final showPending = provider.filter != TaskFilter.completed;
    final showCompleted = provider.filter != TaskFilter.pending;
    final pending = provider.pendingTasks;
    final completed = provider.completedTasks;

    // True when there is nothing to show on the screen.
    final nothingToShow = (!showPending || pending.isEmpty) &&
        (!showCompleted || completed.isEmpty);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TaskFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Light / dark theme button.
          IconButton(
            tooltip: 'Change theme',
            icon: Icon(
              themeProvider.isDark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: provider.isLoading
          // Still loading saved tasks -> show a spinner.
          ? const Center(child: CircularProgressIndicator())
          // Center + ConstrainedBox stops content from being too wide.
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.maxContentWidth(context),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildStats(provider),
                    const SizedBox(height: 16),
                    _buildSearchBox(provider),
                    const SizedBox(height: 12),
                    _buildFilterChips(provider),
                    const SizedBox(height: 8),

                    // Nothing to show? Show a friendly message.
                    if (nothingToShow)
                      SizedBox(
                        height: 300,
                        child: provider.totalCount == 0
                            ? const EmptyState(
                                icon: Icons.task_alt,
                                title: 'No tasks yet',
                                message:
                                    'Tap the "Add Task" button to create your first task.',
                              )
                            : const EmptyState(
                                icon: Icons.search_off,
                                title: 'No tasks found',
                                message:
                                    'Try a different search or filter.',
                              ),
                      ),

                    // Pending section.
                    if (showPending && pending.isNotEmpty) ...[
                      _buildSectionTitle('Pending Tasks', pending.length),
                      _buildTaskGrid(pending),
                    ],

                    // Completed section.
                    if (showCompleted && completed.isNotEmpty) ...[
                      _buildSectionTitle('Completed Tasks', completed.length),
                      _buildTaskGrid(completed),
                    ],

                    // Extra space so the button does not cover the last card.
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}