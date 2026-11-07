import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nhatro_management/core/theme/app_colors.dart';

class OccupancyPieChartWidget extends StatefulWidget {
  final int? occupiedCount;
  final int? vacantCount;
  final int? maintenanceCount;

  const OccupancyPieChartWidget({
    super.key,
    this.occupiedCount,
    this.vacantCount,
    this.maintenanceCount,
  });

  @override
  State<OccupancyPieChartWidget> createState() => _OccupancyPieChartWidgetState();
}

class _OccupancyPieChartWidgetState extends State<OccupancyPieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final int occupied = widget.occupiedCount ?? 18;
    final int vacant = widget.vacantCount ?? 2;
    final int maintenance = widget.maintenanceCount ?? 0;
    final int total = occupied + vacant + maintenance;

    final double occupiedPercent = total > 0 ? (occupied / total) * 100 : 0;
    final double vacantPercent = total > 0 ? (vacant / total) * 100 : 100;
    final double maintenancePercent = total > 0 ? (maintenance / total) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tỷ lệ lấp đầy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                'Tổng: $total phòng',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.grayText),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: _showingSections(occupiedPercent, vacantPercent, maintenancePercent, total),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIndicator(AppColors.primaryGreen, 'Đang thuê\n($occupied phòng)', isSquare: false),
                    const SizedBox(height: 14),
                    _buildIndicator(Colors.orange, 'Phòng trống\n($vacant phòng)', isSquare: false),
                    if (maintenance > 0) ...[
                      const SizedBox(height: 14),
                      _buildIndicator(Colors.grey, 'Bảo trì\n($maintenance phòng)', isSquare: false),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections(
    double occupiedPct,
    double vacantPct,
    double maintenancePct,
    int total,
  ) {
    if (total == 0) {
      return [
        PieChartSectionData(
          color: Colors.grey.shade300,
          value: 100,
          title: '0%',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        )
      ];
    }

    final sections = <PieChartSectionData>[];

    if (occupiedPct > 0) {
      final isTouched = touchedIndex == 0;
      sections.add(
        PieChartSectionData(
          color: AppColors.primaryGreen,
          value: occupiedPct,
          title: '${occupiedPct.round()}%',
          radius: isTouched ? 58.0 : 48.0,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    if (vacantPct > 0) {
      final isTouched = touchedIndex == 1;
      sections.add(
        PieChartSectionData(
          color: Colors.orange,
          value: vacantPct,
          title: '${vacantPct.round()}%',
          radius: isTouched ? 58.0 : 48.0,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    if (maintenancePct > 0) {
      final isTouched = touchedIndex == 2;
      sections.add(
        PieChartSectionData(
          color: Colors.grey,
          value: maintenancePct,
          title: '${maintenancePct.round()}%',
          radius: isTouched ? 58.0 : 48.0,
          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );
    }

    return sections;
  }

  Widget _buildIndicator(Color color, String text, {required bool isSquare}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: isSquare ? BoxShape.rectangle : BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
      ],
    );
  }
}
