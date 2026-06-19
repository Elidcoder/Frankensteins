import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:frankenstein/core/services/content_storage_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

import "../../../models/index.dart";

/// Web storage back end: there is no filesystem in the browser, so content and
/// characters are persisted to localStorage via `shared_preferences`.
///
/// It mirrors `JsonStorageService`: SRD content is seeded from bundled assets
/// on first run, each content type is one JSON document, and characters are
/// keyed by `uniqueID` with a separate index. Only the persistence primitives
/// differ; the load/save logic is shared via [JsonContentStorage].
class WebStorageService extends JsonContentStorage {
  static final WebStorageService _instance = WebStorageService._internal();
  factory WebStorageService() => _instance;
  WebStorageService._internal();

  // Namespacing keeps these keys from colliding with anything else in
  // localStorage for the same origin.
  static const String _contentPrefix = 'frankenstein_content:';
  static const String _characterPrefix = 'frankenstein_character:';
  static const String _characterIndexKey = 'frankenstein_character_index';
  static const String _seededKey = 'frankenstein_content_seeded';

  static const String characterNotReadyMessage = 'Character service not ready';
  static const String contentNotReadyMessage = 'Content service not ready';

  SharedPreferences? _prefs;
  bool _initialized = false;
  bool get isInitialized => _initialized;

  @override
  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _prefs = prefs;

      // Seed default SRD content from assets on first run (mirrors the
      // desktop back end's first-run copy).
      if (!(prefs.getBool(_seededKey) ?? false)) {
        await _seedDefaultContent(prefs);
        await prefs.setBool(_seededKey, true);
      }

      _initialized = true;
      debugPrint('WebStorageService initialized successfully');
      return true;
    } catch (e) {
      debugPrint('WebStorageService initialization failed: $e');
      return false;
    }
  }

  Future<void> _seedDefaultContent(SharedPreferences prefs) async {
    debugPrint('Seeding default SRD content from assets...');
    int successCount = 0;
    int failCount = 0;

    for (final fileName in JsonContentStorage.defaultContentFiles) {
      try {
        final assetContent =
            await rootBundle.loadString('assets/srd/$fileName');
        await prefs.setString('$_contentPrefix$fileName', assetContent);
        successCount++;
      } catch (e) {
        failCount++;
        debugPrint('Failed to seed $fileName from assets: $e');
      }
    }

    debugPrint(
        'Content seeding complete: $successCount succeeded, $failCount failed');
  }

  @override
  Future<Map<String, dynamic>?> readJson(String fileName) async {
    final prefs = _prefs;
    if (!_initialized || prefs == null) {
      debugPrint(contentNotReadyMessage);
      return null;
    }
    try {
      final content = prefs.getString('$_contentPrefix$fileName');
      if (content == null || content.isEmpty) return null;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to read JSON from $fileName: $e');
      return null;
    }
  }

  @override
  Future<bool> writeJson(String fileName, Map<String, dynamic> data) async {
    final prefs = _prefs;
    if (!_initialized || prefs == null) {
      debugPrint(contentNotReadyMessage);
      return false;
    }
    try {
      return await prefs.setString(
          '$_contentPrefix$fileName', jsonEncode(data));
    } catch (e) {
      debugPrint('Failed to write JSON to $fileName: $e');
      return false;
    }
  }

  // Character operations -----------------------------------------------------

  List<String> _readIndex(SharedPreferences prefs) =>
      prefs.getStringList(_characterIndexKey) ?? <String>[];

  Future<void> _writeIndex(SharedPreferences prefs, List<String> ids) async {
    await prefs.setStringList(_characterIndexKey, ids);
  }

  Future<bool> _putCharacter(Character character) async {
    final prefs = _prefs;
    if (!_initialized || prefs == null) {
      debugPrint(characterNotReadyMessage);
      return false;
    }
    try {
      final id = '${character.uniqueID}';
      await prefs.setString(
          '$_characterPrefix$id', jsonEncode(character.toJson()));
      final index = _readIndex(prefs);
      if (!index.contains(id)) {
        index.add(id);
        await _writeIndex(prefs, index);
      }
      debugPrint(
          'Character ${character.name}, UID: ${character.uniqueID}, saved successfully');
      return true;
    } catch (e) {
      debugPrint(
          'Error saving character ${character.name}, UID: ${character.uniqueID}: $e');
      return false;
    }
  }

  @override
  Future<bool> saveCharacter(Character character) => _putCharacter(character);

  @override
  Future<bool> updateCharacter(Character character) => _putCharacter(character);

  @override
  Future<bool> deleteCharacter(int characterId) async {
    final prefs = _prefs;
    if (!_initialized || prefs == null) {
      debugPrint(characterNotReadyMessage);
      return false;
    }
    try {
      final id = '$characterId';
      await prefs.remove('$_characterPrefix$id');
      final index = _readIndex(prefs)..remove(id);
      await _writeIndex(prefs, index);
      debugPrint('Character (ID: $characterId) deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting character (ID: $characterId): $e');
      return false;
    }
  }

  @override
  Future<List<Character>> getAllCharacters() async {
    final prefs = _prefs;
    if (!_initialized || prefs == null) {
      debugPrint(characterNotReadyMessage);
      return [];
    }
    final characters = <Character>[];
    for (final id in _readIndex(prefs)) {
      final raw = prefs.getString('$_characterPrefix$id');
      if (raw == null) continue;
      try {
        characters
            .add(Character.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (e) {
        debugPrint('Error loading character $id: $e');
      }
    }
    debugPrint('Loaded ${characters.length} characters from storage');
    return characters;
  }
}
