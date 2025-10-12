import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LlmController extends GetxController {
  // API Key
  final String geminiApiKey = dotenv.env['GEMINI_API_KEY'] ?? 'API_KEY_NOT_FOUND';

  // Loading state
  final RxBool isLoading = false.obs;

  // Last generated phrase
  final RxString generatedPhrase = ''.obs;

  // System instruction for Gemini
  final String systemInstruction = """
[ROL Y OBJETIVO]
Actúas como el núcleo de un sistema de Comunicación Aumentativa y Alternativa (CAA) diseñado para un usuario que se comunica a través de pictogramas. Tu objetivo principal es ser la voz del usuario, traduciendo secuencias de palabras clave en una única oración en español que sea gramaticalmente correcta, contextualmente apropiada y humanizada. Debes interpretar la intención detrás de los pictogramas, no solo traducirlos literalmente, todos los sujetos son familiares del usuario (usa mi abuelo, mi hermano, etc) a excepcion de maestro y terapeuta (usa el maestro, el terapeuta).

[REGLAS FUNDAMENTALES]
1.  **Interpretación del Sujeto y la Intención:** Esta es tu regla más importante.
    * **Primera Persona (YO):** Si la secuencia empieza con "yo" o la intención es claramente personal, formula una necesidad, deseo, sentimiento o acción del usuario. Aquí es apropiado usar un tono más personal y, si el contexto lo sugiere, amable.
    * **Instrucción Recibida (OTRO + YO):** Si la secuencia empieza con otro sujeto (ej. "mamá", "maestro") pero también incluye "yo", interpreta la frase como una acción, petición o estado que ese sujeto dirige hacia el usuario. Infiere verbos como "quiere que", "me dijo que", "necesita que".
    * **Observación de Terceros (OTROS):** Si la secuencia describe a otras personas y no incluye a "yo", interprétala como una observación objetiva de una situación. El tono debe ser más neutro y descriptivo.

2.  **Inferencia Lógica:** Con secuencias cortas o implícitas, infiere la intención más probable y común. Debes completar la idea para que sea funcional.
    * Ej: ['yo', 'agua'] no es "yo agua", sino "Quiero un vaso de agua" o "Tengo sed".

3.  **Coherencia y Naturalidad:** Añade todos los elementos gramaticales necesarios (artículos, preposiciones, conjunciones, verbos auxiliares) para construir una oración fluida y que suene humana. Evita las estructuras robóticas o excesivamente literales.

4.  **Tiempo y Conjugación:** Conjuga los verbos de forma gramaticalmente correcta en **tiempo presente**, a menos que una palabra clave indique explícitamente un tiempo diferente (ej. "ayer", "mañana", "lunes", "después").

5.  **Conservación del Significado:** Respeta la intensidad y el significado específico de cada palabra clave. "Furioso" es más intenso que "enojado"; "necesitar" es más fuerte que "querer".

[FORMATO DE SALIDA]
Devuelve únicamente la oración final completa, sin comillas, etiquetas ni explicaciones adicionales.
""";

  /// Generate phrase from array of words
  Future<String?> generatePhrase(List<String> words) async {
    if (words.isEmpty) {
      print('✗ No words provided to generate phrase');
      return null;
    }

    print('--- Iniciando generación de frase ---');
    print('Palabras: $words');

    const String apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

    Map<String, String> headers = {
      'x-goog-api-key': geminiApiKey,
      'Content-Type': 'application/json',
    };

    // Convert words array to comma-separated string
    String wordsString = words.map((w) => '"$w"').join(', ');
    String inputText = '[$wordsString]';

    String requestBody = jsonEncode({
      "system_instruction": {
        "parts": [
          {"text": systemInstruction}
        ]
      },
      "contents": [
        {
          "parts": [
            {"text": inputText}
          ]
        }
      ]
    });

    try {
      isLoading.value = true;

      var response = await http
          .post(Uri.parse(apiUrl), headers: headers, body: requestBody)
          .timeout(const Duration(seconds: 15));

      isLoading.value = false;

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);

        String phrase = data['candidates'][0]['content']['parts'][0]['text'];

        // Clean up the phrase (remove quotes if present)
        phrase = phrase.trim();
        if (phrase.startsWith('"') && phrase.endsWith('"')) {
          phrase = phrase.substring(1, phrase.length - 1);
        }

        generatedPhrase.value = phrase;
        print('✓ Frase generada: $phrase');
        return phrase;
      } else {
        print('✗ Error en Gemini API: ${response.statusCode}');
        print('Respuesta: ${response.body}');
        return null;
      }
    } catch (error) {
      isLoading.value = false;
      print('✗ Error al generar frase: $error');
      return null;
    }
  }

  /// Extract words from selectedItems and generate phrase
  Future<String?> generatePhraseFromItems(List<dynamic> selectedItems) async {
    List<String> words = selectedItems
        .map((item) => item.text as String)
        .toList();

    return await generatePhrase(words);
  }
}