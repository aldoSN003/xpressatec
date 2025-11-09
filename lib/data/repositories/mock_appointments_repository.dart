import 'dart:math';

import 'package:xpressatec/domain/entities/appointment.dart';
import 'package:xpressatec/domain/repositories/appointments_repository.dart';

class MockAppointmentsRepository implements AppointmentsRepository {
  MockAppointmentsRepository();

  static final List<Appointment> _seedAppointments = _generateSeed();

  @override
  Future<List<Appointment>> getTutorAppointments({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // In the future this method will perform a network call to the backend API.
    // For now we simulate latency to keep the flow similar to the real scenario.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    return _seedAppointments
        .where((appointment) =>
            appointment.startTime.isAfter(normalizedStart.subtract(const Duration(seconds: 1))) &&
            appointment.startTime.isBefore(normalizedEnd.add(const Duration(seconds: 1))))
        .toList();
  }

  static List<Appointment> _generateSeed() {
    final now = DateTime.now();
    final random = Random(42);
    final List<Appointment> appointments = [];

    for (int i = -5; i <= 10; i++) {
      final date = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      final dailyCount = random.nextInt(2);
      for (int j = 0; j <= dailyCount; j++) {
        final start = date.add(Duration(hours: 9 + j * 2));
        appointments.add(
          Appointment(
            id: '${date.toIso8601String()}-$j',
            startTime: start,
            duration: const Duration(minutes: 45),
            patientName: j % 2 == 0 ? 'Juan Pérez' : 'Ana López',
            title: j % 2 == 0 ? 'Sesión de seguimiento' : 'Evaluación cognitiva',
            notes: 'Mock data - replace with API response',
          ),
        );
      }
    }
    return appointments;
  }
}
