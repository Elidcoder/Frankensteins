import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/content/game_mechanics/selected_feat/selected_feat.dart";

import "../../../test_helpers/fixtures.dart";
import "../../../test_helpers/json_round_trip.dart";

void main() {
  group("SelectedFeat", () {
    test("survives a save/load round-trip", () {
      // The nested Feat needs `explicitToJson` to round-trip cleanly via
      // fromJson(toJson()), and the source doesn't enable it — so route
      // through real JSON the same way production does.
      final original = makeSelectedFeat(timesTaken: 2);

      final restored = roundTripJson(
        original,
        SelectedFeat.fromJson,
        (s) => s.toJson(),
      );

      expect(restored.feat, original.feat);
      expect(restored.timesTaken, original.timesTaken);
    });

    test("timesTaken is mutable", () {
      final sf = makeSelectedFeat(timesTaken: 1);
      sf.timesTaken = 3;
      expect(sf.timesTaken, 3);
    });
  });
}
