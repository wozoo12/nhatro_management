import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/task_model.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(const TaskState()) {
    loadTasks();
  }

  void loadTasks() {
    emit(state.copyWith(status: TaskStatus.loading));
    try {
      // Dữ liệu mẫu thực tế ban đầu phục vụ kiểm thử và trải nghiệm người dùng
      final initialTasks = [
        TaskModel(
          id: 'task_1',
          title: 'Khắc phục sự cố rò rỉ nước bồn rửa',
          description: 'Khách phản ánh vòi nước bị rò rỉ nhẹ dưới bồn rửa mặt',
          category: TaskCategory.issue,
          roomNumber: '102',
          dueDate: DateTime.now().add(const Duration(hours: 3)),
          priority: TaskPriority.urgent,
          isCompleted: false,
        ),
        TaskModel(
          id: 'task_2',
          title: 'Hẹn anh Tuấn đến xem phòng',
          description: 'Khách hẹn xem phòng lúc chiều tối sau giờ tan ca',
          category: TaskCategory.appointment,
          roomNumber: '201',
          dueDate: DateTime.now().add(const Duration(hours: 6)),
          priority: TaskPriority.normal,
          isCompleted: false,
        ),
        TaskModel(
          id: 'task_3',
          title: 'Chốt chỉ số điện nước định kỳ',
          description: 'Ghi số công tơ điện nước các phòng lầu 1 và lầu 2',
          category: TaskCategory.billing,
          roomNumber: null,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          priority: TaskPriority.normal,
          isCompleted: false,
        ),
        TaskModel(
          id: 'task_4',
          title: 'Kiểm tra bình cứu hỏa & lối thoát hiểm',
          description: 'Bảo trì định kỳ hệ thống phòng cháy chữa cháy',
          category: TaskCategory.personal,
          roomNumber: null,
          dueDate: DateTime.now().add(const Duration(days: 2)),
          priority: TaskPriority.low,
          isCompleted: true,
        ),
      ];

      emit(state.copyWith(
        tasks: initialTasks,
        status: TaskStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TaskStatus.error,
        errorMessage: 'Lỗi tải danh sách công việc: ${e.toString()}',
      ));
    }
  }

  void filterByCategory(TaskCategory? category) {
    if (category == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category));
    }
  }

  void toggleTaskCompletion(String taskId) {
    final updatedList = state.tasks.map((task) {
      if (task.id == taskId) {
        return task.copyWith(isCompleted: !task.isCompleted);
      }
      return task;
    }).toList();

    emit(state.copyWith(tasks: updatedList));
  }

  void addTask(TaskModel task) {
    final updatedList = [task, ...state.tasks];
    emit(state.copyWith(tasks: updatedList));
  }

  void deleteTask(String taskId) {
    final updatedList = state.tasks.where((t) => t.id != taskId).toList();
    emit(state.copyWith(tasks: updatedList));
  }
}
