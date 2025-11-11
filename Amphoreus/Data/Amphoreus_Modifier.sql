--  FILE: Amphoreus_Modifier.sql
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni
--  Copyright (c) 2025.
--      All rights reserved.
--  DateCreated: 2025/10/26 15:31:52

CREATE TEMPORARY TABLE IF NOT EXISTS NW_Amphoreus_Traits
(
    LeaderType   TEXT NOT NULL PRIMARY KEY,
    DistrictType TEXT NOT NULL,
    TraitType    TEXT NOT NULL
);
INSERT OR IGNORE INTO NW_Amphoreus_Traits(LeaderType, DistrictType, TraitType)
VALUES
-- 缇宝 刻法勒广场 门径
('LEADER_NW_TRIBIOS', 'DISTRICT_JANUS', 'JANUS'),
-- 万敌 悬锋竞技场 纷争
('LEADER_NW_MYDEI', 'DISTRICT_NIKADOR', 'NIKADOR'),
-- 阿格莱雅 云石天宫 浪漫
('LEADER_NW_AGLAEA', 'DISTRICT_MNESTIA', 'MNESTIA'),
-- 那刻夏 树庭 理性
('LEADER_NW_ANAXA', 'DISTRICT_CERCES', 'CERCES'),
-- 遐蝶 龙骸古城 死亡
('LEADER_NW_CASTORICE', 'DISTRICT_THANATOS', 'THANATOS'),
-- 风堇 疗愈之庭 天空
('LEADER_NW_HYACINTHIA', 'DISTRICT_AQUILA', 'AQUILA'),
-- 赛飞儿 云石市集 诡计
('LEADER_NW_CIFERA', 'DISTRICT_ZAGREUS', 'ZAGREUS'),
-- 白厄 创世涡心 负世
('LEADER_NW_PHAINON', 'DISTRICT_KEPHALE', 'KEPHALE'),
-- 海瑟音 浮影海庭 海洋
('LEADER_NW_HELEKTRA', 'DISTRICT_PHAGOUSA', 'PHAGOUSA'),
-- 刻律德菈 预言书库 律法
('LEADER_NW_CERYDRA', 'DISTRICT_TALANTON', 'TALANTON'),
-- 长夜月 长梦宸扉 岁月
('LEADER_NW_EVERNIGHT', 'DISTRICT_ORONYX', 'ORONYX'),
-- 丹恒•腾荒 万壑岩心 大地
('LEADER_NW_DANHENGPT', 'DISTRICT_GEORIOS', 'GEORIOS');

--============================================================
-- Lua Support
--============================================================
CREATE TABLE IF NOT EXISTS Nwflower_MOD_Traits
(
    TraitType TEXT NOT NULL,
    PRIMARY KEY (TraitType),
    FOREIGN KEY (TraitType) REFERENCES Traits (TraitType) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT OR IGNORE INTO Nwflower_MOD_Traits(TraitType)
VALUES ('TRAIT_CIVILIZATION_NW_AMPHOREUS');

INSERT OR IGNORE INTO Nwflower_MOD_Traits(TraitType)
SELECT 'TRAIT_' || LeaderType || '_' || TraitType
FROM NW_Amphoreus_Traits;

INSERT OR IGNORE INTO TraitModifiers(TraitType, ModifierId)
SELECT TraitType,
       'MODFEAT_TRAIT_PROPERTY_' || TraitType
FROM Nwflower_MOD_Traits;

INSERT OR IGNORE INTO Modifiers(ModifierId, ModifierType)
SELECT 'MODFEAT_TRAIT_PROPERTY_' || TraitType,
       'MODIFIER_PLAYER_ADJUST_PROPERTY'
FROM Nwflower_MOD_Traits;

INSERT OR IGNORE INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODFEAT_TRAIT_PROPERTY_' || TraitType,
       'Key',
       'PROPERTY_' || TraitType
FROM Nwflower_MOD_Traits
UNION
SELECT 'MODFEAT_TRAIT_PROPERTY_' || TraitType,
       'Amount',
       1
FROM Nwflower_MOD_Traits;
--================
-- DynamicModifier
--================

CREATE TEMPORARY TABLE temp_APPEAL_numbers
(
    number INT NOT NULL,
    PRIMARY KEY (number)
);
INSERT INTO temp_APPEAL_numbers (number)
WITH x AS
         (SELECT 1 AS id
          UNION ALL
          SELECT id + 1 AS id
          FROM x
          WHERE id < 30)
SELECT *
FROM x;

-- 城市拥有任意自然奇观
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('REQS_NW_CITY_HAS_ANY_NATURAL_WONDER', 'REQUIREMENTSET_TEST_ANY');
INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'REQS_NW_CITY_HAS_ANY_NATURAL_WONDER', 'REQUIRES_NW_CITY_HAS_' || FeatureType
FROM Features
WHERE NaturalWonder = 1;
INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQUIRES_NW_CITY_HAS_' || FeatureType, 'FeatureType', FeatureType
FROM Features;
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'REQUIRES_NW_CITY_HAS_' || FeatureType, 'REQUIREMENT_CITY_HAS_FEATURE'
FROM Features;

-- 单元格拥有指定地貌
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'REQS_NW_PLOT_HAS_' || FeatureType,
       'REQUIREMENTSET_TEST_ALL'
FROM Features;
INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'REQS_NW_PLOT_HAS_' || FeatureType, 'REQUIRES_NW_PLOT_HAS_' || FeatureType
FROM Features;
INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQUIRES_NW_PLOT_HAS_' || FeatureType, 'FeatureType', FeatureType
FROM Features;
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'REQUIRES_NW_PLOT_HAS_' || FeatureType, 'REQUIREMENT_PLOT_FEATURE_TYPE_MATCHES'
FROM Features;

-- 单元格魅力值至少为
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'REQS_NW_PLOT_HAS_APPEAL_' || number,
       'REQUIREMENTSET_TEST_ALL'
FROM temp_APPEAL_numbers;
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'REQS_NW_PLOT_HAS_APPEAL_' || number,
       'REQ_NW_PLOT_HAS_APPEAL_' || number
FROM temp_APPEAL_numbers;
INSERT INTO Requirements (RequirementId, RequirementType)
SELECT 'REQ_NW_PLOT_HAS_APPEAL_' || number,
       'REQUIREMENT_PLOT_IS_APPEAL_BETWEEN'
FROM temp_APPEAL_numbers;
INSERT INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQ_NW_PLOT_HAS_APPEAL_' || number,
       'MinimumAppeal',
       number
FROM temp_APPEAL_numbers;

-- 单位类型匹配
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'NW_UNIT_IS_' || UnitType,
       'REQUIREMENTSET_TEST_ALL'
FROM Units;
INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'NW_UNIT_IS_' || UnitType,
       'REQ_NW_UNIT_IS_' || UnitType
FROM Units;
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'REQ_NW_UNIT_IS_' || UnitType,
       'REQUIREMENT_UNIT_TYPE_MATCHES'
FROM Units;
INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQ_NW_UNIT_IS_' || UnitType,
       'UnitType',
       UnitType
FROM Units;

-- 城市拥有某建筑
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'NW_CITY_HAS_' || BuildingType,
       'REQUIREMENTSET_TEST_ALL'
FROM Buildings;
INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'NW_CITY_HAS_' || BuildingType,
       'REQ_NW_CITY_HAS_' || BuildingType
FROM Buildings;
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'REQ_NW_CITY_HAS_' || BuildingType,
       'REQUIREMENT_CITY_HAS_BUILDING'
FROM Buildings;
INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQ_NW_CITY_HAS_' || BuildingType,
       'BuildingType',
       BuildingType
FROM Buildings;


-- 条件集：区域是任意专业化区域
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('NW_IS_SPECIALTY_DISTRICT', 'REQUIREMENTSET_TEST_ANY');
INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'NW_IS_SPECIALTY_DISTRICT', 'NW_DISTRICT_IS_' || DistrictType || '_REQUIREMENT'
FROM Districts
WHERE RequiresPopulation = 1;

-- 条件集：区域类型匹配
INSERT OR IGNORE INTO RequirementSets(RequirementSetId, RequirementSetType)
SELECT 'NW_DISTRICT_IS_' || DistrictType, 'REQUIREMENTSET_TEST_ALL'
FROM Districts;
INSERT OR IGNORE INTO RequirementSetRequirements(RequirementSetId, RequirementId)
SELECT 'NW_DISTRICT_IS_' || DistrictType, 'NW_DISTRICT_IS_' || DistrictType || '_REQUIREMENT'
FROM Districts;
INSERT OR IGNORE INTO Requirements(RequirementId, RequirementType)
SELECT 'NW_DISTRICT_IS_' || DistrictType || '_REQUIREMENT', 'REQUIREMENT_DISTRICT_TYPE_MATCHES'
FROM Districts;
INSERT OR IGNORE INTO RequirementArguments(RequirementId, Name, Value)
SELECT 'NW_DISTRICT_IS_' || DistrictType || '_REQUIREMENT', 'DistrictType', DistrictType
FROM Districts;


-- 玩家是否有某科技
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'NW_PLAYER_HAS_TECHNOLOGY_' || TechnologyType,
       'REQUIREMENTSET_TEST_ALL'
FROM Technologies;

INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'NW_PLAYER_HAS_TECHNOLOGY_' || TechnologyType,
       'REQ_NW_PLAYER_HAS_TECHNOLOGY_' || TechnologyType
FROM Technologies;
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'REQ_NW_PLAYER_HAS_TECHNOLOGY_' || TechnologyType,
       'REQUIREMENT_PLAYER_HAS_TECHNOLOGY'
FROM Technologies;
INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQ_NW_PLAYER_HAS_TECHNOLOGY_' || TechnologyType,
       'TechnologyType',
       TechnologyType
FROM Technologies;

-- 条件集：城市拥有某区域
INSERT OR IGNORE INTO RequirementSets(RequirementSetId, RequirementSetType)
SELECT 'NW_CITY_HAS_' || DistrictType, 'REQUIREMENTSET_TEST_ALL'
FROM Districts;
INSERT OR IGNORE INTO RequirementSetRequirements(RequirementSetId, RequirementId)
SELECT 'NW_CITY_HAS_' || DistrictType, 'NW_CITY_HAS_' || DistrictType || '_REQUIREMENT'
FROM Districts;
INSERT OR IGNORE INTO Requirements(RequirementId, RequirementType)
SELECT 'NW_CITY_HAS_' || DistrictType || '_REQUIREMENT', 'REQUIREMENT_CITY_HAS_DISTRICT'
FROM Districts;
INSERT OR IGNORE INTO RequirementArguments(RequirementId, Name, Value)
SELECT 'NW_CITY_HAS_' || DistrictType || '_REQUIREMENT', 'DistrictType', DistrictType
FROM Districts;

-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'REQS_NW_OWNER_' || number || '_PLOTS_AWAY',
       'REQUIREMENTSET_TEST_ALL'
FROM temp_APPEAL_numbers
WHERE number <= 10;
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'REQS_NW_OWNER_' || number || '_PLOTS_AWAY',
       'REQ_NW_OWNER_' || number || '_PLOTS_AWAY'
FROM temp_APPEAL_numbers
WHERE number <= 10;
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType)
SELECT 'REQ_NW_OWNER_' || number || '_PLOTS_AWAY',
       'REQUIREMENT_PLOT_ADJACENT_TO_OWNER'
FROM temp_APPEAL_numbers
WHERE number <= 10;
INSERT INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQ_NW_OWNER_' || number || '_PLOTS_AWAY',
       'MaxDistance',
       number
FROM temp_APPEAL_numbers
WHERE number <= 10
UNION
SELECT 'REQ_NW_OWNER_' || number || '_PLOTS_AWAY',
       'MinDistance',
       number
FROM temp_APPEAL_numbers
WHERE number <= 10;

--================
-- Buildings
--================
-- REMEMBRANCE
-- 圣地的信仰值相邻加成也提供文化。解锁飞行后，提供等量旅游业绩。
INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_REMEMBRANCE', 'MODIFIER_BUILDING_NW_REMEMBRANCE_DISTRICT_HOLY_SITE_GRANT_CULTURE');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_BUILDING_NW_REMEMBRANCE_DISTRICT_HOLY_SITE_GRANT_CULTURE',
        'MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS');
INSERT INTO ModifierArguments
    (ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_REMEMBRANCE_DISTRICT_HOLY_SITE_GRANT_CULTURE', 'YieldTypeToGrant', 'YIELD_CULTURE'),
       ('MODIFIER_BUILDING_NW_REMEMBRANCE_DISTRICT_HOLY_SITE_GRANT_CULTURE', 'YieldTypeToMirror', 'YIELD_FAITH');

INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_REMEMBRANCE', 'MODIFIER_BUILDING_NW_REMEMBRANCE_DISTRICT_FAITH_TO_SCIENCE');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_BUILDING_NW_REMEMBRANCE_DISTRICT_FAITH_TO_SCIENCE',
        'MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS');
INSERT INTO ModifierArguments
    (ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_REMEMBRANCE_DISTRICT_FAITH_TO_SCIENCE', 'YieldTypeToGrant', 'YIELD_SCIENCE'),
       ('MODIFIER_BUILDING_NW_REMEMBRANCE_DISTRICT_FAITH_TO_SCIENCE', 'YieldTypeToMirror', 'YIELD_FAITH');

INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS', 'COLLECTION_PLAYER_DISTRICTS',
        'EFFECT_ADJUST_DISTRICT_YIELD_BASED_ON_ADJACENCY_BONUS');


INSERT INTO BuildingModifiers (BuildingType, ModifierId)
VALUES ('BUILDING_NW_REMEMBRANCE', 'MODIFIER_BUILDING_NW_REMEMBRANCE_GIVE_DISTRICT_TOURISM');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_BUILDING_NW_REMEMBRANCE_GIVE_DISTRICT_TOURISM',
        'MODIFIER_NW_PLAYER_DISTRICT_ADJUST_TOURISM_ADJACENCY_YIELD_MOFIFIER', 0, 0, 0,
        'NW_PLAYER_HAS_TECHNOLOGY_TECH_FLIGHT', 'NW_DISTRICT_IS_DISTRICT_HOLY_SITE');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_REMEMBRANCE_GIVE_DISTRICT_TOURISM', 'Amount', 100),
       ('MODIFIER_BUILDING_NW_REMEMBRANCE_GIVE_DISTRICT_TOURISM', 'YieldType', 'YIELD_FAITH');
-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_PLAYER_DISTRICT_ADJUST_TOURISM_ADJACENCY_YIELD_MOFIFIER', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_PLAYER_DISTRICT_ADJUST_TOURISM_ADJACENCY_YIELD_MOFIFIER', 'COLLECTION_PLAYER_DISTRICTS',
        'EFFECT_ADJUST_DISTRICT_TOURISM_ADJACENCY_YIELD_MOFIFIER');

-- ERUDITION
-- 学院的科技值相邻加成也提供生产力，树庭的文化值相邻加成也提供生产力，学院建筑固定产出的科技值也提供金币
INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_ERUDITION', 'MODIFIER_BUILDING_NW_ERUDITION_DISTRICT_CAMPUS_GRANT_PRODUCTION');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_BUILDING_NW_ERUDITION_DISTRICT_CAMPUS_GRANT_PRODUCTION',
        'MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_ERUDITION_DISTRICT_CAMPUS_GRANT_PRODUCTION', 'YieldTypeToGrant', 'YIELD_PRODUCTION'),
       ('MODIFIER_BUILDING_NW_ERUDITION_DISTRICT_CAMPUS_GRANT_PRODUCTION', 'YieldTypeToMirror', 'YIELD_SCIENCE');
INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_ERUDITION', 'MODIFIER_BUILDING_NW_ERUDITION_DISTRICT_CERCES_GRANT_PRODUCTION');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_BUILDING_NW_ERUDITION_DISTRICT_CERCES_GRANT_PRODUCTION',
        'MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_ERUDITION_DISTRICT_CERCES_GRANT_PRODUCTION', 'YieldTypeToGrant', 'YIELD_PRODUCTION'),
       ('MODIFIER_BUILDING_NW_ERUDITION_DISTRICT_CERCES_GRANT_PRODUCTION', 'YieldTypeToMirror', 'YIELD_CULTURE');
INSERT INTO BuildingModifiers(BuildingType, ModifierId)
SELECT 'BUILDING_NW_ERUDITION',
       'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD'
FROM Building_YieldChanges
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS');
INSERT INTO Modifiers(ModifierId, ModifierType)
SELECT 'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD',
       'MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_YIELD_CHANGE'
FROM Building_YieldChanges
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD',
       'BuildingType',
       BuildingType
FROM Building_YieldChanges
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS')
UNION
SELECT 'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD',
       'YieldType',
       'YIELD_GOLD'
FROM Building_YieldChanges
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS')
UNION
SELECT 'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD',
       'Amount',
       YieldChange
FROM Building_YieldChanges
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS');
INSERT INTO BuildingModifiers(BuildingType, ModifierId)
SELECT 'BUILDING_NW_ERUDITION',
       'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD_IF_POWERED'
FROM Building_YieldChangesBonusWithPower
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS');

INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD_IF_POWERED',
       'MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_YIELD_CHANGE',
       'CITY_IS_POWERED'
FROM Building_YieldChangesBonusWithPower
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD_IF_POWERED',
       'BuildingType',
       BuildingType
FROM Building_YieldChangesBonusWithPower
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS')
UNION
SELECT 'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD_IF_POWERED',
       'YieldType',
       'YIELD_GOLD'
FROM Building_YieldChangesBonusWithPower
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS')
UNION
SELECT 'MODIFIER_BUILDING_NW_ERUDITION_GIVE_' || BuildingType || 'FORM_' || YieldType || '_GOLD_IF_POWERED',
       'Amount',
       YieldChange
FROM Building_YieldChangesBonusWithPower
WHERE BuildingType IN (SELECT BuildingType FROM Buildings where PrereqDistrict = 'DISTRICT_CAMPUS');

-- DESTRUCTION
-- 生产力相邻翻倍、转金币
INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_DESTRUCTION', 'MODIFIER_BUILDING_NW_DESTRUCTION_DOUBLE_PRODUCTION');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_DOUBLE_PRODUCTION',
        'MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_DOUBLE_PRODUCTION', 'YieldTypeToGrant', 'YIELD_PRODUCTION'),
       ('MODIFIER_BUILDING_NW_DESTRUCTION_DOUBLE_PRODUCTION', 'YieldTypeToMirror', 'YIELD_PRODUCTION');

INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_DESTRUCTION', 'MODIFIER_BUILDING_NW_DESTRUCTION_PRODUCTION_TO_GOLD');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_PRODUCTION_TO_GOLD',
        'MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_PRODUCTION_TO_GOLD', 'YieldTypeToGrant', 'YIELD_GOLD'),
       ('MODIFIER_BUILDING_NW_DESTRUCTION_PRODUCTION_TO_GOLD', 'YieldTypeToMirror', 'YIELD_PRODUCTION');

-- 金币相邻翻倍、转生产力
INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_DESTRUCTION', 'MODIFIER_BUILDING_NW_DESTRUCTION_DOUBLE_GOLD');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_DOUBLE_GOLD',
        'MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_DOUBLE_GOLD', 'YieldTypeToGrant', 'YIELD_GOLD'),
       ('MODIFIER_BUILDING_NW_DESTRUCTION_DOUBLE_GOLD', 'YieldTypeToMirror', 'YIELD_GOLD');

INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_DESTRUCTION', 'MODIFIER_BUILDING_NW_DESTRUCTION_GOLD_TO_PRODUCTION');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_GOLD_TO_PRODUCTION',
        'MODIFIER_NW_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_ADJACENCY_BONUS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_GOLD_TO_PRODUCTION', 'YieldTypeToGrant', 'YIELD_PRODUCTION'),
       ('MODIFIER_BUILDING_NW_DESTRUCTION_GOLD_TO_PRODUCTION', 'YieldTypeToMirror', 'YIELD_GOLD');


-- 送大将军
INSERT INTO BuildingModifiers(BuildingType, ModifierId)
VALUES ('BUILDING_NW_DESTRUCTION', 'MODIFIER_BUILDING_NW_DESTRUCTION_GIVE_ROUTE_YIELD_GOLD_1');
INSERT INTO Modifiers(ModifierId, ModifierType, RunOnce, Permanent)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_GIVE_ROUTE_YIELD_GOLD_1',
        'MODIFIER_SINGLE_CITY_GRANT_GREAT_PERSON_CLASS_IN_CITY',
        1, 1);
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_DESTRUCTION_GIVE_ROUTE_YIELD_GOLD_1', 'GreatPersonClassType',
        'GREAT_PERSON_CLASS_GENERAL'),
       ('MODIFIER_BUILDING_NW_DESTRUCTION_GIVE_ROUTE_YIELD_GOLD_1', 'Amount', 1);

--================
-- Civ Modifiers
-- 12全产/黄金时代再给12全产
-- 黄金时代使用游戏自带的REQ
--================
INSERT INTO BuildingModifiers(ModifierId, BuildingType)
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_YIELD_MODIFIER_' || Yields.YieldType,
       'BUILDING_NW_DESTRUCTION'
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_YIELD_MODIFIER_' || Yields.YieldType,
       'BUILDING_NW_REMEMBRANCE'
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_YIELD_MODIFIER_' || Yields.YieldType,
       'BUILDING_NW_ERUDITION'
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_GOLDAGE_YIELD_MODIFIER_' || Yields.YieldType,
       'BUILDING_NW_DESTRUCTION'
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_GOLDAGE_YIELD_MODIFIER_' || Yields.YieldType,
       'BUILDING_NW_REMEMBRANCE'
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_GOLDAGE_YIELD_MODIFIER_' || Yields.YieldType,
       'BUILDING_NW_ERUDITION'
FROM Yields;

INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId)
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_YIELD_MODIFIER_' || Yields.YieldType,
       'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER',
       NULL
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_GOLDAGE_YIELD_MODIFIER_' || Yields.YieldType,
       'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER',
       'PLAYER_HAS_GOLDEN_AGE'
FROM Yields;

INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_YIELD_MODIFIER_' || Yields.YieldType,
       'YieldType',
       Yields.YieldType
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_YIELD_MODIFIER_' || Yields.YieldType,
       'Amount',
       12
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_GOLDAGE_YIELD_MODIFIER_' || Yields.YieldType,
       'YieldType',
       Yields.YieldType
FROM Yields
UNION
SELECT 'MODIFIER_NW_AMPHOREUS_CITY_GOLDAGE_YIELD_MODIFIER_' || Yields.YieldType,
       'Amount',
       12
FROM Yields;


--================
-- TIBAO
--================
-- 单位可在城市之间传送。（LUA）
-- 解锁特色项目“逐火之旅”。
INSERT INTO Types(Type, Kind)
VALUES ('PROJECT_TRIBIOS_JOURNEY', 'KIND_PROJECT');
INSERT INTO Projects(ProjectType, Name, Description, ShortName, Cost, CostProgressionModel, CostProgressionParam1,
                     PrereqDistrict, AdvisorType)
VALUES ('PROJECT_TRIBIOS_JOURNEY', 'LOC_PROJECT_TRIBIOS_JOURNEY_NAME', 'LOC_PROJECT_TRIBIOS_JOURNEY_DESCRIPTION',
        'LOC_PROJECT_TRIBIOS_JOURNEY_NAME', 25, 'COST_PROGRESSION_GAME_PROGRESS', 1500, 'DISTRICT_JANUS',
        'ADVISOR_GENERIC');

-- 项目属性
INSERT INTO Projects_XP2(ProjectType, ReligiousPressureModifier)
VALUES ('PROJECT_TRIBIOS_JOURNEY', 2400);
INSERT INTO Project_GreatPersonPoints(ProjectType, GreatPersonClassType, Points, PointProgressionModel,
                                      PointProgressionParam1)
SELECT 'PROJECT_TRIBIOS_JOURNEY', GreatPersonClassType, Points * 4, PointProgressionModel, PointProgressionParam1
FROM Project_GreatPersonPoints
WHERE ProjectType = 'PROJECT_ENHANCE_DISTRICT_HOLY_SITE';
INSERT INTO Project_YieldConversions (ProjectType, YieldType, PercentOfProductionRate)
SELECT 'PROJECT_TRIBIOS_JOURNEY', YieldType, PercentOfProductionRate * 4
FROM Project_YieldConversions
WHERE ProjectType = 'PROJECT_ENHANCE_DISTRICT_HOLY_SITE';

-- 完成项目后，本城对外输出压力提高100%
INSERT INTO ProjectCompletionModifiers (ProjectType, ModifierId)
VALUES ('PROJECT_TRIBIOS_JOURNEY', 'MODIFIER_PROJECT_TRIBIOS_JOURNEY_RELIGION_PRESSURE');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_PROJECT_TRIBIOS_JOURNEY_RELIGION_PRESSURE', 'MODIFIER_SINGLE_CITY_RELIGION_PRESSURE', 0, 1, 0, NULL,
        NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_PROJECT_TRIBIOS_JOURNEY_RELIGION_PRESSURE', 'Amount', '100');
-- 所有刻法勒广场+25% [ICON_Faith] 信仰值相邻加成
INSERT INTO ProjectCompletionModifiers (ProjectType, ModifierId)
VALUES ('PROJECT_TRIBIOS_JOURNEY', 'MODIFIER_PROJECT_TRIBIOS_JOURNEY_ADJACENT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_PROJECT_TRIBIOS_JOURNEY_ADJACENT', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_MODIFIER', 0, 1, 0, NULL,
        'NW_DISTRICT_IS_DISTRICT_JANUS');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_PROJECT_TRIBIOS_JOURNEY_ADJACENT', 'Amount', '25'),
       ('MODIFIER_PROJECT_TRIBIOS_JOURNEY_ADJACENT', 'YieldType', 'YIELD_FAITH');

-- 并提供1名黄金裔
INSERT INTO ProjectCompletionModifiers (ProjectType, ModifierId)
VALUES ('PROJECT_TRIBIOS_JOURNEY', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT');


--================
-- WANDI
-- 当解锁陆地军事单位的科技完成后，所有城市免费获得一个该单位。
-- 拥有驻军的城市永久忠诚，忠诚的城市 [ICON_Amenities] 宜居度+2， [ICON_Production] 生产力+30%。
-- 所有陆地单位+2移动力，且能对城市输出全额伤害。
--================
-- 当解锁陆地军事单位的科技完成后，所有城市免费获得一个该单位
-- 必须是单位，定义了前置科技且不为特色单位
INSERT INTO TraitModifiers(ModifierId, TraitType)
SELECT 'MODIFIER_WANDI_GRANT_' || Units.UnitType || '_IN_ALL_CITY',
       'TRAIT_LEADER_NW_MYDEI_NIKADOR'
FROM Units
WHERE PrereqTech IS NOT NULL
  AND Domain = 'DOMAIN_LAND'
  AND TraitType IS NULL;
INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId, RunOnce, Permanent)
SELECT 'MODIFIER_WANDI_GRANT_' || Units.UnitType || '_IN_ALL_CITY',
       'MODIFIER_NW_AMPHOREUS_PLAYER_CITIES_GRANT_UNIT_IN_CAPITAL',
       'NW_PLAYER_HAS_TECHNOLOGY_' || Units.PrereqTech,
       1,
       1
FROM Units
WHERE PrereqTech IS NOT NULL
  AND Domain = 'DOMAIN_LAND'
  AND TraitType IS NULL;
INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_WANDI_GRANT_' || UnitType || '_IN_ALL_CITY',
       n.Name,
       CASE n.Name
           WHEN 'UnitType' THEN UnitType
           WHEN 'Amount' THEN 1
           WHEN 'AllowUniqueOverride' THEN 0
           END AS Value
FROM Units
         CROSS JOIN (SELECT 'UnitType' AS Name
                     UNION ALL
                     SELECT 'Amount' AS Name
                     UNION ALL
                     SELECT 'AllowUniqueOverride' AS Name) n
WHERE PrereqTech IS NOT NULL
  AND Domain = 'DOMAIN_LAND'
  AND TraitType IS NULL;

-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_CITIES_GRANT_UNIT_IN_CAPITAL', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_CITIES_GRANT_UNIT_IN_CAPITAL', 'COLLECTION_PLAYER_CITIES',
        'EFFECT_GRANT_UNIT_IN_CITY');

-- 拥有驻军的城市永久忠诚
INSERT INTO TraitModifiers(ModifierId, TraitType)
VALUES ('MODIFIER_WANDI_CITY_IS_LOYAL_IF_HAS_UNIT', 'TRAIT_LEADER_NW_MYDEI_NIKADOR');
INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('MODIFIER_WANDI_CITY_IS_LOYAL_IF_HAS_UNIT', 'MODIFIER_PLAYER_CITIES_ADJUST_ALWAYS_LOYAL',
        'CITY_HAS_GARRISON_UNIT_REQUIERMENT');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_WANDI_CITY_IS_LOYAL_IF_HAS_UNIT', 'AlwaysLoyal', 1);

-- 忠诚的城市+2宜居度，+30%生产力
INSERT INTO TraitModifiers(TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_MYDEI_NIKADOR', 'MODIFIER_WANDI_CITY_GET_EXTRA_ENTERTAINMENT_IF_LOYAL'),
       ('TRAIT_LEADER_NW_MYDEI_NIKADOR', 'MODIFIER_WANDI_CITY_GET_EXTRA_PRODUCTION_IF_LOYAL');
INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('MODIFIER_WANDI_CITY_GET_EXTRA_ENTERTAINMENT_IF_LOYAL', 'MODIFIER_PLAYER_CITIES_ADJUST_TRAIT_AMENITY',
        'MONUMENT_FULL_LOYALTY_REQUIREMENTS'),
       ('MODIFIER_WANDI_CITY_GET_EXTRA_PRODUCTION_IF_LOYAL', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_YIELD_MODIFIER',
        'MONUMENT_FULL_LOYALTY_REQUIREMENTS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_WANDI_CITY_GET_EXTRA_ENTERTAINMENT_IF_LOYAL', 'Amount', 2),
       ('MODIFIER_WANDI_CITY_GET_EXTRA_PRODUCTION_IF_LOYAL', 'YieldType', 'YIELD_PRODUCTION'),
       ('MODIFIER_WANDI_CITY_GET_EXTRA_PRODUCTION_IF_LOYAL', 'Amount', 30);

-- 所有陆地单位+2 [ICON_MOVEMENT] 移动力，且能对城市输出全额伤害
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_MYDEI_NIKADOR', 'MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_MOVEMENT');
INSERT INTO Modifiers (ModifierId, ModifierType) VALUES
('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_MOVEMENT', 'MODIFIER_PLAYER_UNITS_ADJUST_MOVEMENT');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_MOVEMENT', 'Amount', '2');


INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_MYDEI_NIKADOR', 'MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_ENABLE_WALL_ATTACK');
INSERT INTO Modifiers (ModifierId, ModifierType)
VALUES ('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_ENABLE_WALL_ATTACK',
        'MODIFIER_NW_AMPHOREUS_PLAYER_UNITS_ADJUST_ENABLE_WALL_ATTACK');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_ENABLE_WALL_ATTACK', 'Enable', '1');
-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_UNITS_ADJUST_ENABLE_WALL_ATTACK', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_UNITS_ADJUST_ENABLE_WALL_ATTACK', 'COLLECTION_PLAYER_UNITS',
        'EFFECT_ADJUST_UNIT_ENABLE_WALL_ATTACK');

-- 单位从大将军处获得的增幅效果提高900%。
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_MYDEI_NIKADOR', 'MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_EXTRA_MOVEMENT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_EXTRA_MOVEMENT', 'MODIFIER_PLAYER_UNITS_ADJUST_MOVEMENT', 0, 0, 0, NULL, 'REQS_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_MOVEMENT');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_EXTRA_MOVEMENT', 'Amount', '9');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('REQS_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_MOVEMENT', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('REQS_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_MOVEMENT', 'REQ_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_MOVEMENT');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType) VALUES
('REQ_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_MOVEMENT', 'REQUIREMENT_UNIT_HAS_ABILITY');
INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES
('REQ_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_MOVEMENT', 'UnitAbilityType', 'ABILITY_GREAT_GENERAL_MOVEMENT');

INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_MYDEI_NIKADOR', 'MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_EXTRA_COMBAT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_EXTRA_COMBAT', 'MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH', 0, 0, 0, NULL, 'REQS_NW_ABILITY_GREAT_GENERAL_STRENGTH');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_EXTRA_COMBAT', 'Amount', '45');
INSERT INTO ModifierStrings (ModifierId, Context, Text) VALUES
('MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_EXTRA_COMBAT', 'Preview', 'LOC_MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_EXTRA_COMBAT');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('REQS_NW_ABILITY_GREAT_GENERAL_STRENGTH', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('REQS_NW_ABILITY_GREAT_GENERAL_STRENGTH', 'REQ_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_STRENGTH');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType) VALUES
('REQ_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_STRENGTH', 'REQUIREMENT_UNIT_HAS_ABILITY');
INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES
('REQ_NW_UNIT_HAS_ABILITY_GREAT_GENERAL_STRENGTH', 'UnitAbilityType', 'ABILITY_GREAT_GENERAL_STRENGTH');


--================
-- AGELAIYA
-- 已拥有的单元格不降低相邻单元格魅力，区域+2[ICON_Housing] 住房、+1 [ICON_Amenities] 宜居度，并获得等于单元格魅力值的相邻加成。
--================
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_AGLAEA_MNESTIA', 'MODIFIER_TRAIT_LEADER_NW_AGLAEA_MNESTIA_DISTRICTS_ADJUST_HOUSING');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_AGLAEA_MNESTIA_DISTRICTS_ADJUST_HOUSING', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_HOUSING',
        0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_AGLAEA_MNESTIA_DISTRICTS_ADJUST_HOUSING', 'Amount', '2');

INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_AGLAEA_MNESTIA', 'MODIFIER_TRAIT_LEADER_NW_AGLAEA_MNESTIA_DISTRICTS_ADJUST_AMENITY');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_AGLAEA_MNESTIA_DISTRICTS_ADJUST_AMENITY',
        'MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ADJUST_DISTRICT_AMENITY', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_AGLAEA_MNESTIA_DISTRICTS_ADJUST_AMENITY', 'Amount', '1');
-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ADJUST_DISTRICT_AMENITY', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ADJUST_DISTRICT_AMENITY', 'COLLECTION_PLAYER_DISTRICTS',
        'EFFECT_ADJUST_DISTRICT_AMENITY');

--已拥有的单元格不降低相邻单元格魅力
INSERT INTO TraitModifiers(ModifierId, TraitType)
SELECT 'MODIFIER_NW_' || FeatureType || '_ADD_APPEAL', 'TRAIT_LEADER_NW_AGLAEA_MNESTIA'
FROM Features
WHERE Appeal <= 0;
INSERT INTO Modifiers(ModifierId, ModifierType)
SELECT 'MODIFIER_NW_' || FeatureType || '_ADD_APPEAL', 'MODIFIER_PLAYER_CITIES_ADJUST_FEATURE_APPEAL_MODIFIER'
FROM Features
WHERE Appeal <= 0;
INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_NW_' || FeatureType || '_ADD_APPEAL', 'FeatureType', FeatureType
FROM Features
WHERE Appeal <= 0
UNION
SELECT 'MODIFIER_NW_' || FeatureType || '_ADD_APPEAL', 'Amount', 1 - Appeal
FROM Features
WHERE Appeal <= 0;

-- 所有专业化区域额外获得等同于单元格魅力的产出
-- 圣学剧商工
CREATE TEMPORARY TABLE IF NOT EXISTS NW_TEMP_DISTRICT_YIELD
(
    DistrictType TEXT,
    YieldType    TEXT,
    PRIMARY KEY (DistrictType)
);
INSERT OR IGNORE INTO NW_TEMP_DISTRICT_YIELD
VALUES ('DISTRICT_CAMPUS', 'YIELD_SCIENCE'),
       ('DISTRICT_HOLY_SITE', 'YIELD_FAITH'),
       ('DISTRICT_COMMERCIAL_HUB', 'YIELD_GOLD'),
       ('DISTRICT_HARBOR', 'YIELD_GOLD'),
       ('DISTRICT_THEATER', 'YIELD_CULTURE'),
       ('DISTRICT_INDUSTRIAL_ZONE', 'YIELD_PRODUCTION');


INSERT INTO TraitModifiers(ModifierId, TraitType)
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'TRAIT_LEADER_NW_AGLAEA_MNESTIA'
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers;

INSERT INTO Modifiers(ModifierId, ModifierType)
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_APPEAL'
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers;
INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'YieldType',
       YieldType
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
UNION
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'YieldChange',
       1
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
UNION
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'DistrictType',
       DistrictType
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
UNION
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'RequiredAppeal',
       number
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
UNION
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'Description',
       'LOC_Adjacency_DISTRICT_AGELAIYA_APPEAL_' || YieldType
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers;

--================
-- NAKEXIA
-- 建造者+1使用次数。
-- 专业化区域小于三个的城市，建造区域时+1800% [ICON_Production] 生产力。
-- 解锁建造者栽种原始森林的能力，但在市政「土木工程」前，移除地貌的收益-35%。
--================
-- 拥有专业化区域少于三个的城市，建造区域所需的时间大幅缩短。
INSERT INTO TraitModifiers(ModifierId, TraitType)
VALUES ('MODIFIER_NAKEXIA_DISTRICTS_PRODUCTION', 'TRAIT_LEADER_NW_ANAXA_CERCES');-- 灌溉
INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('MODIFIER_NAKEXIA_DISTRICTS_PRODUCTION', 'MODIFIER_PLAYER_CITIES_ADJUST_ALL_DISTRICTS_PRODUCTION',
        'REQSET_CITY_HAS_NOT_3_SPECIALTY_DISTRICTS');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_NAKEXIA_DISTRICTS_PRODUCTION', 'Amount', 1800);

INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('REQSET_CITY_HAS_NOT_3_SPECIALTY_DISTRICTS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('REQSET_CITY_HAS_NOT_3_SPECIALTY_DISTRICTS', 'REQ_CITY_HAS_NOT_3_SPECIALTY_DISTRICTS');
INSERT INTO Requirements (RequirementId, RequirementType, Inverse)
VALUES ('REQ_CITY_HAS_NOT_3_SPECIALTY_DISTRICTS', 'REQUIREMENT_CITY_HAS_X_SPECIALTY_DISTRICTS', 1);
INSERT INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQ_CITY_HAS_NOT_3_SPECIALTY_DISTRICTS', 'Amount', 3);

-- 建造者+1敲，可栽种天然林
INSERT INTO TraitModifiers(TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_ANAXA_CERCES', 'MODIFIER_NAKEXIA_IMPROVEMENTGRANT'),
       ('TRAIT_LEADER_NW_ANAXA_CERCES', 'TRAIT_ADJUST_BUILDER_CHARGES');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_NAKEXIA_IMPROVEMENTGRANT', 'MODIFIER_PLAYER_ADJUST_VALID_IMPROVEMENT');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_NAKEXIA_IMPROVEMENTGRANT', 'ImprovementType', 'IMPROVEMENT_NAKEXIA_FOREST');

-- 移除地貌的收益-35
INSERT INTO TraitModifiers(ModifierId, TraitType)
VALUES ('MODIFIER_NAKEXIA_TRI_RESOURCE_HARVEST_ATTACH', 'TRAIT_LEADER_NW_ANAXA_CERCES');
INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId)
VALUES ('MODIFIER_NAKEXIA_TRI_RESOURCE_HARVEST_ATTACH', 'MODIFIER_PLAYER_CITIES_ATTACH_MODIFIER',
        'NW_PLAYER_HAS_NOT_CIVIC_TUMU'),
       ('MODIFIER_NAKEXIA_TRI_RESOURCE_HARVEST', 'MODIFIER_CITY_ADJUST_RESOURCE_HARVEST_BONUS', NULL);
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_NAKEXIA_TRI_RESOURCE_HARVEST_ATTACH', 'ModifierId', 'MODIFIER_NAKEXIA_TRI_RESOURCE_HARVEST'),
       ('MODIFIER_NAKEXIA_TRI_RESOURCE_HARVEST', 'Amount', -35);
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('NW_PLAYER_HAS_NOT_CIVIC_TUMU', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('NW_PLAYER_HAS_NOT_CIVIC_TUMU', 'REQNW_PLAYER_HAS_NOT_CIVIC_TUMU');
INSERT INTO Requirements (RequirementId, RequirementType,Inverse)
VALUES ('REQNW_PLAYER_HAS_NOT_CIVIC_TUMU', 'REQUIREMENT_PLAYER_HAS_CIVIC', 1);
INSERT INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQNW_PLAYER_HAS_NOT_CIVIC_TUMU', 'CivicType', 'CIVIC_CIVIL_ENGINEERING');

--================
-- TRAIT_LEADER_NW_CASTORICE_THANATOS
--================
-- 文物产出的 [ICON_Culture] 文化值也提供 [ICON_Science] 科技值和 [ICON_Gold] 金币。
INSERT INTO TraitModifiers (TraitType, ModifierId) SELECT
'TRAIT_LEADER_NW_CASTORICE_THANATOS', 'MODFEAT_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_'||YieldType||'_FROM_RELIC'
FROM Yields WHERE YieldType IN ('YIELD_SCIENCE','YIELD_GOLD') ;
INSERT INTO Modifiers (ModifierId, ModifierType) SELECT
'MODFEAT_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_'||YieldType||'_FROM_RELIC', 'MODIFIER_PLAYER_CITIES_ADJUST_GREATWORK_YIELD'
FROM Yields WHERE YieldType IN ('YIELD_SCIENCE','YIELD_GOLD') ;
INSERT INTO ModifierArguments (ModifierId, Name, Value) SELECT
'MODFEAT_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_'||YieldType||'_FROM_RELIC', 'GreatWorkObjectType', 'GREATWORKOBJECT_ARTIFACT'
FROM Yields WHERE YieldType IN ('YIELD_SCIENCE','YIELD_GOLD') UNION SELECT
'MODFEAT_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_'||YieldType||'_FROM_RELIC', 'YieldChange', COALESCE((SELECT MAX(YieldChange) FROM GreatWork_YieldChanges WHERE GreatWorkType LIKE 'GREATWORK_ARTIFACT_%'), 3)
FROM Yields WHERE YieldType IN ('YIELD_SCIENCE','YIELD_GOLD') UNION SELECT
'MODFEAT_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_'||YieldType||'_FROM_RELIC', 'YieldType', YieldType
FROM Yields WHERE YieldType IN ('YIELD_SCIENCE','YIELD_GOLD') ;

-- 单位死亡后，获得等于每回合 [ICON_FAITH] 信仰值收益的 [ICON_Science] 科技值、 [ICON_CULTURE] 文化值和[ICON_Gold] 金币。(LUA)
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_SCIENCE', 'MODIFIER_PLAYER_GRANT_YIELD_BASED_ON_CURRENT_YIELD_RATE', 1, 1);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_SCIENCE', 'Multiplier', '1'),
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_SCIENCE', 'YieldToBaseOn', 'YIELD_FAITH'),
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_SCIENCE', 'YieldToGrant', 'YIELD_SCIENCE');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_CULTURE', 'MODIFIER_PLAYER_GRANT_YIELD_BASED_ON_CURRENT_YIELD_RATE', 1, 1);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_CULTURE', 'Multiplier', '1'),
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_CULTURE', 'YieldToBaseOn', 'YIELD_FAITH'),
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_CULTURE', 'YieldToGrant', 'YIELD_CULTURE');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_GOLD', 'MODIFIER_PLAYER_GRANT_YIELD_BASED_ON_CURRENT_YIELD_RATE', 1, 1);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_GOLD', 'Multiplier', '1'),
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_GOLD', 'YieldToBaseOn', 'YIELD_FAITH'),
('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_GOLD', 'YieldToGrant', 'YIELD_GOLD');


--================
-- TRAIT_LEADER_NW_HYACINTHIA_AQUILA
--================
-- 奇观（即使未建成）释放文化炸弹。
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HYACINTHIA_AQUILA', 'MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_BOMB');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_BOMB', 'MODIFIER_PLAYER_ADD_CULTURE_BOMB_TRIGGER', 0, 0, 0, NULL,
        NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_BOMB', 'DistrictType', 'DISTRICT_WONDER');

-- 每个奇观（即使未建成）为所有城市生产太空竞赛项目时+100% [ICON_Production] 生产力。
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HYACINTHIA_AQUILA', 'MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_PORDUCTION');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_PORDUCTION',
        'MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ATTACH_MODIFIER', 0, 0, 0, NULL,
        'NW_DISTRICT_IS_DISTRICT_WONDER');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_PORDUCTION', 'ModifierId',
        'MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_PORDUCTION_ATTACH');
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ATTACH_MODIFIER', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ATTACH_MODIFIER', 'COLLECTION_PLAYER_DISTRICTS',
        'EFFECT_ATTACH_MODIFIER');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_PORDUCTION_ATTACH',
        'MODIFIER_PLAYER_CITIES_ADJUST_SPACE_RACE_PROJECTS_PRODUCTION', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_PORDUCTION_ATTACH', 'Amount', '100');

-- 于相邻山脉建成学院时获得一个大科学家。
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_HYACINTHIA_AQUILA', 'MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_GRANT_SCIENTIST');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_GRANT_SCIENTIST', 'MODIFIER_NW_AM_PLAYER_DISTRICT_GRANT_GREAT_PERSON_CLASS_IN_CITY', 1, 1, 0, 'NW_DISTRICT_IS_DISTRICT_CAMPUS', 'NW_AM_PLOT_ADJACNET_MOUNTAIN');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_GRANT_SCIENTIST', 'Amount', '1'),
('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_GRANT_SCIENTIST', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_SCIENTIST');
-- Custom ModifierType
INSERT INTO Types (Type, Kind) VALUES
('MODIFIER_NW_AM_PLAYER_DISTRICT_GRANT_GREAT_PERSON_CLASS_IN_CITY', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType) VALUES
('MODIFIER_NW_AM_PLAYER_DISTRICT_GRANT_GREAT_PERSON_CLASS_IN_CITY', 'COLLECTION_PLAYER_DISTRICTS', 'EFFECT_GRANT_GREAT_PERSON_CLASS_IN_CITY');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('NW_AM_PLOT_ADJACNET_MOUNTAIN', 'REQUIREMENTSET_TEST_ANY');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) SELECT
'NW_AM_PLOT_ADJACNET_MOUNTAIN', 'REQ_NW_AM_PLOT_ADJACNET_'||TerrainType
FROM Terrains WHERE Mountain = 1;
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType) SELECT
'REQ_NW_AM_PLOT_ADJACNET_'||TerrainType, 'REQUIREMENT_PLOT_ADJACENT_TERRAIN_TYPE_MATCHES'
FROM Terrains WHERE Mountain = 1;
INSERT INTO RequirementArguments (RequirementId, Name, Value) SELECT
'REQ_NW_AM_PLOT_ADJACNET_'||TerrainType, 'TerrainType', 'TERRAIN_GRASS_MOUNTAIN'
FROM Terrains WHERE Mountain = 1 UNION SELECT
'REQ_NW_AM_PLOT_ADJACNET_'||TerrainType, 'MinRange', '1'
FROM Terrains WHERE Mountain = 1 UNION SELECT
'REQ_NW_AM_PLOT_ADJACNET_'||TerrainType, 'MaxRange', '1'
FROM Terrains WHERE Mountain = 1 ;

-- 所有单位在回合结束时强制回复生命值。
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_HYACINTHIA_AQUILA', 'MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_GRANT_HEAL_AFTER_ACTION');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_GRANT_HEAL_AFTER_ACTION', 'MODIFIER_NW_PLAYER_UNITS_GRANT_HEAL_AFTER_ACTION', 0, 0, 0, NULL, NULL);
-- Custom ModifierType
INSERT INTO Types (Type, Kind) VALUES
('MODIFIER_NW_PLAYER_UNITS_GRANT_HEAL_AFTER_ACTION', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType) VALUES
('MODIFIER_NW_PLAYER_UNITS_GRANT_HEAL_AFTER_ACTION', 'COLLECTION_PLAYER_UNITS', 'EFFECT_GRANT_HEAL_AFTER_ACTION');

--================
-- TRAIT_LEADER_NW_CIFERA_ZAGREUS
-- 回合开始时，不与你处于同一队伍但相邻于你的单位的单位将归顺于你。
--================
INSERT INTO TraitModifiers(TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_CIFERA_ZAGREUS', 'MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_OWNER_UNIT_GRANT_ABILITY');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_OWNER_UNIT_GRANT_ABILITY', 'MODIFIER_PLAYER_UNITS_GRANT_ABILITY');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_OWNER_UNIT_GRANT_ABILITY', 'AbilityType',
        'ABILITY_CIFERA_UNIT_CHANGE_OWNER');


INSERT INTO Types (Type, Kind)
VALUES ('ABILITY_CIFERA_UNIT_CHANGE_OWNER', 'KIND_ABILITY');
INSERT INTO TypeTags (Type, Tag)
VALUES ('ABILITY_CIFERA_UNIT_CHANGE_OWNER', 'CLASS_ALL_UNITS');
INSERT INTO UnitAbilities (UnitAbilityType, Name, Description, Inactive)
VALUES ('ABILITY_CIFERA_UNIT_CHANGE_OWNER',
        'LOC_TRAIT_LEADER_NW_CIFERA_ZAGREUS_NAME',
        'LOC_ABILITY_CIFERA_UNIT_CHANGE_OWNER_DESCRIPTION',
        1);

INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId)
VALUES ('ABILITY_CIFERA_UNIT_CHANGE_OWNER', 'MODIFIER_ABILITY_CIFERA_UNIT_CHANGE_OWNER');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_ABILITY_CIFERA_UNIT_CHANGE_OWNER', 'MODIFIER_PLAYER_UNITS_ADJUST_OWNER', 1, 1, 0, 'ON_TURN_STARTED',
        'REQS_NW_AM_UNIT_IS_NOT_TEAM_AND_ADJACENT');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_ABILITY_CIFERA_UNIT_CHANGE_OWNER', 'NewOwner', 'Player');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('REQS_NW_AM_UNIT_IS_NOT_TEAM_AND_ADJACENT', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('REQS_NW_AM_UNIT_IS_NOT_TEAM_AND_ADJACENT', 'REQ_NW_AM_UNIT_IS_NOT_TEAM'),
       ('REQS_NW_AM_UNIT_IS_NOT_TEAM_AND_ADJACENT', 'REQ_NW_OWNER_1_PLOTS_AWAY');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType, Inverse)
VALUES ('REQ_NW_AM_UNIT_IS_NOT_TEAM', 'REQUIREMENT_PLAYER_IS_TEAM_MEMBER', 1);

-- 新训练的商人提供一个免费的间谍及间谍容量
INSERT INTO TraitModifiers(TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_CIFERA_ZAGREUS', 'MODFEAT_NW_CIFERA_TRAIN_TRADE2'),
       ('TRAIT_LEADER_NW_CIFERA_ZAGREUS', 'MODFEAT_NW_CIFERA_TRAIN_TRADE'),
       ('TRAIT_LEADER_NW_CIFERA_ZAGREUS', 'MODFEAT_NW_CIFERA_TRAIN_TRADE3');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODFEAT_NW_CIFERA_TRAIN_TRADE3', 'MODTYPE_NW_AM_PLAYER_TRAINED_UNITS_ATTACH_MODIFIER', 0, 0, 0, NULL,
        'NW_UNIT_IS_UNIT_TRADER');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_NW_CIFERA_TRAIN_TRADE3', 'ModifierId', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODFEAT_NW_CIFERA_TRAIN_TRADE2', 'MODTYPE_NW_AM_PLAYER_TRAINED_UNITS_ATTACH_MODIFIER', 0, 0, 0, NULL,
        'NW_UNIT_IS_UNIT_TRADER'),
       ('MODFEAT_NW_CIFERA_GRANT_SPY', 'MODIFIER_PLAYER_GRANT_SPY', 1, 1, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_NW_CIFERA_TRAIN_TRADE2', 'ModifierId', 'MODFEAT_NW_CIFERA_GRANT_SPY'),
       ('MODFEAT_NW_CIFERA_GRANT_SPY', 'Amount', 1);

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODFEAT_NW_CIFERA_TRAIN_TRADE', 'MODTYPE_NW_AM_PLAYER_TRAINED_UNITS_ATTACH_MODIFIER', 0, 0, 0, NULL,
        'NW_UNIT_IS_UNIT_TRADER'),
       ('MODFEAT_NW_CIFERA_GRANT_SPY_UNIT', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_NEAREST_CITY', 1, 1, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_NW_CIFERA_TRAIN_TRADE', 'ModifierId', 'MODFEAT_NW_CIFERA_GRANT_SPY_UNIT'),
       ('MODFEAT_NW_CIFERA_GRANT_SPY_UNIT', 'AllowUniqueOverride', 0),
       ('MODFEAT_NW_CIFERA_GRANT_SPY_UNIT', 'Amount', 1),
       ('MODFEAT_NW_CIFERA_GRANT_SPY_UNIT', 'UnitType', 'UNIT_SPY');

-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODTYPE_NW_AM_PLAYER_TRAINED_UNITS_ATTACH_MODIFIER', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODTYPE_NW_AM_PLAYER_TRAINED_UNITS_ATTACH_MODIFIER', 'COLLECTION_PLAYER_TRAINED_UNITS',
        'EFFECT_ATTACH_MODIFIER');

--================
-- TRAIT_LEADER_NW_PHAINON_KEPHALE
-- 解锁市政或科技后，也获得随之解锁的政策卡效果，通过这种方式获得的政策卡效果不会过期、并可以和政策卡本身叠加生效。解锁城市生产黄金裔的能力。
--================
INSERT INTO Types (Type, Kind)
VALUES ('AM_BAIE_MODIFIER_PLAYER_CAPITAL_ATTACH_MODIFIER', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('AM_BAIE_MODIFIER_PLAYER_CAPITAL_ATTACH_MODIFIER', 'COLLECTION_PLAYER_CAPITAL_CITY', 'EFFECT_ATTACH_MODIFIER');

-- 遍历市政线政策
INSERT INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_PHAINON_KEPHALE',
       'BAIE_ATTACH_' || pm.PolicyType || '_' || pm.ModifierId
FROM PolicyModifiers pm
         JOIN Policies p ON pm.PolicyType = p.PolicyType
WHERE p.PrereqCivic IS NOT NULL;
INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId)
SELECT 'BAIE_ATTACH_' || pm.PolicyType || '_' || pm.ModifierId,
       'AM_BAIE_MODIFIER_PLAYER_CAPITAL_ATTACH_MODIFIER',
       'REQS_BAIE_HAS_' || p.PrereqCivic
FROM PolicyModifiers pm
         JOIN Policies p ON pm.PolicyType = p.PolicyType
WHERE p.PrereqCivic IS NOT NULL;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'BAIE_ATTACH_' || pm.PolicyType || '_' || pm.ModifierId,
       'ModifierId',
       pm.ModifierId
FROM PolicyModifiers pm
         JOIN Policies p ON pm.PolicyType = p.PolicyType
WHERE p.PrereqCivic IS NOT NULL;

INSERT INTO RequirementSets(RequirementSetId, RequirementSetType)
SELECT 'REQS_BAIE_HAS_' || CivicType,
       'REQUIREMENTSET_TEST_ALL'
FROM Civics;
INSERT INTO RequirementSetRequirements(RequirementSetId, RequirementId)
SELECT 'REQS_BAIE_HAS_' || CivicType,
       'REQ_BAIE_HAS_' || CivicType
FROM Civics;

INSERT INTO Requirements(RequirementId, RequirementType)
SELECT 'REQ_BAIE_HAS_' || CivicType,
       'REQUIREMENT_PLAYER_HAS_CIVIC'
FROM Civics;
INSERT INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQ_BAIE_HAS_' || CivicType,
       'CivicType',
       CivicType
FROM Civics;

-- 遍历科技线政策
INSERT INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_PHAINON_KEPHALE',
       'BAIE_ATTACH_' || pm.PolicyType || '_' || pm.ModifierId
FROM PolicyModifiers pm
         JOIN Policies p ON pm.PolicyType = p.PolicyType
WHERE p.PrereqTech IS NOT NULL;
INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId)
SELECT 'BAIE_ATTACH_' || pm.PolicyType || '_' || pm.ModifierId,
       'AM_BAIE_MODIFIER_PLAYER_CAPITAL_ATTACH_MODIFIER',
       'NW_PLAYER_HAS_TECHNOLOGY_' || p.PrereqTech
FROM PolicyModifiers pm
         JOIN Policies p ON pm.PolicyType = p.PolicyType
WHERE p.PrereqTech IS NOT NULL;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'BAIE_ATTACH_' || pm.PolicyType || '_' || pm.ModifierId,
       'ModifierId',
       pm.ModifierId
FROM PolicyModifiers pm
         JOIN Policies p ON pm.PolicyType = p.PolicyType
WHERE p.PrereqTech IS NOT NULL;

INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_PHAINON_KEPHALE', 'MODIFIER_TRAIT_LEADER_NW_PHAINON_KEPHALE_VALID_BUILD');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_PHAINON_KEPHALE_VALID_BUILD', 'MODIFIER_PLAYER_ADJUST_VALID_UNIT_BUILD', 0, 0, 0,NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_PHAINON_KEPHALE_VALID_BUILD', 'UnitType', 'UNIT_GOLD_SON');

--================
-- TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA
-- 游戏开始时出生于海洋单元格中。初始拥有航海术和造船术。单位可以无视前置科技进入海洋单元格。建立首都时获得1个开拓者。位于海洋单元格的单位提供+4 [ICON_SCIENCE] 科技值。建立城市时获得3个单元格内的所有海岸、湖泊与海洋单元格。海洋单元格依据特色区域的数量获得对应产出。
--================
-- 游戏开始时出生于海洋单元格中。
INSERT INTO Leaders_XP2(LeaderType, OceanStart)
VALUES ('LEADER_NW_HELEKTRA', 1);
-- 初始拥有航海术和造船术。
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECHNOLOGY', 0, 0, 0, NULL,
        NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH', 'TechType', 'TECH_SAILING');


INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH_SHIPBUILDING');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH_SHIPBUILDING', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECHNOLOGY', 0,
        0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH_SHIPBUILDING', 'TechType', 'TECH_SHIPBUILDING');

-- 单位可以无视前置科技进入海洋单元格。
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ADJUST_VALID_TERRAIN');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ADJUST_VALID_TERRAIN', 'MODIFIER_PLAYER_UNITS_ADJUST_VALID_TERRAIN',
        0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ADJUST_VALID_TERRAIN', 'TerrainType', 'TERRAIN_OCEAN'),
       ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ADJUST_VALID_TERRAIN', 'Valid', '1');

-- 建立首都时获得1个开拓者。
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER', 'MODIFIER_PLAYER_GRANT_UNIT_IN_CAPITAL', 0, 1, 0,
        NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER', 'AllowUniqueOverride', '1'),
       ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER', 'Amount', '1'),
       ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER', 'UnitType', 'UNIT_SETTLER');

-- 位于海洋单元格的单位提供+4 [ICON_SCIENCE] 科技值。
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_IN_TERRAIN_OCEAN');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_IN_TERRAIN_OCEAN',
        'MODIFIER_NW_AMPHOREUS_PLAYER_UNITS_ADJUST_YIELD_CHANGE', 0, 0, 0, NULL, 'REQS_NW_UNIT_IN_TERRAIN_OCEAN');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_IN_TERRAIN_OCEAN', 'Amount', '4'),
       ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_IN_TERRAIN_OCEAN', 'YieldType', 'YIELD_SCIENCE');
-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_UNITS_ADJUST_YIELD_CHANGE', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AMPHOREUS_PLAYER_UNITS_ADJUST_YIELD_CHANGE', 'COLLECTION_PLAYER_UNITS',
        'EFFECT_ADJUST_PLAYER_YIELD_CHANGE');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('REQS_NW_UNIT_IN_TERRAIN_OCEAN', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('REQS_NW_UNIT_IN_TERRAIN_OCEAN', 'REQ_NW_UNIT_IN_TERRAIN_OCEAN');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType)
VALUES ('REQ_NW_UNIT_IN_TERRAIN_OCEAN', 'REQUIREMENT_PLOT_TERRAIN_TYPE_MATCHES');
INSERT INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQ_NW_UNIT_IN_TERRAIN_OCEAN', 'TerrainType', 'TERRAIN_OCEAN');

-- 每个相邻海岸建立的城市为新建立的城市额外获得4个单元格
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_CITY_TILES');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_CITY_TILES', 'MODIFIER_NW_AM_PLAYER_CITIES_ADJUST_CITY_TILES', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_CITY_TILES', 'Amount', '4');
-- Custom ModifierType
INSERT INTO Types (Type, Kind) VALUES
('MODIFIER_NW_AM_PLAYER_CITIES_ADJUST_CITY_TILES', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType) VALUES
('MODIFIER_NW_AM_PLAYER_CITIES_ADJUST_CITY_TILES', 'COLLECTION_PLAYER_CITIES', 'EFFECT_ADJUST_PLAYER_CITY_TILES');

-- 海洋单元格依据特色区域的数量获得对应产出。
INSERT INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA',
       'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_' || DistrictType || '_' || YieldType
FROM NW_TEMP_DISTRICT_YIELD;
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_' || DistrictType || '_' || YieldType,
       'MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ATTACH_MODIFIER',
       'NW_DISTRICT_IS_' || DistrictType
FROM NW_TEMP_DISTRICT_YIELD;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_' || DistrictType || '_' || YieldType,
       'ModifierId',
       'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ATTACH_' || YieldType
FROM NW_TEMP_DISTRICT_YIELD;

INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT DISTINCT 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ATTACH_' || YieldType,
                'MODIFIER_PLAYER_ADJUST_PLOT_YIELD',
                'REQS_NW_UNIT_IN_TERRAIN_OCEAN'
FROM NW_TEMP_DISTRICT_YIELD;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT DISTINCT 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ATTACH_' || YieldType,
                'Amount',
                '1'
FROM NW_TEMP_DISTRICT_YIELD
UNION
SELECT DISTINCT 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ATTACH_' || YieldType,
                'YieldType',
                YieldType
FROM NW_TEMP_DISTRICT_YIELD;

--================
-- TRAIT_LEADER_NW_CERYDRA_TALANTON
-- 建造区域、建筑和单位时，从每个已拥有的同类区域、建筑和单位中获得+50% [ICON_PRODUCTION] 生产力。
-- 著作类巨作产出额外八倍的 [ICON_CULTURE] 文化值和旅游业绩。
-- 如果城市忠诚，则其溢出的忠诚度将转化为等量的 [ICON_GOLD] 金币。(LUA)
--================
-- 著作类巨作产出额外八倍的 [ICON_CULTURE] 文化值和旅游业绩。
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_CERYDRA_TALANTON', 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_TOURISM');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_TOURISM', 'MODIFIER_PLAYER_CITIES_ADJUST_TOURISM', 0, 0, 0, NULL,
        NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_TOURISM', 'GreatWorkObjectType', 'GREATWORKOBJECT_WRITING'),
       ('MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_TOURISM', 'ScalingFactor', '800');

INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_CERYDRA_TALANTON', 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_GREATWORK_YIELD');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_GREATWORK_YIELD', 'MODIFIER_PLAYER_CITIES_ADJUST_GREATWORK_YIELD', 0,
        0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_GREATWORK_YIELD', 'GreatWorkObjectType', 'GREATWORKOBJECT_WRITING'),
       ('MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_GREATWORK_YIELD', 'ScalingFactor', '800'),
       ('MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_GREATWORK_YIELD', 'YieldType', 'YIELD_CULTURE');

-- 建造区域、建筑和单位时，从每个已拥有的同类区域、建筑和单位中获得+50% [ICON_PRODUCTION] 生产力。
-- 区域
INSERT INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_CERYDRA_TALANTON',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || DistrictType
FROM Districts;
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || DistrictType,
       'MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ATTACH_MODIFIER',
       'NW_DISTRICT_IS_' || DistrictType
FROM Districts;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || DistrictType,
       'ModifierId',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || DistrictType
FROM Districts;
INSERT INTO Modifiers (ModifierId, ModifierType)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || DistrictType,
       'MODIFIER_PLAYER_CITIES_ADJUST_DISTRICT_PRODUCTION'
FROM Districts;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || DistrictType,
       'Amount',
       50
FROM Districts
UNION
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || DistrictType,
       'DistrictType',
       DistrictType
FROM Districts;
-- 建筑
INSERT INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_CERYDRA_TALANTON',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || BuildingType
FROM Buildings;
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || BuildingType,
       'MODIFIER_PLAYER_CITIES_ATTACH_MODIFIER',
       'NW_CITY_HAS_' || BuildingType
FROM Buildings;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || BuildingType,
       'ModifierId',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || BuildingType
FROM Buildings;
INSERT INTO Modifiers (ModifierId, ModifierType)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || BuildingType,
       'MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_PRODUCTION'
FROM Buildings;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || BuildingType,
       'Amount',
       50
FROM Buildings
UNION
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || BuildingType,
       'BuildingType',
       BuildingType
FROM Buildings;

-- 单位
INSERT INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_CERYDRA_TALANTON',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || UnitType
FROM Units;
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || UnitType,
       'MODIFIER_PLAYER_UNITS_ATTACH_MODIFIER',
       'NW_UNIT_IS_' || UnitType
FROM Units;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || UnitType,
       'ModifierId',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || UnitType
FROM Units;
INSERT INTO Modifiers (ModifierId, ModifierType)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || UnitType,
       'MODIFIER_PLAYER_CITIES_ADJUST_UNIT_PRODUCTION'
FROM Units;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || UnitType,
       'Amount',
       50
FROM Units
UNION
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || UnitType,
       'UnitType',
       UnitType
FROM Units;



--================
-- TRAIT_LEADER_NW_EVERNIGHT_ORONYX
-- 单位每历经1个回合便+1 [ICON_Strength] 战斗力和+1 [ICON_GOLD] 金币。自建成起，纪念碑每历经1个回合便+1 [ICON_CULTURE] 文化值和+1 [ICON_Tourism] 旅游业绩。
--================
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_EVERNIGHT_ORONYX', 'MODIFIER_TRAIT_LEADER_NW_EVERNIGHT_ORONYX_GRANT_AB');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_EVERNIGHT_ORONYX_GRANT_AB', 'MODIFIER_PLAYER_UNITS_GRANT_ABILITY', 0, 1, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_EVERNIGHT_ORONYX_GRANT_AB', 'AbilityType', 'AB_ORONYX_ADD_COMBAT_FROM_TURN');

INSERT OR IGNORE INTO Types(Type, Kind)
VALUES ( 'AB_ORONYX_ADD_COMBAT_FROM_TURN','KIND_ABILITY');
INSERT OR IGNORE INTO TypeTags(Type,Tag)
VALUES ('AB_ORONYX_ADD_COMBAT_FROM_TURN','CLASS_ALL_UNITS');
INSERT OR IGNORE INTO UnitAbilities(UnitAbilityType,Inactive,Name,Description)
VALUES ( 'AB_ORONYX_ADD_COMBAT_FROM_TURN', 1 ,'LOC_TRAIT_LEADER_NW_EVERNIGHT_ORONYX_NAME','LOC_AB_ORONYX_ADD_COMBAT_FROM_TURN_DESCRIPTION');

INSERT OR IGNORE INTO UnitAbilityModifiers(UnitAbilityType,ModifierId)
VALUES ( 'AB_ORONYX_ADD_COMBAT_FROM_TURN', 'AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_PROPERTY');
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId) VALUES
('AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_PROPERTY', 'MODIFIER_SINGLE_UNIT_ATTACH_MODIFIER', 'ON_TURN_STARTED');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_PROPERTY', 'ModifierId', 'MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_PROPERTY');

INSERT INTO Modifiers (ModifierId, ModifierType) VALUES
('MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_PROPERTY', 'MODIFIER_UNIT_ADJUST_PROPERTY');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_PROPERTY', 'Key', 'AB_ORONYX_ADD_COMBAT_FROM_TURN'),
('MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_PROPERTY', 'Amount', '1');

INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId) VALUES
('AB_ORONYX_ADD_COMBAT_FROM_TURN', 'MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_COMBAT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_COMBAT', 'MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_COMBAT', 'Key', 'AB_ORONYX_ADD_COMBAT_FROM_TURN'),
('MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_COMBAT', 'Max', 120);
INSERT INTO ModifierStrings (ModifierId, Context, Text) VALUES
('MODIFIER_AB_ORONYX_ADD_COMBAT_FROM_TURN_ADD_COMBAT', 'Preview', 'LOC_AB_ORONYX_ADD_COMBAT_FROM_TURN_COMBAT');


INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId)
VALUES ('AB_ORONYX_ADD_COMBAT_FROM_TURN', 'MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_GOLD');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_GOLD', 'MODIFIER_PLAYER_ADJUST_YIELD_CHANGE', 0, 1, 0,
        'ON_TURN_STARTED', NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_GOLD', 'Amount', '1'),
       ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_GOLD', 'YieldType', 'YIELD_GOLD');


INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_EVERNIGHT_ORONYX', 'MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_MONUMENT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_MONUMENT', 'MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_YIELD_CHANGE', 0,
        1, 0, 'ON_TURN_STARTED', 'NW_CITY_HAS_BUILDING_MONUMENT');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_MONUMENT', 'Amount', '1'),
       ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_MONUMENT', 'BuildingType', 'BUILDING_MONUMENT'),
       ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_MONUMENT', 'YieldType', 'YIELD_CULTURE');


INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_EVERNIGHT_ORONYX', 'MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_TOURISM_CHANGE');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_TOURISM_CHANGE', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_TOURISM_CHANGE', 0,
        1, 0, 'ON_TURN_STARTED', 'NW_CITY_HAS_BUILDING_MONUMENT_AND_CITY_CENTER');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIERTRAIT_LEADER_NW_EVERNIGHT_ORONYX_TOURISM_CHANGE', 'Amount', '1');
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('NW_CITY_HAS_BUILDING_MONUMENT_AND_CITY_CENTER', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('NW_CITY_HAS_BUILDING_MONUMENT_AND_CITY_CENTER', 'REQ_NW_CITY_HAS_BUILDING_MONUMENT'),
       ('NW_CITY_HAS_BUILDING_MONUMENT_AND_CITY_CENTER', 'NW_DISTRICT_IS_DISTRICT_CITY_CENTER_REQUIREMENT');


--================
-- TRAIT_LEADER_NW_DANHENGPT_GEORIOS
-- 单元格的每点魅力值为单位+3 [ICON_Strength] 战斗力，通过这种方式，至多+50 [ICON_Strength] 战斗力
INSERT INTO TraitModifiers(TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_DANHENGPT_GEORIOS', 'MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_OWNER_UNIT_GRANT_ABILITY');
INSERT INTO Modifiers(ModifierId, ModifierType)
VALUES ('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_OWNER_UNIT_GRANT_ABILITY', 'MODIFIER_PLAYER_UNITS_GRANT_ABILITY');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_OWNER_UNIT_GRANT_ABILITY', 'AbilityType',
        'ABILITY_DANHENGPT_GEORIOS');

INSERT INTO Types (Type, Kind)
VALUES ('ABILITY_DANHENGPT_GEORIOS', 'KIND_ABILITY');
INSERT INTO TypeTags (Type, Tag)
VALUES ('ABILITY_DANHENGPT_GEORIOS', 'CLASS_ALL_UNITS');
INSERT INTO UnitAbilities (UnitAbilityType, Name, Description, Inactive)
VALUES ('ABILITY_DANHENGPT_GEORIOS',
        'LOC_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_NAME',
        'LOC_ABILITY_DANHENGPT_GEORIOS_DESCRIPTION',
        1);

INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId)
VALUES ('ABILITY_DANHENGPT_GEORIOS', 'MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_COMBAT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_COMBAT', 'MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_COMBAT', 'Key', 'TRAIT_LEADER_NW_DANHENGPT_GEORIOS'),
       ('MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_COMBAT', 'Max', '50');

INSERT INTO ModifierStrings (ModifierId, Context, Text) VALUES
('MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_COMBAT', 'Preview', 'LOC_MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_COMBAT');



INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId)
SELECT 'ABILITY_DANHENGPT_GEORIOS',
       'MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_PROPERTY_WHEN_APPEAL_' || number
FROM temp_APPEAL_numbers;
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_PROPERTY_WHEN_APPEAL_' || number,
       'MODIFIER_UNIT_ADJUST_PROPERTY',
       'REQS_NW_PLOT_HAS_APPEAL_' || number
FROM temp_APPEAL_numbers;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_PROPERTY_WHEN_APPEAL_' || number,
       'Key',
       'TRAIT_LEADER_NW_DANHENGPT_GEORIOS'
FROM temp_APPEAL_numbers
UNION
SELECT 'MODIFIER_ABILITY_DANHENGPT_GEORIOS_ADD_PROPERTY_WHEN_APPEAL_' || number,
       'Amount',
       3
FROM temp_APPEAL_numbers;


INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_DANHENGPT_GEORIOS', 'MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_EXTRA_DISTRICT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_EXTRA_DISTRICT', 'MODIFIER_PLAYER_CITIES_EXTRA_DISTRICT', 0, 0, 0,
        NULL, 'REQS_NW_CITY_HAS_ANY_NATURAL_WONDER');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_EXTRA_DISTRICT', 'Amount', 99);


INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_DANHENGPT_GEORIOS', 'MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_UNLOCK');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_UNLOCK', 'MODIFIER_PLAYER_ADJUST_DISTRICT_UNLOCK', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_UNLOCK', 'DistrictType', 'DISTRICT_AQUEDUCT'),
('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_UNLOCK', 'TechType', 'TECH_MINING');


--================
