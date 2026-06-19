// External Imports
import 'dart:convert';
import "dart:io" show File;

import "package:flutter/foundation.dart" show debugPrint;
import "package:frankenstein/core/services/storage_service.dart";

import "../../../models/index.dart";
import "../utils/helpers.dart" show mapEquipment;

/// Global list manager that handles initialization and access to all game content lists
class GlobalListManager {
  static final GlobalListManager _instance = GlobalListManager._internal();
  factory GlobalListManager() => _instance;
  GlobalListManager._internal();
  late StorageService storageService;

  // Content lists
  List<Spell> _spellList = [];
  List<Class> _classList = [];
  List<Race> _raceList = [];
  List<Feat> _featList = [];
  List<Item> _itemList = [];
  List<Background> _backgroundList = [];
  List<Proficiency> _proficiencyList = [];
  List<String> _languageList = [];
  List<ColourScheme> _themeList = [];
  List<Character> _characterList = [];
  List<String> _groupList = [];

  // Initialization flags
  bool _spellsInitialized = false;
  bool _classesInitialized = false;
  bool _racesInitialized = false;
  bool _featsInitialized = false;
  bool _itemsInitialized = false;
  bool _backgroundsInitialized = false;
  bool _proficienciesInitialized = false;
  bool _languagesInitialized = false;
  bool _themesInitialized = false;
  bool _charactersInitialized = false;
  bool _groupsInitialized = false;

  /// Initialize both content and character storage systems
  Future<bool> initialise(StorageService injectedStorageService) async {
    try {
      storageService = injectedStorageService;
      await storageService.initialize();
      return true;
    } catch (e) {
      debugPrint('Failed to initialize storage systems: $e');
      return false;
    }
  }

  /// Initialize spell list
  Future<List<Spell>> initialiseSpellList() async {
    if (_spellsInitialized) return _spellList;

    try {
      _spellList = await storageService.loadSpells();
      _spellsInitialized = true;
      debugPrint('Initialized spell list with ${_spellList.length} spells');
      return _spellList;
    } catch (e) {
      debugPrint('Failed to initialize spell list: $e');
      rethrow;
    }
  }

  /// Initialize class list
  Future<List<Class>> initialiseClassList() async {
    if (_classesInitialized) return _classList;

    try {
      _classList = await storageService.loadClasses();
      _classesInitialized = true;
      debugPrint('Initialized class list with ${_classList.length} classes');
      return _classList;
    } catch (e) {
      debugPrint('Failed to initialize class list: $e');
      rethrow;
    }
  }

  /// Initialize race list
  Future<List<Race>> initialiseRaceList() async {
    if (_racesInitialized) return _raceList;

    try {
      _raceList = await storageService.loadRaces();
      _racesInitialized = true;
      debugPrint('Initialized race list with ${_raceList.length} races');
      return _raceList;
    } catch (e) {
      debugPrint('Failed to initialize race list: $e');
      rethrow;
    }
  }

  /// Initialize feat list
  Future<List<Feat>> initialiseFeatList() async {
    if (_featsInitialized) return _featList;

    try {
      _featList = await storageService.loadFeats();
      _featsInitialized = true;
      debugPrint('Initialized feat list with ${_featList.length} feats');
      return _featList;
    } catch (e) {
      debugPrint('Failed to initialize feat list: $e');
      rethrow;
    }
  }

  /// Initialize item list
  Future<List<Item>> initialiseItemList() async {
    if (_itemsInitialized) return _itemList;

    try {
      _itemList = await storageService.loadItems();
      _itemsInitialized = true;
      debugPrint('Initialized item list with ${_itemList.length} items');
      return _itemList;
    } catch (e) {
      debugPrint('Failed to initialize item list: $e');
      rethrow;
    }
  }

  /// Initialize background list
  Future<List<Background>> initialiseBackgroundList() async {
    if (_backgroundsInitialized) return _backgroundList;

    try {
      _backgroundList = await storageService.loadBackgrounds();
      _backgroundsInitialized = true;
      debugPrint(
          'Initialized background list with ${_backgroundList.length} backgrounds');
      return _backgroundList;
    } catch (e) {
      debugPrint('Failed to initialize background list: $e');
      rethrow;
    }
  }

  /// Initialize proficiency list
  Future<List<Proficiency>> initialiseProficiencyList() async {
    if (_proficienciesInitialized) return _proficiencyList;

    try {
      _proficiencyList = await storageService.loadProficiencies();
      _proficienciesInitialized = true;
      debugPrint(
          'Initialized proficiency list with ${_proficiencyList.length} proficiencies');
      return _proficiencyList;
    } catch (e) {
      debugPrint('Failed to initialize proficiency list: $e');
      rethrow;
    }
  }

  /// Initialize language list
  Future<List<String>> initialiseLanguageList() async {
    if (_languagesInitialized) return _languageList;

    try {
      _languageList = await storageService.loadLanguages();
      _languagesInitialized = true;
      debugPrint(
          'Initialized language list with ${_languageList.length} languages');
      return _languageList;
    } catch (e) {
      debugPrint('Failed to initialize language list: $e');
      rethrow;
    }
  }

  /// Initialize theme list
  Future<List<ColourScheme>> initialiseThemeList() async {
    if (_themesInitialized) return _themeList;

    try {
      _themeList = await storageService.loadThemes();
      _themesInitialized = true;
      debugPrint('Initialized theme list with ${_themeList.length} themes');
      return _themeList;
    } catch (e) {
      debugPrint('Failed to initialize theme list: $e');
      rethrow;
    }
  }

  /// Initialize character list
  Future<List<Character>> initialiseCharacterList() async {
    if (_charactersInitialized) return _characterList;

    try {
      _characterList = await storageService.getAllCharacters();
      _charactersInitialized = true;
      debugPrint(
          'Initialized character list with ${_characterList.length} characters');

      // Automatically initialize groups when characters are loaded
      _updateGroupList();

      return _characterList;
    } catch (e) {
      debugPrint('Failed to initialize character list: $e');
      rethrow;
    }
  }

  /// Update group list from current character list (internal method)
  void _updateGroupList() {
    final groups = _characterList
        .map((c) => c.group)
        .where((group) => group != null && group.trim().isNotEmpty)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    _groupList = groups;
    _groupsInitialized = true;
    debugPrint('Updated group list with ${_groupList.length} groups');
  }

  /// Spell list getter (crashes if not initialized)
  List<Spell> get spellList {
    if (!_spellsInitialized) {
      throw StateError(
          'Spell list not initialized. Call initialiseSpellList() first.');
    }
    return _spellList;
  }

  /// Class list getter (crashes if not initialized)
  List<Class> get classList {
    if (!_classesInitialized) {
      throw StateError(
          'Class list not initialized. Call initialiseClassList() first.');
    }
    return _classList;
  }

  /// Race list getter (crashes if not initialized)
  List<Race> get raceList {
    if (!_racesInitialized) {
      throw StateError(
          'Race list not initialized. Call initialiseRaceList() first.');
    }
    return _raceList;
  }

  /// Feat list getter (crashes if not initialized)
  List<Feat> get featList {
    if (!_featsInitialized) {
      throw StateError(
          'Feat list not initialized. Call initialiseFeatList() first.');
    }
    return _featList;
  }

  /// Item list getter (crashes if not initialized)
  List<Item> get itemList {
    if (!_itemsInitialized) {
      throw StateError(
          'Item list not initialized. Call initialiseItemList() first.');
    }
    return _itemList;
  }

  /// Background list getter (crashes if not initialized)
  List<Background> get backgroundList {
    if (!_backgroundsInitialized) {
      throw StateError(
          'Background list not initialized. Call initialiseBackgroundList() first.');
    }
    return _backgroundList;
  }

  /// Proficiency list getter (crashes if not initialized)
  List<Proficiency> get proficiencyList {
    if (!_proficienciesInitialized) {
      throw StateError(
          'Proficiency list not initialized. Call initialiseProficiencyList() first.');
    }
    return _proficiencyList;
  }

  /// Language list getter (crashes if not initialized)
  List<String> get languageList {
    if (!_languagesInitialized) {
      throw StateError(
          'Language list not initialized. Call initialiseLanguageList() first.');
    }
    return _languageList;
  }

  /// Theme list getter (crashes if not initialized)
  List<ColourScheme> get themeList {
    if (!_themesInitialized) {
      throw StateError(
          'Theme list not initialized. Call initialiseThemeList() first.');
    }
    return _themeList;
  }

  /// Character list getter (crashes if not initialized)
  List<Character> get characterList {
    if (!_charactersInitialized) {
      throw StateError(
          'Character list not initialized. Call initialiseCharacterList() first.');
    }
    return _characterList;
  }

  /// Group list getter (crashes if not initialized)
  List<String> get groupList {
    if (!_groupsInitialized) {
      throw StateError(
          'Group list not initialized. Call initialiseCharacterList() first.');
    }
    return _groupList;
  }

  Future<void> initialiseContentLists() async {
    await Future.wait([
      initialiseSpellList(),
      initialiseClassList(),
      initialiseRaceList(),
      initialiseFeatList(),
      initialiseItemList(),
      initialiseBackgroundList(),
      initialiseProficiencyList(),
      initialiseLanguageList(),
      initialiseThemeList(),
      //initialiseCharacterList(),//TODO(UNEEDED IN CONTENT PAGE)
    ]);
  }

  //TODO()
  //TODO()
  //TODO() these below

  Future<bool> saveSpell(Spell spell) async {
    try {
      // Add spell to the list
      _spellList.add(spell);

      // Save the updated spell list
      final savedSuccess = await storageService.saveSpells(_spellList);

      // Save success
      if (savedSuccess) {
        debugPrint('Spell "${spell.name}" saved successfully.');
        return true;
      }

      // Handle any saving errors
    } catch (e) {
      debugPrint('Error occured trying to save spell ${spell.name}: $e');
    }
    debugPrint('Failed to save spell "${spell.name}".');
    _spellList.remove(spell);
    return false;
  }

  Future<bool> saveTheme(ColourScheme newScheme) async {
    try {
      // Update the theme lists
      _themeList.removeWhere((theme) => newScheme.isSameColourScheme(theme));
      _themeList.add(newScheme);

      // Save only the themes (more efficient than saving all content)
      final savedSuccess = await storageService.saveThemes(_themeList);

      // Save success
      if (savedSuccess) {
        debugPrint('Theme "${newScheme.name}" saved successfully.');
        return true;
      }

      // Handle any saving errors
    } catch (e) {
      debugPrint('Error occured trying to save theme ${newScheme.name}: $e');
    }
    debugPrint('Failed to save theme "${newScheme.name}".');
    _themeList.remove(newScheme);
    return false;
  }

  Future<bool> saveCharacter(Character character) async {
    try {
      var savedSuccess = false;
      // Updating character occurs
      debugPrint(
          'Attempting to save character: ${character.characterDescription.name}');
      if (_characterList.contains(character)) {
        // Abuse == overload relying only on UID
        // Remove pre modificationcharacter from the list
        _characterList.remove(character);

        debugPrint(
            'Previous entry found, deleting before saving character: ${character.characterDescription.name}');

        // Save the updated character list
        savedSuccess = await storageService.updateCharacter(character);
      }

      // New character is created
      else {
        debugPrint(
            'No previous entry found, continuing to save character: ${character.characterDescription.name}');
        // Save the updated character list
        savedSuccess = await storageService.saveCharacter(character);
      }

      // Add character to the list
      _characterList.add(character);

      // Save success
      if (savedSuccess) {
        debugPrint(
            'Character "${character.characterDescription.name}" saved successfully.');
        return true;
      }
    } catch (e) {
      debugPrint(
          'Error occured trying to save character ${character.characterDescription.name}: $e');
    }
    debugPrint(
        'Failed to save character "${character.characterDescription.name}".');
    _characterList.remove(character);
    return false;
  }

  Future<bool> deleteCharacter(Character character) async {
    try {
      var deletedSuccess = false;

      // Save the updated character list
      deletedSuccess = await storageService.deleteCharacter(character.uniqueID);

      // Save success
      if (deletedSuccess) {
        debugPrint(
            'Character "${character.characterDescription.name}" deleted successfully.');
        _characterList.remove(character);
        debugPrint(
            'Character "${character.characterDescription.name}" removed from list successfully.');
        return true;
      }
    } catch (e) {
      debugPrint(
          'Error occured trying to delete character ${character.characterDescription.name}: $e');
    }
    debugPrint(
        'Failed to delete character "${character.characterDescription.name}".');
    _characterList.remove(character);
    return false;
  }

  // Will save the current content lists to persistent storage overwriting the existing content
  // Will not modify the currently loaded content lists in memory
  // Will not save characters
  Future<bool> saveLists() async {
    try {
      // Save all content lists - can be done in parallel as they are independent files
      await Future.wait([
        storageService.saveSpells(_spellList),
        storageService.saveClasses(_classList),
        storageService.saveRaces(_raceList),
        storageService.saveFeats(_featList),
        storageService.saveItems(_itemList),
        storageService.saveBackgrounds(_backgroundList),
        storageService.saveProficiencies(_proficiencyList),
        storageService.saveLanguages(_languageList),
        storageService.saveThemes(_themeList),
      ]);

      debugPrint('All content lists saved successfully.');
      return true;
    } catch (e) {
      debugPrint('Failed to save content lists: $e');
      return false;
    }
  }

  /// Load content from an external JSON file and add it to the existing content
  Future<void> loadContentFromFile(File file) async {
    final jsonString = await file.readAsString();
    return loadContentFromJson(jsonString);
  }

  /// Load content from an external JSON document and add it to the existing
  /// content. Callers are responsible for reading the file/bytes into a string
  /// (desktop reads from disk, web from the picked file's bytes) so this stays
  /// free of `dart:io` and works on every platform.
  Future<void> loadContentFromJson(String jsonString) async {
    final jsonMap = jsonDecode(jsonString);

    // Parse content from the file
    final newSpells = List<Spell>.from(
        (jsonMap["Spells"] ?? []).map((x) => Spell.fromJson(x)));
    final newClasses = List<Class>.from(
        (jsonMap["Classes"] ?? []).map((x) => Class.fromJson(x)));
    final newRaces =
        List<Race>.from((jsonMap["Races"] ?? []).map((x) => Race.fromJson(x)));
    final newFeats =
        List<Feat>.from((jsonMap["Feats"] ?? []).map((x) => Feat.fromJson(x)));
    final newItems = List<Item>.from(
        (jsonMap["Equipment"] ?? []).map((x) => mapEquipment(x)));
    final newBackgrounds = List<Background>.from(
        (jsonMap["Backgrounds"] ?? []).map((x) => Background.fromJson(x)));
    final newProficiencies = List<Proficiency>.from(
        (jsonMap["Proficiencies"] ?? []).map((x) => Proficiency.fromJson(x)));
    final newLanguages = List<String>.from(jsonMap["Languages"] ?? []);
    final newThemes = List<ColourScheme>.from(
        (jsonMap["ColourSchemes"] ?? []).map((x) => ColourScheme.fromJson(x)));

    // Merge content (avoid duplicates by name/id)
    //TODO(Improve the unpacking of their stuff) - swap to switch cases
    _spellList = [
      ..._spellList,
      ...newSpells.where(
          (spell) => !_spellList.any((existing) => existing.name == spell.name))
    ];
    _classList = [
      ..._classList,
      ...newClasses.where(
          (cls) => !_classList.any((existing) => existing.name == cls.name))
    ];
    _raceList = [
      ..._raceList,
      ...newRaces.where(
          (race) => !_raceList.any((existing) => existing.name == race.name))
    ];
    _featList = [
      ..._featList,
      ...newFeats.where(
          (feat) => !_featList.any((existing) => existing.name == feat.name))
    ];
    _itemList = [
      ..._itemList,
      ...newItems.where(
          (item) => !_itemList.any((existing) => existing.name == item.name))
    ];
    _backgroundList = [
      ..._backgroundList,
      ...newBackgrounds.where(
          (bg) => !_backgroundList.any((existing) => existing.name == bg.name))
    ];
    _proficiencyList = [
      ..._proficiencyList,
      ...newProficiencies.where((prof) => !_proficiencyList.any((existing) =>
          existing.proficiencyTree.toString() ==
          prof.proficiencyTree.toString()))
    ];
    _languageList =
        [..._languageList.toSet(), ...newLanguages.toSet()].toList();
    _themeList = [
      ..._themeList,
      ...newThemes.where((theme) =>
          !_themeList.any((existing) => existing.isSameColourScheme(theme)))
    ];

    // Save the updated lists to persistent storage
    saveLists();
  }
}
