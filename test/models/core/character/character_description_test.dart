import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/core/character/character_description.dart";

void main() {
  group("CharacterDescription", () {
    test("default constructor produces empty strings for every field", () {
      final desc = CharacterDescription();

      expect(desc.age, "");
      expect(desc.height, "");
      expect(desc.weight, "");
      expect(desc.eyes, "");
      expect(desc.skin, "");
      expect(desc.hair, "");
      expect(desc.backstory, "");
      expect(desc.name, "");
      expect(desc.gender, "");
    });

    test("named constructor populates every field", () {
      final desc = CharacterDescription(
        name: "Aria",
        gender: "female",
        age: "28",
        height: "5'7",
        weight: "140lb",
        eyes: "green",
        skin: "fair",
        hair: "red",
        backstory: "A wandering bard.",
      );

      expect(desc.name, "Aria");
      expect(desc.gender, "female");
      expect(desc.age, "28");
      expect(desc.height, "5'7");
      expect(desc.weight, "140lb");
      expect(desc.eyes, "green");
      expect(desc.skin, "fair");
      expect(desc.hair, "red");
      expect(desc.backstory, "A wandering bard.");
    });

    test("round-trips through JSON", () {
      final desc = CharacterDescription(
        name: "Aria",
        gender: "female",
        age: "28",
      );

      final restored = CharacterDescription.fromJson(desc.toJson());

      expect(restored.name, desc.name);
      expect(restored.gender, desc.gender);
      expect(restored.age, desc.age);
      expect(restored.backstory, "");
    });

    test("fields are mutable", () {
      final desc = CharacterDescription();
      desc.name = "Renamed";
      desc.gender = "nonbinary";
      expect(desc.name, "Renamed");
      expect(desc.gender, "nonbinary");
    });
  });
}
