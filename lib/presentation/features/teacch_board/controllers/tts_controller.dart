import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/constant_words.dart';

class TtsController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Voice IDs
  final String isamarVoiceId = 'iyvXhCAqzDxKnq3FDjZl';
  final String emmanuelVoiceId = 'qvN99qHpu3uqmqBD6pEt';
  final String lauraVoiceId = 'zl1Ut8dvwcVSuQSB9XkG';
  final String alexVoiceId = '6DsgX00trsI64jl83WWS';

  // API Key
  final String elevenLabsApiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  // Selected assistant
  final RxString selectedAssistant = 'emmanuel'.obs;

  // Is currently playing
  final RxBool isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer.onPlayerComplete.listen((_) {
      isPlaying.value = false;
      print('Audio playback completed');
    });
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  String _sanitizeTextForFilename(String text) {
    String lowercased = text.toLowerCase();
    String withoutDiacritics = lowercased
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u');
    RegExp invalidChars = RegExp(r'[^a-z0-9]');
    String sanitized = withoutDiacritics.replaceAll(invalidChars, '');
    return sanitized;
  }

  Future<String> _getAudioFilePath(String text, String assistant) async {
    final directory = await getApplicationDocumentsDirectory();
    final sanitizedText = _sanitizeTextForFilename(text);
    return '${directory.path}/audio_cache/${assistant}_$sanitizedText.mp3';
  }

  String _getVoiceId() {
    switch (selectedAssistant.value) {
      case 'isamar':
        return isamarVoiceId;
      case 'laura':
        return lauraVoiceId;
      case 'alex':
        return alexVoiceId;
      case 'emmanuel':
      default:
        return emmanuelVoiceId;
    }
  }

  Future<void> _playAudio(String filePath) async {
    isPlaying.value = true;
    await _audioPlayer.play(DeviceFileSource(filePath));
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// 🎯 MAIN METHOD: Tell phrase (cache-first, then API)
  Future<String?> tellPhrase11labs(String text) async {
    print("--- Iniciando tellPhrase11labs ---");
    print("Texto original: $text");
    print("Asistente seleccionado: ${selectedAssistant.value}");

    final String filePath = await _getAudioFilePath(text, selectedAssistant.value);
    final File audioFile = File(filePath);

    print("Buscando archivo en la ruta: $filePath");

    // ✅ STEP 1: Check local cache first
    if (await audioFile.exists()) {
      print('✓ Cache hit para "$text". Reproduciendo desde almacenamiento local.');
      await _playAudio(filePath);
      return filePath;
    }

    print('✗ Cache miss para "$text". Llamando a la API de ElevenLabs...');

    // ✅ STEP 2: Call ElevenLabs API (for dynamic phrases or missing audios)
    String voiceId = _getVoiceId();
    final String url = 'https://api.elevenlabs.io/v1/text-to-speech/$voiceId?output_format=mp3_44100_96';

    final Map<String, String> headers = {
      'Accept': 'audio/mpeg',
      'Content-Type': 'application/json',
      'xi-api-key': elevenLabsApiKey,
    };

    final Map<String, dynamic> body = {
      'text': text,
      'model_id': 'eleven_multilingual_v2',
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('✓ Audio recibido de ElevenLabs API');

        // Save to cache
        await audioFile.parent.create(recursive: true);
        await audioFile.writeAsBytes(response.bodyBytes);

        // Play audio
        await _playAudio(filePath);
        print('✓ Audio guardado y reproducido desde: $filePath');
        return filePath;
      } else {
        print('✗ Error al obtener audio de la API: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        _showErrorDialog('Error al generar audio.\nCódigo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('✗ Ocurrió una excepción durante la llamada a la API: $e');
      _showErrorDialog('Error de conexión:\n$e');
      return null;
    }
  }

  /// Play multiple phrases in sequence
  Future<void> speakSelectedItems(List<String> phrases) async {
    for (final phrase in phrases) {
      await tellPhrase11labs(phrase);
      while (isPlaying.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  void stopAudio() {
    _audioPlayer.stop();
    isPlaying.value = false;
  }
}