import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/core/utils/helpers.dart";
import "package:frankenstein/models/content/equipment/armour/armour.dart";
import "package:frankenstein/models/content/equipment/item/item.dart";
import "package:frankenstein/models/content/equipment/weapon/weapon.dart";

void main() {
  group("sum<T extends num>", () {
    test("adds ints", () {
      expect(sum<int>(2, 3), 5);
    });

    test("adds doubles", () {
      expect(sum<double>(2.5, 3.25), 5.75);
    });
  });

  group("displayPlural", () {
    test("returns empty string for single-element list", () {
      expect(displayPlural([1]), "");
    });

    test("returns 's' for multi-element list", () {
      expect(displayPlural([1, 2]), "s");
      expect(displayPlural([1, 2, 3, 4, 5]), "s");
    });

    test("returns empty string for empty list", () {
      // length 0 is not > 1, so returns "".
      expect(displayPlural([]), "");
    });
  });

  group("isAllowedContent", () {
    test("is a stub that always returns true (TODO in source)", () {
      expect(isAllowedContent("anything"), isTrue);
      expect(isAllowedContent(null), isTrue);
      expect(isAllowedContent(42), isTrue);
    });
  });

  group("mapEquipment", () {
    test("returns Armour when EquipmentType contains 'Armour'", () {
      final result = mapEquipment({
        "Name": "Leather",
        "SourceBook": "PHB",
        "Cost": [10, "gold"],
        "Weight": 10.0,
        "EquipmentType": ["Armour", "Light"],
        "ArmourFormula": "11 + dexterity",
        "ImposeStealthDisadvantage": false,
        "StrengthRequirement": false,
        "armourType": "Light",
      });

      expect(result, isA<Armour>());
    });

    test("returns Weapon when EquipmentType contains 'Weapon'", () {
      final result = mapEquipment({
        "Name": "Dagger",
        "SourceBook": "PHB",
        "Cost": [2, "gold"],
        "Weight": 1.0,
        "EquipmentType": ["Weapon", "Simple Melee"],
        "Properties": ["Finesse"],
        "DamageDiceAndType": [
          ["piercing", "1d4"],
        ],
      });

      expect(result, isA<Weapon>());
    });

    test("returns plain Item when EquipmentType is neither Armour nor Weapon",
        () {
      final result = mapEquipment({
        "Name": "Rope",
        "SourceBook": "PHB",
        "Cost": [1, "gold"],
        "Weight": 10.0,
        "EquipmentType": ["Adventuring Gear"],
      });

      expect(result, isA<Item>());
      expect(result, isNot(isA<Weapon>()));
      expect(result, isNot(isA<Armour>()));
    });

    test("falls through to Item.fromJson when EquipmentType contains 'Magic'",
        () {
      // The Magic branch in mapEquipment has an empty body (TODO in source),
      // so execution drops out of the if-chain and hits the final
      // `return Item.fromJson(x)`. We supply the minimum fields Item needs.
      final result = mapEquipment({
        "Name": "Magic Wand",
        "SourceBook": "PHB",
        "Cost": [100, "gold"],
        "Weight": 1.0,
        "EquipmentType": ["Magic"],
      });

      expect(result, isA<Item>());
      expect(result, isNot(isA<Weapon>()));
      expect(result, isNot(isA<Armour>()));
    });
  });
}
