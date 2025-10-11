import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TtsController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Voice IDs (replace with your actual IDs)
  final String isamarVoiceId = 'iyvXhCAqzDxKnq3FDjZl';
  final String emmanuelVoiceId = 'qvN99qHpu3uqmqBD6pEt';
  final String lauraVoiceId='zl1Ut8dvwcVSuQSB9XkG';
  final String alexVoiceId='6DsgX00trsI64jl83WWS';

  // API Key (better to use environment variables or secure storage)
 // final String elevenLabsApiKey = dotenv.env['ELEVENLABS_API_KEY'] ?? 'API_KEY_NOT_FOUND';
  final String elevenLabsApiKey = "";

  // Selected assistant
  final RxString selectedAssistant = 'emmanuel'.obs;

  // Is currently playing
  final RxBool isPlaying = false.obs;

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  // Get audio file path for caching
  Future<String> _getAudioFilePath(String text, String assistant) async {
    final directory = await getApplicationDocumentsDirectory();
    final sanitizedText = text.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '_');
    return '${directory.path}/audio_cache/${assistant}_$sanitizedText.mp3';
  }

  Future<String?> tellPhrase11labs(String text) async {
    print("--- Iniciando tellPhrase11labs ---");
    print("Asistente seleccionado: ${selectedAssistant.value}");

    // 1. Determinar la ruta completa donde el archivo de audio debe estar cacheado
    final String filePath = await _getAudioFilePath(text, selectedAssistant.value);
    final File audioFile = File(filePath);

    print("Buscando archivo en la ruta: $filePath");

    // 2. Comprobar si el archivo ya existe en la caché
    if (await audioFile.exists()) {
      print('Cache hit para "$text". Reproduciendo desde almacenamiento local.');
      await _playAudio(filePath);
      return filePath;
    }

    // 3. El archivo no está en caché: Llamar a la API para generar el audio
    print('Cache miss para "$text". Llamando a la API de ElevenLabs...');

    String voiceId;
    switch (selectedAssistant.value) {
      case 'isamar':
        voiceId = isamarVoiceId;
        break;
      case 'laura':
        voiceId = lauraVoiceId;
        break;
      case 'alex':
        voiceId = alexVoiceId;
        break;
      case 'emmanuel':
        voiceId = emmanuelVoiceId;
        break;
      default:
        print('Advertencia: Asistente desconocido. Usando Emmanuel por defecto.');
        voiceId = emmanuelVoiceId;
        break;
    }

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
        // 4. Guardar el nuevo archivo de audio en la caché
        await audioFile.parent.create(recursive: true);
        await audioFile.writeAsBytes(response.bodyBytes);

        // 5. Reproducir el audio recién descargado
        await _playAudio(filePath);
        print('Audio guardado y reproducido desde: $filePath');
        return filePath;
      } else {
        print('Error al obtener audio de la API: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Ocurrió una excepción durante la llamada a la API: $e');
      return null;
    }
  }

  Future<void> _playAudio(String filePath) async {
    isPlaying.value = true;
    await _audioPlayer.play(DeviceFileSource(filePath));

    // Listen for completion
    _audioPlayer.onPlayerComplete.listen((_) {
      isPlaying.value = false;
    });
  }

  // Play multiple phrases in sequence
  Future<void> speakSelectedItems(List<String> phrases) async {
    for (final phrase in phrases) {
      await tellPhrase11labs(phrase);
      // Wait for current audio to finish before playing next
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