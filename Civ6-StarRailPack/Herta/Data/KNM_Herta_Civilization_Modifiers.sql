---- KNM_Herta_Civilization_Modifiers
---- Author: Konomi
---- DateCreated: 6/7/2023 00:22:24
----------------------------------------------------------------

INSERT INTO GreatWorkModifiers 
		(GreatWorkType,		ModifierID) 
SELECT	GreatWorkType,		'MODIFIER_KNM_HERTA_GREAT_WORK_PRODUCTION' FROM GreatWorks;

INSERT INTO Modifiers 
		(ModifierId,									ModifierType,												SubjectRequirementSetId) 
VALUES	('MODIFIER_KNM_HERTA_GREAT_WORK_PRODUCTION',	'MODIFIER_SINGLE_CITY_ADJUST_CITY_YIELD_PER_POPULATION',	'REQSET_LEADER_IS_KNM_HERTA_OR_ASTA');

INSERT INTO ModifierArguments 
		(ModifierId,									Name,			Value) 
VALUES	('MODIFIER_KNM_HERTA_GREAT_WORK_PRODUCTION',	'Amount',		'0.2'),
		('MODIFIER_KNM_HERTA_GREAT_WORK_PRODUCTION',	'YieldType',	'YIELD_PRODUCTION');

INSERT INTO GreatWorkModifiers 
		(GreatWorkType,		ModifierID) 
SELECT	GreatWorkType,		'MODIFIER_KNM_HERTA_GREAT_WORK_SCIENCE' FROM GreatWorks;

INSERT INTO Modifiers 
		(ModifierId,									ModifierType,												SubjectRequirementSetId) 
VALUES	('MODIFIER_KNM_HERTA_GREAT_WORK_SCIENCE',		'MODIFIER_SINGLE_CITY_ADJUST_CITY_YIELD_PER_POPULATION',	'REQSET_LEADER_IS_KNM_HERTA_OR_ASTA');

INSERT INTO ModifierArguments 
		(ModifierId,									Name,			Value) 
VALUES	('MODIFIER_KNM_HERTA_GREAT_WORK_SCIENCE',		'Amount',		'0.3'),
		('MODIFIER_KNM_HERTA_GREAT_WORK_SCIENCE',		'YieldType',	'YIELD_SCIENCE');

INSERT INTO RequirementSets 
		(RequirementSetId,							RequirementSetType) 
VALUES	('REQSET_LEADER_IS_KNM_HERTA_OR_ASTA',		'REQUIREMENTSET_TEST_ANY');

INSERT INTO RequirementSetRequirements 
		(RequirementSetId,							RequirementId) 
VALUES	('REQSET_LEADER_IS_KNM_HERTA_OR_ASTA',		'REQ_LEADER_IS_KNM_HERTA'), 
		('REQSET_LEADER_IS_KNM_HERTA_OR_ASTA',		'REQ_LEADER_IS_KNM_ASTA');

INSERT INTO Requirements 
		(RequirementId,					RequirementType) 
VALUES	('REQ_LEADER_IS_KNM_HERTA',		'REQUIREMENT_PLAYER_LEADER_TYPE_MATCHES'), 
		('REQ_LEADER_IS_KNM_ASTA',		'REQUIREMENT_PLAYER_LEADER_TYPE_MATCHES');

INSERT INTO RequirementArguments 
		(RequirementId,					Name,			Value) 
VALUES	('REQ_LEADER_IS_KNM_HERTA',		'LeaderType',	'LEADER_KNM_HERTA'), 
		('REQ_LEADER_IS_KNM_ASTA',		'LeaderType',	'LEADER_KNM_ASTA');
