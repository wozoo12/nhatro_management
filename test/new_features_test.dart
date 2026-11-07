import 'package:flutter_test/flutter_test.dart';
import 'package:nhatro_management/features/tasks/data/models/task_model.dart';
import 'package:nhatro_management/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:nhatro_management/features/tasks/presentation/cubit/task_state.dart';
import 'package:nhatro_management/features/tenant_finding/data/models/lead_model.dart';
import 'package:nhatro_management/features/tenant_finding/presentation/cubit/tenant_finding_cubit.dart';
import 'package:nhatro_management/features/tenant_finding/presentation/cubit/tenant_finding_state.dart';

void main() {
  group('TaskCubit Tests (Module Công việc & Lịch hẹn)', () {
    late TaskCubit cubit;

    setUp(() {
      cubit = TaskCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Khởi tạo và tải danh sách công việc thành công', () {
      expect(cubit.state.status, equals(TaskStatus.success));
      expect(cubit.state.tasks, isNotEmpty);
      expect(cubit.state.pendingCount, greaterThan(0));
    });

    test('Lọc công việc theo danh mục chính xác', () {
      cubit.filterByCategory(TaskCategory.issue);
      expect(cubit.state.selectedCategory, equals(TaskCategory.issue));
      for (final task in cubit.state.filteredTasks) {
        expect(task.category, equals(TaskCategory.issue));
      }

      // Xóa bộ lọc (Xem tất cả)
      cubit.filterByCategory(null);
      expect(cubit.state.selectedCategory, isNull);
      expect(cubit.state.filteredTasks.length, equals(cubit.state.tasks.length));
    });

    test('Chuyển đổi trạng thái hoàn tất công việc', () {
      final firstTaskId = cubit.state.tasks.first.id;
      final initialCompletion = cubit.state.tasks.first.isCompleted;

      cubit.toggleTaskCompletion(firstTaskId);
      final updatedTask = cubit.state.tasks.firstWhere((t) => t.id == firstTaskId);
      expect(updatedTask.isCompleted, equals(!initialCompletion));
    });

    test('Thêm công việc mới thành công', () {
      final initialCount = cubit.state.tasks.length;
      final newTask = TaskModel(
        id: 'new_task_test',
        title: 'Kiểm tra đường ống nước lầu 3',
        category: TaskCategory.issue,
        dueDate: DateTime.now().add(const Duration(days: 1)),
      );

      cubit.addTask(newTask);
      expect(cubit.state.tasks.length, equals(initialCount + 1));
      expect(cubit.state.tasks.first.id, equals('new_task_test'));
    });

    test('Xóa công việc thành công', () {
      final targetId = cubit.state.tasks.first.id;
      final initialCount = cubit.state.tasks.length;

      cubit.deleteTask(targetId);
      expect(cubit.state.tasks.length, equals(initialCount - 1));
      expect(cubit.state.tasks.any((t) => t.id == targetId), isFalse);
    });
  });

  group('TenantFindingCubit Tests (Module Tìm khách & Leads CRM)', () {
    late TenantFindingCubit cubit;

    setUp(() {
      cubit = TenantFindingCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('Khởi tạo và tải danh sách khách tiềm năng thành công', () {
      expect(cubit.state.status, equals(TenantFindingStatus.success));
      expect(cubit.state.leads, isNotEmpty);
    });

    test('Lọc khách theo trạng thái chính xác', () {
      cubit.filterByStatus(LeadStatus.viewingScheduled);
      expect(cubit.state.selectedFilter, equals(LeadStatus.viewingScheduled));
      for (final lead in cubit.state.filteredLeads) {
        expect(lead.status, equals(LeadStatus.viewingScheduled));
      }

      // Xóa lọc
      cubit.filterByStatus(null);
      expect(cubit.state.selectedFilter, isNull);
    });

    test('Thêm khách thuê tiềm năng mới', () {
      final initialCount = cubit.state.leads.length;
      final newLead = LeadModel(
        id: 'lead_test_1',
        name: 'Hoàng Lan',
        phone: '0933889900',
        preferredRoom: '302',
        status: LeadStatus.interested,
        createdAt: DateTime.now(),
      );

      cubit.addLead(newLead);
      expect(cubit.state.leads.length, equals(initialCount + 1));
      expect(cubit.state.leads.first.id, equals('lead_test_1'));
    });

    test('Cập nhật trạng thái khách thuê', () {
      final leadId = cubit.state.leads.first.id;
      cubit.updateLeadStatus(leadId, LeadStatus.deposited);

      final updatedLead = cubit.state.leads.firstWhere((l) => l.id == leadId);
      expect(updatedLead.status, equals(LeadStatus.deposited));
    });

    test('Xóa khách tiềm năng', () {
      final leadId = cubit.state.leads.first.id;
      final initialCount = cubit.state.leads.length;

      cubit.deleteLead(leadId);
      expect(cubit.state.leads.length, equals(initialCount - 1));
      expect(cubit.state.leads.any((l) => l.id == leadId), isFalse);
    });
  });
}
