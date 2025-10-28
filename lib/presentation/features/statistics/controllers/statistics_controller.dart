import 'package:get/get.dart';
import 'package:xpressatec/data/models/phrase_model.dart';
import 'package:xpressatec/domain/entities/phrase_statistics.dart';
import 'package:xpressatec/domain/usecases/phrase/get_user_phrases_usecase.dart';
import 'package:xpressatec/core/utils/statistics_calculator.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

enum TimeRange { last7Days, last30Days, allTime }

class StatisticsController extends GetxController {
  final GetUserPhrasesUseCase _getUserPhrasesUseCase;

  StatisticsController({
    required GetUserPhrasesUseCase getUserPhrasesUseCase,
  }) : _getUserPhrasesUseCase = getUserPhrasesUseCase;

  // Observable state
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<TimeRange> selectedTimeRange = TimeRange.last7Days.obs;
  final Rx<PhraseStatistics> statistics = PhraseStatistics.empty().obs;
  final RxList<PhraseModel> allPhrases = <PhraseModel>[].obs;
  final RxList<PhraseModel> filteredPhrases = <PhraseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  /// Load statistics for current user
  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get current user
      final authController = Get.find<AuthController>();
      final userId = authController.currentUser.value?.uuid;

      if (userId == null || userId.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Fetch all phrases for user
      final phrases = await _getUserPhrasesUseCase(userId);
      allPhrases.value = phrases;

      print('📊 Loaded ${phrases.length} phrases for user');

      // Apply time filter
      _applyTimeFilter();
    } catch (e) {
      print('❌ Error loading statistics: $e');
      errorMessage.value = e.toString();
      statistics.value = PhraseStatistics.empty();
    } finally {
      isLoading.value = false;
    }
  }

  /// Change time range filter
  void changeTimeRange(TimeRange range) {
    selectedTimeRange.value = range;
    _applyTimeFilter();
  }

  /// Apply time filter and recalculate statistics
  void _applyTimeFilter() {
    List<PhraseModel> filtered;

    switch (selectedTimeRange.value) {
      case TimeRange.last7Days:
        filtered = StatisticsCalculator.getLastNDays(allPhrases, 7);
        break;
      case TimeRange.last30Days:
        filtered = StatisticsCalculator.getLastNDays(allPhrases, 30);
        break;
      case TimeRange.allTime:
        filtered = StatisticsCalculator.getAllTime(allPhrases);
        break;
    }

    filteredPhrases.value = filtered;
    statistics.value = StatisticsCalculator.calculate(filtered);

    print('📊 Statistics calculated for ${filtered.length} phrases');
  }

  /// Refresh statistics
  Future<void> refresh() async {
    await loadStatistics();
  }

  /// Get time range display text
  String get timeRangeText {
    switch (selectedTimeRange.value) {
      case TimeRange.last7Days:
        return 'Últimos 7 días';
      case TimeRange.last30Days:
        return 'Últimos 30 días';
      case TimeRange.allTime:
        return 'Todo el tiempo';
    }
  }
}