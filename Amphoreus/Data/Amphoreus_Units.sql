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
        3,
        4,
        25,
        0,
        0,
        0,
        'DOMAIN_LAND',
        'FORMATION_CLASS_LAND_COMBAT',
        100,
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
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        0,
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
        1,
        0,
        1);