// JsonStorageService is a process-wide singleton. Within this file we
// initialise it once against a temp directory and then exercise every
// save/load round-trip plus character index management.
//
// We pre-create the content directory so the "first run" branch (which
// copies SRD assets from rootBundle) is skipped — that branch needs real
// assets and is exercised by the integration build, not unit tests.
import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/core/services/json_storage_service.dart";
import "package:path/path.dart" as p;
import "package:path_provider_platform_interface/path_provider_platform_interface.dart";

import "../../test_helpers/fake_path_provider.dart";
import "../../test_helpers/fixtures.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory contentDir;
  late JsonStorageService service;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp("frankenstein_test_");
    // Pre-create the content directory so initialize() skips first-run
    // asset copying.
    contentDir = Directory(p.join(tempDir.path, "frankenstein_content"));
    await contentDir.create(recursive: true);

    PathProviderPlatform.instance = FakePathProvider(tempDir.path);

    service = JsonStorageService();
    final ok = await service.initialize();
    expect(ok, isTrue);
    expect(service.isInitialized, isTrue);
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {
      // Best-effort cleanup; Windows sometimes locks files briefly.
    }
  });

  group("initialize", () {
    test("is idempotent", () async {
      final ok = await service.initialize();
      expect(ok, isTrue);
    });

    test("creates the characters subdirectory", () {
      final charactersDir =
          Directory(p.join(contentDir.path, "frankenstein_characters"));
      expect(charactersDir.existsSync(), isTrue);
    });
  });

  group("backgrounds round-trip", () {
    test("save then load returns equivalent entries", () async {
      final bg = makeBackground(name: "TestBG_Unique");

      final saved = await service.saveBackgrounds([bg]);
      expect(saved, isTrue);

      final loaded = await service.loadBackgrounds();
      expect(loaded.any((b) => b.name == "TestBG_Unique"), isTrue);
    });
  });

  group("classes round-trip", () {
    test("save then load returns equivalent entries", () async {
      final cls = makeClass(name: "TestClass_Unique");

      expect(await service.saveClasses([cls]), isTrue);
      final loaded = await service.loadClasses();
      expect(loaded.any((c) => c.name == "TestClass_Unique"), isTrue);
    });
  });

  group("feats round-trip", () {
    test("save then load returns equivalent entries", () async {
      final feat = makeFeat(name: "TestFeat_Unique");

      expect(await service.saveFeats([feat]), isTrue);
      final loaded = await service.loadFeats();
      expect(loaded.any((f) => f.name == "TestFeat_Unique"), isTrue);
    });
  });

  group("items round-trip", () {
    test("save then load returns equivalent entries", () async {
      final item = makeItem(name: "TestItem_Unique");

      expect(await service.saveItems([item]), isTrue);
      final loaded = await service.loadItems();
      expect(loaded.any((i) => i.name == "TestItem_Unique"), isTrue);
    });
  });

  group("languages round-trip", () {
    test("save then load preserves the list", () async {
      const langs = ["Common", "Elvish", "Draconic"];

      expect(await service.saveLanguages(langs), isTrue);
      final loaded = await service.loadLanguages();
      expect(loaded, containsAll(langs));
    });
  });

  group("proficiencies round-trip", () {
    test("save then load returns equivalent entries", () async {
      final p1 = makeProficiency(tree: ["Skills", "UniqueTestProf"]);

      expect(await service.saveProficiencies([p1]), isTrue);
      final loaded = await service.loadProficiencies();
      expect(loaded.any((p) => p.proficiencyTree.last == "UniqueTestProf"),
          isTrue);
    });
  });

  group("races round-trip", () {
    test("save then load returns equivalent entries", () async {
      final race = makeRace(name: "TestRace_Unique");

      expect(await service.saveRaces([race]), isTrue);
      final loaded = await service.loadRaces();
      expect(loaded.any((r) => r.name == "TestRace_Unique"), isTrue);
    });
  });

  group("spells round-trip", () {
    test("save then load returns equivalent entries", () async {
      final spell = makeSpell(name: "TestSpell_Unique");

      expect(await service.saveSpells([spell]), isTrue);
      final loaded = await service.loadSpells();
      expect(loaded.any((s) => s.name == "TestSpell_Unique"), isTrue);
    });
  });

  group("themes round-trip", () {
    test("save then load returns equivalent entries", () async {
      final theme = makeColourScheme();

      expect(await service.saveThemes([theme]), isTrue);
      final loaded = await service.loadThemes();
      expect(loaded.length, greaterThanOrEqualTo(1));
    });
  });

  group("missing-file behaviour", () {
    test("load* returns [] when there is no on-disk file", () async {
      // Delete one of the files and confirm load returns empty.
      final classesFile = File(p.join(contentDir.path, "classes.json"));
      if (await classesFile.exists()) {
        await classesFile.delete();
      }

      final loaded = await service.loadClasses();
      expect(loaded, isEmpty);
    });

    test("load* returns [] when the file is empty", () async {
      final feats = File(p.join(contentDir.path, "feats.json"));
      await feats.writeAsString("");

      final loaded = await service.loadFeats();
      expect(loaded, isEmpty);
    });
  });

  group("character storage", () {
    test("saveCharacter writes a json file named after the uniqueID", () async {
      final character = makeCharacter(uniqueID: 444444444444444);

      final ok = await service.saveCharacter(character);
      expect(ok, isTrue);

      final file = File(p.join(
          contentDir.path, "frankenstein_characters", "444444444444444.json"));
      expect(file.existsSync(), isTrue);
    });

    test("saveCharacter also updates the index file", () async {
      final character = makeCharacter(uniqueID: 555555555555555);
      await service.saveCharacter(character);

      final indexFile = File(
          p.join(contentDir.path, "frankenstein_characters", "index.json"));
      final indexData =
          jsonDecode(await indexFile.readAsString()) as Map<String, dynamic>;
      expect(indexData["characters"], contains("555555555555555"));
    });

    test("getAllCharacters loads every saved character via the index",
        () async {
      final c1 = makeCharacter(uniqueID: 666666666666666);
      final c2 = makeCharacter(uniqueID: 777777777777777);
      await service.saveCharacter(c1);
      await service.saveCharacter(c2);

      final loaded = await service.getAllCharacters();
      expect(loaded.any((c) => c.uniqueID == 666666666666666), isTrue);
      expect(loaded.any((c) => c.uniqueID == 777777777777777), isTrue);
    });

    test("updateCharacter overwrites the existing file", () async {
      final character = makeCharacter(
        uniqueID: 888888888888888,
        playerName: "InitialPlayer",
      );
      await service.saveCharacter(character);

      character.playerName = "UpdatedPlayer";
      final ok = await service.updateCharacter(character);
      expect(ok, isTrue);

      final loaded = await service.getAllCharacters();
      final stored = loaded.firstWhere((c) => c.uniqueID == 888888888888888);
      expect(stored.playerName, "UpdatedPlayer");
    });

    test("deleteCharacter removes the file and updates the index", () async {
      final character = makeCharacter(uniqueID: 999999999999999);
      await service.saveCharacter(character);
      final file = File(p.join(
          contentDir.path, "frankenstein_characters", "999999999999999.json"));
      expect(file.existsSync(), isTrue);

      final ok = await service.deleteCharacter(999999999999999);
      expect(ok, isTrue);
      expect(file.existsSync(), isFalse);

      final indexFile = File(
          p.join(contentDir.path, "frankenstein_characters", "index.json"));
      final indexData =
          jsonDecode(await indexFile.readAsString()) as Map<String, dynamic>;
      expect(indexData["characters"], isNot(contains("999999999999999")));
    });

    test("deleteCharacter returns true even when the file does not exist",
        () async {
      // The implementation only short-circuits the unlink; the index update
      // and final return remain true. This pins the current behaviour.
      final ok = await service.deleteCharacter(123); // never saved
      expect(ok, isTrue);
    });
  });
}
