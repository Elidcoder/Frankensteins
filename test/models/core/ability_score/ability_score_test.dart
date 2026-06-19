import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/core/ability_score/ability_score.dart";

void main() {
  group("AbilityScore", () {
    test("constructor stores name and value", () {
      final score = AbilityScore(name: "Strength", value: 14);

      expect(score.name, "Strength");
      expect(score.value, 14);
    });

    group("abilityScoreCost", () {
      test("costs 1 for value <= 12", () {
        expect(AbilityScore(name: "S", value: 8).abilityScoreCost, 1);
        expect(AbilityScore(name: "S", value: 10).abilityScoreCost, 1);
        expect(AbilityScore(name: "S", value: 12).abilityScoreCost, 1);
      });

      test("costs 2 for value > 12", () {
        expect(AbilityScore(name: "S", value: 13).abilityScoreCost, 2);
        expect(AbilityScore(name: "S", value: 15).abilityScoreCost, 2);
      });
    });

    test("round-trips through JSON", () {
      final original = AbilityScore(name: "Dexterity", value: 16);

      final restored = AbilityScore.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.value, original.value);
    });

    test("value is mutable", () {
      final score = AbilityScore(name: "Strength", value: 10);
      score.value = 18;
      expect(score.value, 18);
      expect(score.abilityScoreCost, 2);
    });
  });
}
