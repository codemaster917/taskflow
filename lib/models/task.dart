// Priority of a task.
enum Priority { low, medium, high }

// Blueprint for one task.
class Task {
  final String id;
  final String title;
  final String description;
  final Priority priority;
  final DateTime dueDate;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Creates a copy with updated values.
  Task copyWith({
    String? title,
    String? description,
    Priority? priority,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Converts Task into a Map for saving.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // Converts saved Map back into Task.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      priority: Priority.values.firstWhere(
        (p) => p.name == map['priority'],
      ),
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'],
    );
  }
}