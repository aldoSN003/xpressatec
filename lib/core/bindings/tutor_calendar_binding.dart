import 'package:get/get.dart';
import 'package:xpressatec/data/repositories/mock_appointments_repository.dart';
import 'package:xpressatec/domain/repositories/appointments_repository.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
import 'package:xpressatec/presentation/features/calendar/controllers/tutor_calendar_controller.dart';

class TutorCalendarBinding extends Bindings {
  @override
  void dependencies() {
    // Once the backend endpoint is ready this repository registration can be
    // swapped for a remote implementation without touching the UI layer.
    Get.lazyPut<AppointmentsRepository>(
      () => MockAppointmentsRepository(),
    );

    Get.lazyPut<TutorCalendarController>(
      () => TutorCalendarController(
        Get.find<AppointmentsRepository>(),
        Get.find<AuthController>(),
      ),
    );
  }
}
