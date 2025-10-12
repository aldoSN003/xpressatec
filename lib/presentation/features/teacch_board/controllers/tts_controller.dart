import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
    // ✅ Setup listener ONCE here
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

  // ✅ NEW: Sanitize text for filename (handles Spanish diacritics)
  String _sanitizeTextForFilename(String text) {
    String lowercased = text.toLowerCase();

    // Manual replacement for common Spanish diacritics
    String withoutDiacritics = lowercased
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u');

    // Remove all non-alphanumeric characters using a regular expression
    RegExp invalidChars = RegExp(r'[^a-z0-9]');
    String sanitized = withoutDiacritics.replaceAll(invalidChars, '');

    return sanitized;
  }

  // Get audio file path for caching
  Future<String> _getAudioFilePath(String text, String assistant) async {
    final directory = await getApplicationDocumentsDirectory();
    final sanitizedText = _sanitizeTextForFilename(text);
    return '${directory.path}/audio_cache/${assistant}_$sanitizedText.mp3';
  }

  Future<String?> tellPhrase11labs(String text) async {
    print("--- Iniciando tellPhrase11labs ---");
    print("Texto original: $text");
    print("Asistente seleccionado: ${selectedAssistant.value}");

    // 1. Determinar la ruta completa donde el archivo de audio debe estar cacheado
    final String filePath = await _getAudioFilePath(text, selectedAssistant.value);
    final File audioFile = File(filePath);

    print("Buscando archivo en la ruta: $filePath");

    // 2. Comprobar si el archivo ya existe en la caché
    if (await audioFile.exists()) {
      print('✓ Cache hit para "$text". Reproduciendo desde almacenamiento local.');
      await _playAudio(filePath);
      return filePath;
    }

    // 3. El archivo no está en caché: Llamar a la API para generar el audio
    print('✗ Cache miss para "$text". Llamando a la API de ElevenLabs...');

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
        print('✓ Audio recibido de ElevenLabs API');

        // 4. Guardar el nuevo archivo de audio en la caché
        await audioFile.parent.create(recursive: true);
        await audioFile.writeAsBytes(response.bodyBytes);

        // 5. Reproducir el audio recién descargado
        await _playAudio(filePath);
        print('✓ Audio guardado y reproducido desde: $filePath');
        return filePath;
      } else {
        print('✗ Error al obtener audio de la API: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('✗ Ocurrió una excepción durante la llamada a la API: $e');
      return null;
    }
  }


  // ✅ NEW: Preview audio before saving to cache
  Future<String?> tellPhraseWithPreview(String text) async {
    print("--- Iniciando tellPhraseWithPreview ---");
    print("Texto original: $text");
    print("Asistente seleccionado: ${selectedAssistant.value}");

    final String filePath = await _getAudioFilePath(text, selectedAssistant.value);
    final File audioFile = File(filePath);

    print("Buscando archivo en la ruta: $filePath");

    // 1. If already cached, just play it
    if (await audioFile.exists()) {
      print('✓ Cache hit para "$text". Reproduciendo desde almacenamiento local.');
      await _playAudio(filePath);
      return filePath;
    }

    // 2. Loop to allow regeneration if user doesn't like the audio
    int attemptNumber = 1;
    while (true) {
      print('✗ Cache miss para "$text". Intento #$attemptNumber - Llamando a la API de ElevenLabs...');

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
          print('✓ Audio recibido de ElevenLabs API (Intento #$attemptNumber)');

          // 3. Create temporary file to play preview
          final directory = await getTemporaryDirectory();
          final tempFilePath = '${directory.path}/temp_preview_${DateTime.now().millisecondsSinceEpoch}.mp3';
          final tempFile = File(tempFilePath);
          await tempFile.writeAsBytes(response.bodyBytes);

          // 4. Play the preview audio
          await _playAudio(tempFilePath);

          // 5. Wait for audio to finish playing
          while (isPlaying.value) {
            await Future.delayed(const Duration(milliseconds: 100));
          }

          // 6. Show confirmation dialog with three options
          String? userChoice = await Get.dialog<String>(
            AlertDialog(
              title: const Text('Confirmación'),
              content: Text('¿Seguro que quieres guardar este audio?\n\nIntento: $attemptNumber'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: 'cancel'),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Get.back(result: 'no'),
                  child: const Text('No, generar otro'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: 'yes'),
                  child: const Text('Sí, guardar'),
                ),
              ],
            ),
            barrierDismissible: false,
          );

          // 7. Handle user's choice
          if (userChoice == 'yes') {
            // Save to cache
            await audioFile.parent.create(recursive: true);
            await audioFile.writeAsBytes(response.bodyBytes);
            print('✓ Audio guardado en caché: $filePath');

            // Delete temp file
            await tempFile.delete();
            return filePath;
          } else if (userChoice == 'no') {
            // Delete temp file and try again
            print('✗ Usuario rechazó el audio. Generando nueva versión...');
            await tempFile.delete();
            attemptNumber++;
            // Loop continues to make another API call
            continue;
          } else {
            // User cancelled entirely
            print('✗ Usuario canceló el proceso');
            await tempFile.delete();
            return null;
          }
        } else {
          print('✗ Error al obtener audio de la API: ${response.statusCode}');
          print('Cuerpo de la respuesta: ${response.body}');

          // Show error dialog
          Get.dialog(
            AlertDialog(
              title: const Text('Error'),
              content: Text('No se pudo generar el audio.\nCódigo: ${response.statusCode}'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return null;
        }
      } catch (e) {
        print('✗ Ocurrió una excepción durante la llamada a la API: $e');

        // Show error dialog
        Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: Text('Ocurrió un error:\n$e'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return null;
      }
    }
  }


  Future<void> _playAudio(String filePath) async {
    isPlaying.value = true;
    await _audioPlayer.play(DeviceFileSource(filePath));
    // ✅ Listener is already set up in onInit
  }

  // Play multiple phrases in sequence
  Future<void> speakSelectedItems(List<String> phrases) async {
    for (final phrase in phrases) {
      await tellPhraseWithPreview(phrase);
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