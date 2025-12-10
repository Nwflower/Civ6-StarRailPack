-- Firefly_Unit
-- Author: Pen
-- DateCreated: 2024/7/26 15:58:43
--------------------------------------------------------------
insert or replace into Types
(Type,														Kind)
values
('ABILITY_PEN_FIREFLY_SAMU2',								'KIND_ABILITY'),
('ABILITY_PEN_FIREFLY_SAMU1',								'KIND_ABILITY'),
('UNIT_PEN_FIREFLY_SAMU',									'KIND_UNIT');

insert or replace into Units
(UnitType,					            Name,						    	Description,			                	Cost,	BaseMoves,	BaseSightRange,		ZoneOfControl,		Domain,			Combat,	PrereqTech,				StrategicResource,	Maintenance,AntiAirCombat,	FormationClass,					PromotionClass,		AdvisorType,		PurchaseYield,		MustPurchase,	PseudoYieldType,CostProgressionModel,				CostProgressionParam1,	CanTrain,	UseMaxMeleeTrainedStrength,	CanRetreatWhenCaptured,CanEarnExperience,	BuildCharges,	TraitType)
values
('UNIT_PEN_FIREFLY_SAMU',				'LOC_UNIT_PEN_FIREFLY_SAMU_NAME',	'LOC_UNIT_PEN_FIREFLY_SAMU_DESCRIPTION',	240,	2,			2,					1,					'DOMAIN_LAND',	20,		null,					null,				2,			90,				'FORMATION_CLASS_LAND_COMBAT',	null,				'ADVISOR_GENERIC',	'YIELD_FAITH',		0,				null,			'COST_PROGRESSION_PREVIOUS_COPIES',	40,						0,			0,							0,						0,					1,				'TRAIT_CIVILIZATION_UNIT_PEN_GLAMOTH_CAVALRY');

insert or replace into UnitAiInfos	(UnitType,AiType)
Select 'UNIT_PEN_FIREFLY_SAMU',AiType
from UnitAiInfos where UnitType='UNIT_MUSKETMAN';

insert or replace into Units_XP2
(UnitType,								CanEarnExperience,	CanFormMilitaryFormation,	MajorCivOnly)
values
('UNIT_PEN_FIREFLY_SAMU',				0,					0,							1);

insert or replace into Units_Presentation
(UnitType,					UIFlagOffset)
values
('UNIT_PEN_FIREFLY_SAMU',	6);

insert or replace into TypeProperties
(Type,						Name,				Value)
values
('UNIT_PEN_FIREFLY_SAMU',	'LIFESPAN',			26);--神秘寿命计算，设40联机速算32，设38算30

insert or replace into UnitAbilities
(UnitAbilityType,											Name,													Description,													Inactive)
values
('ABILITY_PEN_FIREFLY_SAMU2',								null,													null,															1),
('ABILITY_PEN_FIREFLY_SAMU1',								'LOC_ABILITY_PEN_FIREFLY_SAMU1_NAME',					'LOC_ABILITY_PEN_FIREFLY_SAMU1_DESCRIPTION',					0);

insert or replace into UnitAbilityModifiers
(UnitAbilityType,											ModifierId)
values
('ABILITY_PEN_FIREFLY_SAMU2',								'PEN_FIREFLY_UNIT_SUM_BUILD_CHARGE'),
('ABILITY_PEN_FIREFLY_SAMU1',								'PEN_FIREFLY_SAMU_STRENGTH_FROM_SPACEPORT'),
('ABILITY_PEN_FIREFLY_SAMU1',								'PEN_FIREFLY_SAMU_STRENGTH_FROM_MILITARY_ACADEMY'),
('ABILITY_PEN_FIREFLY_SAMU1',								'PEN_FIREFLY_SAMU_STRENGTH_FROM_ARMORY'),
('ABILITY_PEN_FIREFLY_SAMU1',								'PEN_FIREFLY_SAMU_STRENGTH_FROM_BARRACKS'),
('ABILITY_PEN_FIREFLY_SAMU1',								'PEN_FIREFLY_SAMU_STRENGTH_FROM_ENCAMPMENT'),
('ABILITY_PEN_FIREFLY_SAMU1',								'PEN_FIREFLY_SAMU_STRENGTH_GROWTH'),
('ABILITY_PEN_FIREFLY_SAMU1',								'PEN_FIREFLY_SAMU_VOLCANIC_SOIL_MOVEMENT');

insert or replace into Modifiers
(ModifierId,										ModifierType,												OwnerRequirementSetId,				SubjectRequirementSetId)
values
('PEN_FIREFLY_UNIT_SUM_BUILD_CHARGE',				'MODIFIER_UNIT_ADJUST_BUILDER_CHARGES',						null,								null),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_SPACEPORT',		'MODIFIER_UNIT_ADJUST_PROPERTY',							'PEN_FIREFLY_HAS_SPACEPORT',		null),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_MILITARY_ACADEMY',	'MODIFIER_UNIT_ADJUST_PROPERTY',							'PEN_FIREFLY_HAS_MILITARY_ACADEMY',	null),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_ARMORY',			'MODIFIER_UNIT_ADJUST_PROPERTY',							'PEN_FIREFLY_HAS_ARMORY',			null),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_BARRACKS',			'MODIFIER_UNIT_ADJUST_PROPERTY',							'PEN_FIREFLY_HAS_BARRACKS',			null),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_ENCAMPMENT',		'MODIFIER_UNIT_ADJUST_PROPERTY',							'PEN_FIREFLY_HAS_ENCAMPMENT',		null),
('PEN_FIREFLY_SAMU_STRENGTH_GROWTH',				'MODIFIER_UNIT_ADJUST_COMBAT_STRENGTH',						null,								null),

('PEN_FIREFLY_SAMU_VOLCANIC_SOIL_MOVEMENT',			'MODIFIER_PLAYER_UNIT_ADJUST_MOVEMENT',						null,								'PEN_FIREFLY_PLOT_IS_SOIL');

insert or replace into ModifierArguments
(ModifierId,										Name,						value)
values
('PEN_FIREFLY_UNIT_SUM_BUILD_CHARGE',				'Amount',					'1'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_SPACEPORT',		'Key',						'PEN_FIREFLY_SAMU_STRENGTH_GROWTH'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_SPACEPORT',		'Amount',					'30'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_MILITARY_ACADEMY',	'Key',						'PEN_FIREFLY_SAMU_STRENGTH_GROWTH'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_MILITARY_ACADEMY',	'Amount',					'15'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_ARMORY',			'Key',						'PEN_FIREFLY_SAMU_STRENGTH_GROWTH'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_ARMORY',			'Amount',					'15'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_BARRACKS',			'Key',						'PEN_FIREFLY_SAMU_STRENGTH_GROWTH'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_BARRACKS',			'Amount',					'10'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_ENCAMPMENT',		'Key',						'PEN_FIREFLY_SAMU_STRENGTH_GROWTH'),
('PEN_FIREFLY_SAMU_STRENGTH_FROM_ENCAMPMENT',		'Amount',					'10'),
('PEN_FIREFLY_SAMU_STRENGTH_GROWTH',				'Key',						'PEN_FIREFLY_SAMU_STRENGTH_GROWTH'),

('PEN_FIREFLY_SAMU_VOLCANIC_SOIL_MOVEMENT',			'Amount',					2);

insert or replace into ModifierStrings
(ModifierId,							Context,			Text)
values
('PEN_FIREFLY_SAMU_STRENGTH_GROWTH',	'Preview',			'LOC_ABILITY_PEN_FIREFLY_SAMU2_STR_DESCRIPTION');

insert or replace into Tags 
(Tag,										Vocabulary)
values
('CLASS_PEN_FIREFLY_SAMU',					'ABILITY_CLASS');

insert or replace into TypeTags
(Type,										Tag)
values
('UNIT_PEN_FIREFLY_SAMU',					'CLASS_MELEE'),
('ABILITY_PEN_FIREFLY_SAMU1',				'CLASS_PEN_FIREFLY_SAMU'),
('ABILITY_PEN_FIREFLY_SAMU2',				'CLASS_PEN_FIREFLY_SAMU'),
('ABILITY_UNIT_FIGHT_WHILE_EMBARKED',		'CLASS_PEN_FIREFLY_SAMU'),
('UNIT_PEN_FIREFLY_SAMU',					'CLASS_PEN_FIREFLY_SAMU');
/*
--晋升
insert or replace into Types
(Type,														Kind)
values
('PROMOTION_CLASS_PEN_FIREFLY_SAMU',						'KIND_PROMOTION_CLASS'),
('PROMOTION_PEN_FIREFLY_SAMU_L1',							'KIND_PROMOTION'),
('PROMOTION_PEN_FIREFLY_SAMU_L2',							'KIND_PROMOTION'),
('PROMOTION_PEN_FIREFLY_SAMU_L3',							'KIND_PROMOTION'),
('PROMOTION_PEN_FIREFLY_SAMU_L4',							'KIND_PROMOTION');

insert or replace into UnitPromotionClasses
(PromotionClassType,					Name)
values
('PROMOTION_CLASS_PEN_FIREFLY_SAMU',	'LOC_PROMOTION_CLASS_PEN_FIREFLY_SAMU_NAME');

insert or replace into UnitPromotions
(UnitPromotionType,						Name,											Description,									Level,	PromotionClass,						Column)
values
('PROMOTION_PEN_FIREFLY_SAMU_L1',		'LOC_PROMOTION_PEN_FIREFLY_SAMU_L1_NAME',		'LOC_PROMOTION_PEN_FIREFLY_SAMU_L1_DESCRIPTION',	1,		'PROMOTION_CLASS_PEN_FIREFLY_SAMU',	2),
('PROMOTION_PEN_FIREFLY_SAMU_L2',		'LOC_PROMOTION_PEN_FIREFLY_SAMU_L2_NAME',		'LOC_PROMOTION_PEN_FIREFLY_SAMU_L2_DESCRIPTION',	2,		'PROMOTION_CLASS_PEN_FIREFLY_SAMU',	2),
('PROMOTION_PEN_FIREFLY_SAMU_L3',		'LOC_PROMOTION_PEN_FIREFLY_SAMU_L3_NAME',		'LOC_PROMOTION_PEN_FIREFLY_SAMU_L3_DESCRIPTION',	3,		'PROMOTION_CLASS_PEN_FIREFLY_SAMU',	2),
('PROMOTION_PEN_FIREFLY_SAMU_L4',		'LOC_PROMOTION_PEN_FIREFLY_SAMU_L4_NAME',		'LOC_PROMOTION_PEN_FIREFLY_SAMU_L4_DESCRIPTION',	4,		'PROMOTION_CLASS_PEN_FIREFLY_SAMU',	2);

insert or replace into UnitPromotionPrereqs
(UnitPromotion,						PrereqUnitPromotion)
values
('PROMOTION_PEN_FIREFLY_SAMU_L2',		'PROMOTION_PEN_FIREFLY_SAMU_L1'),
('PROMOTION_PEN_FIREFLY_SAMU_L3',		'PROMOTION_PEN_FIREFLY_SAMU_L2'),
('PROMOTION_PEN_FIREFLY_SAMU_L4',		'PROMOTION_PEN_FIREFLY_SAMU_L3');

insert or replace into UnitPromotionModifiers
(UnitPromotionType,					ModifierId)
values
('PROMOTION_PEN_FIREFLY_SAMU_L1',		'PEN_FIREFLY_SAMU_DEFEND_FROM_HEALTH'),
('PROMOTION_PEN_FIREFLY_SAMU_L2',		'PEN_FIREFLY_SAMU_ADJ_BARB_STRENGTH'),
('PROMOTION_PEN_FIREFLY_SAMU_L3',		'PEN_FIREFLY_SAMU_ADDITIONAL_ATTACK'),
('PROMOTION_PEN_FIREFLY_SAMU_L4',		'PEN_FIREFLY_SAMU_UNUSED_MOVEMENT_COMBAT');
*/