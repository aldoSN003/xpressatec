import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/utils/media_path_mapper.dart';

abstract class MediaApiDatasource {
  String buildRemoteUrl(String relativePath);
  Future<Uint8List> downloadImage(String relativePath);
}

class MediaApiDatasourceImpl implements MediaApiDatasource {
  MediaApiDatasourceImpl({http.Client? client, String baseUrl = _baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  static const String _baseUrl = 'https://xpressatec.online';
  final http.Client _client;
  final String _baseUrl;

  @override
  String buildRemoteUrl(String relativePath) {
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
