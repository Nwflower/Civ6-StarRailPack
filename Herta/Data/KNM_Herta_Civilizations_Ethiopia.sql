-- KNM_Herta_Civilizations_Ethiopia
-- Author: Konomi
-- DateCreated: 7/5/2024 16:00:39
--------------------------------------------------------------

INSERT INTO TraitModifiers 
		(TraitType,											ModifierId) 
VALUES	('TRAIT_CIVILIZATION_KNM_HERTA_SPACE_STATION',		'MODIFIER_KNM_HERTA_CONSULATE_GREAT_WORK_SLOT');

INSERT INTO Modifiers 
		(ModifierId,											ModifierType,													SubjectRequirementSetId) 
VALUES	('MODIFIER_KNM_HERTA_CONSULATE_GREAT_WORK_SLOT',		'MODIFIER_PLAYER_CITIES_ADJUST_EXTRA_GREAT_WORK_SLOTS',			NULL);

INSERT INTO ModifierArguments 
		(ModifierId,											Name,								Value) 
VALUES	('MODIFIER_KNM_HERTA_CONSULATE_GREAT_WORK_SLOT',		'Amount',							'1'),
		('MODIFIER_KNM_HERTA_CONSULATE_GREAT_WORK_SLOT',		'BuildingType',						'BUILDING_CONSULATE'),
		('MODIFIER_KNM_HERTA_CONSULATE_GREAT_WORK_SLOT',		'GreatWorkSlotType',				'GREATWORKSLOT_PALACE');
		