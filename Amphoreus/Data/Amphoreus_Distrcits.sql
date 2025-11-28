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
       Cost / 2,
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
       YieldChange
FROM District_CitizenYieldChanges d
         JOIN NW_Amphoreus_Districts nd ON d.DistrictType = nd.ReplacesDistrictType;

INSERT INTO District_GreatPersonPoints(DistrictType, GreatPersonClassType, PointsPerTurn)
SELECT nd.DistrictType,
       GreatPersonClassType,
       PointsPerTurn
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
       YieldChangeAsDomesticDestination,
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
INSERT INTO Modifiers(ModifierId, ModifierType, OwnerRequirementSetId)
SELECT 'MODIFIER_' || DistrictType || '_CULTURE_BOMB_TRIGGER',
       'MODIFIER_PLAYER_ADD_CULTURE_BOMB_TRIGGER',
       'PLAYER_HAS_GOLDEN_AGE'
FROM NW_Amphoreus_Districts;
INSERT INTO ModifierArguments(ModifierId, Name, Value)
SELECT 'MODIFIER_' || DistrictType || '_CULTURE_BOMB_TRIGGER', 'DistrictType', DistrictType
FROM NW_Amphoreus_Districts;


--======================================================================
-- 刻法勒广场
-- DISTRICT_JANUS
--======================================================================
-- 基础+2
INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, AdjacentDistrict)
VALUES ('ADJACENCY_DISTRICT_JANUS_SELF', 'LOC_ADJACENCY_DISTRICT_JANUS_SELF', 'YIELD_FAITH', 2, 'DISTRICT_CITY_CENTER');
-- 相邻规则绑定区域
INSERT INTO District_Adjacencies(DistrictType, YieldChangeId)
VALUES ('DISTRICT_JANUS', 'ADJACENCY_DISTRICT_JANUS_SELF');

DELETE
FROM District_Adjacencies
WHERE DistrictType = 'DISTRICT_JANUS'
  AND YieldChangeId LIKE 'Mountain/_Faith_' ESCAPE '/';


-- 允许购买XX区域中的建筑
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_JANUS', 'MODIFIER_DISTRICT_JANUS_FAITH_PURCHASE');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_JANUS_FAITH_PURCHASE', 'MODIFIER_CITY_ENABLE_BUILDING_FAITH_PURCHASE', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_JANUS_FAITH_PURCHASE', 'DistrictType', 'DISTRICT_JANUS');

--======================================================================
-- 悬锋斗技场
-- DISTRICT_NIKADOR
--======================================================================

INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, AdjacentDistrict)
VALUES ('ADJACENCY_DISTRICT_NIKADOR_DISTRICT_ENTERTAINMENT_COMPLEX',
        'LOC_ADJACENCY_DISTRICT_NIKADOR_DISTRICT_ENTERTAINMENT_COMPLEX', 'YIELD_PRODUCTION', 2,
        'DISTRICT_ENTERTAINMENT_COMPLEX');
-- 相邻规则绑定区域
INSERT INTO District_Adjacencies(DistrictType, YieldChangeId)
VALUES ('DISTRICT_NIKADOR', 'ADJACENCY_DISTRICT_NIKADOR_DISTRICT_ENTERTAINMENT_COMPLEX');


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
SELECT 'MODIFIER_NW_FIGHTING_CAMP_' || BuildingType || '_GIVER_HOUSING', 'Amount', 1
FROM Buildings
WHERE PrereqDistrict = 'DISTRICT_ENCAMPMENT';

--======================================================================
-- 云石天宫
-- DISTRICT_MNESTIA
--======================================================================

UPDATE Districts
SET PrereqTech = 'TECH_IRRIGATION'
WHERE DistrictType = 'DISTRICT_MNESTIA';

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_MNESTIA', 'MODIFIER_DISTRICT_MNESTIA_ADD_POPULATION');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_MNESTIA_ADD_POPULATION', 'MODIFIER_NW_AM_SINGLE_CITY_ADD_POPULATION', 1, 1, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_MNESTIA_ADD_POPULATION', 'Amount', '3');

-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AM_SINGLE_CITY_ADD_POPULATION', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AM_SINGLE_CITY_ADD_POPULATION', 'COLLECTION_OWNER', 'EFFECT_ADJUST_CITY_POPULATION');


--================
-- 树庭
-- DISTRICT_CERCES
--================

INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_CERCES', 'MODIFIER_DISTRICT_CERCES_GRANT_BUILDING');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent)
VALUES ('MODIFIER_DISTRICT_CERCES_GRANT_BUILDING', 'MODIFIER_SINGLE_CITY_GRANT_BUILDING_IN_CITY_IGNORE', 0, 1);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_CERCES_GRANT_BUILDING', 'BuildingType', 'BUILDING_WALLS');

DELETE
FROM District_Adjacencies
WHERE DistrictType = 'DISTRICT_CERCES';

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
WHERE ID IN (SELECT DISTINCT YieldChangeId FROM District_Adjacencies WHERE DistrictType = 'DISTRICT_CAMPUS')
  AND YieldChange > 0;

-- 再获得所有文化值加成
INSERT OR
REPLACE
INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT 'DISTRICT_CERCES',
       'ADJACENCY_DISTRICT_CERCES_' || ID
FROM Adjacency_YieldChanges
WHERE ID IN (SELECT DISTINCT YieldChangeId FROM District_Adjacencies WHERE DistrictType = 'DISTRICT_CAMPUS')
  AND YieldChange > 0;

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

--================
-- 龙骸古城
-- DISTRICT_THANATOS
--================
-- 建于首都时提供虚拟建筑
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_THANATOS', 'MODIFIER_DISTRICT_THANATOS_GRANT_BUILDING');
INSERT INTO Modifiers (ModifierId, ModifierType, OwnerRequirementSetId, Permanent)
VALUES ('MODIFIER_DISTRICT_THANATOS_GRANT_BUILDING', 'MODIFIER_SINGLE_CITY_GRANT_BUILDING_IN_CITY_IGNORE',
        'BUILDING_IS_PALACE', 1);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_THANATOS_GRANT_BUILDING', 'BuildingType', 'BUILDING_DISTRICT_THANATOS');

-- 拥有3个文物槽位，建成时提供一个考古学家，文物产出等于信仰值产出16倍的科技值和金币。
INSERT INTO Building_GreatWorks(BuildingType, GreatWorkSlotType, NumSlots, ThemingUniquePerson, ThemingSameObjectType,
                                ThemingUniqueCivs, ThemingSameEras, ThemingYieldMultiplier, ThemingTourismMultiplier,
                                NonUniquePersonYield, NonUniquePersonTourism, ThemingBonusDescription)
SELECT 'BUILDING_DISTRICT_THANATOS',
       GreatWorkSlotType,
       NumSlots,
       ThemingUniquePerson,
       ThemingSameObjectType,
       ThemingUniqueCivs,
       ThemingSameEras,
       ThemingYieldMultiplier,
       ThemingTourismMultiplier,
       NonUniquePersonYield,
       NonUniquePersonTourism,
       ThemingBonusDescription
FROM Building_GreatWorks
WHERE BuildingType = 'BUILDING_MUSEUM_ARTIFACT';

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
       Cost,                                          -- 生产力
       PopulationCost,                                -- 消耗人口
       FoundCity,                                     -- 能否创建城市
       FoundReligion,                                 -- 能否创建宗教
       MakeTradeRoute,                                -- 能否创建商路
       EvangelizeBelief,                              -- 能否纳入新信仰
       LaunchInquisition,                             -- 是否能开启宗教审讯
       RequiresInquisition,                           -- 是否需要已开启宗教审讯才能生产/购买
       BuildCharges,                                  -- 劳动力
       ReligiousStrength,                             -- 宗教战斗力
       ReligionEvictPercent,                          -- 压教比例
       SpreadCharges,                                 -- 传教次数
       ReligiousHealCharges,                          -- 宗教治疗次数
       ExtractsArtifacts,                             -- 是否可以挖掘文物。
       'LOC_UNIT_ARCHAEOLOGIST_THANATOS_DESCRIPTION', -- 描述文本
       Flavor,
       CanCapture,                                    -- 可以俘虏平民单位
       CanRetreatWhenCaptured,                        -- 被俘虏时传送回最近城市
       NULL,                                          -- 绑定特性
       AllowBarbarians,                               -- 允许蛮族生成
       CostProgressionModel,                          -- 涨价方式 NO_COST_PROGRESSION不涨价
       CostProgressionParam1,                         -- 涨价参数 COST_PROGRESSION_GAME_PROGRESS按游戏进程涨价 CostProgressionParam1填最终（即全科技/市政后的）价格百分比 COST_PROGRESSION_PREVIOUS_COPIES按已有数量涨价 CostProgressionParam1填每一个涨价的数量
       PromotionClass,                                -- 单位的晋升树，指向UnitPromotionClasses表的PromotionClassType列。
       InitialLevel,                                  -- 单位的初始等级，1是没有初始升级，2是附赠1级初始升级，以此类推。
       NumRandomChoices,                              -- 单位升级时从所有升级里随机抽出的数量
       NULL,                                          -- 前置科技
       NULL,                                          -- 前置市政
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
SET PrereqTech            = 'TECH_ASTRONOMY',
    Cost                  = 54,
    CostProgressionModel='COST_PROGRESSION_NUM_UNDER_AVG_PLUS_TECH',
    CostProgressionParam1 = 40
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

--================
-- 云石市集
-- DISTRICT_ZAGREUS
--================
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_ZAGREUS', 'MODIFIER_DISTRICT_ZAGREUS_UNIT_PURCHASE_COST');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_UNIT_PURCHASE_COST', 'MODIFIER_NW_AM_SINGLE_CITY_ADJUST_UNIT_PURCHASE_COST', 0, 0, 0,
        NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_ZAGREUS_UNIT_PURCHASE_COST', 'Amount', '35'),
       ('MODIFIER_DISTRICT_ZAGREUS_UNIT_PURCHASE_COST', 'UnitType', 'UNIT_TRADER');
-- Custom ModifierType
INSERT INTO Types (Type, Kind)
VALUES ('MODIFIER_NW_AM_SINGLE_CITY_ADJUST_UNIT_PURCHASE_COST', 'KIND_MODIFIER');
INSERT INTO DynamicModifiers (ModifierType, CollectionType, EffectType)
VALUES ('MODIFIER_NW_AM_SINGLE_CITY_ADJUST_UNIT_PURCHASE_COST', 'COLLECTION_OWNER', 'EFFECT_ADJUST_UNIT_PURCHASE_COST');


--================
-- 创世涡心
-- DISTRICT_KEPHALE
--================
-- 使此城每回合的忠诚度+8、为相邻区域提供标准相邻加成。奖励2个 [Icon_Governor] 总督头衔。
INSERT INTO DistrictModifiers (DistrictType, ModifierId)
VALUES ('DISTRICT_KEPHALE', 'MODIFIER_DISTRICT_KEPHALE_GP');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_DISTRICT_KEPHALE_GP', 'MODIFIER_PLAYER_ADJUST_GOVERNOR_POINTS', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_DISTRICT_KEPHALE_GP', 'Delta', '1');


--================
-- 浮影海庭
-- DISTRICT_PHAGOUSA
--================
-- 海瑟音的特色区域，替代港口但解锁更早，建造费用更低。该区域具有区域防御，建成后免费获得防洪坝和该区域内的所有建筑。

UPDATE Districts
SET HitPoints               = 100,
    CaptureRemovesBuildings = 1,
    CanAttack               = 1,
    NoAdjacentCity          = 1
WHERE DistrictType = 'DISTRICT_PHAGOUSA';

-- 从每个相邻的礁石单元格+2 [ICON_GOLD] 金币。
INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, AdjacentFeature)
VALUES ('ADJACENCY_DISTRICT_PHAGOUSA', 'LOC_ADJACENCY_DISTRICT_PHAGOUSA', 'YIELD_GOLD', 2, 'FEATURE_REEF');
-- 相邻规则绑定区域
INSERT INTO District_Adjacencies(DistrictType, YieldChangeId)
VALUES ('DISTRICT_PHAGOUSA', 'ADJACENCY_DISTRICT_PHAGOUSA');

--================
-- 预言书库
-- DISTRICT_TALANTON
--================
-- 刻律德菈的特色区域，替代外交区但解锁更早，建造费用更低，可以重复建造。该区域产出一定的科技值。[NEWLINE]如果还有奇观尚未建成且未被预言，则建成预言书库时可以指定一个奇观发起预言。当被预言的奇观建成时，将获得3个部落村庄奖励，并提供等同于该奇观 [ICON_PRODUCTION] 生产力200%的 [ICON_CULTURE] 文化值、[ICON_GOLD] 金币和[ICON_FAITH] 信仰值。
INSERT OR
REPLACE
INTO District_Adjacencies(DistrictType, YieldChangeId)
SELECT 'DISTRICT_TALANTON',
       Adjacency_YieldChanges.ID
FROM Adjacency_YieldChanges
WHERE YieldType = 'YIELD_SCIENCE'
  AND Description IS NOT 'Placeholder'
  AND YieldChange > 0;

--================
-- 长梦宸扉
-- DISTRICT_ORONYX
--================
-- 为相邻单元格提供+3魅力值。从其他长梦宸扉获得标准相邻加成。产出等同于相邻加成的旅游业绩。
UPDATE Districts
SET Appeal = 3
WHERE DistrictType = 'DISTRICT_ORONYX';

INSERT INTO Adjacency_YieldChanges(ID, Description, YieldType, YieldChange, AdjacentDistrict)
VALUES ('ADJACENCY_DISTRICT_ORONYX', 'LOC_ADJACENCY_DISTRICT_ORONYX', 'YIELD_CULTURE', 1, 'DISTRICT_ORONYX');
-- 相邻规则绑定区域
INSERT INTO District_Adjacencies(DistrictType, YieldChangeId)
VALUES ('DISTRICT_ORONYX', 'ADJACENCY_DISTRICT_ORONYX');

INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_DISTRICT_ORONYX', 'MODIFIER_TRAIT_DISTRICT_ORONYX_TOURISM_ADJACENCY_YIELD_MOFIFIER');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_DISTRICT_ORONYX_TOURISM_ADJACENCY_YIELD_MOFIFIER',
        'MODIFIER_PLAYER_DISTRICTS_ADJUST_TOURISM_ADJACENCY_YIELD_MOFIFIER', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_DISTRICT_ORONYX_TOURISM_ADJACENCY_YIELD_MOFIFIER', 'Amount', '100'),
       ('MODIFIER_TRAIT_DISTRICT_ORONYX_TOURISM_ADJACENCY_YIELD_MOFIFIER', 'YieldType', 'YIELD_CULTURE');


--================
-- 万壑岩心
-- DISTRICT_GEORIOS
--================
-- 每回合提供+3 [ICON_GreatEngineer] 大工程师点数。[NEWLINE][NEWLINE]该区域无法从水渠获得相邻加成。但每招募一个 [ICON_GreatEngineer] 大工程师，所有的万壑岩心就会+1 [ICON_PRODUCTION] 生产力相邻加成。
UPDATE District_GreatPersonPoints
SET PointsPerTurn = 3
WHERE DistrictType = 'DISTRICT_GEORIOS';

DELETE
FROM District_Adjacencies
WHERE YieldChangeId = 'Aqueduct_Production'
  AND DistrictType = 'DISTRICT_GEORIOS';

INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_DISTRICT_GEORIOS', 'MODIFIER_TRAIT_DISTRICT_GEORIOS_GPATTACH');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_DISTRICT_GEORIOS_GPATTACH', 'MODIFIER_PLAYER_UNITS_ATTACH_MODIFIER', 0, 0, 0, NULL,
        'NW_AM_UNIT_IS_GE');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_DISTRICT_GEORIOS_GPATTACH', 'ModifierId', 'MODIFIER_TRAIT_DISTRICT_GEORIOS_GP');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
VALUES ('NW_AM_UNIT_IS_GE', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId)
VALUES ('NW_AM_UNIT_IS_GE', 'REQ_NW_AM_UNIT_IS_GE');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType)
VALUES ('REQ_NW_AM_UNIT_IS_GE', 'REQUIREMENT_GREAT_PERSON_TYPE_MATCHES');
INSERT INTO RequirementArguments (RequirementId, Name, Value)
VALUES ('REQ_NW_AM_UNIT_IS_GE', 'GreatPersonClassType', 'GREAT_PERSON_CLASS_ENGINEER');


INSERT INTO TraitModifiers (TraitType, ModifierId)
VALUES ('TRAIT_DISTRICT_GEORIOS', 'MODIFIER_TRAIT_DISTRICT_GEORIOS_GP');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_TRAIT_DISTRICT_GEORIOS_GP', 'MODIFIER_PLAYER_DISTRICT_ADJUST_BASE_YIELD_CHANGE', 0, 0, 0, NULL,
        'NW_DISTRICT_IS_DISTRICT_GEORIOS');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_TRAIT_DISTRICT_GEORIOS_GP', 'Amount', '1'),
       ('MODIFIER_TRAIT_DISTRICT_GEORIOS_GP', 'YieldType', 'YIELD_PRODUCTION');

