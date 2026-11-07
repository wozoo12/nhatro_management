import 'package:equatable/equatable.dart';
import '../../data/models/task_model.dart';

enum TaskStatus { initial, loading, success, error }

class TaskState extends Equatable {
  final List<TaskModel> tasks;
  final TaskCategory? selectedCategory;
  final TaskStatus status;
  final String? errorMessage;

  const TaskState({
    this.tasks = const [],
    this.selectedCategory,
    this.status = TaskStatus.initial,
    this.errorMessage,
  });

  TaskState copyWith({
    List<TaskModel>? tasks,
    TaskCategory? selectedCategory,
    bool clearCategory = false,
    TaskStatus? status,
    String? errorMessage,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<TaskModel> get filteredTasks {
    if (selectedCategory == null) return tasks;
    return tasks.where((t) => t.category == selectedCategory).toList();
  }

  int get pendingCount => tasks.where((t) => !t.isCompleted).length;
  int get completedCount => tasks.where((t) => t.isCompleted).length;

  @override
  List<Object?> get props => [tasks, selectedCategory, status, errorMessage];
}
