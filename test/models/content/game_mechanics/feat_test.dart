import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/game_mechanics/feat/feat.dart";

import "../../../test_helpers/fixtures.dart";

void main() {
  group("Feat", () {
    test("round-trips through JSON", () {
      final original = makeFeat(
        name: "Great Weapon Master",
        isHalfFeat: false,
        numberOfTimesTakeable: 1,
      );

      final restored = Feat.fromJson(original.toJson());

      expect(restored, equals(original));
      expect(restored.name, original.name);
      expect(restored.description, original.description);
    });

    group("equality", () {
      test("identical instances are equal", () {
        final feat = makeFeat();
        expect(feat == feat, isTrue);
      });

      test("matching field values are equal", () {
        expect(makeFeat() == makeFeat(), isTrue);
      });

      test("differing names are not equal", () {
        expect(makeFeat(name: "Tough") == makeFeat(name: "Lucky"), isFalse);
      });

      test("differing abilities are not equal", () {
        final a = makeFeat(abilities: const [
          ["Bonus", "HP", "+2 HP per level"],
        ]);
        final b = makeFeat(abilities: const [
          ["Bonus", "AC", "+1 AC"],
        ]);
        expect(a == b, isFalse);
      });

      test("differing numberOfTimesTakeable are not equal", () {
        expect(
          makeFeat(numberOfTimesTakeable: 1) ==
              makeFeat(numberOfTimesTakeable: 2),
          isFalse,
        );
      });

      test("a Feat is never equal to a non-Feat", () {
        final Object notAFeat = "Tough";
        expect(makeFeat() == notAFeat, isFalse);
      });

      test("hashCode is consistent with equality", () {
        final a = makeFeat();
        final b = makeFeat();
        expect(a == b, isTrue);
        expect(a.hashCode, b.hashCode);
      });
    });

    test("display getter formats bonus abilities", () {
      final feat = makeFeat(
        name: "Tough",
        abilities: const [
          ["Bonus", "HP", "+2 HP per level"],
          ["Other", "Marker", "Ignored"],
        ],
      );

      expect(feat.display, contains("Tough"));
      expect(feat.display, contains("+2 HP per level"));
      expect(feat.display, isNot(contains("Ignored")));
    });
  });
}
