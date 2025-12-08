--	FILE: Amphoreus_Unit.sql
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni
--	Copyright (c) 2025.
--	All rights reserved.
--  DateCreated: 2025/10/26 15:31:52
--======================================================================
--  作者： 千川白浪
--  特别鸣谢： 优妮
--======================================================================

-- 单位基础类型、标签、分类
INSERT INTO Types(Type, Kind)
VALUES ('UNIT_GOLD_SON', 'KIND_UNIT');

INSERT INTO TypeTags(Type, Tag)
SELECT 'UNIT_GOLD_SON', Tag
FROM TypeTags
WHERE Type = 'UNIT_INFANTRY';

INSERT INTO UnitAiInfos(UnitType, AiType)
SELECT 'UNIT_GOLD_SON', AiType
FROM UnitAiInfos
WHERE UnitType = 'UNIT_INFANTRY';

INSERT OR IGNORE INTO Units(UnitType, Name, BaseSightRange, BaseMoves, Combat, RangedCombat, Range, Bombard, Domain,
                            FormationClass, Cost, PopulationCost, FoundCity, FoundReligion, MakeTradeRoute,
                            EvangelizeBelief, LaunchInquisition, RequiresInquisition, BuildCharges, ReligiousStrength,
                            ReligionEvictPercent, SpreadCharges, ReligiousHealCharges, ExtractsArtifacts, Description,
                            Flavor, CanCapture, CanRetreatWhenCaptured, TraitType, AllowBarbarians,
                            CostProgressionModel, CostProgressionParam1, PromotionClass, InitialLevel, NumRandomChoices,
                            PrereqTech, PrereqCivic, PrereqDistrict, PrereqPopulation, LeaderType, CanTrain,
                            StrategicResource, PurchaseYield, MustPurchase, Maintenance, Stackable, AirSlots,
                            CanTargetAir, PseudoYieldType, ZoneOfControl, AntiAirCombat, Spy, WMDCapable, ParkCharges,
                            IgnoreMoves, TeamVisibility, ObsoleteTech, ObsoleteCivic, MandatoryObsoleteTech,
                            MandatoryObsoleteCivic, AdvisorType, EnabledByReligion, TrackReligion, DisasterCharges,
                            UseMaxMeleeTrainedStrength, ImmediatelyName, CanEarnExperience)
VALUES ('UNIT_GOLD_SON',
        'LOC_UNIT_GOLD_SON_NAME',
        2,
        2,
        36,
        0,
        0,
        0,
        'DOMAIN_LAND',
        'FORMATION_CLASS_LAND_COMBAT',
        90,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        'LOC_UNIT_GOLD_SON_DESCRIPTION',
        NULL,
        1,
        0,
        'TRAIT_UNIT_GOLD_SON',
        0,
        'NO_COST_PROGRESSION',
        0,
        'PROMOTION_CLASS_MELEE',
        1,
        0,
        'TECH_IRON_WORKING',
        NULL,
        NULL,
        NULL,
        NULL,
        1,
        NULL,
        'YIELD_GOLD',
        0,
        0,
        0,
        0,
        0,
        NULL,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        NULL,
        NULL,
        NULL,
        NULL,
        'ADVISOR_CONQUEST',
        0,
        0,
        0,
        0,
        0,
        1);

INSERT INTO UnitReplaces(CivUniqueUnitType, ReplacesUnitType) VALUES
('UNIT_GOLD_SON','UNIT_SWORDSMAN');


-- 定义一个新的单位能力
INSERT INTO Types (Type, Kind)
VALUES ('ABILITY_UNIT_GOLD_SON', 'KIND_ABILITY');
-- 定义一个新的单位集合
INSERT INTO Tags (Tag, Vocabulary)
VALUES ('CLASS_UNIT_GOLD_SON', 'ABILITY_CLASS');
-- 将单位能力和单位集合相关联
INSERT INTO TypeTags (Type, Tag)
VALUES ('UNIT_GOLD_SON', 'CLASS_UNIT_GOLD_SON'),
       ('ABILITY_UNIT_GOLD_SON', 'CLASS_UNIT_GOLD_SON');

INSERT INTO UnitAbilities (UnitAbilityType, Name, Description, Inactive)
VALUES ('ABILITY_UNIT_GOLD_SON',
        'LOC_UNIT_GOLD_SON_NAME',
        'LOC_UNIT_GOLD_SON_DESCRIPTION',
        0 -- 该单位能力是否默认隐藏。为1时需要使用Modifier授予
       );

-- 已经定义好了授予的Modifier可以直接修改使用
-- INSERT INTO TraitModifiers (TraitType, ModifierId)
-- VALUES ('TRAIT_GRANT_UA_EXAMPLE', 'MODFEAT_GRANT_ABILITY_UNIT_GOLD_SON');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODFEAT_GRANT_ABILITY_UNIT_GOLD_SON', 'MODIFIER_PLAYER_UNITS_GRANT_ABILITY', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_GRANT_ABILITY_UNIT_GOLD_SON', 'AbilityType', 'ABILITY_UNIT_GOLD_SON');

-- 驻扎在市中心时，使城市额外获得10点防御力。
INSERT INTO UnitAbilityModifiers (UnitAbilityType, ModifierId) VALUES
('ABILITY_UNIT_GOLD_SON', 'MODIFIER_ABILITY_UNIT_GOLD_SON_DEFENSE');
INSERT INTO Modifiers (ModifierId, ModifierType, OwnerStackLimit,SubjectStackLimit, SubjectRequirementSetId) VALUES
('MODIFIER_ABILITY_UNIT_GOLD_SON_DEFENSE', 'MODIFIER_PLAYER_CITIES_ADJUST_INNER_DEFENSE', 1,1, 'REQS_NW_OWNER_1_PLOTS_AWAY');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_ABILITY_UNIT_GOLD_SON_DEFENSE', 'Amount', '10');
