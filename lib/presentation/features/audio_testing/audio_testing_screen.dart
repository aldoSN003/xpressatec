import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../data/datasources/remote/firebase_storage_datasource.dart';
import '../../../../domain/repositories/teacch_repository.dart';
import '../teacch_board/controllers/tts_controller.dart';



class AudioTestingScreen extends StatefulWidget {
  const AudioTestingScreen({Key? key}) : super(key: key);

  @override
  State<AudioTestingScreen> createState() => _AudioTestingScreenState();
}

class _AudioTestingScreenState extends State<AudioTestingScreen> {
  final TtsController _ttsController = Get.find<TtsController>();
  final FirebaseStorageDatasource _firebaseStorage = FirebaseStorageDatasourceImpl();
  final TeacchRepository _repository = Get.find<TeacchRepository>();
  final TextEditingController _searchController = TextEditingController();

  List<String> allWords = [];
  List<String> filteredWords = [];
  Map<String, bool> firebaseStatus = {};
  bool isLoadingWords = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAllWords();
    _searchController.addListener(_filterWords);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterWords() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        filteredWords = List.from(allWords);
      } else {
        filteredWords = allWords
            .where((word) => word.toLowerCase().contains(searchQuery))
            .toList();
      }
    });
  }

  Future<void> _loadAllWords() async {
    setState(() => isLoadingWords = true);

    final Set<String> wordsSet = {};

    // 1. Add category names (portadas)
    for (final category in AppConstants.mainCategories) {
      final categoryName = category.name.toLowerCase();
      wordsSet.add(categoryName);
      print('Added category: $categoryName');
    }

    // 2. Load words from all categories
    for (final category in AppConstants.mainCategories) {
      try {
        print('Loading items from category: ${category.name}');

        final assets = await _repository.getAssetPaths(category.contentPath);

        for (final subcategoryPaths in assets.values) {
          for (final path in subcategoryPaths) {
            // Extract word from filename
            final name = path.split('/').last.split('.').first.replaceAll('_', ' ');

            if (name.isNotEmpty && name.toLowerCase() != 'portada') {
              wordsSet.add(name.toLowerCase());
            }
          }
        }
      } catch (e) {
        print('Error loading category ${category.name}: $e');
      }
    }

    allWords = wordsSet.toList()..sort();
    filteredWords = List.from(allWords);
    print('Total unique words found: ${allWords.length}');

    // Check Firebase status for all words
    await _checkFirebaseStatus();

    setState(() => isLoadingWords = false);
  }

  Future<void> _checkFirebaseStatus() async {
    for (final word in allWords) {
      try {
        final exists = await _firebaseStorage.audioExists(
          word: word,
          assistant: _ttsController.selectedAssistant.value,
        );
        firebaseStatus[word] = exists;
      } catch (e) {
        print('Error checking Firebase status for $word: $e');
        firebaseStatus[word] = false;
      }
    }
    setState(() {});
  }

  Future<void> _generateAudio(String word) async {
    final exists = firebaseStatus[word] ?? false;

    if (exists) {
      // Show override confirmation
      final override = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Audio ya existe'),
          content: Text('Ya existe un audio para "$word" en Firebase.\n\n¿Quieres reemplazarlo con un nuevo audio generado?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Sí, generar nuevo'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      );

      if (override != true) return;

      // Generate NEW audio with forceRegenerate = true
      print('🔄 Forzando regeneración para: $word');
      final result = await _ttsController.tellPhraseWithPreview(word, forceRegenerate: true);

      if (result != null) {
        setState(() {
          firebaseStatus[word] = true;
        });

        Get.snackbar(
          '✅ Audio Reemplazado',
          'Nuevo audio para "$word" guardado exitosamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } else {
      // Generate audio normally (no override needed)
      final result = await _ttsController.tellPhraseWithPreview(word);

      if (result != null) {
        setState(() {
          firebaseStatus[word] = true;
        });

        Get.snackbar(
          '✅ Completado',
          'Audio para "$word" guardado exitosamente',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  int get totalInFirebase => firebaseStatus.values.where((e) => e).length;
  int get totalMissing => firebaseStatus.values.where((e) => !e).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de Audios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              _loadAllWords();
            },
            tooltip: 'Recargar',
          ),
          Obx(() => PopupMenuButton<String>(
            initialValue: _ttsController.selectedAssistant.value,
            onSelected: (value) {
              _ttsController.selectedAssistant.value = value;
              _checkFirebaseStatus();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'emmanuel', child: Text('Emmanuel')),
              const PopupMenuItem(value: 'isamar', child: Text('Isamar')),
              const PopupMenuItem(value: 'laura', child: Text('Laura')),
              const PopupMenuItem(value: 'alex', child: Text('Alex')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_ttsController.selectedAssistant.value.capitalizeFirst!),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          )),
        ],
      ),
      body: isLoadingWords
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando palabras...'),
          ],
        ),
      )
          : allWords.isEmpty
          ? const Center(
        child: Text(
          'No se encontraron palabras.\nVerifica tus assets.',
          textAlign: TextAlign.center,
        ),
      )
          : Column(
        children: [
          // Stats bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatWidget(
                      label: 'Total',
                      value: allWords.length.toString(),
                      color: Colors.blue,
                    ),
                    _StatWidget(
                      label: 'En Firebase',
                      value: totalInFirebase.toString(),
                      color: Colors.green,
                    ),
                    _StatWidget(
                      label: 'Faltantes',
                      value: totalMissing.toString(),
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar palabra...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Mostrando ${filteredWords.length} de ${allWords.length} palabras',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Word list
          Expanded(
            child: filteredWords.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron resultados para "$searchQuery"',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredWords.length,
              itemBuilder: (context, index) {
                final word = filteredWords[index];
                final existsInFirebase = firebaseStatus[word] ?? false;

                return ListTile(
                  leading: Icon(
                    existsInFirebase ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: existsInFirebase ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    word,
                    style: TextStyle(
                      fontWeight: existsInFirebase ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (existsInFirebase)
                        IconButton(
                          icon: const Icon(Icons.play_arrow, color: Colors.blue),
                          onPressed: () async {
                            await _ttsController.tellPhraseWithPreview(word);
                          },
                          tooltip: 'Reproducir',
                        ),
                      IconButton(
                        icon: Icon(
                          existsInFirebase ? Icons.refresh : Icons.mic,
                          color: existsInFirebase ? Colors.orange : Colors.green,
                        ),
                        onPressed: () => _generateAudio(word),
                        tooltip: existsInFirebase ? 'Regenerar' : 'Generar',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatWidget({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}