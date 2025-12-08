-- Firefly_Building
-- Author: Pen
-- DateCreated: 2024/7/26 15:58:06
--------------------------------------------------------------
insert or replace into Types
(Type,												Kind)
values
('BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',		    'KIND_BUILDING');

insert or replace into Buildings	
(BuildingType,										TraitType,														Name,													Description,													PrereqTech,			PrereqCivic,		Cost,		PrereqDistrict,	PurchaseYield,	Housing,	Entertainment,	Maintenance,	CitizenSlots,	InternalOnly,AdvisorType)
Select
'BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',		    'TRAIT_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',				'LOC_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS_NAME',	    'LOC_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS_DESCRIPTION',	    PrereqTech,			PrereqCivic,		50,			PrereqDistrict,	PurchaseYield,	2,			1,				Maintenance,	CitizenSlots,	InternalOnly,AdvisorType
from Buildings where BuildingType = 'BUILDING_GRANARY';

insert or replace into BuildingReplaces	
(CivUniqueBuildingType,			                    ReplacesBuildingType)
values
('BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',		    'BUILDING_GRANARY');

insert or replace into BuildingPrereqs
(Building,				PrereqBuilding)
Select	'BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',PrereqBuilding from BuildingPrereqs
Where BuildingPrereqs.Building = 'BUILDING_GRANARY';

insert or replace into BuildingPrereqs
(Building,				PrereqBuilding)
Select	Building,'BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS' from BuildingPrereqs
Where BuildingPrereqs.PrereqBuilding = 'BUILDING_GRANARY';

insert or replace into Building_YieldChanges
(BuildingType,	YieldType,	YieldChange)
Select	'BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',YieldType,YieldChange from Building_YieldChanges
Where Building_YieldChanges.BuildingType = 'BUILDING_GRANARY';

insert or replace into Building_CitizenYieldChanges
(BuildingType,				YieldType,			YieldChange)
Select	'BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',YieldType,YieldChange from Building_CitizenYieldChanges 
Where Building_CitizenYieldChanges.BuildingType = 'BUILDING_GRANARY';

insert or replace into Building_GreatPersonPoints
(BuildingType,			GreatPersonClassType,		PointsPerTurn)
Select	'BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',GreatPersonClassType,PointsPerTurn from Building_GreatPersonPoints 
Where Building_GreatPersonPoints.BuildingType = 'BUILDING_GRANARY';

insert or replace into Building_GreatWorks
(BuildingType,			GreatWorkSlotType,		NumSlots,	ThemingSameObjectType,	ThemingYieldMultiplier,	ThemingTourismMultiplier,	NonUniquePersonYield,	NonUniquePersonTourism)
Select	'BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',GreatWorkSlotType,NumSlots,ThemingSameObjectType,ThemingYieldMultiplier,ThemingTourismMultiplier,NonUniquePersonYield,NonUniquePersonTourism from Building_GreatWorks
Where Building_GreatWorks.BuildingType = 'BUILDING_GRANARY';

insert or replace into Building_YieldChanges
(BuildingType,											YieldType,			YieldChange)
values
('BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',				'YIELD_FOOD',		1);

insert or replace into BuildingModifiers
(BuildingType,											ModifierId)
values
('BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',			    'MODIFIER_PRODUCTION_PEN_GLAMOTH_TITANIA_DREAM');

insert or replace into Modifiers 
(ModifierId, 															ModifierType,																		SubjectRequirementSetId)
values
('MODIFIER_PRODUCTION_PEN_GLAMOTH_TITANIA_DREAM',						'MODIFIER_SINGLE_CITY_ADJUST_PROJECT_PRODUCTION',									null);

insert or replace into ModifierArguments
(ModifierId,															Name,					Value)
values
('MODIFIER_PRODUCTION_PEN_GLAMOTH_TITANIA_DREAM',						'ProjectType',			'PROJECT_PEN_GLAMOTH_TITANIA_DREAM'),
('MODIFIER_PRODUCTION_PEN_GLAMOTH_TITANIA_DREAM',						'Amount',				30);