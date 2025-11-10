import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../../../core/utils/media_path_mapper.dart';

abstract class MediaApiDatasource {
  /// Construye la URL remota a partir del relativePath lógico (ej: assets/images/amarillo/Amigo.png)
  String buildRemoteUrl(String relativePath);

  /// Descarga la imagen como bytes desde el servidor.
  Future<Uint8List> downloadImage(String relativePath);
}

class MediaApiDatasourceImpl implements MediaApiDatasource {
  MediaApiDatasourceImpl({
    http.Client? client,
    String baseUrl = defaultBaseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  /// Base URL por defecto del backend
  static const String defaultBaseUrl = 'https://xpressatec.online';

  final http.Client _client;
  final String _baseUrl;

  @override
  String buildRemoteUrl(String relativePath) {
    // relativePath viene con la ruta lógica tipo:
    // assets/images/amarillo/Amigo.png
    //
    // MediaPathMapper.toServerPath(relativePath) debe:
    // - quitar el prefijo "assets/"
    // - devolver algo como "images/amarillo/Amigo.png"
    //
    // Luego aquí encodeamos segmento por segmento para soportar espacios, tildes, ñ, etc.
    final serverPath = MediaPathMapper.toServerPath(relativePath)
        .split('/')
        .map(Uri.encodeComponent)
        .join('/');

    return '$_baseUrl/media/$serverPath';
  }

  @override
  Future<Uint8List> downloadImage(String relativePath) async {
    final uri = Uri.parse(buildRemoteUrl(relativePath));
    final response = await _client.get(uri);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    }

    throw Exception(
      'No se pudo descargar la imagen (${response.statusCode}) desde ${uri.toString()}',
    );
  }
}
