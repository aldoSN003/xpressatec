class User {
  final int id;
  final String uuid;
  final String nombre;
  final String email;
  final String rol; // 'Paciente', 'Terapeuta', 'Tutor'
  final DateTime? fechaCreacion;

  const User({
    required this.id,
    required this.uuid,
    required this.nombre,
    required this.email,
    required this.rol,
    this.fechaCreacion,
  });

  // Helper methods
  bool get isPaciente => rol == 'Paciente';
  bool get isTerapeuta => rol == 'Terapeuta';
  bool get isTutor => rol == 'Tutor';

  @override
  String toString() => 'User(id: $id, nombre: $nombre, rol: $rol)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}