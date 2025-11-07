import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/statistics/controllers/statistics_controller.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/overview_cards.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/timeline_chart_widget.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/top_words_chart_widget.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/category_pie_chart_widget.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/recent_phrases_list.dart';
import 'package:xpressatec/presentation/features/statistics/widgets/time_range_selector.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refresh(),
          ),
        ],
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cargando estadísticas...'),
              ],
            ),
          );
        }

        // Error state
        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${controller.errorMessage.value}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.refresh(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (controller.allPhrases.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Aún no hay frases guardadas',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Genera y guarda frases para ver tus estadísticas',
                  style: TextStyle(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Statistics Dashboard
        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time Range Selector
                TimeRangeSelector(
                  selectedRange: controller.selectedTimeRange.value,
                  onChanged: (range) => controller.changeTimeRange(range),
                ),
                const SizedBox(height: 16),

                // Overview Cards
                OverviewCards(statistics: controller.statistics.value),
                const SizedBox(height: 24),

                // Timeline Chart
                _buildSectionTitle('Actividad'),
                const SizedBox(height: 12),
                TimelineChartWidget(statistics: controller.statistics.value),
                const SizedBox(height: 24),

                // Top Words Chart
                _buildSectionTitle('Palabras Más Usadas'),
                const SizedBox(height: 12),
                TopWordsChartWidget(statistics: controller.statistics.value),
                const SizedBox(height: 24),

                // Category Pie Chart
                _buildSectionTitle('Uso por Categoría'),
                const SizedBox(height: 12),
                CategoryPieChartWidget(statistics: controller.statistics.value),
                const SizedBox(height: 24),

                // Recent Phrases
                _buildSectionTitle('Frases Recientes'),
                const SizedBox(height: 12),
                RecentPhrasesList(phrases: controller.filteredPhrases),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}