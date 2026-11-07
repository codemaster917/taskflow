import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/models/task.dart';

void main() {
  // Test 1: a task can be saved as a Map and loaded back.
  test('Task can be saved to a Map and loaded back', () {
    final task = Task(
      id: '1',
      title: 'Study Flutter',
      description: 'Finish the project',
      priority: Priority.high,
      dueDate: DateTime(2026, 11, 20),
    );

    final loaded = Task.fromMap(task.toMap());

    expect(loaded.title, 'Study Flutter');
    expect(loaded.priority, Priority.high);
    expect(loaded.isCompleted, false); // a new task is not done
  });

  // Test 2: copyWith changes only the values we give.
  test('copyWith changes only the given values', () {
    final task = Task(
      id: '2',
      title: 'Old title',
      description: 'Same description',
      priority: Priority.low,
      dueDate: DateTime(2026, 11, 21),
    );

    final updated = task.copyWith(title: 'New title', isCompleted: true);

    expect(updated.title, 'New title');
    expect(updated.isCompleted, true);
    expect(updated.description, 'Same description'); // not changed
    expect(updated.id, '2'); // the id never changes
  });
}