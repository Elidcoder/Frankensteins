import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/equipment/armour/armour.dart";
import "package:frankenstein/models/content/equipment/item/item.dart";

import "../../../test_helpers/fixtures.dart";

void main() {
  group("Armour", () {
    test("round-trips through JSON", () {
      final original = makeArmour(
        name: "Plate",
        cost: const [1500, "gold"],
        weight: 65.0,
        armourFormula: "18",
        imposeStealthDisadvantage: true,
        strengthRequirement: true,
        armourType: "Heavy",
      );

      final restored = Armour.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.armourFormula, original.armourFormula);
      expect(restored.imposeStealthDisadvantage,
          original.imposeStealthDisadvantage);
      expect(restored.strengthRequirement, original.strengthRequirement);
      expect(restored.armourType, original.armourType);
      expect(restored.weight, original.weight);
    });

    test("is an Item subtype", () {
      final a = makeArmour();
      expect(a, isA<Item>());
    });

    test("imposeStealthDisadvantage defaults to false when absent", () {
      final json = {
        "Name": "Leather",
        "SourceBook": "PHB",
        "Cost": [10, "gold"],
        "Weight": 10.0,
        "EquipmentType": ["Armour", "Light"],
        "ArmourFormula": "11 + dexterity",
        // ImposeStealthDisadvantage absent
        // StrengthRequirement absent
        "armourType": "Light",
      };

      final a = Armour.fromJson(json);
      expect(a.imposeStealthDisadvantage, isFalse);
      expect(a.strengthRequirement, isFalse);
    });
  });
}
