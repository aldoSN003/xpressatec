import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:xpressatec/domain/entities/phrase_statistics.dart';
import 'package:xpressatec/core/theme/app_colors.dart';

import '../../../../core/utils/category_mapper.dart';

class CategoryPieChartWidget extends StatelessWidget {
  final PhraseStatistics statistics;

  const CategoryPieChartWidget({Key? key, required this.statistics})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statistics.categoryUsage.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Pie Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: _getPieChartSections(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: statistics.categoryUsage.entries.map((entry) {
              final color = _getColorForCategory(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${entry.key} (${entry.value})',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections() {
    final total = statistics.categoryUsage.values.fold(0, (a, b) => a + b);

    return statistics.categoryUsage.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      final color = _getColorForCategory(entry.key);

      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '$percentage%',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColorForCategory(String category) {
    final categoryMapper = CategoryMapper();
    final color = categoryMapper.getColorObjectForCategory(category);
    return color ?? Colors.grey;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'No hay datos para mostrar',
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }
}