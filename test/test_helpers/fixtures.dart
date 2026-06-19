// Test fixtures: minimal valid instances of every model the project uses.
//
// Every factory accepts named params for every field it sets. Defaults are
// chosen to be obviously-realistic D&D values so failing tests are easy to
// read in CI output — "Fire Bolt" is more informative than "TestSpell".
//
// Pattern: start from a fixture and override only what the test cares about.
// Don't construct a 50-field Character by hand. If you find yourself
// overriding the same combination of fields in three places, add a new
// factory here instead.
import "dart:collection" show Queue;

import "package:frankenstein/core/theme/colour_scheme.dart";
import "package:frankenstein/models/content/character_elements/background/background.dart";
import "package:frankenstein/models/content/character_elements/class/class.dart";
import "package:frankenstein/models/content/character_elements/proficiency.dart";
import "package:frankenstein/models/content/character_elements/race/race.dart";
import "package:frankenstein/models/content/character_elements/subclass/subclass.dart";
import "package:frankenstein/models/content/character_elements/subrace/subrace.dart";
import "package:frankenstein/models/content/equipment/armour/armour.dart";
import "package:frankenstein/models/content/equipment/item/item.dart";
import "package:frankenstein/models/content/equipment/weapon/weapon.dart";
import "package:frankenstein/models/content/game_mechanics/feat/feat.dart";
import "package:frankenstein/models/content/game_mechanics/selected_feat/selected_feat.dart";
import "package:frankenstein/models/content/game_mechanics/spell/spell.dart";
import "package:frankenstein/models/core/ability_score/ability_score.dart";
import "package:frankenstein/models/core/character/character.dart";
import "package:frankenstein/models/core/character/character_description.dart";
import "package:flutter/material.dart" show Color, Colors;

AbilityScore makeAbilityScore({String name = "Strength", int value = 10}) =>
    AbilityScore(name: name, value: value);

CharacterDescription makeCharacterDescription({
  String name = "Test Hero",
  String gender = "Other",
  String age = "30",
  String height = "6'",
  String weight = "180lb",
  String eyes = "brown",
  String skin = "tan",
  String hair = "black",
  String backstory = "A test backstory.",
}) =>
    CharacterDescription(
      name: name,
      gender: gender,
      age: age,
      height: height,
      weight: weight,
      eyes: eyes,
      skin: skin,
      hair: hair,
      backstory: backstory,
    );

Proficiency makeProficiency({List<String>? tree}) =>
    Proficiency(proficiencyTree: tree ?? ["Skills", "Athletics"]);

Spell makeSpell({
  String name = "Fire Bolt",
  String sourceBook = "PHB",
  int level = 0,
  String effect = "You hurl a mote of fire.",
  String spellSchool = "Evocation",
  String range = "120 feet",
  List<String>? availableTo,
  List<dynamic>? timings,
  bool? ritual,
  bool? verbal = true,
  bool? somatic = true,
  String? material,
}) =>
    Spell(
      name: name,
      sourceBook: sourceBook,
      level: level,
      effect: effect,
      spellSchool: spellSchool,
      range: range,
      availableTo: availableTo ?? const ["Wizard", "Sorcerer"],
      timings: timings ?? const ["Action", 1, "Instantaneous", 0],
      ritual: ritual,
      verbal: verbal,
      somatic: somatic,
      material: material,
    );

Feat makeFeat({
  String name = "Tough",
  String sourceBook = "PHB",
  bool isHalfFeat = false,
  String description =
      "Your hit point maximum increases by an amount equal to twice your level.",
  List<List<dynamic>>? abilities,
  int numberOfTimesTakeable = 1,
}) =>
    Feat(
      name: name,
      sourceBook: sourceBook,
      isHalfFeat: isHalfFeat,
      description: description,
      abilities: abilities ??
          const [
            ["Bonus", "HP", "+2 HP per level"],
          ],
      numberOfTimesTakeable: numberOfTimesTakeable,
    );

SelectedFeat makeSelectedFeat({Feat? feat, int timesTaken = 1}) =>
    SelectedFeat(feat: feat ?? makeFeat(), timesTaken: timesTaken);

Item makeItem({
  String name = "Backpack",
  String sourceBook = "PHB",
  List<String>? equipmentType,
  List<dynamic>? cost,
  double weight = 5.0,
  bool stackable = false,
  String? description = "A leather backpack.",
}) =>
    Item(
      name: name,
      sourceBook: sourceBook,
      equipmentType: equipmentType ?? const ["Adventuring Gear"],
      cost: cost ?? const [2, "gold"],
      weight: weight,
      stackable: stackable,
      description: description,
    );

Weapon makeWeapon({
  String name = "Longsword",
  String sourceBook = "PHB",
  List<String>? equipmentType,
  List<dynamic>? cost,
  double weight = 3.0,
  bool stackable = false,
  String? description,
  List<String>? properties,
  List<List<String>>? damageDiceAndType,
}) =>
    Weapon(
      name: name,
      sourceBook: sourceBook,
      equipmentType: equipmentType ?? const ["Weapon", "Martial Melee"],
      cost: cost ?? const [15, "gold"],
      weight: weight,
      stackable: stackable,
      description: description,
      properties: properties ?? const ["Versatile"],
      damageDiceAndType: damageDiceAndType ??
          const [
            ["slashing", "1d8"],
          ],
    );

Armour makeArmour({
  String name = "Chain Mail",
  String sourceBook = "PHB",
  List<String>? equipmentType,
  List<dynamic>? cost,
  double weight = 55.0,
  bool stackable = false,
  String? description,
  String armourFormula = "16",
  bool imposeStealthDisadvantage = true,
  bool strengthRequirement = true,
  String armourType = "Heavy",
}) =>
    Armour(
      name: name,
      sourceBook: sourceBook,
      equipmentType: equipmentType ?? const ["Armour", "Heavy"],
      cost: cost ?? const [75, "gold"],
      weight: weight,
      stackable: stackable,
      description: description,
      armourFormula: armourFormula,
      imposeStealthDisadvantage: imposeStealthDisadvantage,
      strengthRequirement: strengthRequirement,
      armourType: armourType,
    );

Background makeBackground({
  String name = "Acolyte",
  String sourceBook = "PHB",
  int numberOfSkillChoices = 0,
  int numberOfLanguageChoices = 2,
  List<String>? features,
  List<String>? initialProficiencies,
  List<String>? optionalSkillProficiencies,
  List<String>? languageOptions,
  List<String>? toolProficiencies,
  List<String>? personalityTrait,
  List<String>? ideal,
  List<String>? bond,
  List<String>? flaw,
  List<String>? equipment,
}) =>
    Background(
      name: name,
      sourceBook: sourceBook,
      numberOfSkillChoices: numberOfSkillChoices,
      numberOfLanguageChoices: numberOfLanguageChoices,
      features: features ?? const ["Shelter of the Faithful"],
      initialProficiencies:
          initialProficiencies ?? const ["Insight", "Religion"],
      optionalSkillProficiencies: optionalSkillProficiencies ?? const [],
      languageOptions: languageOptions ?? const [],
      toolProficiencies: toolProficiencies ?? const [],
      personalityTrait:
          personalityTrait ?? const ["I idolize a particular hero."],
      ideal: ideal ?? const ["Tradition."],
      bond: bond ?? const ["I would die to recover an ancient relic."],
      flaw: flaw ?? const ["I judge others harshly."],
      equipment: equipment ?? const ["Holy symbol"],
    );

Race makeRace({
  String name = "Human",
  String sourceBook = "PHB",
  List<int>? raceScoreIncrease,
  List<String>? languages,
  List<String>? toolProficiencies,
  List<Subrace>? subRaces,
  List<String>? resistances,
  List<String>? abilities,
  List<Proficiency>? proficienciesGained,
  int darkVision = 0,
  int walkingSpeed = 30,
  int mystery1S = 0,
  int mystery2S = 0,
}) =>
    Race(
      name: name,
      sourceBook: sourceBook,
      raceScoreIncrease: raceScoreIncrease ?? const [1, 1, 1, 1, 1, 1],
      languages: languages ?? const ["Common"],
      toolProficiencies: toolProficiencies,
      subRaces: subRaces,
      resistances: resistances,
      abilities: abilities,
      proficienciesGained: proficienciesGained,
      darkVision: darkVision,
      walkingSpeed: walkingSpeed,
      mystery1S: mystery1S,
      mystery2S: mystery2S,
    );

Subrace makeSubrace({
  String name = "Hill Dwarf",
  String sourceBook = "PHB",
  List<int>? subRaceScoreIncrease,
  List<String>? languages,
  List<String>? resistances,
  List<String>? abilities,
  List<Proficiency>? proficienciesGained,
  int darkVision = 60,
  int walkingSpeed = 25,
  int mystery1S = 0,
  int mystery2S = 0,
  List<String>? toolProficiencies,
}) =>
    Subrace(
      name: name,
      sourceBook: sourceBook,
      subRaceScoreIncrease: subRaceScoreIncrease ?? const [0, 0, 0, 0, 1, 0],
      languages: languages ?? const [],
      resistances: resistances ?? const [],
      abilities: abilities ?? const [],
      proficienciesGained: proficienciesGained,
      darkVision: darkVision,
      walkingSpeed: walkingSpeed,
      mystery1S: mystery1S,
      mystery2S: mystery2S,
      toolProficiencies: toolProficiencies ?? const [],
    );

Class makeClass({
  String name = "Fighter",
  String sourceBook = "PHB",
  String classType = "Martial",
  int maxHitDiceRoll = 10,
  bool? roundDown,
  String mainOrSpellcastingAbility = "Strength",
  List<int>? multiclassingRequirements,
  int numberOfSkillChoices = 2,
  List<String>? optionsForSkillProficiencies,
  List<String>? spellsAndSpellSlots,
  String? spellsKnownFormula,
  List<int>? spellsKnownPerLevel,
  List<String>? savingThrowProficiencies,
  List<List<dynamic>>? equipmentOptions,
  List<String>? proficienciesGained,
  List<List<dynamic>>? gainAtEachLevel,
}) =>
    Class(
      name: name,
      sourceBook: sourceBook,
      classType: classType,
      maxHitDiceRoll: maxHitDiceRoll,
      roundDown: roundDown,
      mainOrSpellcastingAbility: mainOrSpellcastingAbility,
      multiclassingRequirements:
          multiclassingRequirements ?? const [13, 0, 0, 0, 0, 0, 1],
      numberOfSkillChoices: numberOfSkillChoices,
      optionsForSkillProficiencies:
          optionsForSkillProficiencies ?? const ["Athletics", "Intimidation"],
      spellsAndSpellSlots: spellsAndSpellSlots,
      spellsKnownFormula: spellsKnownFormula,
      spellsKnownPerLevel: spellsKnownPerLevel,
      savingThrowProficiencies:
          savingThrowProficiencies ?? const ["Strength", "Constitution"],
      equipmentOptions: equipmentOptions ?? const [],
      proficienciesGained: proficienciesGained,
      gainAtEachLevel: gainAtEachLevel ?? const [],
    );

Subclass makeSubclass({
  String name = "Champion",
  String sourceBook = "PHB",
  String classType = "Fighter",
  bool? roundDown,
  String mainOrSpellcastingAbility = "Strength",
  List<List<List<String>>>? gainAtEachLevel,
}) =>
    Subclass(
      name: name,
      sourceBook: sourceBook,
      classType: classType,
      mainOrSpellcastingAbility: mainOrSpellcastingAbility,
      roundDown: roundDown,
      gainAtEachLevel: gainAtEachLevel ?? const [],
    );

ColourScheme makeColourScheme({
  Color textColour = Colors.white,
  Color backingColour = Colors.blue,
  Color backgroundColour = Colors.black,
}) =>
    ColourScheme(
      textColour: textColour,
      backingColour: backingColour,
      backgroundColour: backgroundColour,
    );

/// Build a fully-formed Character that does NOT depend on GlobalListManager.
/// Pass in Race/Background to avoid hidden singleton coupling.
Character makeCharacter({
  Race? race,
  Background? background,
  CharacterDescription? characterDescription,
  String playerName = "Test Player",
  int? uniqueID,
}) {
  final r = race ?? makeRace();
  final bg = background ?? makeBackground();
  // Collections are deliberately non-const so tests can mutate them.
  return Character(
    uniqueID: uniqueID,
    skillBonusMap: {
      "Acrobatics": 0,
      "Athletics": 0,
    },
    levelsPerClass: [0],
    allSelected: [],
    classSubclassMapper: {},
    ACList: [
      ["10 + dexterity"],
    ],
    allSpellsSelected: [],
    allSpellsSelectedAsListsOfThings: [],
    armourList: [],
    featsSelected: {},
    itemList: [],
    equipmentSelectedFromChoices: [],
    optionalOnesStates: [],
    optionalTwosStates: [],
    speedBonuses: {
      "Walking": [],
    },
    weaponList: [],
    unstackableEquipmentSelected: [],
    featuresAndTraits: [],
    languagesKnown: ["Common"],
    classList: [],
    stackableEquipmentSelected: {},
    skillsSelected: Queue<String>(),
    languageChoices: Queue<String>(),
    mainToolProficiencies: [],
    savingThrowProficiencies: [],
    skillProficiencies: [],
    background: bg,
    classLevels: [0],
    race: r,
    backgroundIdeal: bg.ideal.first,
    backgroundPersonalityTrait: bg.personalityTrait.first,
    backgroundBond: bg.bond.first,
    backgroundFlaw: bg.flaw.first,
    raceAbilityScoreIncreases: r.raceScoreIncrease,
    strength: makeAbilityScore(name: "Strength", value: 15),
    dexterity: makeAbilityScore(name: "Dexterity", value: 14),
    classSkillsSelected: [],
    constitution: makeAbilityScore(name: "Constitution", value: 13),
    intelligence: makeAbilityScore(name: "Intelligence", value: 12),
    wisdom: makeAbilityScore(name: "Wisdom", value: 10),
    charisma: makeAbilityScore(name: "Charisma", value: 8),
    featsASIScoreIncreases: [0, 0, 0, 0, 0, 0],
    currency: {
      "Copper Pieces": 0,
      "Silver Pieces": 0,
      "Electrum Pieces": 0,
      "Gold Pieces": 0,
      "Platinum Pieces": 0,
    },
    characterDescription: characterDescription ?? makeCharacterDescription(),
    playerName: playerName,
  );
}
