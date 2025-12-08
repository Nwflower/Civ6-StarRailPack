-- XianZhou_Building
-- Author: Pen
-- DateCreated: 2024/5/18 10:31:00
--------------------------------------------------------------
insert or replace into Types
(Type,												Kind)
values
('BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',		'KIND_BUILDING');

insert or replace into Buildings	
(BuildingType,										TraitType,														Name,													Description,													PrereqTech,			PrereqCivic,		Cost,		PrereqDistrict,	PurchaseYield,	RequiresAdjacentRiver,	Entertainment,	Maintenance,	CitizenSlots,	InternalOnly,AdvisorType)
Select
'BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',		'TRAIT_BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',				'LOC_BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION_NAME',	'LOC_BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION_DESCRIPTION',	PrereqTech,			PrereqCivic,		Cost*0.6,	PrereqDistrict,	PurchaseYield,	1,						Entertainment,	Maintenance,	CitizenSlots,	InternalOnly,AdvisorType
from Buildings where BuildingType = 'BUILDING_WATER_MILL';

insert or replace into BuildingReplaces	
(CivUniqueBuildingType,			ReplacesBuildingType)
values
('BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',		'BUILDING_WATER_MILL');

insert or replace into BuildingModifiers
(BuildingType,											ModifierId)
values
('BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',			'XIANZHOU_CITY_RIVER_FASTER_BUILDTIME_DISTRICT'),
('BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',			'XIANZHOU_CITY_DARKAGE_EXTRA_DISTRICT_CAPACITY'),
('BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',			'XIANZHOU_CITY_LOYLOYALTY_PER_DISTRICT');


insert or replace into Modifiers 
(ModifierId, 															ModifierType,																		SubjectRequirementSetId)
values
('XIANZHOU_CITY_RIVER_FASTER_BUILDTIME_DISTRICT',						'MODIFIER_XIANZHOU_CITY_ADJUST_RIVER_DISTRICT_PRODUCTION',							null),
('XIANZHOU_CITY_DARKAGE_EXTRA_DISTRICT_CAPACITY',						'MODIFIER_SINGLE_CITY_EXTRA_DISTRICT',												'XIANZHOU_DARKAGE_AND_FULL_LOYALTY'),
('XIANZHOU_CITY_LOYLOYALTY_PER_DISTRICT_MODIFIER',						'MODIFIER_SINGLE_CITY_ADJUST_IDENTITY_PER_TURN',									null),
('XIANZHOU_CITY_LOYLOYALTY_PER_DISTRICT',								'MODIFIER_XIANZHOU_CITY_DISTRICTS_ATTACH_MODIFIER',									null);

insert or replace into ModifierArguments
(ModifierId,															Name,					Value)
values
('XIANZHOU_CITY_RIVER_FASTER_BUILDTIME_DISTRICT',						'Amount',				20),
('XIANZHOU_CITY_DARKAGE_EXTRA_DISTRICT_CAPACITY',						'Amount',				1),
('XIANZHOU_CITY_LOYLOYALTY_PER_DISTRICT_MODIFIER',						'Amount',				1),
('XIANZHOU_CITY_LOYLOYALTY_PER_DISTRICT',								'ModifierId',			'XIANZHOU_CITY_LOYLOYALTY_PER_DISTRICT_MODIFIER');

insert or replace into BuildingPrereqs
(Building,				PrereqBuilding)
Select	'BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',PrereqBuilding from BuildingPrereqs
Where BuildingPrereqs.Building = 'BUILDING_WATER_MILL';

insert or replace into BuildingPrereqs
(Building,				PrereqBuilding)
Select	Building,'BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION' from BuildingPrereqs
Where BuildingPrereqs.PrereqBuilding = 'BUILDING_WATER_MILL';

insert or replace into Building_YieldChanges
(BuildingType,	YieldType,	YieldChange)
Select	'BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',YieldType,YieldChange from Building_YieldChanges
Where Building_YieldChanges.BuildingType = 'BUILDING_WATER_MILL';

insert or replace into Building_CitizenYieldChanges
(BuildingType,				YieldType,			YieldChange)
Select	'BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',YieldType,YieldChange from Building_CitizenYieldChanges 
Where Building_CitizenYieldChanges.BuildingType = 'BUILDING_WATER_MILL';

insert or replace into Building_GreatPersonPoints
(BuildingType,			GreatPersonClassType,		PointsPerTurn)
Select	'BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',GreatPersonClassType,PointsPerTurn from Building_GreatPersonPoints 
Where Building_GreatPersonPoints.BuildingType = 'BUILDING_WATER_MILL';

insert or replace into Building_GreatWorks
(BuildingType,			GreatWorkSlotType,		NumSlots,	ThemingSameObjectType,	ThemingYieldMultiplier,	ThemingTourismMultiplier,	NonUniquePersonYield,	NonUniquePersonTourism)
Select	'BUILDING_XIANZHOU_CRESCENT_TRANSMIGRATION',GreatWorkSlotType,NumSlots,ThemingSameObjectType,ThemingYieldMultiplier,ThemingTourismMultiplier,NonUniquePersonYield,NonUniquePersonTourism from Building_GreatWorks
Where Building_GreatWorks.BuildingType = 'BUILDING_WATER_MILL';