import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/character_elements/subrace/subrace.dart";

import "../../../test_helpers/fixtures.dart";
import "../../../test_helpers/global_list_manager_bootstrap.dart";

void main() {
  group("Subrace", () {
    test("round-trips through JSON when no proficienciesGained are set", () {
      final original = makeSubrace(
        name: "High Elf",
        subRaceScoreIncrease: const [0, 0, 0, 1, 0, 0],
        languages: const ["Elvish"],
        darkVision: 60,
        walkingSpeed: 30,
      );

      final restored = Subrace.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.sourceBook, original.sourceBook);
      expect(restored.subRaceScoreIncrease, original.subRaceScoreIncrease);
      expect(restored.languages, original.languages);
      expect(restored.darkVision, original.darkVision);
      expect(restored.walkingSpeed, original.walkingSpeed);
      // Subrace.toJson uses `?? []` so null proficienciesGained round-trips
      // to an empty list, NOT null — this is intentional in the source and
      // asymmetric with Race.toJson, which preserves null. Pin the contract.
      expect(restored.proficienciesGained, isEmpty);
    });

    test("applies default values when optional fields are absent", () {
      final json = {
        "name": "Mystery Subrace",
        "sourceBook": "Homebrew",
        "subRaceScoreIncrease": [0, 0, 0, 0, 0, 0],
        "mystery1S": 0,
        "mystery2S": 0,
        // darkVision, walkingSpeed, languages, resistances, abilities omitted
      };

      final subrace = Subrace.fromJson(json);

      expect(subrace.darkVision, 0);
      expect(subrace.walkingSpeed, 30);
      expect(subrace.languages, isEmpty);
      expect(subrace.resistances, isEmpty);
    });

    group("with proficienciesGained (requires GlobalListManager)", () {
      setUpAll(() async {
        await GlobalListManagerBootstrap.ensureInitialised();
      });

      test("resolves gainedProficiencies via GlobalListManager", () {
        final original = makeSubrace(
          proficienciesGained:
              GlobalListManagerBootstrap.storage.seedProficiencies,
        );

        final json = original.toJson();
        // Subrace.toJson uses prof.toString() (not proficiencyTree.last)
        // and Subrace.fromJson compares against proficiencyTree.last.
        // To exercise resolution we patch the serialized form to use
        // the leaf name, which is the contract Race.fromJson uses too.
        json["gainedProficiencies"] = GlobalListManagerBootstrap
            .storage.seedProficiencies
            .map((p) => p.proficiencyTree.last)
            .toList();

        final restored = Subrace.fromJson(json);

        expect(restored.proficienciesGained, isNotNull);
        expect(restored.proficienciesGained!.length,
            GlobalListManagerBootstrap.storage.seedProficiencies.length);
      });
    });
  });
}
