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
    return UserModel(
      id: json['id'] ?? json['uid']?.hashCode ?? 0,
      uuid: json['uuid'] ?? json['uid'] ?? '',
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      email: json['email'] ?? json['Email'] ?? '',
      rol: json['rol'] ?? json['Rol'] ?? '',
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : (json['FechaCreacion'] != null
          ? DateTime.parse(json['FechaCreacion'])
          : null),
      fechaNacimiento: json['fechaNacimiento'],
      cedula: json['cedula'],
    );
  }

  // Convert to JSON (for Firestore and local storage)
  Map<String, dynamic> toJson() {
    return {
      'uid': uuid, // Firebase UID
      'uuid': uuid,
      'id': id,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaNacimiento': fechaNacimiento,
      'cedula': cedula,
    };
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