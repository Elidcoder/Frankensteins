import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/game_mechanics/spell/spell.dart";

import "../../../test_helpers/fixtures.dart";

void main() {
  group("Spell", () {
    test("round-trips through JSON", () {
      final original = makeSpell(
        name: "Magic Missile",
        level: 1,
        spellSchool: "Evocation",
        verbal: true,
        somatic: true,
        material: null,
        ritual: false,
      );

      final restored = Spell.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.sourceBook, original.sourceBook);
      expect(restored.level, original.level);
      expect(restored.effect, original.effect);
      expect(restored.spellSchool, original.spellSchool);
      expect(restored.range, original.range);
      expect(restored.availableTo, original.availableTo);
      expect(restored.timings, original.timings);
      expect(restored.verbal, original.verbal);
      expect(restored.somatic, original.somatic);
      expect(restored.ritual, original.ritual);
    });

    test("applies default values when fields are absent from JSON", () {
      final json = {
        "name": "Mystery Spell",
        "sourceBook": "Homebrew",
        "effect": "Does something.",
        "spellSchool": "Divination",
        "range": "Self",
        "availableTo": ["Wizard"],
        "timings": ["Action", 1, "Instantaneous", 0],
        // level, ritual, verbal, somatic, material all omitted
      };

      final spell = Spell.fromJson(json);

      expect(spell.level, 0);
      expect(spell.ritual, false);
      expect(spell.verbal, false);
      expect(spell.somatic, false);
      expect(spell.material, "None");
    });

    test("preserves Content interface contract", () {
      final spell = makeSpell(name: "Eldritch Blast", sourceBook: "PHB");
      expect(spell.name, "Eldritch Blast");
      expect(spell.sourceBook, "PHB");
    });

    test(
        "round-trips the [casting type, multiple, duration type, multiple] timings tuple",
        () {
      // The source documents timings as a 4-element heterogeneous list. We
      // verify a non-trivial value survives both ways through JSON.
      final original = makeSpell(
        timings: const ["Bonus Action", 1, "Concentration", 10],
      );

      final restored = Spell.fromJson(original.toJson());

      expect(restored.timings, ["Bonus Action", 1, "Concentration", 10]);
    });

    test("preserves the availableTo class list", () {
      final original = makeSpell(
        availableTo: const ["Cleric", "Druid", "Paladin"],
      );

      final restored = Spell.fromJson(original.toJson());

      expect(restored.availableTo, ["Cleric", "Druid", "Paladin"]);
    });
  });
}
