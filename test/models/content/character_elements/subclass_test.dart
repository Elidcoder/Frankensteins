import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/character_elements/subclass/subclass.dart";

import "../../../test_helpers/fixtures.dart";

void main() {
  group("Subclass", () {
    test("round-trips through JSON", () {
      final original = makeSubclass(
        name: "Battle Master",
        classType: "Fighter",
        roundDown: true,
        gainAtEachLevel: const [
          [
            ["Maneuvers", "3"],
          ],
        ],
      );

      final restored = Subclass.fromJson(original.toJson());

      expect(restored.name, original.name);
      expect(restored.sourceBook, original.sourceBook);
      expect(restored.classType, original.classType);
      expect(restored.roundDown, original.roundDown);
      expect(restored.mainOrSpellcastingAbility,
          original.mainOrSpellcastingAbility);
      expect(restored.gainAtEachLevel.length, original.gainAtEachLevel.length);
    });

    test("roundDown can be null", () {
      final s = makeSubclass(roundDown: null);
      final restored = Subclass.fromJson(s.toJson());
      expect(restored.roundDown, isNull);
    });
  });
}
