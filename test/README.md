# Tests

Unit-level coverage for the Frankenstein D&D character builder. Run with `flutter test` from the repo root. Static analysis lives in `flutter analyze test`.

## Layout

```
test/
├── core/               ← mirrors lib/core
│   ├── services/       ← GlobalListManager, JsonStorageService
│   ├── theme/          ← ColourScheme, ThemeManager
│   └── utils/          ← helpers.dart
├── models/             ← mirrors lib/models
│   ├── content/        ← background, class, race, spell, equipment, feats…
│   └── core/           ← character, ability_score, character_description
└── test_helpers/       ← shared fixtures and test doubles (NOT a mirror of lib/)
    ├── fixtures.dart                   ← make*() factories for every model
    ├── fake_storage_service.dart       ← in-memory StorageService double
    ├── fake_storage_service_test.dart  ← self-tests for the double
    ├── fake_path_provider.dart         ← path_provider plugin mock
    ├── global_list_manager_bootstrap.dart
    │   ← idempotently seeds the singleton with deterministic content
    └── json_round_trip.dart            ← jsonEncode/decode helper
```

## Conventions

**Test data comes from fixtures.** Don't build a Character (or any other model) from scratch in a test — call `makeCharacter(...)` and override only the fields you actually care about. New fields added to a model only have to be set up in one place.

**JSON round-trips go through `roundTripJson`** whenever the model nests another `@JsonSerializable` (Character, SelectedFeat). The project's models don't set `explicitToJson: true`, so the naive `Foo.fromJson(foo.toJson())` leaves nested objects as live references and trips the generated cast. `roundTripJson` mirrors the `jsonEncode → disk → jsonDecode` path production uses.

**Singletons are bootstrapped, not reset.** `GlobalListManager`, `ThemeManager`, and `JsonStorageService` are process-wide singletons with no reset hook. Because `flutter test` runs each *file* in its own VM isolate, this works out: each test file gets a clean singleton, and within a file the singleton is shared. Files that need the singleton call `GlobalListManagerBootstrap.ensureInitialised()` in `setUpAll`; mutations later in the same file should use unique identifiers so tests can't clobber one another.

**Pin the contract, not the incident.** Tests should describe what callers can rely on, not the exact shape of the current implementation:

- Prefer `containsPair("Acrobatics", 0)` over `length == 26` — adding a skill shouldn't break unrelated tests.
- Prefer `greaterThan(0)` over `toString().length == 15` for generated IDs.
- Pin known quirks (e.g. `Character.getCopy` regenerates `uniqueID`, `Subrace.toJson` emits `[]` where `Race.toJson` emits `null`) with a comment explaining *why* the test asserts that shape, so a future reader knows whether the assertion is documenting intent or merely the current bug.

**Test names read like sentences.** `"true when name, gender, and playerName are all non-blank"` over `"basicsCompleteAllFieldsFilled"`. Group headers carry the subject (`group("Character.basicsComplete", () {...})`), so test names can focus on the condition.

## Adding tests for a new model

1. Add a `make<Model>()` factory in [test_helpers/fixtures.dart](test_helpers/fixtures.dart). Every required field gets a default; every optional field is exposed as a parameter.
2. Add a `<model>_test.dart` mirroring the model's location under `lib/`.
3. At minimum cover: JSON round-trip, default values for absent JSON keys, any custom `==` / `hashCode` / `getCopy` logic, and any business-logic methods (e.g. `Character.basicsComplete`).
4. If the model needs `GlobalListManager` content (Race, Subrace, Background), call `GlobalListManagerBootstrap.ensureInitialised()` in `setUpAll`.
5. If the model nests another `@JsonSerializable`, route the round-trip through `roundTripJson` from [test_helpers/json_round_trip.dart](test_helpers/json_round_trip.dart).

## Known gaps

These aren't covered by unit tests yet:

- Widget tests for the creation tabs, character list, and PDF preview.
- Golden tests for `pdf_generator_service.makePdf` output.
- Property-based tests for the point-buy cost / ability-score interaction.
- A full integration test that drives `character_creation_screen` end-to-end.
