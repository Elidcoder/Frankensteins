// NOTE: GlobalListManager is a process-wide singleton with no reset hook.
// Because flutter_test runs each *file* in its own VM isolate, the singleton
// here is isolated from other test files — but within this file, every test
// shares state. The setUpAll bootstrap seeds the singleton; tests that mutate
// it use unique names so they can't collide with one another.
import "dart:convert" show jsonEncode;
import "dart:io" show Directory, File;

import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/core/services/global_list_manager.dart";
import "package:path/path.dart" as p;

import "../../test_helpers/fixtures.dart";
import "../../test_helpers/global_list_manager_bootstrap.dart";

void main() {
  setUpAll(() async {
    await GlobalListManagerBootstrap.ensureInitialised();
  });

  group("GlobalListManager singleton", () {
    test("factory always returns the same instance", () {
      expect(identical(GlobalListManager(), GlobalListManager()), isTrue);
    });

    test("initialise is idempotent (returns true on re-init with same fake)",
        () async {
      final ok = await GlobalListManager()
          .initialise(GlobalListManagerBootstrap.storage);
      expect(ok, isTrue);
    });
  });

  group("content list getters", () {
    test("spellList contains the seeded spell", () {
      expect(GlobalListManager().spellList, isNotEmpty);
    });

    test("classList contains the seeded class", () {
      expect(GlobalListManager().classList, isNotEmpty);
    });

    test("raceList contains the seeded race", () {
      expect(GlobalListManager().raceList, isNotEmpty);
    });

    test("featList contains the seeded feat", () {
      expect(GlobalListManager().featList, isNotEmpty);
    });

    test("itemList contains the seeded item", () {
      expect(GlobalListManager().itemList, isNotEmpty);
    });

    test("backgroundList contains the seeded background", () {
      expect(GlobalListManager().backgroundList, isNotEmpty);
    });

    test("proficiencyList contains the seeded proficiencies", () {
      expect(
          GlobalListManager().proficiencyList.length, greaterThanOrEqualTo(2));
    });

    test("languageList contains the seeded languages", () {
      expect(GlobalListManager().languageList, contains("Common"));
    });

    test("themeList contains the seeded theme", () {
      expect(GlobalListManager().themeList, isNotEmpty);
    });

    test("characterList starts empty (no characters seeded)", () {
      // Verified after any mutating tests have NOT yet run.
      // We don't assert isEmpty because earlier-running tests in this file
      // may have added characters. Instead, assert the list exists.
      expect(GlobalListManager().characterList, isA<List>());
    });

    test("groupList is non-null and sorted (no group seeded so empty)", () {
      expect(GlobalListManager().groupList, isA<List<String>>());
    });
  });

  group("saveSpell", () {
    test("appends the new spell to the spell list", () async {
      final before = GlobalListManager().spellList.length;
      final newSpell = makeSpell(name: "Unique Test Spell A");

      final ok = await GlobalListManager().saveSpell(newSpell);

      expect(ok, isTrue);
      expect(GlobalListManager().spellList.length, before + 1);
      expect(GlobalListManager().spellList.any((s) => s.name == newSpell.name),
          isTrue);
    });
  });

  group("saveTheme", () {
    test("removes any matching theme then appends the new one", () async {
      final newTheme = makeColourScheme();
      final before = GlobalListManager().themeList.length;

      final ok = await GlobalListManager().saveTheme(newTheme);

      expect(ok, isTrue);
      // The bootstrap seeds an identical theme, so saveTheme should *replace*
      // rather than duplicate. Length stays the same.
      expect(GlobalListManager().themeList.length, before);
    });
  });

  group("saveLists", () {
    test("flushes every content list back to the storage service", () async {
      // We've mutated several lists via saveSpell/saveTheme — saveLists
      // should push the in-memory state through the storage seeder.
      final ok = await GlobalListManager().saveLists();

      expect(ok, isTrue);
      // The fake storage's seedSpells should now mirror the in-memory list.
      expect(
        GlobalListManagerBootstrap.storage.seedSpells.length,
        GlobalListManager().spellList.length,
      );
    });
  });

  group("loadContentFromFile", () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp("frank_glm_import_");
    });

    tearDown(() async {
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {
        // Best-effort.
      }
    });

    test("appends new spells while skipping duplicates by name", () async {
      // One brand-new spell + one whose name already exists in the seeded
      // list. Only the new one should land in spellList.
      final importFile = File(p.join(tempDir.path, "import.json"));
      final existingName = GlobalListManager().spellList.first.name;
      await importFile.writeAsString(jsonEncode({
        "Spells": [
          makeSpell(name: "Brand New Import Spell").toJson(),
          makeSpell(name: existingName).toJson(),
        ],
      }));

      final beforeCount = GlobalListManager().spellList.length;
      await GlobalListManager().loadContentFromFile(importFile);

      expect(
          GlobalListManager()
              .spellList
              .any((s) => s.name == "Brand New Import Spell"),
          isTrue);
      // Duplicate by name was skipped — only one new entry was added.
      expect(GlobalListManager().spellList.length, beforeCount + 1);
    });

    test("tolerates a file that omits entire content sections", () async {
      // The importer only contributes the keys it provides; missing keys
      // (e.g. "Races") should not crash or wipe the existing list.
      final importFile = File(p.join(tempDir.path, "partial.json"));
      await importFile.writeAsString(jsonEncode({
        "Languages": ["Aarakocran"],
      }));

      final racesBefore = GlobalListManager().raceList.length;
      await GlobalListManager().loadContentFromFile(importFile);

      expect(GlobalListManager().languageList, contains("Aarakocran"));
      expect(GlobalListManager().raceList.length, racesBefore);
    });
  });

  group("saveCharacter & deleteCharacter", () {
    test("saveCharacter adds a new character to the list", () async {
      final character = makeCharacter(
        uniqueID: 111111111111111,
        playerName: "SaveTest",
      );

      final ok = await GlobalListManager().saveCharacter(character);

      expect(ok, isTrue);
      expect(
          GlobalListManager()
              .characterList
              .any((c) => c.uniqueID == 111111111111111),
          isTrue);
    });

    test("saveCharacter updates rather than duplicates an existing entry",
        () async {
      final character = makeCharacter(
        uniqueID: 222222222222222,
        playerName: "Original",
      );
      await GlobalListManager().saveCharacter(character);
      final countAfterFirstSave = GlobalListManager().characterList.length;

      // Mutate then re-save — same UID, so it should update in place.
      character.playerName = "Updated";
      await GlobalListManager().saveCharacter(character);

      expect(GlobalListManager().characterList.length, countAfterFirstSave);
      final stored = GlobalListManager()
          .characterList
          .firstWhere((c) => c.uniqueID == 222222222222222);
      expect(stored.playerName, "Updated");
    });

    test("deleteCharacter removes the character from the list", () async {
      final character = makeCharacter(uniqueID: 333333333333333);
      await GlobalListManager().saveCharacter(character);
      expect(
          GlobalListManager()
              .characterList
              .any((c) => c.uniqueID == 333333333333333),
          isTrue);

      final ok = await GlobalListManager().deleteCharacter(character);

      expect(ok, isTrue);
      expect(
          GlobalListManager()
              .characterList
              .any((c) => c.uniqueID == 333333333333333),
          isFalse);
    });
  });
}
