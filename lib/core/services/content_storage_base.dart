import 'package:flutter/foundation.dart';
import 'package:frankenstein/core/services/storage_service.dart';

import "../../../models/index.dart";

/// Shared, platform-agnostic implementation of the content half of
/// [StorageService].
///
/// All the SRD content types are stored as named JSON documents (one per
/// content type). The only thing that differs between platforms is *where*
/// those documents live: the desktop build writes them to files on disk
/// (`JsonStorageService`) while the web build keeps them in the browser's
/// localStorage (`WebStorageService`). Both back ends only have to implement
/// [readJson]/[writeJson]; every load/save method below is shared.
///
/// Character persistence is intentionally left abstract because the two back
/// ends model it differently (a directory of files vs. an index key).
abstract class JsonContentStorage implements StorageService {
  /// The default SRD content documents bundled as assets under `assets/srd/`.
  /// Both back ends seed these into storage on first run.
  static const List<String> defaultContentFiles = [
    'backgrounds.json',
    'classes.json',
    'feats.json',
    'items.json',
    'languages.json',
    'proficiencies.json',
    'races.json',
    'spells.json',
    'themes.json',
  ];

  /// Reads a stored JSON document by logical name (e.g. `spells.json`).
  ///
  /// Returns `null` when the document is missing, empty, unreadable, or the
  /// service has not been initialised yet.
  @protected
  Future<Map<String, dynamic>?> readJson(String fileName);

  /// Persists [data] under the logical name [fileName]. Returns `false` on
  /// failure (or when the service has not been initialised).
  @protected
  Future<bool> writeJson(String fileName, Map<String, dynamic> data);

  /// Wraps a content list in the standard envelope used on disk/in storage.
  Map<String, dynamic> _envelope(
    String contentType,
    Object entries,
  ) =>
      {
        contentType: entries,
        'version': '1.0',
        'contentType': contentType,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

  @override
  Future<List<Background>> loadBackgrounds() async {
    try {
      final data = await readJson('backgrounds.json');
      if (data == null || data['backgrounds'] == null) {
        debugPrint('No background data found');
        return [];
      }
      final backgroundList = data['backgrounds'] as List;
      return backgroundList.map((json) => Background.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load backgrounds: $e');
      return [];
    }
  }

  @override
  Future<List<Class>> loadClasses() async {
    try {
      final data = await readJson('classes.json');
      if (data == null || data['classes'] == null) {
        debugPrint('No class data found');
        return [];
      }
      final classList = data['classes'] as List;
      return classList.map((json) => Class.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load classes: $e');
      return [];
    }
  }

  @override
  Future<List<Feat>> loadFeats() async {
    try {
      final data = await readJson('feats.json');
      if (data == null || data['feats'] == null) {
        debugPrint('No feat data found');
        return [];
      }
      final featList = data['feats'] as List;
      return featList.map((json) => Feat.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load feats: $e');
      return [];
    }
  }

  @override
  Future<List<Item>> loadItems() async {
    try {
      final data = await readJson('items.json');
      if (data == null || data['items'] == null) {
        debugPrint('No item data found');
        return [];
      }
      final itemList = data['items'] as List;
      return itemList.map((json) => Item.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load items: $e');
      return [];
    }
  }

  @override
  Future<List<String>> loadLanguages() async {
    try {
      final data = await readJson('languages.json');
      if (data == null || data['languages'] == null) {
        debugPrint('No language data found');
        return [];
      }
      final languageList = data['languages'] as List;
      return languageList.cast<String>();
    } catch (e) {
      debugPrint('Failed to load languages: $e');
      return [];
    }
  }

  @override
  Future<List<Proficiency>> loadProficiencies() async {
    try {
      final data = await readJson('proficiencies.json');
      if (data == null || data['proficiencies'] == null) {
        debugPrint('No proficiency data found');
        return [];
      }
      final proficiencyList = data['proficiencies'] as List;
      return proficiencyList.map((json) => Proficiency.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load proficiencies: $e');
      return [];
    }
  }

  @override
  Future<List<Race>> loadRaces() async {
    try {
      final data = await readJson('races.json');
      if (data == null || data['races'] == null) {
        debugPrint('No race data found');
        return [];
      }
      final raceList = data['races'] as List;
      return raceList.map((json) => Race.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load races: $e');
      return [];
    }
  }

  @override
  Future<List<Spell>> loadSpells() async {
    try {
      final data = await readJson('spells.json');
      if (data == null || data['spells'] == null) {
        debugPrint('No spell data found');
        return [];
      }
      final spellList = data['spells'] as List;
      return spellList.map((json) => Spell.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load spells: $e');
      return [];
    }
  }

  @override
  Future<List<ColourScheme>> loadThemes() async {
    try {
      final data = await readJson('themes.json');
      if (data == null || data['themes'] == null) {
        debugPrint('No theme data found');
        return [];
      }
      final themeList = data['themes'] as List;
      return themeList.map((json) => ColourScheme.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Failed to load themes: $e');
      return [];
    }
  }

  @override
  Future<bool> saveBackgrounds(List<Background> backgrounds) async {
    try {
      return await writeJson(
          'backgrounds.json',
          _envelope(
              'backgrounds', backgrounds.map((bg) => bg.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save backgrounds: $e');
      return false;
    }
  }

  @override
  Future<bool> saveClasses(List<Class> classes) async {
    try {
      return await writeJson('classes.json',
          _envelope('classes', classes.map((cls) => cls.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save classes: $e');
      return false;
    }
  }

  @override
  Future<bool> saveFeats(List<Feat> feats) async {
    try {
      return await writeJson('feats.json',
          _envelope('feats', feats.map((feat) => feat.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save feats: $e');
      return false;
    }
  }

  @override
  Future<bool> saveItems(List<Item> items) async {
    try {
      return await writeJson('items.json',
          _envelope('items', items.map((item) => item.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save items: $e');
      return false;
    }
  }

  @override
  Future<bool> saveLanguages(List<String> languages) async {
    try {
      return await writeJson(
          'languages.json', _envelope('languages', languages));
    } catch (e) {
      debugPrint('Failed to save languages: $e');
      return false;
    }
  }

  @override
  Future<bool> saveProficiencies(List<Proficiency> proficiencies) async {
    try {
      return await writeJson(
          'proficiencies.json',
          _envelope('proficiencies',
              proficiencies.map((prof) => prof.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save proficiencies: $e');
      return false;
    }
  }

  @override
  Future<bool> saveRaces(List<Race> races) async {
    try {
      return await writeJson('races.json',
          _envelope('races', races.map((race) => race.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save races: $e');
      return false;
    }
  }

  @override
  Future<bool> saveSpells(List<Spell> spells) async {
    try {
      return await writeJson('spells.json',
          _envelope('spells', spells.map((spell) => spell.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save spells: $e');
      return false;
    }
  }

  @override
  Future<bool> saveThemes(List<ColourScheme> themes) async {
    try {
      return await writeJson('themes.json',
          _envelope('themes', themes.map((theme) => theme.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save themes: $e');
      return false;
    }
  }
}
