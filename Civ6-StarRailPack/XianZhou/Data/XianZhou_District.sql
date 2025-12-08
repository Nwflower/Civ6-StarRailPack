-- XianZhou_District
-- Author: Pen
-- DateCreated: 2024/2/3 9:53:22
--------------------------------------------------------------
insert or
replace into Types
    (Type, Kind)
values ('DISTRICT_XIANZHOU_ALCHEMY_COMMISSION', 'KIND_DISTRICT'),
       ('DISTRICT_XIANZHOU_CLOUD_KNIGHTS', 'KIND_DISTRICT'),

       ('DISTRICT_XIANZHOU_TENLORDS_COMMISSION', 'KIND_DISTRICT');

insert or
replace into DistrictReplaces
    (CivUniqueDistrictType, ReplacesDistrictType)
values ('DISTRICT_XIANZHOU_CLOUD_KNIGHTS', 'DISTRICT_ENCAMPMENT'),

       ('DISTRICT_XIANZHOU_TENLORDS_COMMISSION', 'DISTRICT_PRESERVE');

insert or
replace into Districts
(DistrictType, TraitType, Name, Description, PrereqTech, PrereqCivic, Coast, Cost, RequiresPlacement,
 RequiresPopulation, NoAdjacentCity, CityCenter, Aqueduct, InternalOnly, ZOC, FreeEmbark, HitPoints,
 CaptureRemovesBuildings, CaptureRemovesCityDefenses, PlunderType, PlunderAmount, TradeEmbark, MilitaryDomain,
 CostProgressionModel, CostProgressionParam1, Appeal, Housing, Entertainment, OnePerCity, AllowsHolyCity, Maintenance,
 AirSlots, CitizenSlots, TravelTime, CityStrengthModifier, AdjacentToLand, CanAttack, AdvisorType,
 CaptureRemovesDistrict, MaxPerPlayer)
Select 'DISTRICT_XIANZHOU_ALCHEMY_COMMISSION',
       'TRAIT_DISTRICT_XIANZHOU_ALCHEMY_COMMISSION',
       'LOC_DISTRICT_XIANZHOU_ALCHEMY_COMMISSION_NAME',
       'LOC_DISTRICT_XIANZHOU_ALCHEMY_COMMISSION_DESCRIPTION',
       'TECH_ENGINEERING',
       null,
       Coast,
       Cost * 0.5,
       RequiresPlacement,
       RequiresPopulation,
       NoAdjacentCity,
       CityCenter,
       Aqueduct,
       InternalOnly,
       ZOC,
       FreeEmbark,
       HitPoints,
       CaptureRemovesBuildings,
       CaptureRemovesCityDefenses,
       PlunderType,
       PlunderAmount,
       TradeEmbark,
       MilitaryDomain,
       CostProgressionModel,
       CostProgressionParam1,
       Appeal,
       3,
       Entertainment,
       1,
       AllowsHolyCity,
       Maintenance,
       AirSlots,
       2,
       TravelTime,
       0,
       AdjacentToLand,
       CanAttack,
       AdvisorType,
       CaptureRemovesDistrict,
       MaxPerPlayer
from Districts
where DistrictType = 'DISTRICT_NEIGHBORHOOD'
Union
Select 'DISTRICT_XIANZHOU_CLOUD_KNIGHTS',
       'TRAIT_DISTRICT_XIANZHOU_CLOUD_KNIGHTS',
       'LOC_DISTRICT_XIANZHOU_CLOUD_KNIGHTS_NAME',
       'LOC_DISTRICT_XIANZHOU_CLOUD_KNIGHTS_DESCRIPTION',
       PrereqTech,
       PrereqCivic,
       Coast,
       Cost * 0.5,
       RequiresPlacement,
       RequiresPopulation,
       NoAdjacentCity,
       CityCenter,
       Aqueduct,
       InternalOnly,
       ZOC,
       FreeEmbark,
       HitPoints,
       CaptureRemovesBuildings,
       CaptureRemovesCityDefenses,
       PlunderType,
       PlunderAmount,
       TradeEmbark,
       MilitaryDomain,
       CostProgressionModel,
       CostProgressionParam1,
       Appeal,
       Housing,
       Entertainment,
       OnePerCity,
       AllowsHolyCity,
       Maintenance,
       AirSlots,
       1,
       TravelTime,
       CityStrengthModifier,
       AdjacentToLand,
       CanAttack,
       AdvisorType,
       CaptureRemovesDistrict,
       MaxPerPlayer
from Districts
where DistrictType = 'DISTRICT_ENCAMPMENT'

Union
Select 'DISTRICT_XIANZHOU_TENLORDS_COMMISSION',
       'TRAIT_DISTRICT_XIANZHOU_TENLORDS_COMMISSION',
       'LOC_DISTRICT_XIANZHOU_TENLORDS_COMMISSION_NAME',
       'LOC_DISTRICT_XIANZHOU_TENLORDS_COMMISSION_DESCRIPTION',
       PrereqTech,
       PrereqCivic,
       Coast,
       Cost * 0.5,
       RequiresPlacement,
       RequiresPopulation,
       NoAdjacentCity,
       CityCenter,
       Aqueduct,
       InternalOnly,
       ZOC,
       FreeEmbark,
       HitPoints,
       CaptureRemovesBuildings,
       CaptureRemovesCityDefenses,
       PlunderType,
       PlunderAmount,
       TradeEmbark,
       MilitaryDomain,
       CostProgressionModel,
       CostProgressionParam1,
       -1,
       2,
       Entertainment,
       OnePerCity,
       AllowsHolyCity,
       Maintenance,
       AirSlots,
       CitizenSlots,
       TravelTime,
       CityStrengthModifier,
       AdjacentToLand,
       CanAttack,
       AdvisorType,
       CaptureRemovesDistrict,
       MaxPerPlayer
from Districts
where DistrictType = 'DISTRICT_PRESERVE';

insert or
replace into Districts_XP2
(DistrictType, OnePerRiver, PreventsFloods, PreventsDrought, Canal, AttackRange)
Select 'DISTRICT_XIANZHOU_ALCHEMY_COMMISSION', OnePerRiver, PreventsFloods, PreventsDrought, Canal, AttackRange
from Districts_XP2
where DistrictType = 'DISTRICT_NEIGHBORHOOD'
Union
Select 'DISTRICT_XIANZHOU_CLOUD_KNIGHTS', OnePerRiver, PreventsFloods, PreventsDrought, Canal, AttackRange
from Districts_XP2
where DistrictType = 'DISTRICT_ENCAMPMENT'

Union
Select 'DISTRICT_XIANZHOU_TENLORDS_COMMISSION', OnePerRiver, PreventsFloods, PreventsDrought, Canal, AttackRange
from Districts_XP2
where DistrictType = 'DISTRICT_PRESERVE';

--other bonus
insert or
replace into District_TradeRouteYields
(DistrictType, YieldType, YieldChangeAsOrigin, YieldChangeAsDomesticDestination, YieldChangeAsInternationalDestination)
Select 'DISTRICT_XIANZHOU_ALCHEMY_COMMISSION',
       YieldType,
       YieldChangeAsOrigin,
       YieldChangeAsDomesticDestination,
       YieldChangeAsInternationalDestination
from District_TradeRouteYields
Where District_TradeRouteYields.DistrictType = 'DISTRICT_NEIGHBORHOOD'
Union
Select 'DISTRICT_XIANZHOU_CLOUD_KNIGHTS',
       YieldType,
       YieldChangeAsOrigin,
       YieldChangeAsDomesticDestination,
       YieldChangeAsInternationalDestination
from District_TradeRouteYields
Where District_TradeRouteYields.DistrictType = 'DISTRICT_ENCAMPMENT'

Union
Select 'DISTRICT_XIANZHOU_TENLORDS_COMMISSION',
       YieldType,
       YieldChangeAsOrigin,
       YieldChangeAsDomesticDestination,
       YieldChangeAsInternationalDestination
from District_TradeRouteYields
Where District_TradeRouteYields.DistrictType = 'DISTRICT_PRESERVE';

insert or
replace into District_CitizenYieldChanges
    (DistrictType, YieldType, YieldChange)
Select 'DISTRICT_XIANZHOU_TENLORDS_COMMISSION', YieldType, YieldChange
from District_CitizenYieldChanges
Where District_CitizenYieldChanges.DistrictType = 'DISTRICT_PRESERVE';


insert or
replace into District_CitizenYieldChanges
    (DistrictType, YieldType, YieldChange)
values ('DISTRICT_XIANZHOU_ALCHEMY_COMMISSION', 'YIELD_CULTURE', 1),
       ('DISTRICT_XIANZHOU_ALCHEMY_COMMISSION', 'YIELD_PRODUCTION', 2),
       ('DISTRICT_XIANZHOU_ALCHEMY_COMMISSION', 'YIELD_FOOD', 3),
       ('DISTRICT_XIANZHOU_CLOUD_KNIGHTS', 'YIELD_GOLD', 3),
       ('DISTRICT_XIANZHOU_CLOUD_KNIGHTS', 'YIELD_PRODUCTION', 3),
       ('DISTRICT_XIANZHOU_CLOUD_KNIGHTS', 'YIELD_FOOD', 1);

insert or
replace into District_GreatPersonPoints
    (DistrictType, GreatPersonClassType, PointsPerTurn)
Select 'DISTRICT_XIANZHOU_ALCHEMY_COMMISSION', GreatPersonClassType, PointsPerTurn
from District_GreatPersonPoints
Where District_GreatPersonPoints.DistrictType = 'DISTRICT_NEIGHBORHOOD'
Union
Select 'DISTRICT_XIANZHOU_CLOUD_KNIGHTS', GreatPersonClassType, PointsPerTurn
from District_GreatPersonPoints
Where District_GreatPersonPoints.DistrictType = 'DISTRICT_ENCAMPMENT'

Union
Select 'DISTRICT_XIANZHOU_TENLORDS_COMMISSION', GreatPersonClassType, PointsPerTurn
from District_GreatPersonPoints
Where District_GreatPersonPoints.DistrictType = 'DISTRICT_PRESERVE';

-- 避免非魔女环境下该语句报错
insert or
replace into DistrictModifiers
    (DistrictType, ModifierId)
SELECT 'DISTRICT_XIANZHOU_TENLORDS_COMMISSION', ModifierId
FROM Modifiers
WHERE ModifierId IN ('BAOHUQU_FOOD', 'BAOHUQU_PRODUCTION');

insert or
replace into DistrictModifiers
    (DistrictType, ModifierId)
values ('DISTRICT_XIANZHOU_ALCHEMY_COMMISSION', 'XIANZHOU_ALCHEMY_COMMISSION_INCREASE_GROWTH'),

       ('DISTRICT_XIANZHOU_TENLORDS_COMMISSION', 'XIANZHOU_DISTRICT_GRANT_UNITS_BARB_COMBAT');


insert or
replace into Modifiers
    (ModifierId, ModifierType, SubjectRequirementSetId)
values ('XIANZHOU_ALCHEMY_COMMISSION_INCREASE_GROWTH', 'MODIFIER_XIANZHOU_CITY_ADJUST_CITY_GROWTH', null),

       ('XIANZHOU_DISTRICT_GRANT_UNITS_BARB_COMBAT', 'MODIFIER_PLAYER_UNITS_ADJUST_BARBARIAN_COMBAT',
        'XIANZHOU_UNITS_WITHIN_6');

insert or
replace into Modifiers
    (ModifierId, ModifierType, RunOnce, Permanent)
values ('XIANZHOU_EXTRA_DISTRICT_CAPACITY', 'MODIFIER_SINGLE_CITY_EXTRA_DISTRICT', 1, 1);

insert or
replace into ModifierArguments
    (ModifierId, Name, Value)
values ('XIANZHOU_ALCHEMY_COMMISSION_INCREASE_GROWTH', 'Amount', 10),
       ('XIANZHOU_EXTRA_DISTRICT_CAPACITY', 'Amount', 1),

       ('XIANZHOU_DISTRICT_GRANT_UNITS_BARB_COMBAT', 'Amount', '5');

insert or
replace into Adjacent_AppealYieldChanges
(DistrictType, YieldType, MaximumValue, MinimumValue, BuildingType, YieldChange, Description, Unimproved)
Select 'DISTRICT_XIANZHOU_TENLORDS_COMMISSION',
       YieldType,
       -MinimumValue,
       -MaximumValue,
       BuildingType,
       YieldChange,
       Description,
       0
from Adjacent_AppealYieldChanges
Where Adjacent_AppealYieldChanges.DistrictType = 'DISTRICT_PRESERVE';

insert or
replace into District_Adjacencies
    (DistrictType, YieldChangeId)
Select 'DISTRICT_XIANZHOU_CLOUD_KNIGHTS', YieldChangeId
from District_Adjacencies
Where District_Adjacencies.DistrictType = 'DISTRICT_ENCAMPMENT';

/* 
UPDATE Adjacent_AppealYieldChanges Set YieldChange = 1 where BuildingType = 'BUILDING_GROVE' and YieldType = 'YIELD_FOOD';
UPDATE Adjacent_AppealYieldChanges Set YieldChange = 1 where BuildingType = 'BUILDING_GROVE' and YieldType = 'YIELD_FAITH';
UPDATE Adjacent_AppealYieldChanges Set YieldChange = 1, MaximumValue = '-2' where BuildingType = 'BUILDING_GROVE' and YieldType = 'YIELD_CULTURE' and MaximumValue = '-4';
*/