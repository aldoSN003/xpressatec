import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final String id;
  final DateTime startTime;
  final Duration duration;
  final String patientName;
  final String title;
  final String? notes;

  const Appointment({
    required this.id,
    required this.startTime,
    required this.duration,
    required this.patientName,
    required this.title,
    this.notes,
  });

  DateTime get endTime => startTime.add(duration);

  @override
  List<Object?> get props => [id, startTime, duration, patientName, title, notes];
}
