import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:frankenstein/core/services/content_storage_base.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import "../../../models/index.dart";

/// Desktop/mobile storage back end: persists content and characters as JSON
/// files under the application documents directory.
///
/// Web has no filesystem, so the web build uses `WebStorageService` instead;
/// the two are selected at runtime by `storage_factory.dart`. The shared
/// content load/save logic lives in [JsonContentStorage]; this class only
/// supplies the file-backed [readJson]/[writeJson] plus character storage.
class JsonStorageService extends JsonContentStorage {
  // TODO(LOOK FOR RACE CONDITIONS - MAYBE USE MUTEX)
  static final JsonStorageService _instance = JsonStorageService._internal();
  factory JsonStorageService() => _instance;
  JsonStorageService._internal();

  late Directory _baseDirectory;
  late Directory _characterDirectory;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  static const String _contentPath = 'frankenstein_content';
  static const String _charactersSubfolder = 'frankenstein_characters';

  static const String characterNotReadyMessage = 'Character service not ready';
  static const String contentNotReadyMessage = 'Content service not ready';

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      final appDocsDir = await getApplicationDocumentsDirectory();

      // Initialise content storage
      _baseDirectory = Directory(path.join(appDocsDir.path, _contentPath));
      final isFirstRun = !await _baseDirectory.exists();

      if (isFirstRun) {
        await _baseDirectory.create(recursive: true);
        debugPrint('Created main storage directory: ${_baseDirectory.path}');

        // Copy default SRD content from assets on first run
        await _initializeDefaultContent();
      } else {
        debugPrint(
            'Using existing main storage directory: ${_baseDirectory.path}');
      }

      // initialise character storage
      _characterDirectory = Directory(
          path.join(appDocsDir.path, _contentPath, _charactersSubfolder));
      if (!await _characterDirectory.exists()) {
        await _characterDirectory.create(recursive: true);
        debugPrint(
            'Created character storage directory: ${_characterDirectory.path}');
      } else {
        debugPrint(
            'Using existing character storage directory: ${_characterDirectory.path}');
      }

      _initialized = true;
      debugPrint('JsonStorageService initialized successfully');
      return true;
    } catch (e) {
      // TODO(Possibly attempt some kind of file repair or warning system)
      debugPrint('JsonStorageService initialization failed: $e');
      return false;
    }
  }

  /// Copies default SRD content from assets to storage directory on first run
  Future<void> _initializeDefaultContent() async {
    debugPrint('Initializing default SRD content from assets...');

    int successCount = 0;
    int failCount = 0;

    for (final fileName in JsonContentStorage.defaultContentFiles) {
      try {
        // Load from assets using rootBundle (doesn't require BuildContext)
        final assetPath = 'assets/srd/$fileName';
        final assetContent = await rootBundle.loadString(assetPath);

        // Write to storage directory
        final targetFile = File(path.join(_baseDirectory.path, fileName));
        await targetFile.writeAsString(assetContent);
        successCount++;
        debugPrint('Copied $fileName from assets to storage');
      } catch (e) {
        failCount++;
        debugPrint('Failed to copy $fileName from assets: $e');
        // Continue with other files even if one fails
      }
    }

    debugPrint(
        'Content initialization complete: $successCount succeeded, $failCount failed');
  }

  String _getFullPath(String fileName) {
    return path.join(_baseDirectory.path, fileName);
  }

  @override
  Future<Map<String, dynamic>?> readJson(String fileName) async {
    if (!_initialized) {
      debugPrint(contentNotReadyMessage);
      return null;
    }
    try {
      final file = File(_getFullPath(fileName));
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      if (content.isEmpty) return null;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to read JSON from $fileName: $e');
      return null;
    }
  }

  @override
  Future<bool> writeJson(String fileName, Map<String, dynamic> data) async {
    if (!_initialized) {
      debugPrint(contentNotReadyMessage);
      return false;
    }
    try {
      final jsonString = jsonEncode(data);
      final fullPath = _getFullPath(fileName);
      final targetFile = File(fullPath);
      final parentDir = targetFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      final tempFile = File('$fullPath.tmp');
      try {
        await tempFile.writeAsString(jsonString);
        await tempFile.rename(fullPath);
        return true;
      } catch (e) {
        if (await tempFile.exists()) {
          try {
            await tempFile.delete();
          } catch (_) {}
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('Failed to write JSON to $fileName: $e');
      return false;
    }
  }

  // Character operations
  // Updates the index file to ensure it is up to date with the current characters
  Future<void> _updateIndex() async {
    try {
      final files = _characterDirectory.listSync().whereType<File>();
      final characterIds = files
          .where((file) =>
              file.path.endsWith('.json') && !file.path.endsWith('index.json'))
          .map((file) => path.basenameWithoutExtension(file.path))
          .toList();
      final indexData = {
        'characters': characterIds,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      final indexFile = File(path.join(_characterDirectory.path, 'index.json'));
      await indexFile.writeAsString(jsonEncode(indexData));
      debugPrint('Index updated with ${characterIds.length} characters');
    } catch (e) {
      debugPrint('Error updating index: $e');
    }
  }

  @override
  Future<bool> deleteCharacter(int characterId) async {
    if (!_initialized) {
      debugPrint(characterNotReadyMessage);
      return false;
    }
    try {
      final filePath = path.join(_characterDirectory.path, '$characterId.json');
      debugPrint('Attempting to delete file: $filePath');
      final characterFile = File(filePath);
      if (await characterFile.exists()) {
        debugPrint('File exists, deleting: $filePath');
        await characterFile.delete();
      }
      await _updateIndex();
      debugPrint('Character (ID: $characterId) deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting character (ID: $characterId): $e');
      return false;
    }
  }

  @override
  Future<List<Character>> getAllCharacters() async {
    if (!_initialized) {
      debugPrint(characterNotReadyMessage);
      return [];
    }
    try {
      return await _loadAllCharacters();
    } catch (e) {
      debugPrint('Error loading characters from new system: $e');
      return [];
    }
  }

  //TODO(Cleanup function)
  // Function can error, this should be handled by the caller
  Future<List<Character>> _loadAllCharacters() async {
    final characters = <Character>[];
    final indexFile = File(path.join(_characterDirectory.path, 'index.json'));
    if (await indexFile.exists()) {
      final indexContent = await indexFile.readAsString();
      final indexData = jsonDecode(indexContent) as Map<String, dynamic>;
      final characterIds = List<String>.from(indexData['characters'] ?? []);
      for (final characterId in characterIds) {
        final characterFile =
            File(path.join(_characterDirectory.path, '$characterId.json'));
        if (await characterFile.exists()) {
          try {
            final characterContent = await characterFile.readAsString();
            final characterData =
                jsonDecode(characterContent) as Map<String, dynamic>;
            final character = Character.fromJson(characterData);
            characters.add(character);
          } catch (e) {
            debugPrint('Error loading character $characterId: $e');
          }
        }
      }
    } else {
      final files = _characterDirectory.listSync().whereType<File>();
      for (final file in files) {
        if (file.path.endsWith('.json') && !file.path.endsWith('index.json')) {
          try {
            final characterContent = await file.readAsString();
            final characterData =
                jsonDecode(characterContent) as Map<String, dynamic>;
            final character = Character.fromJson(characterData);
            characters.add(character);
          } catch (e) {
            debugPrint('Error loading character from ${file.path}: $e');
          }
        }
      }
    }
    debugPrint('Loaded ${characters.length} characters from storage');
    return characters;
  }

  @override
  Future<bool> saveCharacter(Character character) async {
    if (!_initialized) {
      debugPrint(characterNotReadyMessage);
      return false;
    }
    try {
      final characterFile = File(
          path.join(_characterDirectory.path, '${character.uniqueID}.json'));
      final characterData = character.toJson();
      await characterFile.writeAsString(jsonEncode(characterData));
      await _updateIndex();
      debugPrint(
          'Character  ${character.name}, UID: ${character.uniqueID}, saved successfully');
      return true;
    } catch (e) {
      debugPrint(
          'Error saving character ${character.name}, UID: ${character.uniqueID}: $e');
      return false;
    }
  }

  @override
  Future<bool> updateCharacter(Character character) async {
    if (!_initialized) {
      debugPrint(characterNotReadyMessage);
      return false;
    }
    try {
      final characterFile = File(
          path.join(_characterDirectory.path, '${character.uniqueID}.json'));
      final characterData = character.toJson();
      await characterFile.writeAsString(jsonEncode(characterData));
      await _updateIndex();
      debugPrint(
          'Character  ${character.name}, UID: ${character.uniqueID}, updated successfully');
      return true;
    } catch (e) {
      debugPrint(
          'Error updating character ${character.name}, UID: ${character.uniqueID}: $e');
      return false;
    }
  }
}
