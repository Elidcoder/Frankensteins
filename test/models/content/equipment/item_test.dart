import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/equipment/item/item.dart";

import "../../../test_helpers/fixtures.dart";

void main() {
  group("Item", () {
    test("round-trips through JSON", () {
      final original = makeItem(
        name: "Rope, hempen (50ft)",
        cost: const [1, "gold"],
        weight: 10.0,
        stackable: false,
      );

      final restored = Item.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.sourceBook, original.sourceBook);
      expect(restored.cost, original.cost);
      expect(restored.weight, original.weight);
      expect(restored.stackable, original.stackable);
      expect(restored.equipmentType, original.equipmentType);
      expect(restored.description, original.description);
    });

    test("stackable defaults to false when absent from JSON", () {
      final json = {
        "Name": "Mystery Item",
        "SourceBook": "Homebrew",
        "Cost": [1, "copper"],
        "Weight": 0.0,
        "EquipmentType": ["Misc"],
      };

      final item = Item.fromJson(json);

      expect(item.stackable, isFalse);
      expect(item.description, isNull);
    });

    test("name and other fields are mutable", () {
      final item = makeItem();
      item.name = "Renamed Item";
      item.weight = 100.0;
      item.stackable = true;
      expect(item.name, "Renamed Item");
      expect(item.weight, 100.0);
      expect(item.stackable, isTrue);
    });

    test("round-trips a stackable item with no description", () {
      // Stackable items (rations, torches, arrows) are the main use case
      // for stackableEquipmentSelected — make sure they survive serialization.
      final original = makeItem(
        name: "Rations",
        stackable: true,
        description: null,
      );

      final restored = Item.fromJson(original.toJson());

      expect(restored.stackable, isTrue);
      expect(restored.description, isNull);
    });
  });
}
