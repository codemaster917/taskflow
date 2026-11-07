import 'dart:convert'; // for jsonEncode and jsonDecode
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

// The 3 filter choices on the dashboard.
enum TaskFilter { all, pending, completed }

// ChangeNotifier lets this class tell the screens "something changed!"
class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = []; // the list of all tasks (private because of _)
  String _searchText = ''; // what the user typed in the search box
  TaskFilter _filter = TaskFilter.all; // current filter choice
  bool _isLoading = true; // true while we load saved tasks

  // Constructor: runs when the provider is created.
  // It loads the saved tasks from the browser.
  TaskProvider() {
    loadTasks();
  }

  // ---------- GETTERS (screens use these to READ data) ----------

  bool get isLoading => _isLoading;
  TaskFilter get filter => _filter;
  String get searchText => _searchText;

  // Counts for the dashboard (these ignore the search).
  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isCompleted).length;
  int get pendingCount => _tasks.where((t) => !t.isCompleted).length;

  // Pending tasks that match the search text.
  List<Task> get pendingTasks {
    return _tasks.where((t) => !t.isCompleted && _matchesSearch(t)).toList();
  }

  // Completed tasks that match the search text.
  List<Task> get completedTasks {
    return _tasks.where((t) => t.isCompleted && _matchesSearch(t)).toList();
  }

  // Find one task by its id (used by the details screen).
  // Returns null if the task is not found.
  Task? getTaskById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  // ---------- ACTIONS (screens use these to CHANGE data) ----------

  // Add a new task.
  void addTask({
    required String title,
    required String description,
    required Priority priority,
    required DateTime dueDate,
  }) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // unique id
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );
    _tasks.insert(0, task); // put the new task at the top
    _saveAndNotify();
  }

  // Edit an existing task.
  void updateTask({
    required String id,
    required String title,
    required String description,
    required Priority priority,
    required DateTime dueDate,
  }) {
    final index = _tasks.indexWhere((t) => t.id == id); // find its position
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      _saveAndNotify();
    }
  }

  // Delete a task.
  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveAndNotify();
  }

  // Switch a task between done and not done.
  void toggleComplete(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      _saveAndNotify();
    }
  }

  // Called when the user types in the search box.
  void setSearchText(String text) {
    _searchText = text;
    notifyListeners(); // no need to save, search is not saved
  }

  // Called when the user taps All / Pending / Completed.
  void setFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  // ---------- SAVING AND LOADING ----------

  // Load tasks saved in the browser.
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedText = prefs.getString('tasks'); // read the saved text
    if (savedText != null) {
      final List<dynamic> list = jsonDecode(savedText); // text -> list
      _tasks = list
          .map((item) => Task.fromMap(item as Map<String, dynamic>))
          .toList();
    }
    _isLoading = false;
    notifyListeners(); // tell screens: loading finished
  }

  // Save all tasks in the browser.
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _tasks.map((t) => t.toMap()).toList(); // tasks -> maps
    await prefs.setString('tasks', jsonEncode(list)); // maps -> text
  }

  // Small helper: save, then update the screens.
  void _saveAndNotify() {
    _saveTasks();
    notifyListeners();
  }

  // Helper: does this task match the search text?
  bool _matchesSearch(Task task) {
    final text = _searchText.toLowerCase();
    return task.title.toLowerCase().contains(text) ||
        task.description.toLowerCase().contains(text);
  }
}