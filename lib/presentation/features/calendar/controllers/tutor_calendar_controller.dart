import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:xpressatec/domain/entities/appointment.dart';
import 'package:xpressatec/domain/repositories/appointments_repository.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

class TutorCalendarController extends GetxController {
  TutorCalendarController(
    this._repository,
    this._authController,
  );

  final AppointmentsRepository _repository;
  final AuthController _authController;

  final Rx<DateTime> focusedDay = DateTime.now().obs;
  final Rx<DateTime> selectedDay = DateTime.now().obs;
  final RxBool isLoading = false.obs;
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxString errorMessage = ''.obs;

  bool get isTutor => _authController.isTutor;

  List<Appointment> get appointmentsForSelectedDay =>
      appointmentsForDay(selectedDay.value);

  List<Appointment> appointmentsForDay(DateTime day) => appointments
      .where((appointment) => _isSameDay(appointment.startTime, day))
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  @override
  void onInit() {
    super.onInit();
    if (!isTutor) {
      errorMessage.value = 'Esta sección es exclusiva para tutores.';
      return;
    }
    _loadAppointmentsForVisibleRange();
  }

  Future<void> onRefresh() async {
    await _loadAppointmentsForVisibleRange(forceReload: true);
  }

  Future<void> onDaySelected(DateTime selected, DateTime focused) async {
    selectedDay.value = selected;
    focusedDay.value = focused;

    if (!_hasDataFor(selected)) {
      await _loadAppointmentsForVisibleRange(reference: selected);
    } else {
      appointments.refresh();
    }
  }

  Future<void> onPageChanged(DateTime focused) async {
    focusedDay.value = focused;
    await _loadAppointmentsForVisibleRange(reference: focused);
  }

  bool hasAppointmentsOn(DateTime day) {
    return appointments.any((appointment) => _isSameDay(appointment.startTime, day));
  }

  Future<void> _loadAppointmentsForVisibleRange({
    DateTime? reference,
    bool forceReload = false,
  }) async {
    final DateTime base = reference ?? focusedDay.value;
    final DateTime start = DateTime(base.year, base.month, 1);
    final DateTime end = DateTime(base.year, base.month + 1, 0);

    final shouldFetch = forceReload ||
        appointments
            .where((appointment) => _isWithinRange(appointment.startTime, start, end))
            .isEmpty;

    if (!shouldFetch) {
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await _repository.getTutorAppointments(
        startDate: start,
        endDate: end,
      );

      appointments
        ..removeWhere((appointment) => _isWithinRange(appointment.startTime, start, end))
        ..addAll(result);

      appointments.sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (error) {
      errorMessage.value =
          'No pudimos cargar tus citas. Intenta nuevamente más tarde. (${error.toString()})';
    } finally {
      isLoading.value = false;
    }
  }

  bool _hasDataFor(DateTime day) {
    return appointments.any((appointment) => _isSameDay(appointment.startTime, day));
  }

  bool _isSameDay(DateTime dateA, DateTime dateB) {
    return dateA.year == dateB.year && dateA.month == dateB.month && dateA.day == dateB.day;
  }

  bool _isWithinRange(DateTime date, DateTime start, DateTime end) {
    final normalized = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return (normalized.isAtSameMomentAs(normalizedStart) ||
            normalized.isAfter(normalizedStart)) &&
        (normalized.isAtSameMomentAs(normalizedEnd) ||
            normalized.isBefore(normalizedEnd));
  }

  String formatTimeRange(Appointment appointment) {
    final timeFormat = DateFormat('HH:mm');
    return '${timeFormat.format(appointment.startTime)} - ${timeFormat.format(appointment.endTime)}';
  }
}
