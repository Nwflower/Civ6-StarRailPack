-- Penacony_Unit
-- Author: Nwflower
-- DateCreated: 2025-5-9 16:39:32
--------------------------------------------------------------
--================
-- 筑梦师
--================
INSERT OR
REPLACE
INTO Types(Type, Kind)
VALUES ('UNIT_DREAM_BUILDER', 'KIND_UNIT');
INSERT OR
REPLACE
INTO Tags(Tag, Vocabulary)
VALUES ('CLASS_DREAM_BUILDER', 'ABILITY_CLASS');
INSERT OR
REPLACE
INTO TypeTags(Type, Tag)
VALUES ('UNIT_DREAM_BUILDER', 'CLASS_DREAM_BUILDER');

INSERT OR
REPLACE
INTO TypeTags(Type, Tag)
SELECT 'UNIT_DREAM_BUILDER',
       Tag
FROM TypeTags
WHERE Type = 'UNIT_ROCK_BAND';
INSERT OR
REPLACE
INTO UnitAiInfos(UnitType, AiType)
SELECT 'UNIT_DREAM_BUILDER',
       AiType
FROM UnitAiInfos
WHERE UnitType = 'UNIT_ROCK_BAND';

-- 继承军事工程师的属性
INSERT OR
REPLACE
INTO Units(UnitType, Name, BaseSightRange, BaseMoves, Combat, RangedCombat, Range, Bombard, Domain,
           FormationClass, Cost, PopulationCost, FoundCity, FoundReligion, MakeTradeRoute, EvangelizeBelief,
           LaunchInquisition, RequiresInquisition, BuildCharges, ReligiousStrength, ReligionEvictPercent,
           SpreadCharges, ReligiousHealCharges, ExtractsArtifacts, Description, Flavor, CanCapture,
           CanRetreatWhenCaptured, TraitType, AllowBarbarians, CostProgressionModel, CostProgressionParam1,
           PromotionClass, InitialLevel, NumRandomChoices, PrereqTech, PrereqCivic, PrereqDistrict,
           PrereqPopulation, LeaderType, CanTrain, StrategicResource, PurchaseYield, MustPurchase, Maintenance,
           Stackable, AirSlots, CanTargetAir, PseudoYieldType, ZoneOfControl, AntiAirCombat, Spy, WMDCapable,
           ParkCharges, IgnoreMoves, TeamVisibility, ObsoleteTech, ObsoleteCivic, MandatoryObsoleteTech,
           MandatoryObsoleteCivic, AdvisorType, EnabledByReligion, TrackReligion, DisasterCharges,
           UseMaxMeleeTrainedStrength, ImmediatelyName, CanEarnExperience)
SELECT 'UNIT_DREAM_BUILDER',
       'LOC_UNIT_DREAM_BUILDER_NAME',
       BaseSightRange,
       BaseMoves,
       60,
       RangedCombat,
       Range,
       Bombard,
       Domain,
       'FORMATION_CLASS_LAND_COMBAT',
       Cost * 0.8,
       PopulationCost,
       FoundCity,
       FoundReligion,
       MakeTradeRoute,
       EvangelizeBelief,
       LaunchInquisition,
       RequiresInquisition,
       0,
       ReligiousStrength,
       ReligionEvictPercent,
       SpreadCharges,
       ReligiousHealCharges,
       ExtractsArtifacts,
       'LOC_UNIT_DREAM_BUILDER_DESCRIPTION',
       Flavor,
       CanCapture,
       CanRetreatWhenCaptured,
       'TRAIT_UNIT_DREAM_BUILDER',
       AllowBarbarians,
       CostProgressionModel,
       CostProgressionParam1 * 1.2,
       PromotionClass,
       InitialLevel,
       NumRandomChoices,
       NULL,
       'CIVIC_THE_ENLIGHTENMENT',
       PrereqDistrict,
       PrereqPopulation,
       LeaderType,
       CanTrain,
       StrategicResource,
       PurchaseYield,
       0,
       Maintenance,
       Stackable,
       AirSlots,
       CanTargetAir,
       PseudoYieldType,
       ZoneOfControl,
       AntiAirCombat,
       Spy,
       WMDCapable,
       ParkCharges,
       IgnoreMoves,
       TeamVisibility,
       ObsoleteTech,
       ObsoleteCivic,
       MandatoryObsoleteTech,
       MandatoryObsoleteCivic,
       AdvisorType,
       EnabledByReligion,
       TrackReligion,
       DisasterCharges,
       UseMaxMeleeTrainedStrength,
       ImmediatelyName,
       CanEarnExperience
FROM Units
WHERE UnitType = 'UNIT_ROCK_BAND';

INSERT INTO Units_XP2(UnitType, TourismBombPossible)
VALUES ('UNIT_DREAM_BUILDER', 1);

--================
-- UnitAbility
--================

INSERT OR IGNORE INTO Types(Type, Kind)
VALUES ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'KIND_ABILITY');
INSERT OR IGNORE INTO TypeTags(Type, Tag)
VALUES ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'CLASS_DREAM_BUILDER');
INSERT OR IGNORE INTO UnitAbilities(UnitAbilityType, Inactive, Name, Description)
VALUES ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 0,
        'LOC_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_NAME',
        'LOC_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_NAME');

INSERT OR IGNORE INTO UnitAbilityModifiers (UnitAbilityType, ModifierId)
values ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_TOURISM_BOMB_ALL');

INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType)
values ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_TOURISM_BOMB_ALL',
        'MODIFIER_NW_PN_PLAYER_UNIT_ADJUST_ROCK_BAND_TOURISM_BOMB_VALUE_PEACE');

INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
values ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_TOURISM_BOMB_ALL', 'Amount', -50);


-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_PN_PLAYER_UNIT_ADJUST_ROCK_BAND_TOURISM_BOMB_VALUE_PEACE', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_PN_PLAYER_UNIT_ADJUST_ROCK_BAND_TOURISM_BOMB_VALUE_PEACE', 'COLLECTION_OWNER',
        'EFFECT_ADJUST_UNIT_ROCK_BAND_TOURISM_BOMB_VALUE_PEACE');

