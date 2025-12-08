-- Penacony_Modifier
-- Author: Nwflower
-- DateCreated: 2025-3-21 22:00:14
--------------------------------------------------------------
--================
-- Civ Trait
--================

INSERT INTO TraitModifiers(ModifierId,								TraitType)VALUES
('MODFEAT_PENACONY_GET_FREE_SULEDA', 'TRAIT_CIVILIZATION_SINKDREAM');
INSERT INTO Modifiers(ModifierId,ModifierType)VALUES
('MODFEAT_PENACONY_GET_FREE_SULEDA', 'MODIFIER_CAPITAL_CITY_GRANT_RESOURCE_IN_CITY');
INSERT INTO ModifierArguments(ModifierId,								Name,						Value)VALUES
('MODFEAT_PENACONY_GET_FREE_SULEDA',		'Amount',	2),
('MODFEAT_PENACONY_GET_FREE_SULEDA',		'ResourceType',	'RESOURCE_SULEDA');

INSERT INTO Types (Type, Kind) VALUES
('MODIFIER_CAPITAL_CITY_GRANT_RESOURCE_IN_CITY', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType) VALUES
('MODIFIER_CAPITAL_CITY_GRANT_RESOURCE_IN_CITY', 'COLLECTION_PLAYER_CAPITAL_CITY', 'EFFECT_GRANT_FREE_RESOURCE_IN_CITY');

--================
-- ROBIN
--================
-- 宫殿获得1个音乐巨作槽位。
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_FLY_TO_SKY_TOGETHER', 'MODFEAT_PENACONY_ROBIN_GET_FREE_GREATWORKSLOT_MUSIC');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODFEAT_PENACONY_ROBIN_GET_FREE_GREATWORKSLOT_MUSIC', 'MODIFIER_PLAYER_CITIES_ADJUST_EXTRA_GREAT_WORK_SLOTS', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODFEAT_PENACONY_ROBIN_GET_FREE_GREATWORKSLOT_MUSIC', 'Amount', 1),
('MODFEAT_PENACONY_ROBIN_GET_FREE_GREATWORKSLOT_MUSIC', 'BuildingType', 'BUILDING_PALACE'),
('MODFEAT_PENACONY_ROBIN_GET_FREE_GREATWORKSLOT_MUSIC', 'GreatWorkSlotType', 'GREATWORKSLOT_MUSIC');

-- 黄金时代音乐家
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_FLY_TO_SKY_TOGETHER', 'MODIFIER_TRAIT_LEADER_FLY_TO_SKY_TOGETHER_GREAT_PERSON_GUARANTEE');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_FLY_TO_SKY_TOGETHER_GREAT_PERSON_GUARANTEE', 'MODIFIER_PLAYER_ADJUST_GREAT_PERSON_GUARANTEE', 1, 1, 0, 'PLAYER_HAS_GOLDEN_AGE', NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_FLY_TO_SKY_TOGETHER_GREAT_PERSON_GUARANTEE', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_ROBIN');

--================
-- SUNDAY
--================
-- 回合数恰好能被7整除时，所有城市立即获得等同于回合数1/7的 [ICON_Production] 生产力。
CREATE TEMPORARY TABLE TURN_numbers
(
    number INT NOT NULL,
    PRIMARY KEY (number)
);
INSERT OR IGNORE INTO TURN_numbers (number)
WITH x AS
         (SELECT 1 AS id
          UNION ALL
          SELECT id + 1 AS id
          FROM x
          WHERE id < 72)
SELECT *
FROM x;

INSERT INTO TraitModifiers (TraitType, ModifierId) SELECT
'TRAIT_LEADER_POEM_CHOIR', 'MODIFIER_TRAIT_LEADER_POEM_CHOIR_PRODUCTION_'||number
FROM TURN_numbers;
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) SELECT
'MODIFIER_TRAIT_LEADER_POEM_CHOIR_PRODUCTION_'||number, 'MODIFIER_NW_PN_PLAYER_CITIES_GRANT_PRODUCTION_IN_CITY', 0, 1, 0, 'NW_GAME_TURN_ATLAST_'||number, NULL
FROM TURN_numbers;
INSERT INTO ModifierArguments (ModifierId, Name, Value) SELECT
'MODIFIER_TRAIT_LEADER_POEM_CHOIR_PRODUCTION_'||number, 'Amount', number
FROM TURN_numbers UNION SELECT
'MODIFIER_TRAIT_LEADER_POEM_CHOIR_PRODUCTION_'||number, 'KeepOverflow', '1'
FROM TURN_numbers;

-- Custom ModifierType
INSERT INTO Types (Type, Kind) VALUES
('MODIFIER_NW_PN_PLAYER_CITIES_GRANT_PRODUCTION_IN_CITY', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType) VALUES
('MODIFIER_NW_PN_PLAYER_CITIES_GRANT_PRODUCTION_IN_CITY', 'COLLECTION_PLAYER_CITIES', 'EFFECT_GRANT_PRODUCTION_IN_CITY');


-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) SELECT
'NW_GAME_TURN_ATLAST_'||number, 'REQUIREMENTSET_TEST_ALL'
FROM TURN_numbers;
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) SELECT
'NW_GAME_TURN_ATLAST_'||number, 'REQ_NW_GAME_TURN_ATLAST_'||number
FROM TURN_numbers;
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType) SELECT
'REQ_NW_GAME_TURN_ATLAST_'||number, 'REQUIREMENT_GAME_TURN_ATLEAST'
FROM TURN_numbers;
INSERT INTO RequirementArguments (RequirementId, Name, Value) SELECT
'REQ_NW_GAME_TURN_ATLAST_'||number, 'MinGameTurn', number * 7
FROM TURN_numbers;
