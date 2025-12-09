-- Firefly_Leader
-- Author: Pen
-- DateCreated: 2024/7/26 15:58:22
--------------------------------------------------------------
insert or replace into Types
(Type,												Kind)
values
('LEADER_PEN_FIREFLY',								'KIND_LEADER'),
('TRAIT_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',	'KIND_TRAIT'),
('TRAIT_AGENDA_PEN_FIREFLY',						'KIND_TRAIT'),
('TRAIT_LEADER_PEN_FIREFLY',						'KIND_TRAIT');

insert or replace into Leaders
(LeaderType,							Name,									InheritFrom,		SceneLayers,			Sex)
values
('LEADER_PEN_FIREFLY',					'LOC_LEADER_PEN_FIREFLY_NAME',			'LEADER_DEFAULT',	4,						'Female');

insert or replace into LeaderQuotes
(LeaderType,							Quote,													QuoteAudio)
values
('LEADER_PEN_FIREFLY',					'LOC_PEDIA_LEADERS_PAGE_LEADER_PEN_FIREFLY_QUOTE',		'ACCEPT_DELEGATION_FROM_HUMAN_LEADER_PEN_FIREFLY');--一点素材复用

insert or replace into LeaderTraits
(LeaderType,							TraitType)
values
('LEADER_PEN_FIREFLY',					'TRAIT_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS'),
('LEADER_PEN_FIREFLY',					'TRAIT_LEADER_PEN_FIREFLY');

insert or replace into Traits
(TraitType,												Name,															Description)
values
('TRAIT_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',		'LOC_TRAIT_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS_NAME',		'LOC_TRAIT_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS_DESCRIPTION'),
('TRAIT_LEADER_PEN_FIREFLY',							'LOC_TRAIT_LEADER_PEN_FIREFLY_NAME',							'LOC_TRAIT_LEADER_PEN_FIREFLY_DESCRIPTION');

insert or replace into TraitModifiers
(TraitType,												ModifierId)
values
--('TRAIT_LEADER_PEN_FIREFLY',							'TRAIT_PEN_FIREFLY_VOLCANIC_SOIL_IMPROVE_FOOD'),
--('TRAIT_LEADER_PEN_FIREFLY',							'TRAIT_PEN_FIREFLY_UNIT_SUM_BUILD_CHARGE'),
('TRAIT_LEADER_PEN_FIREFLY',							'TRAIT_PEN_FIREFLY_ALL_VOLCANIC_SOIL');

insert or replace into Modifiers
(ModifierId,											ModifierType,									SubjectRequirementSetId)
values
--('TRAIT_PEN_FIREFLY_VOLCANIC_SOIL_IMPROVE_FOOD',		'MODIFIER_PLAYER_ADJUST_PLOT_YIELD',			'PEN_FIREFLY_PLOT_IS_SOIL_IMPROVED'),
--('TRAIT_PEN_FIREFLY_UNIT_SUM_BUILD_CHARGE',				'MODIFIER_PLAYER_TRAINED_UNITS_ADJUST_BUILDER_CHARGES',			'PEN_FIREFLY_UNIT_IS_SUM'),
('TRAIT_PEN_FIREFLY_ALL_VOLCANIC_SOIL',					'MODIFIER_PLAYER_ADJUST_PROPERTY',				null);

insert or replace into ModifierArguments 
(ModifierId,											Name,					value)
values
--('TRAIT_PEN_FIREFLY_VOLCANIC_SOIL_IMPROVE_FOOD',		'YieldType',			'YIELD_FOOD'),
--('TRAIT_PEN_FIREFLY_VOLCANIC_SOIL_IMPROVE_FOOD',		'Amount',				1),
--('TRAIT_PEN_FIREFLY_UNIT_SUM_BUILD_CHARGE',				'Amount',				1),
('TRAIT_PEN_FIREFLY_ALL_VOLCANIC_SOIL',					'Key',					'PEN_FIREFLY_ALL_VOLCANIC_SOIL'),
('TRAIT_PEN_FIREFLY_ALL_VOLCANIC_SOIL',					'Amount',				1);

--议程
insert or replace into Agendas
(AgendaType,						Name,										Description)
values
('AGENDA_PEN_FIREFLY',				'LOC_AGENDA_PEN_FIREFLY_NAME',			'LOC_AGENDA_PEN_FIREFLY_DESCRIPTION');

insert or replace into HistoricalAgendas
(LeaderType,						AgendaType)
values
('LEADER_PEN_FIREFLY',				'AGENDA_PEN_FIREFLY');

insert or replace into ExclusiveAgendas
(AgendaOne,							AgendaTwo)
values
('AGENDA_PEN_FIREFLY',				'AGENDA_BARBARIAN_LOVER');

insert or replace into AgendaTraits
(AgendaType,						TraitType)
values
('AGENDA_PEN_FIREFLY',				'TRAIT_AGENDA_PEN_FIREFLY');

insert or replace into Traits
(TraitType)
values
('TRAIT_AGENDA_PEN_FIREFLY');

insert or replace into TraitModifiers
(TraitType,								ModifierId)
values
('TRAIT_AGENDA_PEN_FIREFLY',			'AGENDA_PEN_FIREFLY_CLEARS_BARBARIAN_CAMPS'),
('TRAIT_AGENDA_PEN_FIREFLY',			'AGENDA_PEN_FIREFLY_IGNORES_BARBARIAN_CAMPS');

insert or replace into Modifiers
(ModifierId,										ModifierType,									OwnerRequirementSetId,			SubjectRequirementSetId)
values
('AGENDA_PEN_FIREFLY_CLEARS_BARBARIAN_CAMPS',		'MODIFIER_PLAYER_DIPLOMACY_SIMPLE_MODIFIER',		null,					'PLAYER_CLEARS_BARBARIAN_CAMPS'),
('AGENDA_PEN_FIREFLY_IGNORES_BARBARIAN_CAMPS',		'MODIFIER_PLAYER_DIPLOMACY_SIMPLE_MODIFIER',		null,					'PLAYER_IGNORES_BARBARIAN_CAMPS');

insert or replace into ModifierArguments 
(ModifierId,										Name,						value)
values
('AGENDA_PEN_FIREFLY_CLEARS_BARBARIAN_CAMPS',		'InitialValue',						'8'),
('AGENDA_PEN_FIREFLY_CLEARS_BARBARIAN_CAMPS',		'StatementKey',						'LOC_DIPLO_KUDO_LEADER_PEN_FIREFLY_REASON_ANY'),--LOC_DIPLO_KUDO_LEADER_ANY_REASON_AGENDA_ATTACKS_BARBARIANS
('AGENDA_PEN_FIREFLY_CLEARS_BARBARIAN_CAMPS',		'SimpleModifierDescription',		'LOC_DIPLO_MODIFIER_PEN_FIREFLY_ATTACKS_BARBARIANS'),--LOC_DIPLO_MODIFIER_DESCRIPTION_ATTACKS_BARBARIANS
('AGENDA_PEN_FIREFLY_CLEARS_BARBARIAN_CAMPS',		'HiddenAgenda',						'1'),
('AGENDA_PEN_FIREFLY_IGNORES_BARBARIAN_CAMPS',		'InitialValue',						'-8'),
('AGENDA_PEN_FIREFLY_IGNORES_BARBARIAN_CAMPS',		'StatementKey',						'LOC_DIPLO_WARNING_LEADER_PEN_FIREFLY_REASON_ANY'),--LOC_DIPLO_WARNING_LEADER_ANY_REASON_AGENDA_IGNORES_BARBARIANS
('AGENDA_PEN_FIREFLY_IGNORES_BARBARIAN_CAMPS',		'SimpleModifierDescription',		'LOC_DIPLO_MODIFIER_PEN_FIREFLY_IGNORES_BARBARIANS'),--LOC_DIPLO_MODIFIER_DESCRIPTION_IGNORES_BARBARIANS
('AGENDA_PEN_FIREFLY_IGNORES_BARBARIAN_CAMPS',		'HiddenAgenda',						'1');

insert or replace into ModifierStrings
(ModifierId,										Context,		Text)
values
('AGENDA_PEN_FIREFLY_CLEARS_BARBARIAN_CAMPS',		'Sample',		'LOC_TOOLTIP_SAMPLE_DIPLOMACY_ALL'),
('AGENDA_PEN_FIREFLY_IGNORES_BARBARIAN_CAMPS',		'Sample',		'LOC_TOOLTIP_SAMPLE_DIPLOMACY_ALL');

insert or replace into AiListTypes
(ListType)
values
('GlamothFavourUnit'),
('GlamothFavourBuilding');

insert or replace into AiLists
(ListType,							LeaderType,													AgendaType,							System)
values
('GlamothFavourUnit',				'TRAIT_CIVILIZATION_UNIT_PEN_GLAMOTH_CAVALRY',					null,								'Units'),
('GlamothFavourBuilding',			'TRAIT_BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',				null,								'Buildings');

insert or replace into AiFavoredItems
(ListType,							Item,													Favored,	Value)
values
('GlamothFavourUnit',				'UNIT_PEN_FIREFLY_SAMU',								1,			0),
('GlamothFavourBuilding',			'BUILDING_PEN_FIREFLY_REDDENED_CHRYSALIS',				1,			0);

insert or replace into GlobalParameters
(Name,										Value)
values
('PEN_FIREFLY_SAMU_DEFEND_FROM_HEALTH',		2),
('PEN_FIREFLY_DEATH_YIELD_PERCENT',			15),--10%期望为3.8产，15%期望为5.1产，20%期望6.5产
('PEN_FIREFLY_REMOVE_MODIFIER',				100),--%
('PEN_FIREFLY_REMOVE_PROGRESS',				900);--%

--加载界面
insert or replace into LoadingInfo
(LeaderType,						ForegroundImage,								BackgroundImage,						LeaderText,										PlayDawnOfManAudio)
values
('LEADER_PEN_FIREFLY',				'IMG_LOADING_FOREGROUND_PEN_FIREFLY',			'IMG_LOADING_BACKGROUND_GLAMOTH',		'LOC_LEADER_PEN_FIREFLY_DESCRIPTION',		0);

insert or replace into DiplomacyInfo
(Type,								BackgroundImage)
values
('LEADER_PEN_FIREFLY',			    'IMG_DIPLOMACY_BACKGROUND_GLAMOTH');