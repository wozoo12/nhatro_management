enum TaskCategory {
  issue,        // Sự cố / Sửa chữa
  appointment,  // Lịch hẹn xem phòng
  billing,      // Chốt điện nước / Thu tiền
  personal,     // Việc cá nhân / Khác
}

enum TaskPriority {
  low,
  normal,
  urgent,
}

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskCategory category;
  final String? roomNumber;
  final DateTime dueDate;
  final bool isCompleted;
  final TaskPriority priority;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.roomNumber,
    required this.dueDate,
    this.isCompleted = false,
    this.priority = TaskPriority.normal,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    String? roomNumber,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      roomNumber: roomNumber ?? this.roomNumber,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  String get categoryLabel {
    switch (category) {
      case TaskCategory.issue:
        return 'Sự cố';
      case TaskCategory.appointment:
        return 'Lịch hẹn';
      case TaskCategory.billing:
        return 'Thu tiền / Điện nước';
      case TaskCategory.personal:
        return 'Việc cần làm';
    }
  }
}
