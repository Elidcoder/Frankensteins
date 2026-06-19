import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/core/theme/theme_manager.dart";

import "../../test_helpers/fixtures.dart";
import "../../test_helpers/global_list_manager_bootstrap.dart";

void main() {
  setUpAll(() async {
    await GlobalListManagerBootstrap.ensureInitialised();
  });

  group("ThemeManager", () {
    test("instance getter returns a singleton", () {
      final a = ThemeManager.instance;
      final b = ThemeManager.instance;
      expect(identical(a, b), isTrue);
    });

    test("currentScheme is non-null with default colours before initialize",
        () {
      // Without explicitly calling initialize, the scheme falls back to the
      // hard-coded white/blue/white default.
      final scheme = ThemeManager.instance.currentScheme;
      expect(scheme.textColour, isNotNull);
      expect(scheme.backingColour, isNotNull);
      expect(scheme.backgroundColour, isNotNull);
    });

    test("updateScheme notifies registered listeners", () {
      int notifyCount = 0;
      void listener() => notifyCount++;

      ThemeManager.instance.addListener(listener);

      ThemeManager.instance.updateScheme(
        makeColourScheme(
          textColour: Colors.yellow,
          backingColour: Colors.purple,
          backgroundColour: Colors.black,
        ),
      );

      expect(notifyCount, 1);

      ThemeManager.instance.removeListener(listener);
    });

    test("updateScheme replaces currentScheme", () {
      final newScheme = makeColourScheme(
        textColour: Colors.orange,
        backingColour: Colors.green,
        backgroundColour: Colors.white,
      );

      ThemeManager.instance.updateScheme(newScheme);

      expect(ThemeManager.instance.currentScheme.isSameColourScheme(newScheme),
          isTrue);
    });

    test("removeListener stops further notifications", () {
      int notifyCount = 0;
      void listener() => notifyCount++;

      ThemeManager.instance.addListener(listener);
      ThemeManager.instance.removeListener(listener);

      ThemeManager.instance.updateScheme(makeColourScheme());

      expect(notifyCount, 0);
    });

    test("themeData picks light brightness for light background", () {
      ThemeManager.instance.updateScheme(
        makeColourScheme(
          backgroundColour: Colors.white,
          textColour: Colors.black,
          backingColour: Colors.blue,
        ),
      );

      expect(ThemeManager.instance.themeData.brightness, Brightness.light);
    });

    test("themeData picks dark brightness for dark background", () {
      ThemeManager.instance.updateScheme(
        makeColourScheme(
          backgroundColour: Colors.black,
          textColour: Colors.white,
          backingColour: Colors.blue,
        ),
      );

      expect(ThemeManager.instance.themeData.brightness, Brightness.dark);
    });

    test("dispose() clears every registered listener", () {
      int notifyCount = 0;
      ThemeManager.instance.addListener(() => notifyCount++);
      ThemeManager.instance.addListener(() => notifyCount++);

      ThemeManager.instance.dispose();

      ThemeManager.instance.updateScheme(makeColourScheme());
      expect(notifyCount, 0);
    });

    test("savedThemes hides the currently-active scheme", () {
      final activeScheme = makeColourScheme(
        textColour: Colors.white,
        backingColour: Colors.indigo,
        backgroundColour: Colors.black,
      );

      ThemeManager.instance.updateScheme(activeScheme);

      // None of the schemes in savedThemes should match the active one.
      for (final saved in ThemeManager.instance.savedThemes) {
        expect(saved.isSameColourScheme(activeScheme), isFalse);
      }
    });

    test("themeData propagates backing colour to AppBar background", () {
      ThemeManager.instance.updateScheme(
        makeColourScheme(
          backingColour: const Color(0xFF123456),
          textColour: Colors.white,
          backgroundColour: Colors.white,
        ),
      );

      expect(ThemeManager.instance.themeData.appBarTheme.backgroundColor,
          const Color(0xFF123456));
    });
  });
}
