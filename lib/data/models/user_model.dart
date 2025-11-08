import '../../domain/entities/user.dart';

class UserModel extends User {
  final String? fechaNacimiento;
  final String? cedula;

  const UserModel({
    required super.id,
    required super.uuid,
    required super.nombre,
    required super.email,
    required super.rol,
    super.fechaCreacion,
    this.fechaNacimiento,
    this.cedula,
  });

  // Create from JSON (Firestore format)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    int _parseId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? value.hashCode;
      }
      return 0;
    }

    DateTime? _parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    final idValue = json['id'] ?? json['idPersona'] ?? json['id_persona'] ?? json['uid'];

    final uuidValue = json['uuid'] ?? json['UUID'] ?? json['uid'] ?? '';
    final nombreValue = json['nombre'] ?? json['Nombre'] ?? '';
    final emailValue =
        json['email'] ?? json['Email'] ?? json['correo'] ?? json['Correo'] ?? '';
    final rolValue = json['rol'] ?? json['Rol'] ?? '';
    final fechaCreacionValue = json['fechaCreacion'] ??
        json['FechaCreacion'] ??
        json['fecha_creacion'] ??
        json['Fecha_creacion'];
    final fechaNacimientoValue =
        json['fechaNacimiento'] ?? json['fecha_nacimiento'];

    return UserModel(
      id: _parseId(idValue),
      uuid: uuidValue.toString(),
      nombre: nombreValue.toString(),
      email: emailValue.toString(),
      rol: rolValue.toString(),
      fechaCreacion: _parseDate(fechaCreacionValue),
      fechaNacimiento:
          fechaNacimientoValue == null ? null : fechaNacimientoValue.toString(),
      cedula: json['cedula']?.toString(),
    );
  }

  // Convert to JSON (for Firestore and local storage)
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'idPersona': id,
      'id_persona': id,
      'uuid': uuid,
      'UUID': uuid,
      'uid': uuid,
      'nombre': nombre,
      'Nombre': nombre,
      'email': email,
      'correo': email,
      'rol': rol,
      'Rol': rol,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaNacimiento': fechaNacimiento,
      'fecha_nacimiento': fechaNacimiento,
      'cedula': cedula,
    };

    data.removeWhere((key, value) => value == null);
    return data;
  }

  // Create from entity
  factory UserModel.fromEntity(User user) {
    if (user is UserModel) {
      return user;
    }
    return UserModel(
      id: user.id,
      uuid: user.uuid,
      nombre: user.nombre,
      email: user.email,
      rol: user.rol,
      fechaCreacion: user.fechaCreacion,
    );
  }

  // Convert to entity (inherited from User, but override for clarity)
  @override
  User toEntity() {
    return User(
      id: id,
      uuid: uuid,
      nombre: nombre,
      email: email,
      rol: rol,
      fechaCreacion: fechaCreacion,
    );
  }

  // CopyWith method for updates
  UserModel copyWith({
    int? id,
    String? uuid,
    String? nombre,
    String? email,
    String? rol,
    DateTime? fechaCreacion,
    String? fechaNacimiento,
    String? cedula,
  }) {
    return UserModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      cedula: cedula ?? this.cedula,
    );
  }
}