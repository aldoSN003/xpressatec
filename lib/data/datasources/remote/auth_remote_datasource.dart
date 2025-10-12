import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient apiClient;

  AuthRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['status'] == 'success') {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Error de conexión');
    }
  }

  @override
  Future<UserModel> register({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  }) async {
    try {
      final data = {
        'nombre': nombre,
        'email': email,
        'password': password,
        'rol': rol,
      };

      // Add optional fields
      if (fechaNacimiento != null) {
        data['fecha_nacimiento'] = fechaNacimiento;
      }
      if (cedula != null) {
        data['cedula'] = cedula;
      }

      final response = await apiClient.post(
        '/auth/register',
        data: data,
      );

      if (response.data['status'] == 'success') {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception('Error de conexión');
    }
  }
}