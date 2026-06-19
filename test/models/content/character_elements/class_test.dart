import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/character_elements/class/class.dart";

import "../../../test_helpers/fixtures.dart";

void main() {
  group("Class", () {
    test("round-trips through JSON", () {
      final original = makeClass(
        name: "Wizard",
        classType: "Caster",
        mainOrSpellcastingAbility: "Intelligence",
        savingThrowProficiencies: const ["Intelligence", "Wisdom"],
        multiclassingRequirements: const [0, 0, 0, 13, 0, 0, 1],
      );

      final restored = Class.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.sourceBook, original.sourceBook);
      expect(restored.classType, original.classType);
      expect(restored.maxHitDiceRoll, original.maxHitDiceRoll);
      expect(restored.mainOrSpellcastingAbility,
          original.mainOrSpellcastingAbility);
      expect(restored.multiclassingRequirements,
          original.multiclassingRequirements);
      expect(restored.numberOfSkillChoices, original.numberOfSkillChoices);
      expect(restored.optionsForSkillProficiencies,
          original.optionsForSkillProficiencies);
      expect(
          restored.savingThrowProficiencies, original.savingThrowProficiencies);
    });

    test("Class implements Content interface", () {
      final c = makeClass();
      expect(c.name, isNotEmpty);
      expect(c.sourceBook, isNotEmpty);
    });

    test("round-trips with all nullable spellcasting fields left null", () {
      // Fighter and Barbarian, in particular, have no spells — so the
      // spellsAndSpellSlots / spellsKnownFormula / spellsKnownPerLevel /
      // roundDown fields should all serialize back as null.
      final original = makeClass(
        name: "Barbarian",
        roundDown: null,
        spellsAndSpellSlots: null,
        spellsKnownFormula: null,
        spellsKnownPerLevel: null,
        proficienciesGained: null,
      );

      final restored = Class.fromJson(original.toJson());

      expect(restored.roundDown, isNull);
      expect(restored.spellsAndSpellSlots, isNull);
      expect(restored.spellsKnownFormula, isNull);
      expect(restored.spellsKnownPerLevel, isNull);
      expect(restored.proficienciesGained, isNull);
    });

    test("preserves the multiclassingRequirements ability-score gates", () {
      // Wizard requires INT 13: [STR, DEX, CON, INT, WIS, CHA, count]
      final original = makeClass(
        name: "Wizard",
        multiclassingRequirements: const [0, 0, 0, 13, 0, 0, 1],
      );

      final restored = Class.fromJson(original.toJson());

      expect(restored.multiclassingRequirements, [0, 0, 0, 13, 0, 0, 1]);
    });
  });
}
