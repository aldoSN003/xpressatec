import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../models/user_model.dart';

abstract class ApiAuthDatasource {
  Future<UserModel> signUpWithEmail({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  });

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Uint8List> getPatientQr(String uuid);
}

class ApiAuthDatasourceImpl implements ApiAuthDatasource {
  ApiAuthDatasourceImpl({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  static const String _defaultBaseUrl = 'https://xpressatec.online';
  final http.Client _client;
  final String _baseUrl;

  Uri _buildUri(String path) => Uri.parse('$_baseUrl$path');

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
      };

  @override
  Future<UserModel> signUpWithEmail({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  }) async {
    final body = <String, dynamic>{
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol': rol,
    };

    if (fechaNacimiento != null && fechaNacimiento.isNotEmpty) {
      body['fecha_nacimiento'] = fechaNacimiento;
    }
    if (cedula != null && cedula.isNotEmpty) {
      body['cedula'] = cedula;
    }

    final response = await _client.post(
      _buildUri('/auth/register'),
      headers: _headers,
      body: jsonEncode(body),
    );

    final decoded = _decodeResponseBody(response);

    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      if (decoded['status'] == 'success') {
        return UserModel.fromJson({
          ...decoded,
          'email': email,
          'nombre': nombre,
        });
      }

      throw Exception(decoded['message'] ?? 'Error en el registro');
    }

    final message = decoded is Map<String, dynamic>
        ? decoded['message']?.toString()
        : 'Error en el registro';
    throw Exception(message);
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _buildUri('/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final decoded = _decodeResponseBody(response);

    if (response.statusCode == 200 && decoded is Map<String, dynamic>) {
      final success = decoded['success'];
      if (success == true) {
        return UserModel.fromJson({
          ...decoded,
          'email': email,
        });
      }

      throw Exception(decoded['message'] ?? 'Error de inicio de sesión');
    }

    final message = decoded is Map<String, dynamic>
        ? decoded['message']?.toString()
        : 'Error de inicio de sesión';
    throw Exception(message);
  }

  @override
  Future<Uint8List> getPatientQr(String uuid) async {
    final response = await _client.post(
      _buildUri('/auth/get-patient-qr'),
      headers: _headers,
      body: jsonEncode({'uuid': uuid}),
    );

    final contentType = response.headers['content-type'] ?? '';
    if (response.statusCode == 200 && contentType.contains('image/png')) {
      return response.bodyBytes;
    }

    final decoded = _decodeResponseBody(response);
    if (decoded is Map<String, dynamic>) {
      throw Exception(
        decoded['message']?.toString() ??
            'Paciente no encontrado o QR no disponible.',
      );
    }

    throw Exception('Paciente no encontrado o QR no disponible.');
  }

  dynamic _decodeResponseBody(http.Response response) {
    try {
      if (response.bodyBytes.isEmpty) {
        return null;
      }
      final decodedBody = utf8.decode(response.bodyBytes);
      if (decodedBody.isEmpty) {
        return null;
      }
      return jsonDecode(decodedBody);
    } catch (_) {
      return null;
    }
  }
}
