-- Penacony_Unit
-- Author: Nwflower
-- DateCreated: 2025-5-9 16:39:32
--------------------------------------------------------------
--================
-- 筑梦师
--================
INSERT OR
REPLACE INTO Types(Type, Kind)
VALUES ('UNIT_DREAM_BUILDER', 'KIND_UNIT');
INSERT OR
REPLACE INTO Tags(Tag, Vocabulary)
VALUES ('CLASS_DREAM_BUILDER', 'ABILITY_CLASS');
INSERT OR
REPLACE INTO TypeTags(Type, Tag)
VALUES ('UNIT_DREAM_BUILDER', 'CLASS_DREAM_BUILDER');

INSERT OR
REPLACE INTO TypeTags(Type, Tag)
SELECT 'UNIT_DREAM_BUILDER',
       Tag
FROM TypeTags
WHERE Type = 'UNIT_ROCK_BAND';
INSERT OR
REPLACE INTO UnitAiInfos(UnitType, AiType)
SELECT 'UNIT_DREAM_BUILDER',
       AiType
FROM UnitAiInfos
WHERE UnitType = 'UNIT_ROCK_BAND';

-- 继承军事工程师的属性
INSERT OR
REPLACE INTO Units(UnitType, Name, BaseSightRange, BaseMoves, Combat, RangedCombat, Range, Bombard, Domain,
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
       64,
       RangedCombat,
       Range,
       Bombard,
       Domain,
       'FORMATION_CLASS_LAND_COMBAT',
       Cost,
       PopulationCost,
       FoundCity,
       FoundReligion,
       MakeTradeRoute,
       EvangelizeBelief,
       LaunchInquisition,
       RequiresInquisition,
       1,
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
       'NO_COST_PROGRESSION',
       0,
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

INSERT INTO Units_XP2(UnitType,TourismBombPossible)VALUES
('UNIT_DREAM_BUILDER',1);

--================
-- UnitAbility
--================
-- 在敌方境内的奇观、娱乐中心、剧院广场、学院和宇航中心的表演效果提升1个等级
INSERT OR IGNORE INTO Types(Type, Kind)
VALUES ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'KIND_ABILITY');
INSERT OR IGNORE INTO TypeTags(Type, Tag)
VALUES ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'CLASS_DREAM_BUILDER');
INSERT OR IGNORE INTO UnitAbilities(UnitAbilityType, Inactive, Name, Description)
VALUES ('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 1,
        'LOC_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_NAME',
        'LOC_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_NAME');

INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_UNIT_DREAM_BUILDER', 'MODIFIER_TRAIT_UNIT_DREAM_BUILDER_GRANT_ABILITY');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_UNIT_DREAM_BUILDER_GRANT_ABILITY', 'MODIFIER_PLAYER_UNITS_GRANT_ABILITY', 0, 0, 0, NULL, 'NW_PN_UNIT_IN_ENEMY_TERRITORY');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_UNIT_DREAM_BUILDER_GRANT_ABILITY', 'AbilityType', 'ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM');

INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('NW_PN_UNIT_IN_ENEMY_TERRITORY', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('NW_PN_UNIT_IN_ENEMY_TERRITORY', 'REQ_NW_PN_UNIT_IN_ENEMY_TERRITORY');
INSERT INTO Requirements (RequirementId, RequirementType) VALUES
('REQ_NW_PN_UNIT_IN_ENEMY_TERRITORY', 'REQUIREMENT_UNIT_IN_ENEMY_TERRITORY');


INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId) VALUES
('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_WONDER');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_WONDER', 'MODIFIER_PLAYER_UNIT_ADJUST_ROCK_BAND_LEVEL_DISTRICT', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_WONDER', 'Amount', 1),
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_WONDER', 'DistrictType', 'DISTRICT_WONDER');

INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId) VALUES
('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_ENTERTAINMENT_COMPLEX');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_ENTERTAINMENT_COMPLEX', 'MODIFIER_PLAYER_UNIT_ADJUST_ROCK_BAND_LEVEL_DISTRICT', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_ENTERTAINMENT_COMPLEX', 'Amount', 1),
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_ENTERTAINMENT_COMPLEX', 'DistrictType', 'DISTRICT_ENTERTAINMENT_COMPLEX');

INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId) VALUES
('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_THEATER');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_THEATER', 'MODIFIER_PLAYER_UNIT_ADJUST_ROCK_BAND_LEVEL_DISTRICT', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_THEATER', 'Amount', 1),
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_THEATER', 'DistrictType', 'DISTRICT_THEATER');

INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId) VALUES
('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_SPACEPORT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_SPACEPORT', 'MODIFIER_PLAYER_UNIT_ADJUST_ROCK_BAND_LEVEL_DISTRICT', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_SPACEPORT', 'Amount', 1),
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_SPACEPORT', 'DistrictType', 'DISTRICT_SPACEPORT');

INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId) VALUES
('ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM', 'MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_CAMPUS');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_CAMPUS', 'MODIFIER_PLAYER_UNIT_ADJUST_ROCK_BAND_LEVEL_DISTRICT', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_CAMPUS', 'Amount', 1),
('MODIFIER_ABILITY_PENACONY_UNITS_GET_EXTRA_TORISM_DISTRICT_CAMPUS', 'DistrictType', 'DISTRICT_CAMPUS');
