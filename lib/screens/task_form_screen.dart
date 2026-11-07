import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_helper.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // The key lets us check ALL the form fields at once.
  final _formKey = GlobalKey<FormState>();

  // Controllers read the text typed by the user.
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _priority = Priority.medium; // default priority
  DateTime? _dueDate; // null = no date chosen yet

  Task? _editingTask; // the task we are editing (null in add mode)
  bool _initialized = false; // makes sure we fill the form only once

  // true = Edit mode, false = Add mode.
  bool get _isEditing => _editingTask != null;

  // This runs once when the screen opens.
  // We check if a task id was sent to this screen (Edit mode).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // Read the "arguments" that were sent with Navigator.pushNamed.
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is String) {
      final task = context.read<TaskProvider>().getTaskById(arguments);
      if (task != null) {
        // Fill the form with the old task values.
        _editingTask = task;
        _titleController.text = task.title;
        _descriptionController.text = task.description;
        _priority = task.priority;
        _dueDate = task.dueDate;
      }
    }
  }

  // Clean up the controllers when the screen closes.
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Open the calendar and let the user choose a date.
  Future<void> _pickDate(FormFieldState<DateTime> field) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _dueDate = picked); // show the new date
      field.didChange(picked); // tell the form a date was chosen
      field.validate(); // check again, so the red error goes away
    }
  }

  // Runs when the user presses the Save button.
  void _save() {
    // validate() runs every validator. If any field is wrong, stop here.
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TaskProvider>();
    final title = _titleController.text.trim(); // trim removes extra spaces
    final description = _descriptionController.text.trim();

    if (_isEditing) {
      provider.updateTask(
        id: _editingTask!.id,
        title: title,
        description: description,
        priority: _priority,
        dueDate: _dueDate!,
      );
    } else {
      provider.addTask(
        title: title,
        description: description,
        priority: _priority,
        dueDate: _dueDate!,
      );
    }

    // Get the messenger BEFORE closing the screen, then show a message.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context); // go back to the previous screen
    messenger.showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Task updated' : 'Task added')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Task' : 'Add Task',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Center + ConstrainedBox: the form is never wider than 600 pixels,
      // so it looks good on desktop too.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---------- 1. TITLE (required) ----------
                      TextFormField(
                        controller: _titleController,
                        maxLength: 50,
                        textCapitalization: TextCapitalization.sentences,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          labelText: 'Task title *',
                          prefixIcon: Icon(Icons.title),
                          border: OutlineInputBorder(),
                        ),
                        // VALIDATOR: returns an error text, or null if okay.
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null; // null means "no error"
                        },
                      ),
                      const SizedBox(height: 12),

                      // ---------- 2. DESCRIPTION (optional) ----------
                      TextFormField(
                        controller: _descriptionController,
                        maxLength: 200,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          prefixIcon: Icon(Icons.notes),
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ---------- 3. PRIORITY ----------
                      Text(
                        'Priority',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<Priority>(
                          segments: [
                            for (final p in Priority.values)
                              ButtonSegment<Priority>(
                                value: p,
                                                                   // FittedBox shrinks the text if there is no room.
                                   label: FittedBox(
                                     fit: BoxFit.scaleDown,
                                     child: Text(AppTheme.priorityLabel(p)),
                                   ),
                                   icon: Icon(
                                     Icons.flag,
                                     size: 18,
                                     color: AppTheme.priorityColor(p),
                                   ),
                              ),
                          ],
                          showSelectedIcon: false, // no tick, saves space
                          selected: {_priority},
                          onSelectionChanged: (selection) {
                            setState(() => _priority = selection.first);
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ---------- 4. DUE DATE (required) ----------
                      // FormField lets a date picker use validation too.
                      FormField<DateTime>(
                        initialValue: _dueDate,
                        validator: (value) =>
                            value == null ? 'Please choose a due date' : null,
                        builder: (field) {
                          return InkWell(
                            onTap: () => _pickDate(field),
                            borderRadius: BorderRadius.circular(4),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Due date *',
                                prefixIcon: const Icon(Icons.calendar_today),
                                border: const OutlineInputBorder(),
                                errorText: field.errorText, // red message
                              ),
                              child: Text(
                                _dueDate == null
                                    ? 'Tap to choose a date'
                                    : formatDate(_dueDate!),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // ---------- BUTTONS ----------
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: Icon(_isEditing ? Icons.check : Icons.add),
                          label: Text(_isEditing ? 'Update Task' : 'Save Task'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}