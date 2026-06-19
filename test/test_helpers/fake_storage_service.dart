// In-memory StorageService used to drive GlobalListManager and ThemeManager
// tests without touching the filesystem or hitting platform channels.
//
// Pre-populate the public seed* lists before calling initialise/load* methods.
import "package:frankenstein/core/services/storage_service.dart";
import "package:frankenstein/models/index.dart";

class FakeStorageService implements StorageService {
  List<Background> seedBackgrounds = [];
  List<Class> seedClasses = [];
  List<Feat> seedFeats = [];
  List<Item> seedItems = [];
  List<String> seedLanguages = [];
  List<Proficiency> seedProficiencies = [];
  List<Race> seedRaces = [];
  List<Spell> seedSpells = [];
  List<ColourScheme> seedThemes = [];
  List<Character> seedCharacters = [];

  bool initializeCalled = false;
  bool throwOnInitialize = false;

  @override
  Future<void> initialize() async {
    initializeCalled = true;
    if (throwOnInitialize) {
      throw StateError("FakeStorageService configured to fail initialize()");
    }
  }

  @override
  Future<List<Background>> loadBackgrounds() async => List.of(seedBackgrounds);

  @override
  Future<List<Class>> loadClasses() async => List.of(seedClasses);

  @override
  Future<List<Feat>> loadFeats() async => List.of(seedFeats);

  @override
  Future<List<Item>> loadItems() async => List.of(seedItems);

  @override
  Future<List<String>> loadLanguages() async => List.of(seedLanguages);

  @override
  Future<List<Proficiency>> loadProficiencies() async =>
      List.of(seedProficiencies);

  @override
  Future<List<Race>> loadRaces() async => List.of(seedRaces);

  @override
  Future<List<Spell>> loadSpells() async => List.of(seedSpells);

  @override
  Future<List<ColourScheme>> loadThemes() async => List.of(seedThemes);

  @override
  Future<bool> saveBackgrounds(List<Background> backgrounds) async {
    seedBackgrounds = List.of(backgrounds);
    return true;
  }

  @override
  Future<bool> saveClasses(List<Class> classes) async {
    seedClasses = List.of(classes);
    return true;
  }

  @override
  Future<bool> saveFeats(List<Feat> feats) async {
    seedFeats = List.of(feats);
    return true;
  }

  @override
  Future<bool> saveItems(List<Item> items) async {
    seedItems = List.of(items);
    return true;
  }

  @override
  Future<bool> saveLanguages(List<String> languages) async {
    seedLanguages = List.of(languages);
    return true;
  }

  @override
  Future<bool> saveProficiencies(List<Proficiency> proficiencies) async {
    seedProficiencies = List.of(proficiencies);
    return true;
  }

  @override
  Future<bool> saveRaces(List<Race> races) async {
    seedRaces = List.of(races);
    return true;
  }

  @override
  Future<bool> saveSpells(List<Spell> spells) async {
    seedSpells = List.of(spells);
    return true;
  }

  @override
  Future<bool> saveThemes(List<ColourScheme> themes) async {
    seedThemes = List.of(themes);
    return true;
  }

  @override
  Future<List<Character>> getAllCharacters() async => List.of(seedCharacters);

  @override
  Future<bool> saveCharacter(Character character) async {
    seedCharacters
        .removeWhere((existing) => existing.uniqueID == character.uniqueID);
    seedCharacters.add(character);
    return true;
  }

  @override
  Future<bool> updateCharacter(Character character) async =>
      saveCharacter(character);

  @override
  Future<bool> deleteCharacter(int characterId) async {
    final before = seedCharacters.length;
    seedCharacters.removeWhere((c) => c.uniqueID == characterId);
    return seedCharacters.length != before;
  }
}
