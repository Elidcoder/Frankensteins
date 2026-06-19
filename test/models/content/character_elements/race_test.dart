import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/character_elements/race/race.dart";

import "../../../test_helpers/fixtures.dart";
import "../../../test_helpers/global_list_manager_bootstrap.dart";
import "../../../test_helpers/json_round_trip.dart";

void main() {
  group("Race", () {
    test("round-trips through JSON when no proficienciesGained are set", () {
      final original = makeRace(
        name: "Elf",
        sourceBook: "PHB",
        raceScoreIncrease: const [0, 2, 0, 0, 0, 0],
        languages: const ["Common", "Elvish"],
        toolProficiencies: const [],
        darkVision: 60,
        walkingSpeed: 30,
      );

      final restored = Race.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.sourceBook, original.sourceBook);
      expect(restored.raceScoreIncrease, original.raceScoreIncrease);
      expect(restored.languages, original.languages);
      expect(restored.darkVision, original.darkVision);
      expect(restored.walkingSpeed, original.walkingSpeed);
      expect(restored.proficienciesGained, isNull);
    });

    test("applies default values when fields are absent", () {
      final json = {
        "name": "Wildling",
        "abilityScoreMap": [1, 1, 1, 1, 1, 1],
        "mystery1S": 0,
        "mystery2S": 0,
        // sourceBook, languages, darkVision, walkingSpeed all omitted
      };

      final race = Race.fromJson(json);

      expect(race.sourceBook, "N/A");
      expect(race.languages, ["Common"]);
      expect(race.darkVision, 0);
      expect(race.walkingSpeed, 30);
    });

    test("preserves a list of nested Subraces through JSON", () {
      // Races often carry their subraces inline — e.g. Dwarf -> [Hill Dwarf,
      // Mountain Dwarf]. Race doesn't enable explicitToJson, so we route
      // through real jsonEncode (the path JsonStorageService takes on save)
      // to flatten the nested Subrace objects to Maps before reloading.
      final original = makeRace(
        name: "Dwarf",
        subRaces: [
          makeSubrace(name: "Hill Dwarf"),
          makeSubrace(name: "Mountain Dwarf"),
        ],
      );

      final restored =
          roundTripJson(original, Race.fromJson, (r) => r.toJson());

      expect(restored.subRaces, hasLength(2));
      expect(restored.subRaces!.map((s) => s.name).toList(),
          ["Hill Dwarf", "Mountain Dwarf"]);
    });

    test("preserves null subRaces as null when the race has none", () {
      final restored = Race.fromJson(makeRace(subRaces: null).toJson());
      expect(restored.subRaces, isNull);
    });

    group("with proficienciesGained (requires GlobalListManager)", () {
      setUpAll(() async {
        await GlobalListManagerBootstrap.ensureInitialised();
      });

      test("resolves gainedProficiencies via GlobalListManager", () {
        final original = makeRace(
          name: "Half-Orc",
          proficienciesGained:
              GlobalListManagerBootstrap.storage.seedProficiencies,
        );

        final restored = Race.fromJson(original.toJson());

        expect(restored.proficienciesGained, isNotNull);
        expect(restored.proficienciesGained!.length,
            GlobalListManagerBootstrap.storage.seedProficiencies.length);
        expect(restored.proficienciesGained!.first.proficiencyTree,
            ["Skills", "Athletics"]);
      });
    });
  });
}
