// Bootstraps the GlobalListManager singleton with deterministic fake data
// so tests that depend on its content lists (Race.fromJson, Subrace.fromJson,
// Character.createDefault, Background.getLanguageOptions, etc.) can run.
//
// IMPORTANT: GlobalListManager caches its lists internally and exposes no
// reset hook. Once content is loaded for the first time in a test run, the
// SAME content is returned for every subsequent test in the process. Callers
// that need different seed data per-test should adjust expectations, not the
// singleton.
import "package:frankenstein/core/services/global_list_manager.dart";

import "fake_storage_service.dart";
import "fixtures.dart";

class GlobalListManagerBootstrap {
  static FakeStorageService? _storage;
  static bool _seeded = false;

  /// Returns the FakeStorageService used to bootstrap the singleton.
  /// Mutating its seed* lists after the first call has no effect on the
  /// already-cached singleton lists.
  static FakeStorageService get storage => _storage!;

  /// Idempotently initialise GlobalListManager with deterministic fake
  /// content. Safe to call from every test's setUpAll().
  static Future<void> ensureInitialised() async {
    if (_seeded) return;

    final fake = FakeStorageService()
      ..seedProficiencies = [
        makeProficiency(tree: ["Skills", "Athletics"]),
        makeProficiency(tree: ["Skills", "Stealth"]),
      ]
      ..seedLanguages = ["Common", "Elvish", "Dwarvish"]
      ..seedSpells = [makeSpell()]
      ..seedFeats = [makeFeat()]
      ..seedItems = [makeItem()]
      ..seedClasses = [makeClass()]
      ..seedRaces = [makeRace()]
      ..seedBackgrounds = [makeBackground()]
      ..seedThemes = [makeColourScheme()];

    await GlobalListManager().initialise(fake);
    await GlobalListManager().initialiseContentLists();
    await GlobalListManager().initialiseCharacterList();

    _storage = fake;
    _seeded = true;
  }
}
