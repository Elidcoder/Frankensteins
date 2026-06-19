// Sanity checks for the test double itself — a passing FakeStorageService
// test suite is what lets every other test trust the seeded singleton.
import "package:flutter_test/flutter_test.dart";

import "fake_storage_service.dart";
import "fixtures.dart";

void main() {
  group("FakeStorageService", () {
    test("initialize marks initialized", () async {
      final fake = FakeStorageService();
      expect(fake.initializeCalled, isFalse);
      await fake.initialize();
      expect(fake.initializeCalled, isTrue);
    });

    test("initialize rethrows when configured to fail", () async {
      final fake = FakeStorageService()..throwOnInitialize = true;
      expect(fake.initialize(), throwsA(isA<StateError>()));
    });

    test("loadX returns a copy of the seed list (callers can't mutate seed)",
        () async {
      final fake = FakeStorageService()..seedSpells = [makeSpell()];

      final loaded = await fake.loadSpells();
      loaded.clear();

      expect(fake.seedSpells, isNotEmpty);
    });

    test("saveSpells replaces the seed list", () async {
      final fake = FakeStorageService()..seedSpells = [makeSpell()];

      await fake.saveSpells([makeSpell(name: "New")]);

      expect(fake.seedSpells, hasLength(1));
      expect(fake.seedSpells.first.name, "New");
    });

    test("saveCharacter adds a new character", () async {
      final fake = FakeStorageService();
      await fake.saveCharacter(makeCharacter(uniqueID: 1));
      expect(fake.seedCharacters, hasLength(1));
    });

    test("saveCharacter replaces an existing character with the same UID",
        () async {
      final fake = FakeStorageService();
      await fake.saveCharacter(makeCharacter(uniqueID: 1, playerName: "Old"));
      await fake.saveCharacter(makeCharacter(uniqueID: 1, playerName: "New"));

      expect(fake.seedCharacters, hasLength(1));
      expect(fake.seedCharacters.first.playerName, "New");
    });

    test("deleteCharacter returns true on a hit, false on a miss", () async {
      final fake = FakeStorageService();
      await fake.saveCharacter(makeCharacter(uniqueID: 1));

      expect(await fake.deleteCharacter(1), isTrue);
      expect(await fake.deleteCharacter(1), isFalse);
    });
  });
}
