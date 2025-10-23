import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/constant_words.dart';
import '../../../../data/datasources/remote/firebase_storage_datasource.dart';

class TtsController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Lazy initialization - no constructor dependency injection needed
  late final FirebaseStorageDatasource _firebaseStorage = FirebaseStorageDatasourceImpl();

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

  Future<String?> tellPhraseWithPreview(String text, {bool forceRegenerate = false}) async {
    print("--- Iniciando tellPhraseWithPreview ---");
    print("Texto original: $text");
    print("Asistente seleccionado: ${selectedAssistant.value}");
    print("Forzar regeneración: $forceRegenerate");

    // Check if it's a constant word (single word from pictogram)
    final bool isConstantWord = ConstantWords.isConstant(text);
    print("¿Es palabra constante?: $isConstantWord");

    final String filePath = await _getAudioFilePath(text, selectedAssistant.value);
    final File audioFile = File(filePath);

    print("Buscando archivo en la ruta: $filePath");

    // STEP 1: Check local cache (skip if forceRegenerate)
    if (!forceRegenerate && await audioFile.exists()) {
      print('✅ Cache local encontrado. Reproduciendo...');
      await _playAudio(filePath);
      return filePath;
    }

    // If forceRegenerate, delete existing cache
    if (forceRegenerate && await audioFile.exists()) {
      print('🗑️ Borrando cache local existente...');
      await audioFile.delete();
    }

    // STEP 2: If constant word and not forcing regeneration, check Firebase Storage
    if (!forceRegenerate && isConstantWord) {
      print('🔍 Buscando en Firebase Storage...');
      try {
        final downloadedFile = await _firebaseStorage.downloadAudio(
          word: ConstantWords.normalize(text),
          assistant: selectedAssistant.value,
          localPath: filePath,
        );

        if (downloadedFile != null) {
          print('✅ Audio descargado desde Firebase. Reproduciendo...');
          await _playAudio(filePath);
          return filePath;
        } else {
          print('ℹ️ Audio no encontrado en Firebase.');
        }
      } catch (e) {
        print('⚠️ Error al descargar desde Firebase: $e');
        // Continue to API call
      }
    }

    // STEP 3: Call ElevenLabs API with preview loop
    return await _generateAndPreviewAudio(text, audioFile, isConstantWord);
  }

  /// Generate audio from ElevenLabs with preview loop
  Future<String?> _generateAndPreviewAudio(String text, File audioFile, bool isConstantWord) async {
    int attemptNumber = 1;

    while (true) {
      print('📞 Llamando a ElevenLabs API (Intento #$attemptNumber)...');

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
          print('✅ Audio recibido de ElevenLabs (Intento #$attemptNumber)');

          // Create temp file for preview
          final directory = await getTemporaryDirectory();
          final tempFilePath = '${directory.path}/temp_preview_${DateTime.now().millisecondsSinceEpoch}.mp3';
          final tempFile = File(tempFilePath);
          await tempFile.writeAsBytes(response.bodyBytes);

          // Play preview
          await _playAudio(tempFilePath);

          // Wait for audio to finish
          while (isPlaying.value) {
            await Future.delayed(const Duration(milliseconds: 100));
          }

          // Show confirmation dialog
          String? userChoice = await _showConfirmationDialog(text, attemptNumber, isConstantWord);

          // Handle user choice
          if (userChoice == 'yes') {
            return await _saveAudio(response.bodyBytes, audioFile, text, isConstantWord, tempFile);
          } else if (userChoice == 'no') {
            print('❌ Usuario rechazó el audio. Generando nueva versión...');
            await tempFile.delete();
            attemptNumber++;
            continue;
          } else {
            print('❌ Usuario canceló el proceso');
            await tempFile.delete();
            return null;
          }
        } else {
          print('❌ Error en API: ${response.statusCode}');
          print('Cuerpo de la respuesta: ${response.body}');
          _showErrorDialog('Error al generar audio.\nCódigo: ${response.statusCode}');
          return null;
        }
      } catch (e) {
        print('❌ Excepción en API call: $e');
        _showErrorDialog('Error de conexión:\n$e');
        return null;
      }
    }
  }

  /// Save audio to local cache and optionally to Firebase
  Future<String?> _saveAudio(
      List<int> audioBytes,
      File audioFile,
      String text,
      bool isConstantWord,
      File tempFile,
      ) async {
    // Save to local cache
    await audioFile.parent.create(recursive: true);
    await audioFile.writeAsBytes(audioBytes);
    final filePath = audioFile.path;
    print('✅ Audio guardado en cache local: $filePath');

    // Upload to Firebase if constant word
    if (isConstantWord) {
      try {
        print('📤 Subiendo audio a Firebase Storage...');
        await _firebaseStorage.uploadAudio(
          audioFile: audioFile,
          word: ConstantWords.normalize(text),
          assistant: selectedAssistant.value,
        );
        print('✅ Audio subido exitosamente a Firebase!');

        Get.snackbar(
          '✅ Guardado',
          'Audio guardado en Firebase y caché local',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        print('❌ Error al subir a Firebase: $e');
        Get.snackbar(
          '⚠️ Advertencia',
          'Audio guardado localmente pero no se pudo subir a Firebase',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    }

    // Delete temp file
    await tempFile.delete();
    return filePath;
  }

  /// Show confirmation dialog
  Future<String?> _showConfirmationDialog(String text, int attemptNumber, bool isConstantWord) {
    return Get.dialog<String>(
      AlertDialog(
        title: const Text('Confirmación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Guardar este audio para "$text"?'),
            const SizedBox(height: 8),
            Text('Intento: $attemptNumber', style: const TextStyle(fontSize: 12)),
            if (isConstantWord)
              const Text(
                '\n💾 Se guardará en Firebase',
                style: TextStyle(fontSize: 11, color: Colors.blue),
              ),
          ],
        ),
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

  /// Play multiple phrases in sequence
  Future<void> speakSelectedItems(List<String> phrases) async {
    for (final phrase in phrases) {
      await tellPhraseWithPreview(phrase);
      while (isPlaying.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  void stopAudio() {
    _audioPlayer.stop();
    isPlaying.value = false;
  }

  /// Legacy method for backward compatibility (without preview)
  Future<String?> tellPhrase11labs(String text) async {
    print("--- Iniciando tellPhrase11labs ---");
    print("Texto original: $text");
    print("Asistente seleccionado: ${selectedAssistant.value}");

    final String filePath = await _getAudioFilePath(text, selectedAssistant.value);
    final File audioFile = File(filePath);

    print("Buscando archivo en la ruta: $filePath");

    if (await audioFile.exists()) {
      print('✓ Cache hit para "$text". Reproduciendo desde almacenamiento local.');
      await _playAudio(filePath);
      return filePath;
    }

    print('✗ Cache miss para "$text". Llamando a la API de ElevenLabs...');

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

        await audioFile.parent.create(recursive: true);
        await audioFile.writeAsBytes(response.bodyBytes);

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
}