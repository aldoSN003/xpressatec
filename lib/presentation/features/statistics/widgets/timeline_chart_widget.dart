import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:xpressatec/domain/entities/phrase_statistics.dart';

class TimelineChartWidget extends StatelessWidget {
  final PhraseStatistics statistics;

  const TimelineChartWidget({Key? key, required this.statistics})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (statistics.phrasesPerDay.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: 200,
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
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[200]!,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return _buildBottomTitle(value.toInt());
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: _getChartData().length.toDouble() - 1,
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: _getChartData(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTitle(int index) {
    final sortedDates = statistics.phrasesPerDay.keys.toList()..sort();

    if (index < 0 || index >= sortedDates.length) {
      return const SizedBox.shrink();
    }

    final date = sortedDates[index];
    final formatter = DateFormat('dd/MM');

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        formatter.format(date),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
        ),
      ),
    );
  }

  List<FlSpot> _getChartData() {
    final sortedEntries = statistics.phrasesPerDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries
        .asMap()
        .entries
        .map((entry) => FlSpot(
      entry.key.toDouble(),
      entry.value.value.toDouble(),
    ))
        .toList();
  }

  double _getMaxY() {
    if (statistics.phrasesPerDay.isEmpty) return 5;
    final maxValue = statistics.phrasesPerDay.values.reduce((a, b) => a > b ? a : b);
    return (maxValue + 2).toDouble();
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
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
      child: Center(
        child: Text(
          'No hay datos para mostrar',
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }
}