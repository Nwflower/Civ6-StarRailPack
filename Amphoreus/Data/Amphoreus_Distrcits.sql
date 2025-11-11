--     FILE: Amphoreus_Districts.sql
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni
--     Copyright (c) 2025.
--     All rights reserved.
--  DateCreated: 2025/10/26 15:31:52
--======================================================================
--  作者： 千川白浪
--  特别鸣谢： 优妮
--======================================================================

CREATE TEMPORARY TABLE IF NOT EXISTS NW_Amphoreus_Districts
(
    LeaderType           TEXT NOT NULL PRIMARY KEY,
    DistrictType         TEXT NOT NULL,
    ReplacesDistrictType TEXT NOT NULL
);
INSERT OR IGNORE INTO NW_Amphoreus_Districts(LeaderType, DistrictType, ReplacesDistrictType)
VALUES
-- 缇宝 刻法勒广场 门径
('LEADER_NW_TRIBIOS', 'DISTRICT_JANUS', 'DISTRICT_HOLY_SITE'),
-- 万敌 悬锋竞技场 纷争
('LEADER_NW_MYDEI', 'DISTRICT_NIKADOR', 'DISTRICT_ENCAMPMENT'),
-- 阿格莱雅 云石天宫 浪漫
('LEADER_NW_AGLAEA', 'DISTRICT_MNESTIA', 'DISTRICT_AQUEDUCT'),
-- 那刻夏 树庭 理性
('LEADER_NW_ANAXA', 'DISTRICT_CERCES', 'DISTRICT_CAMPUS'),
-- 遐蝶 龙骸古城 死亡
('LEADER_NW_CASTORICE', 'DISTRICT_THANATOS', 'DISTRICT_ENTERTAINMENT_COMPLEX'),
-- 风堇 疗愈之庭 天空
('LEADER_NW_HYACINTHIA', 'DISTRICT_AQUILA', 'DISTRICT_SPACEPORT'),
-- 赛飞儿 云石市集 诡计
('LEADER_NW_CIFERA', 'DISTRICT_ZAGREUS', 'DISTRICT_COMMERCIAL_HUB'),
-- 白厄 创世涡心 负世
('LEADER_NW_PHAINON', 'DISTRICT_KEPHALE', 'DISTRICT_GOVERNMENT'),
-- 海瑟音 浮影海庭 海洋
('LEADER_NW_HELEKTRA', 'DISTRICT_PHAGOUSA', 'DISTRICT_HARBOR'),
-- 刻律德菈 预言书库 律法
('LEADER_NW_CERYDRA', 'DISTRICT_TALANTON', 'DISTRICT_DIPLOMATIC_QUARTER'),
-- 长夜月 长梦宸扉 岁月
('LEADER_NW_EVERNIGHT', 'DISTRICT_ORONYX', 'DISTRICT_THEATER'),
-- 丹恒•腾荒 万壑岩心 大地
('LEADER_NW_DANHENGPT', 'DISTRICT_GEORIOS', 'DISTRICT_INDUSTRIAL_ZONE');
--======================================================================

-- 通用设置

INSERT INTO Types(Type, Kind)
SELECT DistrictType,
       'KIND_DISTRICT'
FROM NW_Amphoreus_Districts;
INSERT INTO DistrictReplaces(CivUniqueDistrictType, ReplacesDistrictType)
SELECT DistrictType,
       ReplacesDistrictType
FROM NW_Amphoreus_Districts;

-- 继承属性 但半价
INSERT INTO Districts(DistrictType, TraitType, Name, Description, PrereqTech, PrereqCivic, Coast, Cost,
                      RequiresPlacement, RequiresPopulation, NoAdjacentCity, CityCenter, Aqueduct, InternalOnly, ZOC,
                      FreeEmbark, HitPoints, CaptureRemovesBuildings, CaptureRemovesCityDefenses, PlunderType,
                      PlunderAmount, TradeEmbark, MilitaryDomain, CostProgressionModel, CostProgressionParam1, Appeal,
                      Housing, Entertainment, OnePerCity, AllowsHolyCity, Maintenance, AirSlots, CitizenSlots,
                      TravelTime, CityStrengthModifier, AdjacentToLand, CanAttack, AdvisorType, CaptureRemovesDistrict,
                      MaxPerPlayer)
SELECT nd.DistrictType,
       'TRAIT_' || nd.DistrictType,
       'LOC_' || nd.DistrictType || '_NAME',
       'LOC_' || nd.DistrictType || '_DESCRIPTION',
       PrereqTech,
       PrereqCivic,
       Coast,
       Cost / 4,
       RequiresPlacement,          --需要放置
       RequiresPopulation,         --专业化区域
       NoAdjacentCity,             -- 不得相邻市中心
       CityCenter,                 --市中心
       Aqueduct,                   --水渠的建造地形条件限制
       InternalOnly,               --内部区域
       ZOC,                        --形成控制区
       FreeEmbark,                 --免费上船
       HitPoints,                  --生命值
       CaptureRemovesBuildings,    --需要占领才不恢复
       CaptureRemovesCityDefenses, --占领移除城市防御
       PlunderType,                --被掠夺给的奖励类型
       PlunderAmount,              --被掠夺给的奖励数量
       TradeEmbark,                --贸易路线
       MilitaryDomain,             --作为军事单位生成的地方，不需要就“NO_DOMAIN” 其他：陆军“DOMAIN_LAND”，海军“DOMAIN_SEA”，空军“DOMAIN_AIR”
       CostProgressionModel,       --涨价模型
       CostProgressionParam1,      --涨价参数
       Appeal,                     --修改地块魅力
       Housing,                    -- 住房
       Entertainment,              --宜居度
       OnePerCity,                 --仅一个
       AllowsHolyCity,             --可发酵
       Maintenance,                --维护费
       AirSlots,                   --飞机槽位
       CitizenSlots,               --公民工作槽位
       TravelTime,                 --间谍旅行时间
       CityStrengthModifier,       --相邻陆地
       AdjacentToLand,
       CanAttack,                  --可以攻击
       AdvisorType,
       CaptureRemovesDistrict,     --城市被占领删除这个区域
       MaxPerPlayer                --最多数量
FROM Districts d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

INSERT INTO Districts_XP2(DistrictType, OnePerRiver, PreventsFloods, PreventsDrought, Canal, AttackRange)
SELECT nd.DistrictType,
       OnePerRiver,
       PreventsFloods,
       PreventsDrought,
       Canal,
       AttackRange
FROM Districts_XP2 d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

-- 继承商路收益、公民产出、伟人点产出、特殊效果和相邻加成
INSERT INTO District_CitizenYieldChanges(DistrictType, YieldType, YieldChange)
SELECT nd.DistrictType,
       YieldType,
       YieldChange * 2
FROM District_CitizenYieldChanges d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

INSERT INTO District_GreatPersonPoints(DistrictType, GreatPersonClassType, PointsPerTurn)
SELECT nd.DistrictType,
       GreatPersonClassType,
       PointsPerTurn * 2
FROM District_GreatPersonPoints d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;


INSERT INTO District_CitizenGreatPersonPoints(DistrictType, GreatPersonClassType, PointsPerTurn)
SELECT nd.DistrictType,
       GreatPersonClassType,
       PointsPerTurn
FROM District_CitizenGreatPersonPoints d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

INSERT INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT nd.DistrictType,
       YieldChangeId
FROM District_Adjacencies d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

INSERT INTO District_TradeRouteYields(DistrictType, YieldType, YieldChangeAsOrigin, YieldChangeAsDomesticDestination,
                                      YieldChangeAsInternationalDestination)
SELECT nd.DistrictType,
       YieldType,
       YieldChangeAsOrigin,
       YieldChangeAsDomesticDestination * 2,
       YieldChangeAsInternationalDestination
FROM District_TradeRouteYields d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

INSERT INTO AppealHousingChanges(DistrictType, MinimumValue, AppealChange, Description)
SELECT nd.DistrictType,
       MinimumValue,
       AppealChange,
       Description
FROM AppealHousingChanges d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

INSERT INTO DistrictModifiers(DistrictType, ModifierId)
SELECT nd.DistrictType,
       ModifierId
FROM DistrictModifiers d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

-- 建成时文化炸弹
INSERT INTO TraitModifiers(TraitType, ModifierId)
SELECT 'TRAIT_' || DistrictType,
       'MODIFIER_' || DistrictType || '_CULTURE_BOMB_TRIGGER'
FROM NW_Amphoreus_Districts;
INSERT INTO Modifiers(ModifierId, ModifierType)
SELECT 'MODIFIER_' || DistrictType || '_CULTURE_BOMB_TRIGGER', 'MODIFIER_PLAYER_ADD_CULTURE_BOMB_TRIGGER'
FROM NW_Amphoreus_Districts;
INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_' || DistrictType || '_CULTURE_BOMB_TRIGGER', 'DistrictType', DistrictType
FROM NW_Amphoreus_Districts;

-- 建成时送黄金裔
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_NIKADOR', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT'),
       ('DISTRICT_MNESTIA', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT'),
       ('DISTRICT_CERCES', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT'),
       ('DISTRICT_THANATOS', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT'),
       ('DISTRICT_AQUILA', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT'),
       ('DISTRICT_ZAGREUS', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT'),
       ('DISTRICT_TALANTON', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT'),
       ('DISTRICT_ORONYX', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT'),
       ('DISTRICT_GEORIOS', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT');
INSERT INTO Modifiers(ModifierId, ModifierType, Permanent)
VALUES ('MODIFIER_NW_FREE_GOLD_SON_EFFECT', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_CITY', 1);
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_NW_FREE_GOLD_SON_EFFECT', 'Amount', 1),
       ('MODIFIER_NW_FREE_GOLD_SON_EFFECT', 'UnitType', 'UNIT_GOLD_SON'),
       ('MODIFIER_NW_FREE_GOLD_SON_EFFECT', 'AllowUniqueOverride', 0);

--======================================================================
-- 刻法勒广场
-- DISTRICT_JANUS
--======================================================================
-- 基础+2
INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, Self)
VALUES ('ADJACENCY_DISTRICT_JANUS_SELF', 'LOC_ADJACENCY_DISTRICT_JANUS_SELF', 'YIELD_FAITH', 2, 1);
-- 地形相邻
INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, AdjacentTerrain)
VALUES ('ADJACENCY_DISTRICT_JANUS_TERRAIN_GRASS', 'LOC_ADJACENCY_DISTRICT_JANUS_TERRAIN_GRASS', 'YIELD_FAITH', 1,
        'TERRAIN_GRASS'),
       ('ADJACENCY_DISTRICT_JANUS_TERRAIN_PLAINS', 'LOC_ADJACENCY_DISTRICT_JANUS_TERRAIN_PLAINS', 'YIELD_FAITH', 1,
        'TERRAIN_PLAINS'),
       ('ADJACENCY_DISTRICT_JANUS_TERRAIN_TUNDRA', 'LOC_ADJACENCY_DISTRICT_JANUS_TERRAIN_TUNDRA', 'YIELD_FAITH', 1,
        'TERRAIN_TUNDRA'),
       ('ADJACENCY_DISTRICT_JANUS_TERRAIN_COAST', 'LOC_ADJACENCY_DISTRICT_JANUS_TERRAIN_COAST', 'YIELD_FAITH', 1,
        'TERRAIN_COAST'),
       ('ADJACENCY_DISTRICT_JANUS_TERRAIN_DESERT', 'LOC_ADJACENCY_DISTRICT_JANUS_TERRAIN_DESERT', 'YIELD_FAITH', 1,
        'TERRAIN_DESERT'),
       ('ADJACENCY_DISTRICT_JANUS_TERRAIN_SNOW', 'LOC_ADJACENCY_DISTRICT_JANUS_TERRAIN_SNOW', 'YIELD_FAITH', 1,
        'TERRAIN_SNOW');

-- 相邻规则绑定区域
INSERT INTO District_Adjacencies(DistrictType, YieldChangeId)
VALUES ('DISTRICT_JANUS', 'ADJACENCY_DISTRICT_JANUS_SELF'),
       ('DISTRICT_JANUS', 'ADJACENCY_DISTRICT_JANUS_TERRAIN_GRASS'),
       ('DISTRICT_JANUS', 'ADJACENCY_DISTRICT_JANUS_TERRAIN_PLAINS'),
       ('DISTRICT_JANUS', 'ADJACENCY_DISTRICT_JANUS_TERRAIN_TUNDRA'),
       ('DISTRICT_JANUS', 'ADJACENCY_DISTRICT_JANUS_TERRAIN_COAST'),
       ('DISTRICT_JANUS', 'ADJACENCY_DISTRICT_JANUS_TERRAIN_SNOW'),
       ('DISTRICT_JANUS', 'ADJACENCY_DISTRICT_JANUS_TERRAIN_DESERT');

-- 允许购买XX区域中的建筑
INSERT OR IGNORE INTO DistrictModifiers(DistrictType, ModifierId)
SELECT 'DISTRICT_JANUS',
       'MODIFIER_NW_DISTRICT_JANUS_ENABLE_BUILDING_FAITH_PURCHASE_' || DistrictType
FROM Districts
WHERE TraitType IS NULL;
INSERT OR IGNORE INTO Modifiers(ModifierId, ModifierType)
SELECT 'MODIFIER_NW_DISTRICT_JANUS_ENABLE_BUILDING_FAITH_PURCHASE_' || DistrictType,
       'MODIFIER_CITY_ENABLE_BUILDING_FAITH_PURCHASE'
FROM Districts
WHERE TraitType IS NULL;
INSERT OR IGNORE INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_NW_DISTRICT_JANUS_ENABLE_BUILDING_FAITH_PURCHASE_' || DistrictType,
       'DistrictType',
       DistrictType
FROM Districts
WHERE TraitType IS NULL;

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
SELECT 'DISTRICT_JANUS',
       'NW_PURCHASE_CHEAPER_' || BuildingType
FROM Buildings
WHERE IsWonder = 0;
INSERT INTO Modifiers (ModifierId, ModifierType)
SELECT 'NW_PURCHASE_CHEAPER_' || BuildingType,
       'MODIFIER_NW_AM_PLAYER_CITY_ADJUST_BUILDING_PURCHASE_COST'
FROM Buildings
WHERE IsWonder = 0;

INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'NW_PURCHASE_CHEAPER_' || BuildingType,
       'Amount',
       30
FROM Buildings
WHERE IsWonder = 0
UNION
SELECT 'NW_PURCHASE_CHEAPER_' || BuildingType,
       'BuildingType',
       BuildingType
FROM Buildings
WHERE IsWonder = 0;

-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AM_PLAYER_CITY_ADJUST_BUILDING_PURCHASE_COST', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AM_PLAYER_CITY_ADJUST_BUILDING_PURCHASE_COST', 'COLLECTION_OWNER',
        'EFFECT_ADJUST_BUILDING_PURCHASE_COST');

--======================================================================
-- 悬锋斗技场
-- DISTRICT_NIKADOR
--======================================================================
-- 建成后释放文化炸弹、并获得一名黄金裔。该区域中的每个建筑为城市提供2点 [ICON_Housing] 住房。[NEWLINE][NEWLINE]该区域具有一定的生产力，且可修建在市中心旁。
UPDATE Districts
SET NoAdjacentCity = 0,
    Appeal         = 0
WHERE DistrictType = 'DISTRICT_NIKADOR';
-- 继承其他生产力加成
INSERT OR IGNORE INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT 'DISTRICT_NIKADOR',
       Adjacency_YieldChanges.ID
FROM Adjacency_YieldChanges
WHERE YieldType = 'YIELD_PRODUCTION' AND Description IS NOT 'Placeholder' AND YieldChange > 0;


-- 该区域中的每个建筑为城市提供2点 [ICON_Housing] 住房
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
SELECT 'DISTRICT_NIKADOR',
       'MODIFIER_NW_FIGHTING_CAMP_' || BuildingType || '_GIVER_HOUSING'
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_ENCAMPMENT';
INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
SELECT 'MODIFIER_NW_FIGHTING_CAMP_' || BuildingType || '_GIVER_HOUSING',
       'MODIFIER_SINGLE_CITY_ADJUST_BUILDING_HOUSING',
       'NW_CITY_HAS_' || BuildingType
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_ENCAMPMENT';
INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_NW_FIGHTING_CAMP_' || BuildingType || '_GIVER_HOUSING', 'Amount', 2
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_ENCAMPMENT';

--======================================================================
-- 云石天宫
-- DISTRICT_MNESTIA
--======================================================================
-- 阿格莱雅特色区域，替代水渠但解锁更早，建造费用更低。
-- 相邻的专业化区域获得标准相邻加成。
-- 建成后释放文化炸弹、并获得一名黄金裔，
-- 且该城市 [ICON_Citizen] 人口立刻填充到[ICON_Housing] 住房上限。(LUA)
-- 场上每有一个云石天宫，所有云石天宫便能额外产出1 [ICON_Amenities] 宜居度和2点 [ICON_Production] 生产力。

UPDATE Districts
SET PrereqTech    = 'TECH_IRRIGATION',
    Entertainment = 2,
    Housing       = 3
WHERE DistrictType = 'DISTRICT_MNESTIA';

-- 为相邻区域提供2相邻加成
INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, AdjacentDistrict)
SELECT 'ADJACENCY_DISTRICT_MNESTIA_GIVE_' || YieldType,
       'LOC_ADJACENCY_DISTRICT_MNESTIA_GIVE_' || YieldType,
       YieldType,
       2,
       'DISTRICT_MNESTIA'
FROM Yields;

INSERT OR IGNORE INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT District_CitizenYieldChanges.DistrictType,
       'ADJACENCY_DISTRICT_MNESTIA_GIVE_' || YieldType
FROM District_CitizenYieldChanges
WHERE DistrictType IN (SELECT DISTINCT ReplacesDistrictType FROM DistrictReplaces);

-- 为本城种植园改良设施+1食物、2生产力
-- 场上每有一个云石天宫，所有云石天宫便能额外产出1宜居度、和2点生产力
INSERT INTO DistrictModifiers(ModifierId, DistrictType)
VALUES ('MODIFIER_MARBLE_ADD_DISTRICT_MORE_AMENITY', 'DISTRICT_MNESTIA'),-- 所有云石天宫便能额外产出1宜居度
       ('MODIFIER_MARBLE_ADD_DISTRICT_MORE_YIELD_ADD_YIELD_PRODUCTION', 'DISTRICT_MNESTIA'),-- 所有云石天宫便能额外产出2点生产力
       ('MODIFIER_MARBLE_ADD_IMPROVEMENT_PLANTATION_YIELD', 'DISTRICT_MNESTIA');-- 为本城种植园改良设施+1食物、2生产力
INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('MODIFIER_MARBLE_ADD_DISTRICT_MORE_AMENITY', 'MODIFIER_PLAYER_DISTRICT_ADJUST_DISTRICT_AMENITY',
        'NW_DISTRICT_IS_DISTRICT_MNESTIA'),
       ('MODIFIER_MARBLE_ADD_DISTRICT_MORE_YIELD_ADD_YIELD_PRODUCTION', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_CHANGE',
        'NW_DISTRICT_IS_DISTRICT_MNESTIA'),
       ('MODIFIER_MARBLE_ADD_IMPROVEMENT_PLANTATION_YIELD', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD',
        'NW_CITY_PLOT_HAS_PLANTATION');
INSERT INTO ModifierArguments(ModifierId, Name, Value)
VALUES ('MODIFIER_MARBLE_ADD_DISTRICT_MORE_AMENITY', 'Amount', 1),
       ('MODIFIER_MARBLE_ADD_DISTRICT_MORE_YIELD_ADD_YIELD_PRODUCTION', 'Amount', 2),
       ('MODIFIER_MARBLE_ADD_DISTRICT_MORE_YIELD_ADD_YIELD_PRODUCTION', 'YieldType', 'YIELD_PRODUCTION'),
       ('MODIFIER_MARBLE_ADD_IMPROVEMENT_PLANTATION_YIELD', 'Amount', '2,1'),
       ('MODIFIER_MARBLE_ADD_IMPROVEMENT_PLANTATION_YIELD', 'YieldType', 'YIELD_PRODUCTION, YIELD_FOOD');

INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('NW_CITY_PLOT_HAS_PLANTATION', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('NW_CITY_PLOT_HAS_PLANTATION', 'REQ_NW_CITY_PLOT_HAS_PLANTATION');
INSERT INTO Requirements (RequirementId, RequirementType)
VALUES ('REQ_NW_CITY_PLOT_HAS_PLANTATION', 'REQUIREMENT_PLOT_IMPROVEMENT_TYPE_MATCHES');
INSERT INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQ_NW_CITY_PLOT_HAS_PLANTATION', 'ImprovementType', 'IMPROVEMENT_PLANTATION');

--================
-- 树庭
-- DISTRICT_CERCES
--================
-- 那刻夏的特色区域，替代学院，相邻加成提供 [ICON_Culture] 文化值，而非 [ICON_Science] 科技值。建成后释放文化炸弹、并获得一名黄金裔，市中心获得免费的城墙。对于该城市市中心两个单元格内尚无地貌的单元格，如果这些单元格为您所有，建成树庭时这些单元格将立即获得原始树林。该区域内的建筑+2 [ICON_Housing] 住房，该区域及其建筑为本城中的树林+1 [ICON_Science] 科技值+1 [ICON_Production] 生产力，雨林+1 [ICON_Culture] 文化值+2 [ICON_Gold] 金币，并赠送一项随机 [ICON_Science] 科技。
UPDATE Districts
SET PrereqTech    = 'TECH_IRRIGATION',
    Entertainment = 2,
    Housing       = 3
WHERE DistrictType = 'DISTRICT_CERCES';


DELETE FROM District_Adjacencies WHERE DistrictType = 'DISTRICT_CERCES';

-- 从科技值相邻加成中生成文化值
INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, TilesRequired, OtherDistrictAdjacent,
                                   AdjacentSeaResource, AdjacentTerrain, AdjacentFeature, AdjacentRiver, AdjacentWonder,
                                   AdjacentNaturalWonder, AdjacentImprovement, AdjacentDistrict, PrereqCivic,
                                   PrereqTech, ObsoleteCivic, ObsoleteTech, AdjacentResource, AdjacentResourceClass,
                                   Self)
SELECT 'ADJACENCY_DISTRICT_CERCES_' || ID,
       Description,
       'YIELD_CULTURE',
       YieldChange,
       TilesRequired,
       OtherDistrictAdjacent,
       AdjacentSeaResource,
       AdjacentTerrain,
       AdjacentFeature,
       AdjacentRiver,
       AdjacentWonder,
       AdjacentNaturalWonder,
       AdjacentImprovement,
       AdjacentDistrict,
       PrereqCivic,
       PrereqTech,
       ObsoleteCivic,
       ObsoleteTech,
       AdjacentResource,
       AdjacentResourceClass,
       Self
FROM Adjacency_YieldChanges
WHERE ID IN (SELECT DISTINCT YieldChangeId FROM District_Adjacencies WHERE DistrictType = 'DISTRICT_CAMPUS') AND YieldChange > 0;

-- 再获得所有文化值加成
INSERT OR
REPLACE INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT 'DISTRICT_CERCES',
       Adjacency_YieldChanges.ID
FROM Adjacency_YieldChanges
WHERE YieldType = 'YIELD_CULTURE' AND Description IS NOT 'Placeholder' AND YieldChange > 0;


-- 吃政策卡提供的翻倍效果
-- 思路 先从政策卡modify中筛选出需要学院的相邻加成的modify
-- 不绑定死是为了兼容对政策卡进行修改的MOD
CREATE TEMPORARY TABLE temp_CERCES_Modifier_Table
(
    PolicyType TEXT,
    ModifierId TEXT
);
INSERT INTO temp_CERCES_Modifier_Table
SELECT PolicyType,
       ModifierId
FROM PolicyModifiers
WHERE ModifierId IN (SELECT ModifierId
                     FROM Modifiers
                     WHERE ModifierType = 'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_MODIFIER'
                       AND SubjectRequirementSetId = 'DISTRICT_IS_CAMPUS');

-- 再插进政策卡效果，把原来的科技值改成文化值
INSERT INTO PolicyModifiers(PolicyType, ModifierId)
SELECT PolicyType,
       ModifierId || '_TO_CERCES'
FROM temp_CERCES_Modifier_Table;
INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId, SubjectRequirementSetId, OwnerStackLimit,
                      SubjectStackLimit)
SELECT ModifierId || '_TO_CERCES',
       ModifierType,
       OwnerRequirementSetId,
       'NW_DISTRICT_IS_DISTRICT_CERCES',
       OwnerStackLimit,
       SubjectStackLimit
FROM Modifiers
WHERE ModifierId IN (SELECT ModifierId FROM temp_CERCES_Modifier_Table);
INSERT INTO ModifierArguments(ModifierId, Name, Type, Value, Extra, SecondExtra)
SELECT ModifierId || '_TO_CERCES',
       Name,
       Type,
       REPLACE(Value, 'YIELD_SCIENCE', 'YIELD_CULTURE'),
       Extra,
       SecondExtra
FROM ModifierArguments
WHERE ModifierId IN (SELECT ModifierId FROM temp_CERCES_Modifier_Table);

DROP TABLE temp_CERCES_Modifier_Table;

-- 随机科技
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_CERCES', 'MODIFIER_NW_CERCES_GIVE_FOREST_YIELD'),
       ('DISTRICT_CERCES', 'MODIFIER_NW_CERCES_GIVE_JUNGLE_YIELD'),
       ('DISTRICT_CERCES', 'MODIFIER_NW_CERCES_GIVE_RANDOM_TECHNOLOGY');
INSERT INTO Modifiers (ModifierId, ModifierType, NewOnly, RunOnce, Permanent)
VALUES ('MODIFIER_NW_CERCES_GIVE_RANDOM_TECHNOLOGY', 'MODIFIER_PLAYER_GRANT_RANDOM_TECHNOLOGY', 0, 1, 1);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_NW_CERCES_GIVE_RANDOM_TECHNOLOGY', 'Amount', 1);

-- 树林+1科技值+1生产力，雨林+1文化值+2金币
INSERT INTO Modifiers(ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('MODIFIER_NW_CERCES_GIVE_FOREST_YIELD', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD',
        'REQS_NW_PLOT_HAS_FEATURE_FOREST'),
       ('MODIFIER_NW_CERCES_GIVE_JUNGLE_YIELD', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD',
        'REQS_NW_PLOT_HAS_FEATURE_JUNGLE');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_NW_CERCES_GIVE_FOREST_YIELD', 'Amount', '1,1'),
       ('MODIFIER_NW_CERCES_GIVE_FOREST_YIELD', 'YieldType', 'YIELD_SCIENCE,YIELD_PRODUCTION'),
       ('MODIFIER_NW_CERCES_GIVE_JUNGLE_YIELD', 'Amount', '1,2'),
       ('MODIFIER_NW_CERCES_GIVE_JUNGLE_YIELD', 'YieldType', 'YIELD_CULTURE,YIELD_GOLD');

-- 建筑加效果，条件：拥有建筑
-- 学院建筑为树林+1科技值+1生产力，雨林+1文化值+2金币
INSERT INTO DistrictModifiers(DistrictType, ModifierId)
SELECT 'DISTRICT_CERCES',
       'MODIFIER_NW_CERCES_GIVE_FOREST_YIELD' || BuildingType
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL
UNION
SELECT 'DISTRICT_CERCES',
       'MODIFIER_NW_CERCES_GIVE_JUNGLE_YIELD' || BuildingType
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL;

INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId, SubjectRequirementSetId)
SELECT 'MODIFIER_NW_CERCES_GIVE_FOREST_YIELD' || BuildingType,
       'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD',
       'NW_CITY_HAS_' || BuildingType,
       'REQS_NW_PLOT_HAS_FEATURE_FOREST'
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL
UNION
SELECT 'MODIFIER_NW_CERCES_GIVE_JUNGLE_YIELD' || BuildingType,
       'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD',
       'NW_CITY_HAS_' || BuildingType,
       'REQS_NW_PLOT_HAS_FEATURE_JUNGLE'
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL;

INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_NW_CERCES_GIVE_FOREST_YIELD' || BuildingType,
       'Amount',
       '1,1'
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL
UNION
SELECT 'MODIFIER_NW_CERCES_GIVE_JUNGLE_YIELD' || BuildingType,
       'Amount',
       '1,2'
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL
UNION
SELECT 'MODIFIER_NW_CERCES_GIVE_FOREST_YIELD' || BuildingType,
       'YieldType',
       'YIELD_SCIENCE,YIELD_PRODUCTION'
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL
UNION
SELECT 'MODIFIER_NW_CERCES_GIVE_JUNGLE_YIELD' || BuildingType,
       'YieldType',
       'YIELD_CULTURE,YIELD_GOLD'
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL;

-- 建筑送科技
INSERT INTO DistrictModifiers(DistrictType, ModifierId)
SELECT 'DISTRICT_CERCES',
       'MODIFIER_NW_CERCES_GIVE_RANDOM_TECHNOLOGY_' || BuildingType
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL;
INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId, RunOnce, Permanent)
SELECT 'MODIFIER_NW_CERCES_GIVE_RANDOM_TECHNOLOGY_' || BuildingType,
       'MODIFIER_PLAYER_GRANT_RANDOM_TECHNOLOGY',
       'NW_CITY_HAS_' || BuildingType,
       1,
       1
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_NW_CERCES_GIVE_RANDOM_TECHNOLOGY_' || BuildingType,
       'Amount',
       1
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_CAMPUS'
  AND IsWonder = 0
  AND TraitType IS NULL;

--================
-- 龙骸古城
-- DISTRICT_THANATOS
--================
UPDATE Districts
SET PrereqTech         = 'TECH_ASTROLOGY',
    Entertainment      = 2,
    PrereqCivic        = NULL,
    RequiresPopulation = 0
WHERE DistrictType = 'DISTRICT_THANATOS';

-- 为相邻区域提供2相邻加成
INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, AdjacentDistrict)
SELECT 'ADJACENCY_DISTRICT_THANATOS_GIVE_' || YieldType,
       'LOC_ADJACENCY_DISTRICT_THANATOS_GIVE_' || YieldType,
       YieldType,
       2,
       'DISTRICT_THANATOS'
FROM Yields;
INSERT OR IGNORE INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT District_CitizenYieldChanges.DistrictType,
       'ADJACENCY_DISTRICT_THANATOS_GIVE_' || YieldType
FROM District_CitizenYieldChanges
WHERE DistrictType IN (SELECT DISTINCT ReplacesDistrictType FROM DistrictReplaces);

-- 获得所有文化值加成
INSERT OR
REPLACE INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT 'DISTRICT_THANATOS',
       Adjacency_YieldChanges.ID
FROM Adjacency_YieldChanges
WHERE YieldType = 'YIELD_CULTURE' AND Description IS NOT 'Placeholder' AND YieldChange > 0;

-- 本城任意改良设施+1 [ICON_Amenities] 宜居度、+1 [ICON_Housing] 住房、+2 [ICON_Production] 生产力。
INSERT INTO ImprovementModifiers (ImprovementType, ModifierId)
SELECT ImprovementType,
       'MODIFIER_DISTRICT_DRAGON_SKELE_GIVE_IMPROVEMENT_AMENITY'
FROM Improvements
WHERE PlunderType IS NOT 'NO_PLUNDER';
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_DRAGON_SKELE_GIVE_IMPROVEMENT_AMENITY', 'MODIFIER_SINGLE_CITY_ADJUST_IMPROVEMENT_AMENITY',
        'NW_CITY_HAS_DISTRICT_THANATOS');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_DRAGON_SKELE_GIVE_IMPROVEMENT_AMENITY', 'Amount', 1);

INSERT INTO ImprovementModifiers (ImprovementType, ModifierId)
SELECT ImprovementType,
       'MODIFIER_DISTRICT_DRAGON_SKELE_GIVE_IMPROVEMENT_HOUSING'
FROM Improvements
WHERE PlunderType IS NOT 'NO_PLUNDER';
INSERT INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_DRAGON_SKELE_GIVE_IMPROVEMENT_HOUSING', 'MODIFIER_SINGLE_CITY_ADJUST_IMPROVEMENT_HOUSING',
        'NW_CITY_HAS_DISTRICT_THANATOS');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_DRAGON_SKELE_GIVE_IMPROVEMENT_HOUSING', 'Amount', 1);

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_THANATOS', 'MODIFIER_DISTRICT_THANATOS_ADD_PRODUCTION');
INSERT OR IGNORE INTO Modifiers (ModifierId, ModifierType, SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_THANATOS_ADD_PRODUCTION', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD',
        'REQS_NW_AM_PLOT_HAS_ANY_IMPROVEMENT');
INSERT OR IGNORE INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_THANATOS_ADD_PRODUCTION', 'YieldType', 'YIELD_PRODUCTION'),
       ('MODIFIER_DISTRICT_THANATOS_ADD_PRODUCTION', 'Amount', 2);

-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('REQS_NW_AM_PLOT_HAS_ANY_IMPROVEMENT', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('REQS_NW_AM_PLOT_HAS_ANY_IMPROVEMENT', 'REQ_NW_AM_PLOT_HAS_ANY_IMPROVEMENT');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType)
VALUES ('REQ_NW_AM_PLOT_HAS_ANY_IMPROVEMENT', 'REQUIREMENT_PLOT_HAS_ANY_IMPROVEMENT');

-- 拥有3个文物槽位，建成时提供一个考古学家，文物产出等于信仰值产出16倍的科技值和金币。
INSERT INTO Building_GreatWorks(BuildingType, GreatWorkSlotType, NumSlots, ThemingSameObjectType,
                                ThemingYieldMultiplier, ThemingTourismMultiplier, ThemingBonusDescription)
VALUES ('BUILDING_DISTRICT_THANATOS', 'GREATWORKSLOT_ARTIFACT', 3, 1, 900, 900,
        'LOC_BUILDING_THEMINGBONUS_DISTRICT_THANATOS');
INSERT INTO Unit_BuildingPrereqs(Unit, PrereqBuilding, NumSupported)
VALUES ('UNIT_ARCHAEOLOGIST_THANATOS', 'BUILDING_DISTRICT_THANATOS', 1);

INSERT INTO BuildingModifiers (BuildingType, ModifierId)
VALUES ('BUILDING_DISTRICT_THANATOS', 'MODIFIER_BUILDING_DISTRICT_THANATOS_FREE_UNIT_ARCHAEOLOGIST');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_BUILDING_DISTRICT_THANATOS_FREE_UNIT_ARCHAEOLOGIST', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_CITY', 0, 0,
        0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_DISTRICT_THANATOS_FREE_UNIT_ARCHAEOLOGIST', 'AllowUniqueOverride', '1'),
       ('MODIFIER_BUILDING_DISTRICT_THANATOS_FREE_UNIT_ARCHAEOLOGIST', 'Amount', '1'),
       ('MODIFIER_BUILDING_DISTRICT_THANATOS_FREE_UNIT_ARCHAEOLOGIST', 'UnitType', 'UNIT_ARCHAEOLOGIST_THANATOS');

INSERT INTO Types(Type, Kind)
VALUES ('UNIT_ARCHAEOLOGIST_THANATOS', 'KIND_UNIT');
INSERT INTO TypeTags(Type, Tag)
SELECT 'UNIT_ARCHAEOLOGIST_THANATOS', Tag
FROM TypeTags
WHERE Type = 'UNIT_ARCHAEOLOGIST';
INSERT INTO UnitAiInfos(UnitType, AiType)
SELECT 'UNIT_ARCHAEOLOGIST_THANATOS', AiType
FROM UnitAiInfos
WHERE UnitType = 'UNIT_ARCHAEOLOGIST';

INSERT INTO Units_XP2(UnitType, CanEarnExperience, CanFormMilitaryFormation)
SELECT 'UNIT_ARCHAEOLOGIST_THANATOS',
       CanEarnExperience,
       CanFormMilitaryFormation
FROM Units_XP2
WHERE UnitType = 'UNIT_ARCHAEOLOGIST';

INSERT INTO Units(UnitType, Name, BaseSightRange, BaseMoves, Combat, RangedCombat, Range, Bombard, Domain,
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
SELECT 'UNIT_ARCHAEOLOGIST_THANATOS',                 -- 类型
       'LOC_UNIT_ARCHAEOLOGIST_THANATOS_NAME',        -- 名称
       BaseSightRange,                                --视野
       BaseMoves,                                     -- 移动力
       Combat,                                        -- 近战力
       RangedCombat,                                  -- 远程力
       Range,                                         -- 射程
       Bombard,                                       -- 轰炸力
       Domain,                                        -- 单位的海陆空类别。可用值：DOMAIN_LAND陆地单位，DOMAIN_SEA海上单位，DOMAIN_AIR空中单位。
       FormationClass,                                -- 单位的编队类别，指向UnitFormationClasses表的FormationClassType列。可用值：FORMATION_CLASS_CIVILIAN平民单位，FORMATION_CLASS_LAND_COMBAT陆地战斗单位，FORMATION_CLASS_NAVAL海上战斗单位，FORMATION_CLASS_SUPPORT支援单位，FORMATION_CLASS_AIR空中战斗单位。
       Cost,                                    -- 生产力
       PopulationCost,                                -- 消耗人口
       FoundCity,                                     -- 能否创建城市
       FoundReligion,                                 -- 能否创建宗教
       MakeTradeRoute,                                -- 能否创建商路
       EvangelizeBelief,                              -- 能否纳入新信仰
       LaunchInquisition,                             -- 是否能开启宗教审讯
       RequiresInquisition,                           -- 是否需要已开启宗教审讯才能生产/购买
       BuildCharges,                              -- 劳动力
       ReligiousStrength,                             -- 宗教战斗力
       ReligionEvictPercent,                          -- 压教比例
       SpreadCharges,                                 -- 传教次数
       ReligiousHealCharges,                          -- 宗教治疗次数
       ExtractsArtifacts,                             -- 是否可以挖掘文物。
       'LOC_UNIT_ARCHAEOLOGIST_THANATOS_DESCRIPTION', -- 描述文本
       Flavor,
       CanCapture,                                    -- 可以俘虏平民单位
       CanRetreatWhenCaptured,                        -- 被俘虏时传送回最近城市
       NULL,                              -- 绑定特性
       AllowBarbarians,                               -- 允许蛮族生成
       CostProgressionModel,                          -- 涨价方式 NO_COST_PROGRESSION不涨价
       CostProgressionParam1,                         -- 涨价参数 COST_PROGRESSION_GAME_PROGRESS按游戏进程涨价 CostProgressionParam1填最终（即全科技/市政后的）价格百分比 COST_PROGRESSION_PREVIOUS_COPIES按已有数量涨价 CostProgressionParam1填每一个涨价的数量
       PromotionClass,                                -- 单位的晋升树，指向UnitPromotionClasses表的PromotionClassType列。
       InitialLevel,                                  -- 单位的初始等级，1是没有初始升级，2是附赠1级初始升级，以此类推。
       NumRandomChoices,                              -- 单位升级时从所有升级里随机抽出的数量
       NULL,                                          -- 前置科技
       NULL,                  -- 前置市政
       PrereqDistrict,                                -- 前置区域
       PrereqPopulation,                              -- 消耗人口
       LeaderType,                                    --
       CanTrain,                                      -- 可生产
       StrategicResource,                             -- 生产单位消耗的战略资源，指向Resources表的ResourceType列。消耗的数量在Units_XP2表的ResourceCost列指定。
       PurchaseYield,                                 -- 购买方式
       MustPurchase,                                  -- 只能购买
       Maintenance,                                   -- 维护费
       Stackable,                                     -- 是否可以堆叠（在一个单元格上存在多个该单位）
       AirSlots,                                      -- 能承载的空军单位数量
       CanTargetAir,                                  -- 是否能攻击空军单位
       PseudoYieldType,
       ZoneOfControl,                                 -- 是否有区域控制
       AntiAirCombat,                                 -- 防空力
       Spy,                                           -- 是间谍
       WMDCapable,
       ParkCharges,                                   -- 建立国家公园次数
       IgnoreMoves,                                   -- 是否不按正常规则移动（例如商人、间谍、飞机）
       TeamVisibility,                                -- 同队可见
       ObsoleteTech,                                  -- 过时科技
       ObsoleteCivic,                                 -- 过时市政
       MandatoryObsoleteTech,                         -- 强制过时科技
       MandatoryObsoleteCivic,                        -- 强制过时市政
       AdvisorType,                                   -- 顾问类型
       EnabledByReligion,                             -- 是否需要信条解锁
       TrackReligion,                                 -- 是否记录该单位信仰的宗教
       DisasterCharges,                               -- 制造灾害次数
       UseMaxMeleeTrainedStrength,                    -- 使用最大近战攻击力
       ImmediatelyName,                               -- 是否需要在出现后立刻命名
       CanEarnExperience                              -- 是否能获得经验
FROM Units
WHERE UnitType = 'UNIT_ARCHAEOLOGIST';



--================
-- 疗愈之庭
-- DISTRICT_AQUILA
--================

UPDATE Districts
SET PrereqTech            = 'TECH_WRITING',
    Cost                  = 24,
    CostProgressionModel='COST_PROGRESSION_PREVIOUS_COPIES',
    CostProgressionParam1 = 12
WHERE DistrictType = 'DISTRICT_AQUILA';
-- 所有单位在城市中驻扎一回合即可恢复全额生命值。
INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_DISTRICT_AQUILA', 'MODIFIER_DISTRICT_AQUILA_HEAL_PER_TURN');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_AQUILA_HEAL_PER_TURN', 'MODIFIER_NW_AM_PLAYER_UNITS_ADJUST_HEAL_PER_TURN', 0, 0, 0, NULL,
        'NW_CITY_HAS_DISTRICT_AQUILA');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_AQUILA_HEAL_PER_TURN', 'Amount', 100),
       ('MODIFIER_DISTRICT_AQUILA_HEAL_PER_TURN', 'Type', 'ALL');
-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AM_PLAYER_UNITS_ADJUST_HEAL_PER_TURN', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AM_PLAYER_UNITS_ADJUST_HEAL_PER_TURN', 'COLLECTION_PLAYER_UNITS',
        'EFFECT_ADJUST_UNIT_HEALING_MODIFIERS');

-- 解锁特色项目“清理黑潮”，每次完成时将推进科技胜利进度。
INSERT INTO Types(Type, Kind)
VALUES ('PROJECT_CLEAN_BLACK_WIND', 'KIND_PROJECT');
INSERT INTO Projects(ProjectType, Name, Description, ShortName, Cost, CostProgressionModel, CostProgressionParam1,
                     PrereqDistrict, MaxPlayerInstances, AdvisorType)
VALUES ('PROJECT_CLEAN_BLACK_WIND', 'LOC_PROJECT_CLEAN_BLACK_WIND_NAME', 'LOC_PROJECT_CLEAN_BLACK_WIND_DESCRIPTION',
        'LOC_PROJECT_CLEAN_BLACK_WIND_NAME', 100, 'COST_PROGRESSION_GAME_PROGRESS', 500, 'DISTRICT_AQUILA',
        (SELECT COUNT(SpaceRace) FROM Projects WHERE SpaceRace > 0), 'ADVISOR_TECHNOLOGY');
INSERT INTO Project_GreatPersonPoints(ProjectType, GreatPersonClassType, Points, PointProgressionModel,
                                      PointProgressionParam1)
SELECT 'PROJECT_CLEAN_BLACK_WIND',
       GreatPersonClassType,
       Points,
       PointProgressionModel,
       PointProgressionParam1
FROM Project_GreatPersonPoints
WHERE ProjectType = 'PROJECT_ENHANCE_DISTRICT_CAMPUS';
INSERT INTO Project_YieldConversions(ProjectType, YieldType, PercentOfProductionRate)
SELECT 'PROJECT_CLEAN_BLACK_WIND',
       YieldType,
       PercentOfProductionRate
FROM Project_YieldConversions
WHERE ProjectType = 'PROJECT_ENHANCE_DISTRICT_CAMPUS';

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent)
SELECT DISTINCT 'MODIFIER_PROJECT_CLEAN_BLACK_WIND_GRANT_' || PrereqTech,
       'MODIFIER_PLAYER_GRANT_SPECIFIC_TECHNOLOGY',
       1,
       1
FROM Projects
WHERE SpaceRace = 1;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT DISTINCT 'MODIFIER_PROJECT_CLEAN_BLACK_WIND_GRANT_' || PrereqTech,
       'TechType',
       PrereqTech
FROM Projects
WHERE SpaceRace = 1;


--================
-- 云石市集
-- DISTRICT_ZAGREUS
--================
-- 建成后城市将能使用金币免费购买区域一级建筑。
-- 所有贸易路线从目的地的每个区域+8 [ICON_GOLD] 金币、+3 [ICON_PRODUCTION] 生产力。
-- 恰与云石市集相距4个单元格的区域、市中心或奇观提供+1 [ICON_TradeRoute] 贸易路线容量，这种方式提供的贸易路线容量可以叠加。
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
SELECT 'DISTRICT_ZAGREUS',
       'MODIFIER_DISTRICT_ZAGREUS_PURCHASE_' || BuildingType
FROM Buildings
WHERE BuildingType NOT IN (SELECT DISTINCT Building FROM BuildingPrereqs)
  AND IsWonder = 0;
INSERT INTO Modifiers (ModifierId, ModifierType)
SELECT 'MODIFIER_DISTRICT_ZAGREUS_PURCHASE_' || BuildingType,
       'MODIFIER_NW_AM_SINGLE_CITY_ADJUST_BUILDING_PURCHASE_COST'
FROM Buildings
WHERE BuildingType NOT IN (SELECT DISTINCT Building FROM BuildingPrereqs)
  AND IsWonder = 0;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_DISTRICT_ZAGREUS_PURCHASE_' || BuildingType,
       'Amount',
       '100'
FROM Buildings
WHERE BuildingType NOT IN (SELECT DISTINCT Building FROM BuildingPrereqs)
  AND IsWonder = 0
UNION
SELECT 'MODIFIER_DISTRICT_ZAGREUS_PURCHASE_' || BuildingType,
       'BuildingType',
       BuildingType
FROM Buildings
WHERE BuildingType NOT IN (SELECT DISTINCT Building FROM BuildingPrereqs)
  AND IsWonder = 0;

-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AM_SINGLE_CITY_ADJUST_BUILDING_PURCHASE_COST', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AM_SINGLE_CITY_ADJUST_BUILDING_PURCHASE_COST', 'COLLECTION_OWNER',
        'EFFECT_ADJUST_BUILDING_PURCHASE_COST');


INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ZAGREUS', 'MODIFIER_DISTRICT_ZAGREUS_PURCHASE_GOLD_DISTRICT_FOR_DOMESTIC');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_GOLD_DISTRICT_FOR_DOMESTIC',
        'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_YIELD_PER_SPECIALTY_DISTRICT_FOR_DOMESTIC', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_GOLD_DISTRICT_FOR_DOMESTIC', 'Amount', 8),
       ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_GOLD_DISTRICT_FOR_DOMESTIC', 'YieldType', 'YIELD_GOLD');

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ZAGREUS', 'MODIFIER_DISTRICT_ZAGREUS_PURCHASE_GOLD_DISTRICT_FOR_INTERNATIONAL');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_GOLD_DISTRICT_FOR_INTERNATIONAL',
        'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_YIELD_PER_SPECIALTY_DISTRICT_FOR_INTERNATIONAL', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_GOLD_DISTRICT_FOR_INTERNATIONAL', 'Amount', 8),
       ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_GOLD_DISTRICT_FOR_INTERNATIONAL', 'YieldType', 'YIELD_GOLD');

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ZAGREUS', 'MODIFIER_DISTRICT_ZAGREUS_PURCHASE_PRODUCTION_DISTRICT_FOR_DOMESTIC');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_PRODUCTION_DISTRICT_FOR_DOMESTIC',
        'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_YIELD_PER_SPECIALTY_DISTRICT_FOR_DOMESTIC', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_PRODUCTION_DISTRICT_FOR_DOMESTIC', 'Amount', 3),
       ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_PRODUCTION_DISTRICT_FOR_DOMESTIC', 'YieldType', 'YIELD_PRODUCTION');

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ZAGREUS', 'MODIFIER_DISTRICT_ZAGREUS_PURCHASE_PRODUCTION_DISTRICT_FOR_INTERNATIONAL');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_PRODUCTION_DISTRICT_FOR_INTERNATIONAL',
        'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_YIELD_PER_SPECIALTY_DISTRICT_FOR_INTERNATIONAL', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_PRODUCTION_DISTRICT_FOR_INTERNATIONAL', 'Amount', 3),
       ('MODIFIER_DISTRICT_ZAGREUS_PURCHASE_PRODUCTION_DISTRICT_FOR_INTERNATIONAL', 'YieldType', 'YIELD_PRODUCTION');


INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ZAGREUS', 'MODIFIER_DISTRICT_ZAGREUS_TRADE_ROUTE_CAPACITY');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_TRADE_ROUTE_CAPACITY', 'MODIFIER_NW_AM_PLAYER_DISTRICT_ADJUST_TRADE_ROUTE_CAPACITY',
        0, 0, 0, NULL, 'REQS_NW_OWNER_4_PLOTS_AWAY');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_TRADE_ROUTE_CAPACITY', 'Amount', '1');
-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AM_PLAYER_DISTRICT_ADJUST_TRADE_ROUTE_CAPACITY', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AM_PLAYER_DISTRICT_ADJUST_TRADE_ROUTE_CAPACITY', 'COLLECTION_PLAYER_DISTRICTS',
        'EFFECT_ADJUST_TRADE_ROUTE_CAPACITY');

--================
-- 创世涡心
-- DISTRICT_KEPHALE
--================
-- 建成后，获得所有黄金时代着力点效果。通过这种方式获得的着力点效果不会过期、并可以和时代着力点本身叠加生效。
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
SELECT 'DISTRICT_KEPHALE',
       'DISTRICT_KEPHALE_' || CommemorationType || '_' || m.ModifierId
FROM CommemorationModifiers cm
         JOIN Modifiers m ON cm.ModifierId = m.ModifierId
WHERE m.OwnerRequirementSetId == 'PLAYER_HAS_GOLDEN_AGE';

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
SELECT 'DISTRICT_KEPHALE_' || CommemorationType || '_' || m.ModifierId,
       ModifierType,
       RunOnce,
       Permanent,
       NewOnly,
       NULL,
       SubjectRequirementSetId
FROM CommemorationModifiers cm
         JOIN Modifiers m ON cm.ModifierId = m.ModifierId
WHERE m.OwnerRequirementSetId == 'PLAYER_HAS_GOLDEN_AGE';

INSERT INTO ModifierArguments(ModifierId, Name, Type, Value, Extra, SecondExtra)
SELECT 'DISTRICT_KEPHALE_' || CommemorationType || '_' || m.ModifierId,
       ma.Name,
       ma.Type,
       ma.Value,
       ma.Extra,
       ma.SecondExtra
FROM CommemorationModifiers cm
         JOIN Modifiers m
         JOIN ModifierArguments ma ON cm.ModifierId = m.ModifierId AND m.ModifierId = ma.ModifierId
WHERE m.OwnerRequirementSetId == 'PLAYER_HAS_GOLDEN_AGE';

--================
-- 浮影海庭
-- DISTRICT_PHAGOUSA
--================
-- 海瑟音的特色区域，替代港口但解锁更早，建造费用更低。该区域具有区域防御，建成后免费获得防洪坝和该区域内的所有建筑。

UPDATE Districts
SET HitPoints               = 100,
    CaptureRemovesBuildings = 1,
    CanAttack               = 1
WHERE DistrictType = 'DISTRICT_PHAGOUSA';
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_PHAGOUSA', 'MODIFIER_NW_FREE_GOLD_SON_EFFECT');

-- 从每个相邻的陆地单元格+2金币。

-- 每拥有1个浮影海庭，所有区域每相邻1个区域便+1金币，并提供等量的旅游业绩。
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
SELECT 'DISTRICT_PHAGOUSA',
       'MODIFIER_DISTRICT_PHAGOUSA_GIVE_GOLD_TO_' || DistrictType
FROM Districts;

INSERT INTO Modifiers (ModifierId, ModifierType)
SELECT 'MODIFIER_DISTRICT_PHAGOUSA_GIVE_GOLD_TO_' || DistrictType,
       'MODIFIER_PLAYER_CITIES_DISTRICT_ADJACENCY'
FROM Districts;

INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_DISTRICT_PHAGOUSA_GIVE_GOLD_TO_' || DistrictType,
       'Amount',
       '1'
FROM Districts
UNION
SELECT 'MODIFIER_DISTRICT_PHAGOUSA_GIVE_GOLD_TO_' || DistrictType,
       'Description',
       'LOC_MODIFIER_DISTRICT_PHAGOUSA_GIVE_GOLD'
FROM Districts
UNION
SELECT 'MODIFIER_DISTRICT_PHAGOUSA_GIVE_GOLD_TO_' || DistrictType,
       'DistrictType',
       DistrictType
FROM Districts
UNION
SELECT 'MODIFIER_DISTRICT_PHAGOUSA_GIVE_GOLD_TO_' || DistrictType,
       'YieldType',
       'YIELD_GOLD'
FROM Districts;

INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_DISTRICT_PHAGOUSA', 'MODIFIER_DISTRICT_PHAGOUSA_GIVE_TOURISM');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_PHAGOUSA_GIVE_TOURISM', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_TOURISM_ADJACENCY_YIELD_MOFIFIER',
        0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_PHAGOUSA_GIVE_TOURISM', 'Amount', '100'),
       ('MODIFIER_DISTRICT_PHAGOUSA_GIVE_TOURISM', 'YieldType', 'YIELD_GOLD');

--================
-- 预言书库
-- DISTRICT_TALANTON
--================
-- 刻律德菈的特色区域，替代外交区但解锁更早，建造费用更低，可以重复建造。该区域产出一定的科技值。[NEWLINE]如果还有奇观尚未建成且未被预言，则建成预言书库时可以指定一个奇观发起预言。当被预言的奇观建成时，将获得3个部落村庄奖励，并提供等同于该奇观 [ICON_PRODUCTION] 生产力200%的 [ICON_CULTURE] 文化值、[ICON_GOLD] 金币和[ICON_FAITH] 信仰值。
UPDATE Districts
SET PrereqTech   = NULL,
    PrereqCivic  = 'CIVIC_FOREIGN_TRADE',
    MaxPerPlayer = -1
WHERE DistrictType = 'DISTRICT_TALANTON';

INSERT OR
REPLACE INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT 'DISTRICT_TALANTON',
       Adjacency_YieldChanges.ID
FROM Adjacency_YieldChanges
WHERE YieldType = 'YIELD_SCIENCE' AND Description IS NOT 'Placeholder' AND YieldChange > 0;

--================
-- 长梦宸扉
-- DISTRICT_ORONYX
--================
-- 长夜月的特色区域，替代剧院广场但解锁更早，建造费用更低。建成时获得1项免费市政，城市中的巨作+200%旅游业绩。本城产出的伟人点数+100%。[NEWLINE][NEWLINE]从每个拥有的单位获得+1相邻加成。
UPDATE Districts
SET PrereqTech  = 'TECH_ASTROLOGY',
    PrereqCivic = NULL
WHERE DistrictType = 'DISTRICT_ORONYX';

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ORONYX', 'MODIFIER_DISTRICT_ORONYX_CIVIC');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_ORONYX_CIVIC', 'MODIFIER_PLAYER_GRANT_RANDOM_CIVIC', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_ORONYX_CIVIC', 'Amount', '1');

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
SELECT 'DISTRICT_ORONYX',
       'MODIFIER_DISTRICT_ORONYX_ADJUST_TOURIS_' || GreatWorkObjectType
FROM GreatWorkObjectTypes;
INSERT INTO Modifiers (ModifierId, ModifierType)
SELECT 'MODIFIER_DISTRICT_ORONYX_ADJUST_TOURIS_' || GreatWorkObjectType,
       'MODIFIER_SINGLE_CITY_ADJUST_TOURISM'
FROM GreatWorkObjectTypes;
INSERT INTO ModifierArguments (ModifierId, Name, Value)
SELECT 'MODIFIER_DISTRICT_ORONYX_ADJUST_TOURIS_' || GreatWorkObjectType,
       'GreatWorkObjectType',
       GreatWorkObjectType
FROM GreatWorkObjectTypes
UNION
SELECT 'MODIFIER_DISTRICT_ORONYX_ADJUST_TOURIS_' || GreatWorkObjectType,
       'ScalingFactor',
       '200'
FROM GreatWorkObjectTypes;

-- 本城产出的伟人点数+100%
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ORONYX', 'MODIFIER_DISTRICT_ORONYX_ADD_POINTS_MODIFIER');
INSERT INTO Modifiers (ModifierId, ModifierType)
VALUES ('MODIFIER_DISTRICT_ORONYX_ADD_POINTS_MODIFIER', 'MODIFIER_CITY_INCREASE_GREAT_PERSON_POINT_BONUS');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_ORONYX_ADD_POINTS_MODIFIER', 'Amount', 100);

-- 从每个拥有的单位获得+1相邻加成。
INSERT INTO Types (Type, Kind)
VALUES ('ABILITY_DISTRICT_ORONYX_ADJACENT', 'KIND_ABILITY');
INSERT INTO TypeTags (Type, Tag)
VALUES ('ABILITY_DISTRICT_ORONYX_ADJACENT', 'CLASS_ALL_UNITS');
INSERT INTO UnitAbilities (UnitAbilityType, Name, Description, Inactive)
VALUES ('ABILITY_DISTRICT_ORONYX_ADJACENT',
        'LOC_ABILITY_DISTRICT_ORONYX_ADJACENT_NAME',
        'LOC_ABILITY_DISTRICT_ORONYX_ADJACENT_DESCRIPTION',
        1);

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ORONYX', 'MODFEAT_GRANT_ABILITY_DISTRICT_ORONYX');
INSERT INTO Modifiers (ModifierId, ModifierType)
VALUES ('MODFEAT_GRANT_ABILITY_DISTRICT_ORONYX', 'MODIFIER_PLAYER_UNITS_GRANT_ABILITY');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_GRANT_ABILITY_DISTRICT_ORONYX', 'AbilityType', 'ABILITY_DISTRICT_ORONYX_ADJACENT');
INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId)
VALUES ('ABILITY_DISTRICT_ORONYX_ADJACENT', 'MODIFIER_ABILITY_DISTRICT_ORONYX_ADJACENT');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_ABILITY_DISTRICT_ORONYX_ADJACENT', 'MODIFIER_NW_AM_PLAYER_DISTRICTS_ADJUST_BASE_YIELD_CHANGE', 0, 0,
        0, NULL, 'NW_DISTRICT_IS_DISTRICT_ORONYX');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_ABILITY_DISTRICT_ORONYX_ADJACENT', 'Amount', '1'),
       ('MODIFIER_ABILITY_DISTRICT_ORONYX_ADJACENT', 'YieldType', 'YIELD_CULTURE');
-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AM_PLAYER_DISTRICTS_ADJUST_BASE_YIELD_CHANGE', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AM_PLAYER_DISTRICTS_ADJUST_BASE_YIELD_CHANGE', 'COLLECTION_PLAYER_DISTRICTS',
        'EFFECT_ADJUST_DISTRICT_BASE_YIELD_CHANGE');


--================
-- 万壑岩心
-- DISTRICT_GEORIOS
--================
-- 丹恒•腾荒的特色区域，替代工业区但解锁更早，建造费用更低。建成时获得1个大工程师和1个自然学家。每个万壑岩心为大工程师和大科学家+1使用次数。为6个单元格以内的万壑岩心+100%相邻加成、城市+2魅力值。
UPDATE Districts
SET PrereqTech = 'TECH_MINING',Appeal = 1
WHERE DistrictType = 'DISTRICT_GEORIOS';

INSERT OR
REPLACE INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT 'DISTRICT_GEORIOS',
       Adjacency_YieldChanges.ID
FROM Adjacency_YieldChanges
WHERE YieldType = 'YIELD_PRODUCTION' AND Description IS NOT 'Placeholder' AND YieldChange > 0;

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_GEORIOS', 'MODIFIER_DISTRICT_GEORIOS_GRANT_GREAT_PERSON_CLASS_ENGINEER');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_GEORIOS_GRANT_GREAT_PERSON_CLASS_ENGINEER',
        'MODIFIER_SINGLE_CITY_GRANT_GREAT_PERSON_CLASS_IN_CITY', 1, 1, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_GEORIOS_GRANT_GREAT_PERSON_CLASS_ENGINEER', 'Amount', '1'),
       ('MODIFIER_DISTRICT_GEORIOS_GRANT_GREAT_PERSON_CLASS_ENGINEER', 'GreatPersonClassType',
        'GREAT_PERSON_CLASS_ENGINEER');

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_GEORIOS', 'MODIFIER_DISTRICT_GEORIOS_FREE_UNIT_NATURALIST');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_GEORIOS_FREE_UNIT_NATURALIST', 'MODIFIER_SINGLE_CITY_GRANT_UNIT_IN_CITY', 0, 0, 0, NULL,
        NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_GEORIOS_FREE_UNIT_NATURALIST', 'AllowUniqueOverride', '1'),
       ('MODIFIER_DISTRICT_GEORIOS_FREE_UNIT_NATURALIST', 'Amount', '1'),
       ('MODIFIER_DISTRICT_GEORIOS_FREE_UNIT_NATURALIST', 'UnitType', 'UNIT_NATURALIST');

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_GEORIOS', 'MODIFIER_DISTRICT_GEORIOS_EXTRA_BC');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_GEORIOS_EXTRA_BC', 'MODIFIER_PLAYER_UNITS_ADJUST_GREAT_PERSON_CHARGES', 0, 0, 0, NULL,
        'REQS_MODIFIER_DISTRICT_GEORIOS_EXTRA_BC');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_GEORIOS_EXTRA_BC', 'Amount', '1');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('REQS_MODIFIER_DISTRICT_GEORIOS_EXTRA_BC', 'REQUIREMENTSET_TEST_ANY');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('REQS_MODIFIER_DISTRICT_GEORIOS_EXTRA_BC', 'REQ_NW_AM_UNIT_IS_GREAT_PERSON_CLASS_ENGINEER'),
       ('REQS_MODIFIER_DISTRICT_GEORIOS_EXTRA_BC', 'REQ_NW_AM_UNIT_IS_GREAT_PERSON_CLASS_SCIENTIST');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType)
VALUES ('REQ_NW_AM_UNIT_IS_GREAT_PERSON_CLASS_ENGINEER', 'REQUIREMENT_GREAT_PERSON_TYPE_MATCHES'),
       ('REQ_NW_AM_UNIT_IS_GREAT_PERSON_CLASS_SCIENTIST', 'REQUIREMENT_GREAT_PERSON_TYPE_MATCHES');
INSERT INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQ_NW_AM_UNIT_IS_GREAT_PERSON_CLASS_ENGINEER', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_ENGINEER'),
       ('REQ_NW_AM_UNIT_IS_GREAT_PERSON_CLASS_SCIENTIST', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_SCIENTIST');


INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_GEORIOS', 'MODIFIER_DISTRICT_GEORIOS_EXTRA_ADJ');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_GEORIOS_EXTRA_ADJ', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_MODIFIER', 0, 0, 0, NULL,
        'REQS_MODIFIER_DISTRICT_GEORIOS_EXTRA_ADJ');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_GEORIOS_EXTRA_ADJ', 'Amount', '100'),
       ('MODIFIER_DISTRICT_GEORIOS_EXTRA_ADJ', 'YieldType', 'YIELD_PRODUCTION');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('REQS_MODIFIER_DISTRICT_GEORIOS_EXTRA_ADJ', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('REQS_MODIFIER_DISTRICT_GEORIOS_EXTRA_ADJ', 'NW_DISTRICT_IS_DISTRICT_GEORIOS_REQUIREMENT'),
       ('REQS_MODIFIER_DISTRICT_GEORIOS_EXTRA_ADJ', 'REQ_NW_OWNER_IN_6_PLOTS');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType)
VALUES ('REQ_NW_OWNER_IN_6_PLOTS', 'REQUIREMENT_PLOT_ADJACENT_TO_OWNER');
INSERT INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQ_NW_OWNER_IN_6_PLOTS', 'MaxDistance', '6'),
       ('REQ_NW_OWNER_IN_6_PLOTS', 'MinDistance', '0');


INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_GEORIOS', 'MODIFIER_DISTRICT_GEORIOS_EXTRA_APPEAL');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_GEORIOS_EXTRA_APPEAL', 'MODIFIER_PLAYER_CITIES_ADJUST_CITY_APPEAL', 0, 0, 0, NULL,
        'REQS_NW_OWNER_IN_6_PLOTS');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_GEORIOS_EXTRA_APPEAL', 'Amount', '2');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('REQS_NW_OWNER_IN_6_PLOTS', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('REQS_NW_OWNER_IN_6_PLOTS', 'REQ_NW_OWNER_IN_6_PLOTS');