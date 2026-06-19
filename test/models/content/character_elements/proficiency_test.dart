import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/character_elements/proficiency.dart";

void main() {
  group("Proficiency", () {
    test("constructor stores tree", () {
      final p = Proficiency(proficiencyTree: ["Skills", "Athletics"]);
      expect(p.proficiencyTree, ["Skills", "Athletics"]);
    });

    test("fromJson reads ProficiencyTree key", () {
      final p = Proficiency.fromJson({
        "ProficiencyTree": ["Skills", "Stealth"],
      });

      expect(p.proficiencyTree, ["Skills", "Stealth"]);
    });

    test("toJson writes ProficiencyTree key", () {
      final p = Proficiency(proficiencyTree: ["Tools", "Smith's Tools"]);

      expect(p.toJson(), {
        "ProficiencyTree": ["Tools", "Smith's Tools"],
      });
    });

    test("round-trips through JSON", () {
      final original = Proficiency(proficiencyTree: ["Skills", "Perception"]);

      final restored = Proficiency.fromJson(original.toJson());

      expect(restored.proficiencyTree, original.proficiencyTree);
    });

    test("toJson copies the list so external mutation does not bleed", () {
      final tree = ["Skills", "Perception"];
      final p = Proficiency(proficiencyTree: tree);

      final json = p.toJson();
      tree.add("Mutated");

      expect(json["ProficiencyTree"], ["Skills", "Perception"]);
    });
  });
}
