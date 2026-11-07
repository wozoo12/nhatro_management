import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';
import 'package:nhatro_management/core/utils/formatters.dart';
import 'package:nhatro_management/features/tasks/data/models/task_model.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import 'widgets/add_task_bottom_sheet.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskCubit(),
      child: const _TasksViewContent(),
    );
  }
}

class _TasksViewContent extends StatelessWidget {
  const _TasksViewContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrayBg,
      appBar: AppBar(
        title: const Text('Quản lý công việc & Lịch hẹn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<TaskCubit>().loadTasks(),
          ),
        ],
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state.status == TaskStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen));
          }

          if (state.status == TaskStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.dangerRed, size: 48),
                  const SizedBox(height: 12),
                  Text(state.errorMessage ?? 'Đã xảy ra lỗi', style: const TextStyle(color: AppColors.grayText)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TaskCubit>().loadTasks(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildSummaryHeader(context, state),
              _buildCategoryFilters(context, state),
              Expanded(
                child: state.filteredTasks.isEmpty
                    ? _buildEmptyState()
                    : _buildTaskList(context, state.filteredTasks),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskBottomSheet(context),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Thêm việc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, TaskState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricTile(
              label: 'Cần làm',
              count: state.pendingCount,
              color: AppColors.warningOrange,
              icon: Icons.pending_actions_rounded,
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          Expanded(
            child: _buildMetricTile(
              label: 'Đã hoàn tất',
              count: state.completedCount,
              color: AppColors.primaryGreen,
              icon: Icons.task_alt_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.grayText)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilters(BuildContext context, TaskState state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip(
            context: context,
            label: 'Tất cả',
            isSelected: state.selectedCategory == null,
            onTap: () => context.read<TaskCubit>().filterByCategory(null),
          ),
          ...TaskCategory.values.map((cat) {
            final isSelected = state.selectedCategory == cat;
            return _buildFilterChip(
              context: context,
              label: _getCategoryLabel(cat),
              isSelected: isSelected,
              onTap: () => context.read<TaskCubit>().filterByCategory(cat),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryGreen.withValues(alpha: 0.15),
        checkmarkColor: AppColors.primaryGreen,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryGreen : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<TaskModel> tasks) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(context, task);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    final catColor = _getCategoryColor(task.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: task.isCompleted ? Colors.grey.shade200 : catColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: task.isCompleted,
                activeColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (_) => context.read<TaskCubit>().toggleTaskCompletion(task.id),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? Colors.grey : AppColors.navyText,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.read<TaskCubit>().deleteTask(task.id),
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 4),
                        child: Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                      ),
                    ),
                  ],
                ),
                if (task.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description!,
                    style: const TextStyle(fontSize: 12, color: AppColors.grayText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        task.categoryLabel,
                        style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (task.roomNumber != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'P.${task.roomNumber}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.navyText),
                        ),
                      ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time_rounded, size: 13, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          AppFormatters.formatDate(task.dueDate),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
            child: const Icon(Icons.done_all_rounded, color: AppColors.primaryGreen, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không có công việc nào!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyText),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tất cả công việc đã được xử lý xong xuôi.',
            style: TextStyle(fontSize: 13, color: AppColors.grayText),
          ),
        ],
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => AddTaskBottomSheet(
        onTaskAdded: (task) {
          context.read<TaskCubit>().addTask(task);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã thêm công việc mới thành công!')),
          );
        },
      ),
    );
  }

  String _getCategoryLabel(TaskCategory cat) {
    switch (cat) {
      case TaskCategory.issue:
        return 'Sự cố';
      case TaskCategory.appointment:
        return 'Lịch hẹn';
      case TaskCategory.billing:
        return 'Thu tiền';
      case TaskCategory.personal:
        return 'Cá nhân';
    }
  }

  Color _getCategoryColor(TaskCategory cat) {
    switch (cat) {
      case TaskCategory.issue:
        return AppColors.dangerRed;
      case TaskCategory.appointment:
        return AppColors.blueCTA;
      case TaskCategory.billing:
        return AppColors.warningOrange;
      case TaskCategory.personal:
        return AppColors.primaryGreen;
    }
  }
}
