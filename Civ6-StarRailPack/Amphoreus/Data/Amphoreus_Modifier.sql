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
INSERT OR IGNORE INTO temp_APPEAL_numbers (number)
WITH x AS
         (SELECT 1 AS id
          UNION ALL
          SELECT id + 1 AS id
          FROM x
          WHERE id < 8)
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
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'REQS_NW_PLOT_HAS_APPEAL_' || number,
       'REQUIREMENTSET_TEST_ALL'
FROM temp_APPEAL_numbers;
INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'REQS_NW_PLOT_HAS_APPEAL_' || number,
       'REQ_NW_PLOT_HAS_APPEAL_' || number
FROM temp_APPEAL_numbers;
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'REQ_NW_PLOT_HAS_APPEAL_' || number,
       'REQUIREMENT_PLOT_IS_APPEAL_BETWEEN'
FROM temp_APPEAL_numbers;
INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
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


-- 玩家拥有某科技
INSERT OR IGNORE INTO RequirementSets(RequirementSetId, RequirementSetType)
SELECT 'NW_PLAYER_HAS_' || TechnologyType, 'REQUIREMENTSET_TEST_ALL'
FROM Technologies;
INSERT OR IGNORE INTO Requirements(RequirementId, RequirementType)
SELECT 'NW_UTILS_PLAYER_HAS_' || TechnologyType || '_REQUIREMENT', 'REQUIREMENT_PLAYER_HAS_TECHNOLOGY'
FROM Technologies;
INSERT OR IGNORE INTO RequirementArguments(RequirementId, Name, Value)
SELECT 'NW_UTILS_PLAYER_HAS_' || TechnologyType || '_REQUIREMENT', 'TechnologyType', TechnologyType
FROM Technologies;
INSERT OR IGNORE INTO RequirementSetRequirements(RequirementSetId, RequirementId)
SELECT 'NW_PLAYER_HAS_' || TechnologyType, 'NW_UTILS_PLAYER_HAS_' || TechnologyType || '_REQUIREMENT'
FROM Technologies;

-- 玩家拥有某市政
INSERT OR IGNORE INTO RequirementSets(RequirementSetId, RequirementSetType)
SELECT 'NW_PLAYER_HAS_' || CivicType, 'REQUIREMENTSET_TEST_ALL'
FROM Civics;
INSERT OR IGNORE INTO Requirements(RequirementId, RequirementType)
SELECT 'NW_UTILS_PLAYER_HAS_' || CivicType || '_REQUIREMENT', 'REQUIREMENT_PLAYER_HAS_CIVIC'
FROM Civics;
INSERT OR IGNORE INTO RequirementArguments(RequirementId, Name, Value)
SELECT 'NW_UTILS_PLAYER_HAS_' || CivicType || '_REQUIREMENT', 'CivicType', CivicType
FROM Civics;
INSERT OR IGNORE INTO RequirementSetRequirements(RequirementSetId, RequirementId)
SELECT 'NW_PLAYER_HAS_' || CivicType, 'NW_UTILS_PLAYER_HAS_' || CivicType || '_REQUIREMENT'
FROM Civics;


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
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'REQS_NW_OWNER_' || number || '_PLOTS_AWAY',
       'REQUIREMENTSET_TEST_ALL'
FROM temp_APPEAL_numbers
WHERE number <= 10;
INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'REQS_NW_OWNER_' || number || '_PLOTS_AWAY',
       'REQ_NW_OWNER_' || number || '_PLOTS_AWAY'
FROM temp_APPEAL_numbers
WHERE number <= 10;
-- Requirements
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'REQ_NW_OWNER_' || number || '_PLOTS_AWAY',
       'REQUIREMENT_PLOT_ADJACENT_TO_OWNER'
FROM temp_APPEAL_numbers
WHERE number <= 10;
INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
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

-- RequirementSets
INSERT OR IGNORE INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'REQS_NW_OWNER_INNER_' || number || '_PLOTS_AWAY',
       'REQUIREMENTSET_TEST_ALL'
FROM temp_APPEAL_numbers
WHERE number <= 10;
INSERT OR IGNORE INTO RequirementSetRequirements (RequirementSetId, RequirementId)
SELECT 'REQS_NW_OWNER_INNER_' || number || '_PLOTS_AWAY',
       'REQ_NW_OWNER_INNER_' || number || '_PLOTS_AWAY'
FROM temp_APPEAL_numbers
WHERE number <= 10;
-- Requirements
INSERT OR IGNORE INTO Requirements (RequirementId, RequirementType)
SELECT 'REQ_NW_OWNER_INNER_' || number || '_PLOTS_AWAY',
       'REQUIREMENT_PLOT_ADJACENT_TO_OWNER'
FROM temp_APPEAL_numbers
WHERE number <= 10;
INSERT OR IGNORE INTO RequirementArguments (RequirementId, Name, Value)
SELECT 'REQ_NW_OWNER_INNER_' || number || '_PLOTS_AWAY',
       'MaxDistance',
       number
FROM temp_APPEAL_numbers
WHERE number <= 10
UNION
SELECT 'REQ_NW_OWNER_INNER_' || number || '_PLOTS_AWAY',
       'MinDistance',
       0
FROM temp_APPEAL_numbers
WHERE number <= 10;

--================
-- Civ
--================
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_CIVILIZATION_NW_AMPHOREUS', 'MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_IRRIGATION');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
('MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_IRRIGATION', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST',1,1);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_IRRIGATION', 'TechType', 'TECH_IRRIGATION');
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_CIVILIZATION_NW_AMPHOREUS', 'MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_BRONZE_WORKING');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
('MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_BRONZE_WORKING', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST',1,1);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_BRONZE_WORKING', 'TechType', 'TECH_BRONZE_WORKING');
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_CIVILIZATION_NW_AMPHOREUS', 'MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_THE_WHEEL');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent) VALUES
('MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_THE_WHEEL', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECH_BOOST',1,1);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_CIVILIZATION_NW_AMPHOREUS_TECH_THE_WHEEL', 'TechType', 'TECH_THE_WHEEL');


--================
-- TIBAO
--================


--================
-- WANDI
-- 首都每生产一个近战或抗骑兵单位，就可以再获得一个相同的近战或抗骑兵单位。
--================

INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_MYDEI_NIKADOR',
       'MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_DOUBLE_' || UnitType
FROM Units
WHERE PromotionClass IN ('PROMOTION_CLASS_MELEE', 'PROMOTION_CLASS_ANTI_CAVALRY');

INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, OwnerRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_DOUBLE_' || UnitType,
       'MODIFIER_NW_AM_PLAYER_CAPITAL_ADJUST_EXTRA_UNIT_COPY',
       'NW_PLAYER_HAS_CIVIC_EARLY_EMPIRE'
FROM Units
WHERE PromotionClass IN ('PROMOTION_CLASS_MELEE', 'PROMOTION_CLASS_ANTI_CAVALRY');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_DOUBLE_' || UnitType,
       'Amount',
       '1'
FROM Units
WHERE PromotionClass IN ('PROMOTION_CLASS_MELEE', 'PROMOTION_CLASS_ANTI_CAVALRY')
UNION
SELECT 'MODIFIER_TRAIT_LEADER_NW_MYDEI_NIKADOR_DOUBLE_' || UnitType,
       'UnitType',
       UnitType
FROM Units
WHERE PromotionClass IN ('PROMOTION_CLASS_MELEE', 'PROMOTION_CLASS_ANTI_CAVALRY');

-- Custom ModifierType
INSERT OR IGNORE INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AM_PLAYER_CAPITAL_ADJUST_EXTRA_UNIT_COPY', 'KIND_MODIFIER');
INSERT OR IGNORE INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AM_PLAYER_CAPITAL_ADJUST_EXTRA_UNIT_COPY', 'COLLECTION_PLAYER_CAPITAL_CITY',
        'EFFECT_ADJUST_EXTRA_UNIT_COPY');


--================
-- AGELAIYA
-- 专业化区域将获得等同于单元格魅力值50%的相邻加成，至多通过这种方式获得+4相邻加成。
--================
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

INSERT OR IGNORE INTO TraitModifiers(ModifierId, TraitType)
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'TRAIT_LEADER_NW_AGLAEA_MNESTIA'
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
WHERE number IN (2,3,4,6);

INSERT OR IGNORE INTO Modifiers(ModifierId, ModifierType)
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_BASED_ON_APPEAL'
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
WHERE number IN (2,3,4,6);
INSERT OR IGNORE INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'YieldType',
       YieldType
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
WHERE number IN (2,3,4,6)
UNION
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'YieldChange',
       1
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
WHERE number IN (2,3,4,6)
UNION
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'DistrictType',
       DistrictType
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
WHERE number IN (2,3,4,6)
UNION
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'RequiredAppeal',
       number
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
WHERE number IN (2,3,4,6)
UNION
SELECT 'MODIFIER_NW_' || DistrictType || '_ADD_YIELD_WITH_' || number || '_APPEAL',
       'Description',
       'LOC_Adjacency_DISTRICT_AGELAIYA_APPEAL_' || YieldType
FROM NW_TEMP_DISTRICT_YIELD,
     temp_APPEAL_numbers
WHERE number IN (2,3,4,6);

--================
-- NAKEXIA
-- 每次进入新时代时获得1项随机科技
--================

INSERT OR IGNORE INTO TraitModifiers(ModifierId, TraitType)
SELECT 'MODIFIER_TRAIT_LEADER_NW_ANAXA_CERCES_TECH' || EraType,
       'TRAIT_LEADER_NW_ANAXA_CERCES'
FROM Eras WHERE EraType IS NOT 'ERA_ANCIENT';
INSERT OR IGNORE INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_ANAXA_CERCES_TECH' || EraType,
       'MODIFIER_PLAYER_GRANT_RANDOM_TECHNOLOGY',
       'NW_PLAYER_IS_IN_' || EraType
FROM Eras WHERE EraType IS NOT 'ERA_ANCIENT';
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_ANAXA_CERCES_TECH' || EraType,
       'Amount',
       1
FROM Eras WHERE EraType IS NOT 'ERA_ANCIENT';

--================
-- TRAIT_LEADER_NW_CASTORICE_THANATOS
--================
--  [ICON_GreatWork_Artifact] 文物提供2倍 [ICON_Culture] 文化值和 [ICON_Tourism] 旅游业绩。
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_CASTORICE_THANATOS', 'MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_CULTURE');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_CULTURE', 'MODIFIER_PLAYER_CITIES_ADJUST_GREATWORK_YIELD', 0,
        0, 0, NULL, NULL);
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_CULTURE', 'GreatWorkObjectType', 'GREATWORKOBJECT_ARTIFACT'),
       ('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_CULTURE', 'YieldChange', '3'),
       ('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_CULTURE', 'YieldType', 'YIELD_PRODUCTION');

INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_CASTORICE_THANATOS', 'MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_TOURISM');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_TOURISM', 'MODIFIER_PLAYER_CITIES_ADJUST_TOURISM', 0, 0, 0,
        NULL, NULL);
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_TOURISM', 'GreatWorkObjectType', 'GREATWORKOBJECT_ARTIFACT'),
       ('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_RELIC_TOURISM', 'ScalingFactor', '200');


--================
-- TRAIT_LEADER_NW_HYACINTHIA_AQUILA
--================
-- 所有单位在回合结束时强制回复生命值。
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HYACINTHIA_AQUILA', 'MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_GRANT_HEAL_AFTER_ACTION');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HYACINTHIA_AQUILA_GRANT_HEAL_AFTER_ACTION',
        'MODIFIER_NW_PLAYER_UNITS_GRANT_HEAL_AFTER_ACTION', 0, 0, 0, NULL, NULL);
-- Custom ModifierType
INSERT OR IGNORE INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_PLAYER_UNITS_GRANT_HEAL_AFTER_ACTION', 'KIND_MODIFIER');
INSERT OR IGNORE INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_PLAYER_UNITS_GRANT_HEAL_AFTER_ACTION', 'COLLECTION_PLAYER_UNITS',
        'EFFECT_GRANT_HEAL_AFTER_ACTION');

-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('REQS_NW_AM_UNIT_DAMAGE_LESS_40', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('REQS_NW_AM_UNIT_DAMAGE_LESS_40', 'REQ_NW_AM_UNIT_DAMAGE_LESS_40');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType, Inverse) VALUES
('REQ_NW_AM_UNIT_DAMAGE_LESS_40', 'REQUIREMENT_UNIT_DAMAGE_MINIMUM', 1);
INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES
('REQ_NW_AM_UNIT_DAMAGE_LESS_40', 'MinimumAmount', '40');

--================
-- TRAIT_LEADER_NW_CIFERA_ZAGREUS
--================
-- 新训练的间谍提供一个贸易路线容量
INSERT OR IGNORE INTO TraitModifiers(TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_CIFERA_ZAGREUS', 'MODFEAT_NW_CIFERA_TRAIN_SPY');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType,
                       SubjectRequirementSetId)
VALUES ('MODFEAT_NW_CIFERA_TRAIN_SPY', 'MODTYPE_NW_AM_PLAYER_UNITS_ADJUST_TRADE_ROUTE_CAPACITY', 'NW_UNIT_IS_UNIT_SPY');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_NW_CIFERA_TRAIN_SPY', 'Amount', 1);

-- Custom ModifierType
INSERT OR IGNORE INTO Types (Type, Kind)
VALUES ('MODTYPE_NW_AM_PLAYER_UNITS_ADJUST_TRADE_ROUTE_CAPACITY', 'KIND_MODIFIER');
INSERT OR IGNORE INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODTYPE_NW_AM_PLAYER_UNITS_ADJUST_TRADE_ROUTE_CAPACITY', 'COLLECTION_PLAYER_UNITS',
        'EFFECT_ADJUST_TRADE_ROUTE_CAPACITY');

INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_CIFERA_ZAGREUS', 'MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_FREE_SPY');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_FREE_SPY', 'MODIFIER_PLAYER_GRANT_SPY', 0, 0, 0, 'NW_PLAYER_HAS_CIVIC_MEDIEVAL_FAIRES', NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_FREE_SPY', 'Amount', '1');

INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_CIFERA_ZAGREUS', 'MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_FREE_SPY_UNIT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_FREE_SPY_UNIT', 'MODIFIER_PLAYER_GRANT_UNIT_IN_CAPITAL', 0, 0, 0, 'NW_PLAYER_HAS_CIVIC_MEDIEVAL_FAIRES', NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_FREE_SPY_UNIT', 'AllowUniqueOverride', '0'),
('MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_FREE_SPY_UNIT', 'Amount', '1'),
('MODIFIER_TRAIT_LEADER_NW_CIFERA_ZAGREUS_FREE_SPY_UNIT', 'UnitType', 'UNIT_SPY');


--================
-- TRAIT_LEADER_NW_PHAINON_KEPHALE
-- 政体中的外交政策槽位全部转化为军事政策槽位。
--================
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_PHAINON_KEPHALE', 'MODIFIER_TRAIT_LEADER_NW_PHAINON_KEPHALE_REPLACE_GOVERNMENT_SLOTS');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_PHAINON_KEPHALE_REPLACE_GOVERNMENT_SLOTS', 'MODIFIER_PLAYER_CULTURE_REPLACE_GOVERNMENT_SLOTS', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_PHAINON_KEPHALE_REPLACE_GOVERNMENT_SLOTS', 'AddedGovernmentSlotType', 'SLOT_MILITARY'),
('MODIFIER_TRAIT_LEADER_NW_PHAINON_KEPHALE_REPLACE_GOVERNMENT_SLOTS', 'ReplacedGovernmentSlotType', 'SLOT_DIPLOMATIC'),
('MODIFIER_TRAIT_LEADER_NW_PHAINON_KEPHALE_REPLACE_GOVERNMENT_SLOTS', 'ReplacesAll', '1');


--================
-- TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA
-- 游戏开始时出生于海洋单元格中。初始拥有航海术和造船术。单位可以无视前置科技进入海洋单元格。建立首都时获得1个开拓者。
--================
-- 游戏开始时出生于海洋单元格中。
INSERT OR IGNORE INTO Leaders_XP2(LeaderType, OceanStart)
VALUES ('LEADER_NW_HELEKTRA', 1);
-- 初始拥有航海术和造船术。
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECHNOLOGY', 0, 0, 0, NULL,
        NULL);
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH', 'TechType', 'TECH_SAILING');


INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH_SHIPBUILDING');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH_SHIPBUILDING', 'MODIFIER_PLAYER_GRANT_SPECIFIC_TECHNOLOGY', 0,
        0, 0, NULL, NULL);
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_TECH_SHIPBUILDING', 'TechType', 'TECH_SHIPBUILDING');

-- 单位可以无视前置科技进入海洋单元格。
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ADJUST_VALID_TERRAIN');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ADJUST_VALID_TERRAIN', 'MODIFIER_PLAYER_UNITS_ADJUST_VALID_TERRAIN',
        0, 0, 0, NULL, NULL);
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ADJUST_VALID_TERRAIN', 'TerrainType', 'TERRAIN_OCEAN'),
       ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_ADJUST_VALID_TERRAIN', 'Valid', '1');

-- 建立首都时获得1个开拓者。
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA', 'MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER', 'MODIFIER_PLAYER_GRANT_UNIT_IN_CAPITAL', 0, 1, 0,
        NULL, NULL);
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER', 'AllowUniqueOverride', '1'),
       ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER', 'Amount', '1'),
       ('MODIFIER_TRAIT_LEADER_NW_HELEKTRA_PHAGOUSA_UNIT_SETTLER', 'UnitType', 'UNIT_SETTLER');

--================
-- TRAIT_LEADER_NW_CERYDRA_TALANTON
--================

-- 建造区域、建筑和单位时，从每个已拥有的同类区域、建筑和单位中获得+50% [ICON_PRODUCTION] 生产力。
-- 区域
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_CERYDRA_TALANTON',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || DistrictType
FROM Districts;
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || DistrictType,
       'MODIFIER_NW_AMPHOREUS_PLAYER_DISTRICTS_ATTACH_MODIFIER',
       'NW_DISTRICT_IS_' || DistrictType
FROM Districts;
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || DistrictType,
       'ModifierId',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || DistrictType
FROM Districts;
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType,SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || DistrictType,
       'MODIFIER_PLAYER_CITIES_ADJUST_DISTRICT_PRODUCTION',
       'MONUMENT_FULL_LOYALTY_REQUIREMENTS'
FROM Districts;
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || DistrictType,
       'Amount',
       12
FROM Districts
UNION
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || DistrictType,
       'DistrictType',
       DistrictType
FROM Districts;
-- 建筑
INSERT OR IGNORE INTO TraitModifiers (TraitType, ModifierId)
SELECT 'TRAIT_LEADER_NW_CERYDRA_TALANTON',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || BuildingType
FROM Buildings;
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || BuildingType,
       'MODIFIER_PLAYER_CITIES_ATTACH_MODIFIER',
       'NW_CITY_HAS_' || BuildingType
FROM Buildings;
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_' || BuildingType,
       'ModifierId',
       'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || BuildingType
FROM Buildings;
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType,SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || BuildingType,
       'MODIFIER_PLAYER_CITIES_ADJUST_BUILDING_PRODUCTION',
       'MONUMENT_FULL_LOYALTY_REQUIREMENTS'
FROM Buildings;
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || BuildingType,
       'Amount',
       12
FROM Buildings
UNION
SELECT 'MODIFIER_TRAIT_LEADER_NW_CERYDRA_TALANTON_ADD_PRODUCTION_' || BuildingType,
       'BuildingType',
       BuildingType
FROM Buildings;


--================
-- TRAIT_LEADER_NW_EVERNIGHT_ORONYX
-- 每次进入新时代时获得1项随机市政
--================

INSERT OR IGNORE INTO Requirements(RequirementId, RequirementType)
SELECT 'NW_PLAYER_IS_IN_' || EraType || '_REQUIREMENT', 'REQUIREMENT_PLAYER_ERA_AT_LEAST'
FROM Eras;
INSERT OR IGNORE INTO RequirementArguments(RequirementId, Name, Value)
SELECT 'NW_PLAYER_IS_IN_' || EraType || '_REQUIREMENT', 'EraType', EraType
FROM Eras;
INSERT OR IGNORE INTO RequirementSets(RequirementSetId, RequirementSetType)
SELECT 'NW_PLAYER_IS_IN_' || EraType, 'REQUIREMENTSET_TEST_ALL'
FROM Eras;
INSERT OR IGNORE INTO RequirementSetRequirements(RequirementSetId, RequirementId)
SELECT 'NW_PLAYER_IS_IN_' || EraType, 'NW_PLAYER_IS_IN_' || EraType || '_REQUIREMENT'
FROM Eras;

INSERT OR IGNORE INTO TraitModifiers(ModifierId, TraitType)
SELECT 'MODIFIER_TRAIT_LEADER_NW_EVERNIGHT_ORONYX_TECH' || EraType,
       'TRAIT_LEADER_NW_EVERNIGHT_ORONYX'
FROM Eras WHERE EraType IS NOT 'ERA_ANCIENT';

INSERT OR IGNORE INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_TRAIT_LEADER_NW_EVERNIGHT_ORONYX_TECH' || EraType,
       'MODIFIER_PLAYER_GRANT_RANDOM_CIVIC',
       'NW_PLAYER_IS_IN_' || EraType
FROM Eras WHERE EraType IS NOT 'ERA_ANCIENT';
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_TRAIT_LEADER_NW_EVERNIGHT_ORONYX_TECH' || EraType,
       'Amount',
       1
FROM Eras WHERE EraType IS NOT 'ERA_ANCIENT';


--================
-- TRAIT_LEADER_NW_DANHENGPT_GEORIOS
-- 平坦的单元格+1生产力。
INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_LEADER_NW_DANHENGPT_GEORIOS', 'MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_PRODUCTION');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_PRODUCTION', 'MODIFIER_PLAYER_ADJUST_PLOT_YIELD', 0, 0, 0, NULL, 'NW_AM_PLOT_IS_PLAINS');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_PRODUCTION', 'Amount', '1'),
('MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_PRODUCTION', 'YieldType', 'YIELD_PRODUCTION');

INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('NW_AM_PLOT_IS_PLAINS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('NW_AM_PLOT_IS_PLAINS', 'REQ_NW_AM_PLOT_IS_PLAINS'),
('NW_AM_PLOT_IS_PLAINS', 'REQ_NW_AM_PLOT_UNIMPROVED');
INSERT INTO Requirements (RequirementId, RequirementType, Inverse) VALUES
('REQ_NW_AM_PLOT_IS_PLAINS', 'REQUIREMENT_PLOT_TERRAIN_CLASS_MATCHES', 0),
('REQ_NW_AM_PLOT_UNIMPROVED', 'REQUIREMENT_PLOT_HAS_ANY_IMPROVEMENT', 1);
INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES
('REQ_NW_AM_PLOT_IS_PLAINS', 'TerrainClass', 'TERRAIN_CLASS_NW_PLAINS');

INSERT INTO TerrainClasses(TerrainClassType, Name) VALUES
('TERRAIN_CLASS_NW_PLAINS','LOC_TERRAIN_CLASS_NW_PLAINS');
INSERT INTO TerrainClass_Terrains(TerrainClassType, TerrainType) SELECT
'TERRAIN_CLASS_NW_PLAINS',TerrainType
FROM Terrains WHERE Hills = 0 AND Mountain = 0 AND Water = 0;

-- 采矿业科技后，可以在平坦的单元格上修建矿山。
INSERT INTO TraitModifiers (TraitType, ModifierId) SELECT
'TRAIT_LEADER_NW_DANHENGPT_GEORIOS', 'MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_IMPROVEMENT_VALID_'||TerrainType
FROM Terrains WHERE Hills = 0 AND Mountain = 0 AND Water = 0;
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) SELECT
'MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_IMPROVEMENT_VALID_'||TerrainType, 'MODIFIER_PLAYER_CITIES_ADJUST_IMPROVEMENT_VALID_TERRAIN', 0, 0, 0, 'NW_PLAYER_HAS_TECH_MINING', NULL
FROM Terrains WHERE Hills = 0 AND Mountain = 0 AND Water = 0;
INSERT INTO ModifierArguments (ModifierId, Name, Value) SELECT
'MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_IMPROVEMENT_VALID_'||TerrainType, 'ImprovementType', 'IMPROVEMENT_MINE'
FROM Terrains WHERE Hills = 0 AND Mountain = 0 AND Water = 0 UNION SELECT
'MODIFIER_TRAIT_LEADER_NW_DANHENGPT_GEORIOS_IMPROVEMENT_VALID_'||TerrainType, 'TerrainType', TerrainType
FROM Terrains WHERE Hills = 0 AND Mountain = 0 AND Water = 0;

--================
