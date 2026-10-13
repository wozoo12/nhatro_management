import 'package:flutter/material.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';

class IssueManagementView extends StatefulWidget {
  const IssueManagementView({super.key});

  @override
  State<IssueManagementView> createState() => _IssueManagementViewState();
}

class _IssueManagementViewState extends State<IssueManagementView> {
  final List<Map<String, dynamic>> _issues = [
    {
      "id": "IS001",
      "room": "P.102",
      "issue": "Hư ống nước bồn rửa chén",
      "date": "21/09/2026",
      "status": "pending", // pending, processing, done
      "cost": null
    },
    {
      "id": "IS002",
      "room": "P.205",
      "issue": "Cháy bóng đèn nhà tắm",
      "date": "20/09/2026",
      "status": "processing",
      "cost": null
    },
    {
      "id": "IS003",
      "room": "P.101",
      "issue": "Kẹt ổ khóa cửa chính",
      "date": "18/09/2026",
      "status": "done",
      "cost": 150000
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Sự cố', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _issues.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final issue = _issues[index];
          return _buildIssueCard(issue);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm sự cố', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildIssueCard(Map<String, dynamic> issue) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (issue['status']) {
      case 'processing':
        statusColor = AppColors.blueCTA;
        statusText = 'Đang sửa';
        statusIcon = Icons.build_circle_outlined;
        break;
      case 'done':
        statusColor = AppColors.primaryGreen;
        statusText = 'Đã xong';
        statusIcon = Icons.check_circle_outline;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusText = 'Đang chờ';
        statusIcon = Icons.schedule;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text(issue['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.mintBg,
                  radius: 20,
                  child: Text(issue['room'], style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(issue['issue'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      if (issue['cost'] != null)
                        Text("Chi phí sửa: ${issue['cost']}đ", style: const TextStyle(color: AppColors.dangerRed, fontSize: 13, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (issue['status'] != 'done')
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cập nhật'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
