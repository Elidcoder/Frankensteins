import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/core/theme/colour_scheme.dart";

import "../../test_helpers/fixtures.dart";

void main() {
  group("ColourScheme", () {
    test("round-trips through JSON", () {
      final original = makeColourScheme(
        textColour: const Color(0xFF112233),
        backingColour: const Color(0xFFAABBCC),
        backgroundColour: const Color(0xFF445566),
      );

      final restored = ColourScheme.fromJson(original.toJson());

      expect(restored.textColour, original.textColour);
      expect(restored.backingColour, original.backingColour);
      expect(restored.backgroundColour, original.backgroundColour);
    });

    group("isSameColourScheme", () {
      test("true when all three colours match", () {
        final a = makeColourScheme();
        final b = makeColourScheme();
        expect(a.isSameColourScheme(b), isTrue);
      });

      test("false when textColour differs", () {
        final a = makeColourScheme(textColour: Colors.white);
        final b = makeColourScheme(textColour: Colors.black);
        expect(a.isSameColourScheme(b), isFalse);
      });

      test("false when backingColour differs", () {
        final a = makeColourScheme(backingColour: Colors.red);
        final b = makeColourScheme(backingColour: Colors.green);
        expect(a.isSameColourScheme(b), isFalse);
      });

      test("false when backgroundColour differs", () {
        final a = makeColourScheme(backgroundColour: Colors.black);
        final b = makeColourScheme(backgroundColour: Colors.white);
        expect(a.isSameColourScheme(b), isFalse);
      });
    });

    test("name getter contains all three colour descriptions", () {
      final scheme = makeColourScheme();
      expect(scheme.name, contains("backing"));
      expect(scheme.name, contains("text"));
      expect(scheme.name, contains("background"));
    });
  });
}
