import 'package:xpressatec/domain/entities/appointment.dart';

abstract class AppointmentsRepository {
  /// Retrieves the appointments for the authenticated tutor between the given range.
  ///
  /// The implementation will later connect to the backend API. For now the
  /// data is mocked in memory.
  Future<List<Appointment>> getTutorAppointments({
    required DateTime startDate,
    required DateTime endDate,
  });
}
