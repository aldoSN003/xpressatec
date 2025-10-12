import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.uuid,
    required super.nombre,
    required super.email,
    required super.rol,
    super.fechaCreacion,
  });

  // Create from JSON (Flask API response)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['IdUsuario'] ?? json['id'] ?? 0,
      uuid: json['UUID'] ?? json['uuid'] ?? '',
      nombre: json['Nombre'] ?? json['nombre'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      rol: json['Rol'] ?? json['rol'] ?? '',
      fechaCreacion: json['FechaCreacion'] != null
          ? DateTime.parse(json['FechaCreacion'])
          : null,
    );
  }

  // Convert to JSON (for local storage)
  Map<String, dynamic> toJson() {
    return {
      'IdUsuario': id,
      'UUID': uuid,
      'Nombre': nombre,
      'Email': email,
      'Rol': rol,
      'FechaCreacion': fechaCreacion?.toIso8601String(),
    };
  }

  // Create from entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      uuid: user.uuid,
      nombre: user.nombre,
      email: user.email,
      rol: user.rol,
      fechaCreacion: user.fechaCreacion,
    );
  }

  // Convert to entity
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
}