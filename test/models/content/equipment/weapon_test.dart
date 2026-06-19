import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/equipment/item/item.dart";
import "package:frankenstein/models/content/equipment/weapon/weapon.dart";

import "../../../test_helpers/fixtures.dart";

void main() {
  group("Weapon", () {
    test("round-trips through JSON", () {
      final original = makeWeapon(
        name: "Greatsword",
        cost: const [50, "gold"],
        weight: 6.0,
        properties: const ["Heavy", "Two-Handed"],
        damageDiceAndType: const [
          ["slashing", "2d6"],
        ],
      );

      final restored = Weapon.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.sourceBook, original.sourceBook);
      expect(restored.properties, original.properties);
      expect(restored.damageDiceAndType, original.damageDiceAndType);
      expect(restored.weight, original.weight);
      expect(restored.cost, original.cost);
    });

    test("is an Item subtype", () {
      final weapon = makeWeapon();
      expect(weapon, isA<Item>());
    });

    test("stackable defaults to false when absent", () {
      final json = {
        "Name": "Dagger",
        "SourceBook": "PHB",
        "Cost": [2, "gold"],
        "Weight": 1.0,
        "EquipmentType": ["Weapon", "Simple Melee"],
        "Properties": ["Finesse", "Light", "Thrown"],
        "DamageDiceAndType": [
          ["piercing", "1d4"],
        ],
      };

      final w = Weapon.fromJson(json);

      expect(w.stackable, isFalse);
      expect(w.description, isNull);
    });

    test("parses nested damageDiceAndType as List<List<String>>", () {
      final json = {
        "Name": "Hand Crossbow",
        "SourceBook": "PHB",
        "Cost": [75, "gold"],
        "Weight": 3.0,
        "EquipmentType": ["Weapon", "Martial Ranged"],
        "Properties": ["Ammunition", "Light", "Loading"],
        "DamageDiceAndType": [
          ["piercing", "1d6"],
        ],
      };

      final w = Weapon.fromJson(json);

      expect(w.damageDiceAndType, isA<List<List<String>>>());
      expect(w.damageDiceAndType.first, ["piercing", "1d6"]);
    });
  });
}
