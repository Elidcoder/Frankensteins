import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/character_elements/background/background.dart";

import "../../../test_helpers/fixtures.dart";
import "../../../test_helpers/global_list_manager_bootstrap.dart";

void main() {
  group("Background", () {
    test("round-trips through JSON", () {
      final original = makeBackground(
        name: "Soldier",
        numberOfSkillChoices: 0,
        numberOfLanguageChoices: 0,
        features: const ["Military Rank"],
        languageOptions: const ["Common", "Orc"],
        toolProficiencies: const ["Gaming Set"],
        personalityTrait: const ["I face problems head-on."],
        ideal: const ["Greater Good."],
        bond: const ["I would still lay down my life for them."],
        flaw: const ["I made a terrible mistake in battle."],
        equipment: const ["Insignia of rank", "Common clothes"],
      );

      final restored = Background.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.sourceBook, original.sourceBook);
      expect(restored.numberOfSkillChoices, original.numberOfSkillChoices);
      expect(
          restored.numberOfLanguageChoices, original.numberOfLanguageChoices);
      expect(restored.features, original.features);
      expect(restored.initialProficiencies, original.initialProficiencies);
      expect(restored.optionalSkillProficiencies,
          original.optionalSkillProficiencies);
      expect(restored.languageOptions, original.languageOptions);
      expect(restored.toolProficiencies, original.toolProficiencies);
      expect(restored.personalityTrait, original.personalityTrait);
      expect(restored.ideal, original.ideal);
      expect(restored.bond, original.bond);
      expect(restored.flaw, original.flaw);
      expect(restored.equipment, original.equipment);
    });

    test("applies default values when optional fields are absent", () {
      final json = {
        "Name": "Mystery Background",
        "SourceBook": "Homebrew",
        "PersonalityTrait": ["x"],
        "Ideal": ["y"],
        "Bond": ["z"],
        "Flaw": ["w"],
        // everything else omitted
      };

      final bg = Background.fromJson(json);

      expect(bg.numberOfSkillChoices, 0);
      expect(bg.numberOfLanguageChoices, 0);
      expect(bg.features, isEmpty);
      expect(bg.equipment, isEmpty);
      expect(bg.initialProficiencies, isEmpty);
      expect(bg.toolProficiencies, isEmpty);
      expect(bg.optionalSkillProficiencies, isEmpty);
    });

    group("getLanguageOptions", () {
      test("returns own languageOptions when non-empty", () {
        final bg = makeBackground(languageOptions: const ["Draconic", "Orc"]);
        expect(bg.getLanguageOptions(), ["Draconic", "Orc"]);
      });

      group("when languageOptions is empty", () {
        setUpAll(() async {
          await GlobalListManagerBootstrap.ensureInitialised();
        });

        test("falls back to GlobalListManager.languageList", () {
          final bg = makeBackground(languageOptions: const []);

          final result = bg.getLanguageOptions();

          // We seed three languages in the bootstrap.
          expect(result, contains("Common"));
          expect(result.length, greaterThan(0));
        });
      });
    });
  });
}
