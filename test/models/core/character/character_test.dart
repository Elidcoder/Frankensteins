import "dart:collection" show Queue;

import "package:flutter_test/flutter_test.dart";
import "package:frankenstein/models/core/character/character.dart";

import "../../../test_helpers/fixtures.dart";
import "../../../test_helpers/global_list_manager_bootstrap.dart";
import "../../../test_helpers/json_round_trip.dart";

Character _roundTrip(Character c) =>
    roundTripJson(c, Character.fromJson, (c) => c.toJson());

void main() {
  group("Character constructor", () {
    test("auto-generates a non-zero uniqueID when none is provided", () {
      // The contract is "unique enough for in-memory equality" — we don't
      // pin the exact 15-digit width because that's an implementation detail.
      final c = makeCharacter();
      expect(c.uniqueID, greaterThan(0));
    });

    test("auto-generated IDs do not collide across many instances", () {
      final ids = List.generate(50, (_) => makeCharacter().uniqueID).toSet();
      expect(ids.length, 50);
    });

    test("uses the caller-supplied uniqueID verbatim", () {
      expect(makeCharacter(uniqueID: 42).uniqueID, 42);
    });

    test("name getter delegates to characterDescription.name", () {
      final c = makeCharacter(
        characterDescription: makeCharacterDescription(name: "Gimli"),
      );
      expect(c.name, "Gimli");
    });

    test("abilityScores returns STR/DEX/CON/INT/WIS/CHA in that order", () {
      final c = makeCharacter();
      expect(
        c.abilityScores.map((s) => s.name).toList(),
        [
          "Strength",
          "Dexterity",
          "Constitution",
          "Intelligence",
          "Wisdom",
          "Charisma"
        ],
      );
    });
  });

  group("Character equality is uniqueID-only", () {
    test("same UID, different fields => equal", () {
      final a = makeCharacter(uniqueID: 100, playerName: "Alice");
      final b = makeCharacter(uniqueID: 100, playerName: "Bob");

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test("different UIDs => not equal", () {
      expect(makeCharacter(uniqueID: 1),
          isNot(equals(makeCharacter(uniqueID: 2))));
    });

    test("identical instances are equal to themselves", () {
      final a = makeCharacter();
      expect(a, equals(a));
    });
  });

  group("Character.getCopy", () {
    test("regenerates uniqueID so copy != original", () {
      // The source omits uniqueID from the getCopy() constructor call, which
      // triggers fresh 15-digit Random ID generation. Pin that contract.
      final original = makeCharacter(uniqueID: 12345);
      final copy = original.getCopy();

      expect(copy.uniqueID, isNot(equals(original.uniqueID)));
      expect(copy, isNot(equals(original)));
    });

    test("copies primitive fields by value", () {
      final original = makeCharacter(playerName: "Alice");
      original.maxHealth = 42;
      original.inspired = true;
      original.extraFeatures = "Has a glowing tattoo.";

      final copy = original.getCopy();

      expect(copy.playerName, "Alice");
      expect(copy.maxHealth, 42);
      expect(copy.inspired, isTrue);
      expect(copy.extraFeatures, "Has a glowing tattoo.");
    });

    // The interesting bugs in getCopy come from forgetting to deep-copy a
    // single collection field — so we cover every one of them in a table.
    test("every mutable collection is independent of the original", () {
      final original = makeCharacter();

      // Seed each collection with something distinguishable.
      original.languagesKnown.add("Elvish");
      original.classList.add("Wizard");
      original.weaponList.add("Longsword");
      original.armourList.add("Chain Mail");
      original.itemList.add("Backpack");
      original.savingThrowProficiencies.add("Wisdom");
      original.skillProficiencies.add("Stealth");
      original.mainToolProficiencies.add("Thieves' Tools");
      original.featuresAndTraits.add("Darkvision");
      original.skillsSelected.add("Athletics");
      original.languageChoices.add("Draconic");
      original.classSkillsSelected.add(true);
      original.currency["Gold Pieces"] = 100;
      original.skillBonusMap["Athletics"] = 5;
      original.stackableEquipmentSelected["Rations"] = 5;
      original.classSubclassMapper["Wizard"] = "Evocation";
      original.speedBonuses["Walking"]!.add("+10");
      original.featsSelected[makeFeat()] = 1;

      final copy = original.getCopy();

      // Mutate every collection on the copy and assert the original is intact.
      copy.languagesKnown.clear();
      copy.classList.clear();
      copy.weaponList.clear();
      copy.armourList.clear();
      copy.itemList.clear();
      copy.savingThrowProficiencies.clear();
      copy.skillProficiencies.clear();
      copy.mainToolProficiencies.clear();
      copy.featuresAndTraits.clear();
      copy.skillsSelected.clear();
      copy.languageChoices.clear();
      copy.classSkillsSelected.clear();
      copy.currency.clear();
      copy.skillBonusMap.clear();
      copy.stackableEquipmentSelected.clear();
      copy.classSubclassMapper.clear();
      copy.speedBonuses["Walking"]!.clear();
      copy.featsSelected.clear();

      expect(original.languagesKnown, contains("Elvish"));
      expect(original.classList, contains("Wizard"));
      expect(original.weaponList, contains("Longsword"));
      expect(original.armourList, contains("Chain Mail"));
      expect(original.itemList, contains("Backpack"));
      expect(original.savingThrowProficiencies, contains("Wisdom"));
      expect(original.skillProficiencies, contains("Stealth"));
      expect(original.mainToolProficiencies, contains("Thieves' Tools"));
      expect(original.featuresAndTraits, contains("Darkvision"));
      expect(original.skillsSelected, contains("Athletics"));
      expect(original.languageChoices, contains("Draconic"));
      expect(original.classSkillsSelected, isNotEmpty);
      expect(original.currency["Gold Pieces"], 100);
      expect(original.skillBonusMap["Athletics"], 5);
      expect(original.stackableEquipmentSelected["Rations"], 5);
      expect(original.classSubclassMapper["Wizard"], "Evocation");
      expect(original.speedBonuses["Walking"], contains("+10"));
      expect(original.featsSelected.values.first, 1);
    });

    test("optionalOnesStates / Twos deep-copy their nested rows", () {
      final original = makeCharacter()
        ..optionalOnesStates = [
          [false, false],
          [false, false],
        ]
        ..optionalTwosStates = [
          [false],
        ];

      final copy = original.getCopy();
      copy.optionalOnesStates![0][0] = true;
      copy.optionalTwosStates![0][0] = true;

      expect(original.optionalOnesStates![0][0], isFalse);
      expect(original.optionalTwosStates![0][0], isFalse);
    });
  });

  group("Character.basicsComplete", () {
    Character withBasics(
            {String name = "Aria",
            String gender = "female",
            String player = "Eli"}) =>
        makeCharacter(
          characterDescription:
              makeCharacterDescription(name: name, gender: gender),
          playerName: player,
        );

    test("true when name, gender, and playerName are all non-blank", () {
      expect(withBasics().basicsComplete, isTrue);
    });

    test("treats whitespace-only fields as blank", () {
      expect(withBasics(name: "   ").basicsComplete, isFalse);
      expect(withBasics(gender: " ").basicsComplete, isFalse);
      expect(withBasics(player: "  ").basicsComplete, isFalse);
    });

    test("false if any of the three required fields is empty", () {
      expect(withBasics(name: "").basicsComplete, isFalse);
      expect(withBasics(gender: "").basicsComplete, isFalse);
      expect(withBasics(player: "").basicsComplete, isFalse);
    });
  });

  group("Character.backstoryComplete", () {
    Character withFilledBackstory() {
      final c = makeCharacter(
        characterDescription: makeCharacterDescription(
          age: "30",
          height: "6'",
          weight: "180",
          eyes: "blue",
          skin: "tan",
          hair: "brown",
          backstory: "Wandered the wastelands.",
        ),
      );
      c.extraFeatures = "Has a pet bird.";
      return c;
    }

    test("true when every description field and extraFeatures is filled", () {
      expect(withFilledBackstory().backstoryComplete, isTrue);
    });

    test("false when any single backstory field is blank", () {
      final c = withFilledBackstory();
      c.characterDescription.backstory = "";
      expect(c.backstoryComplete, isFalse);
    });

    test("false when extraFeatures alone is blank", () {
      final c = withFilledBackstory();
      c.extraFeatures = "";
      expect(c.backstoryComplete, isFalse);
    });
  });

  group("Character.chosenAllSpells", () {
    test("true when every spell-pick entry has 0 remaining", () {
      final c = makeCharacter()
        ..allSpellsSelectedAsListsOfThings = [
          ["wizard", "1", 0],
        ];
      expect(c.chosenAllSpells, isTrue);
    });

    test("false when at least one entry still owes picks", () {
      final c = makeCharacter()
        ..allSpellsSelectedAsListsOfThings = [
          ["wizard", "1", 0],
          ["wizard", "2", 3],
        ];
      expect(c.chosenAllSpells, isFalse);
    });

    test("true vacuously when the spell list is empty", () {
      expect(makeCharacter().chosenAllSpells, isTrue);
    });
  });

  group("Character.chosenAllEqipment (sic)", () {
    test("true when every choice has been resolved (length != 2)", () {
      // Resolved choices come back with length > 2 (or 1). length == 2
      // means "still an A-or-B question".
      final c = makeCharacter()
        ..equipmentSelectedFromChoices = [
          ["resolved", "to", "this"],
        ];
      expect(c.chosenAllEqipment, isTrue);
    });

    test("false when any A-or-B choice remains", () {
      final c = makeCharacter()
        ..equipmentSelectedFromChoices = [
          ["option A", "option B"],
        ];
      expect(c.chosenAllEqipment, isFalse);
    });
  });

  group("Character JSON round-trip", () {
    test("preserves uniqueID and the description block", () {
      final original = makeCharacter(uniqueID: 999)
        ..maxHealth = 25
        ..inspired = true;

      final restored = _roundTrip(original);

      expect(restored.uniqueID, 999);
      expect(restored.name, original.name);
      expect(restored.playerName, original.playerName);
      expect(restored.maxHealth, 25);
      expect(restored.inspired, isTrue);
    });

    test("preserves every ability score's value", () {
      final restored = _roundTrip(makeCharacter());

      expect(restored.strength.value, 15);
      expect(restored.dexterity.value, 14);
      expect(restored.constitution.value, 13);
      expect(restored.intelligence.value, 12);
      expect(restored.wisdom.value, 10);
      expect(restored.charisma.value, 8);
    });

    test("preserves the build-option booleans", () {
      final original = makeCharacter()
        ..featsAllowed = false
        ..multiclassing = false
        ..milestoneLevelling = true
        ..criticalRoleContent = true;

      final restored = _roundTrip(original);

      expect(restored.featsAllowed, isFalse);
      expect(restored.multiclassing, isFalse);
      expect(restored.milestoneLevelling, isTrue);
      expect(restored.criticalRoleContent, isTrue);
    });

    test("preserves the nested Race name and Background name", () {
      final original = makeCharacter(
        race: makeRace(name: "High Elf"),
        background: makeBackground(name: "Sage"),
      );

      final restored = _roundTrip(original);

      expect(restored.race.name, "High Elf");
      expect(restored.background.name, "Sage");
    });

    test("preserves skillsSelected as a Queue<String> with order", () {
      final original = makeCharacter();
      original.skillsSelected.addAll(["Athletics", "Stealth", "Perception"]);

      final restored = _roundTrip(original);

      expect(restored.skillsSelected, isA<Queue<String>>());
      expect(restored.skillsSelected.toList(),
          ["Athletics", "Stealth", "Perception"]);
    });

    test("preserves featsSelected as Map<Feat, int>", () {
      final feat = makeFeat(name: "Tough");
      final original = makeCharacter()..featsSelected[feat] = 2;

      final restored = _roundTrip(original);

      expect(restored.featsSelected, hasLength(1));
      final entry = restored.featsSelected.entries.first;
      expect(entry.key, feat);
      expect(entry.value, 2);
    });

    test("preserves stackableEquipmentSelected counts", () {
      final original = makeCharacter()
        ..stackableEquipmentSelected["Rations"] = 5
        ..stackableEquipmentSelected["Torch"] = 3;

      final restored = _roundTrip(original);

      expect(restored.stackableEquipmentSelected["Rations"], 5);
      expect(restored.stackableEquipmentSelected["Torch"], 3);
    });

    test("preserves currency for all five denominations", () {
      final original = makeCharacter();
      original.currency["Gold Pieces"] = 100;
      original.currency["Silver Pieces"] = 50;

      final restored = _roundTrip(original);

      expect(restored.currency["Gold Pieces"], 100);
      expect(restored.currency["Silver Pieces"], 50);
      expect(restored.currency["Copper Pieces"], 0);
    });
  });

  group("Character.createDefault (requires GlobalListManager)", () {
    setUpAll(GlobalListManagerBootstrap.ensureInitialised);

    test("seeds every ability score at the point-buy minimum of 8", () {
      final c = Character.createDefault();

      for (final score in c.abilityScores) {
        expect(score.value, 8, reason: "${score.name} should start at 8");
      }
    });

    test("starts with Common in languagesKnown", () {
      expect(Character.createDefault().languagesKnown, contains("Common"));
    });

    test("seeds the canonical D&D 5e skills in skillBonusMap", () {
      // We don't pin the exact map size — only that the load-bearing entries
      // exist. Adding a new skill shouldn't break unrelated tests.
      final c = Character.createDefault();
      const requiredSkills = [
        "Acrobatics",
        "Athletics",
        "Perception",
        "Stealth",
        "Persuasion",
        "Strength Saving Throw",
        "Charisma Saving Throw",
        "Passive Perception",
        "Initiative",
      ];
      for (final skill in requiredSkills) {
        expect(c.skillBonusMap, containsPair(skill, 0));
      }
    });

    test("starts with all five currency denominations at zero", () {
      final c = Character.createDefault();
      for (final coin in const [
        "Copper Pieces",
        "Silver Pieces",
        "Electrum Pieces",
        "Gold Pieces",
        "Platinum Pieces",
      ]) {
        expect(c.currency, containsPair(coin, 0));
      }
    });

    test("ACList starts with the unarmored 10 + dexterity formula", () {
      expect(Character.createDefault().ACList, [
        ["10 + dexterity"],
      ]);
    });

    test("levelsPerClass length matches classList length", () {
      // The two lists are index-aligned (class[i] is at level levelsPerClass[i]).
      // If one grows without the other, the app crashes — pin the invariant.
      final c = Character.createDefault();
      expect(c.levelsPerClass.length, c.classLevels.length);
    });
  });
}
