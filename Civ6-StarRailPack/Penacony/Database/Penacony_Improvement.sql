-- Penacony_Improvement
-- Author: Nwflower
-- DateCreated: 2025-5-11 22:08:19
--------------------------------------------------------------
INSERT INTO	Types(Type,Kind)
VALUES
('IMPROVEMENT_DREAM_POOL',	'KIND_IMPROVEMENT');

INSERT INTO Improvements
        (ImprovementType,
		Name,
		PrereqTech,
		Buildable,
		Description,
		PlunderType,
		PlunderAmount,
		Icon,
		TraitType,
        SameAdjacentValid,
		Goody,
		Capturable,
         OnePerCity)
VALUES('IMPROVEMENT_DREAM_POOL',							-- ImprovementType
		'LOC_IMPROVEMENT_DREAM_POOL_NAME',					-- Name
		null,													-- PrereqTech
		1,														-- Buildable
		'LOC_IMPROVEMENT_DREAM_POOL_DESCRIPTION',			-- Description
		'NO_PLUNDER',											-- PlunderType
		0,														-- PlunderAmount
		'ICON_IMPROVEMENT_DREAM_POOL',						-- Icon
		'TRAIT_IMPROVEMENT_DREAM_POOL',							-- TraitType
        0,
		0,														-- Goody (Hide it on civilopedia)
		1,
       1);

INSERT INTO Improvement_YieldChanges(ImprovementType, YieldType, YieldChange) VALUES
('IMPROVEMENT_DREAM_POOL','YIELD_CULTURE',3);
INSERT INTO Improvement_ValidBuildUnits(ImprovementType,UnitType)VALUES
('IMPROVEMENT_DREAM_POOL','UNIT_DREAM_BUILDER');
INSERT INTO Improvement_ValidTerrains(ImprovementType,TerrainType)SELECT
'IMPROVEMENT_DREAM_POOL',TerrainType
FROM Terrains WHERE TerrainType NOT IN ('TERRAIN_COAST','TERRAIN_OCEAN');

INSERT INTO ImprovementModifiers (ImprovementType, ModifierId) VALUES
('IMPROVEMENT_DREAM_POOL', 'MODIFIER_IMPROVEMENT_DREAM_POOL_AMEN');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_IMPROVEMENT_DREAM_POOL_AMEN', 'MODIFIER_SINGLE_CITY_ADJUST_IMPROVEMENT_AMENITY', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_IMPROVEMENT_DREAM_POOL_AMEN', 'Amount', '1');

INSERT INTO TraitModifiers (TraitType, ModifierId) VALUES
('TRAIT_IMPROVEMENT_DREAM_POOL', 'MODIFIER_IMPROVEMENT_DREAM_POOL_GOLD');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_IMPROVEMENT_DREAM_POOL_GOLD', 'MODIFIER_PLAYER_DISTRICTS_ADJUST_YIELD_CHANGE', 0, 0, 0, NULL, 'NW_DIS_NEXT_IMPROVEMENT_DREAM_POOL');
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_IMPROVEMENT_DREAM_POOL_GOLD', 'Amount', '1'),
('MODIFIER_IMPROVEMENT_DREAM_POOL_GOLD', 'YieldType', 'YIELD_GOLD');
-- RequirementSets
INSERT INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('NW_DIS_NEXT_IMPROVEMENT_DREAM_POOL', 'REQUIREMENTSET_TEST_ALL');
INSERT INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('NW_DIS_NEXT_IMPROVEMENT_DREAM_POOL', 'REQ_NW_DIS_NEXT_IMPROVEMENT_DREAM_POOL');
-- Requirements
INSERT INTO Requirements (RequirementId, RequirementType) VALUES
('REQ_NW_DIS_NEXT_IMPROVEMENT_DREAM_POOL', 'REQUIREMENT_PLOT_ADJACENT_IMPROVEMENT_TYPE_MATCHES');
INSERT INTO RequirementArguments (RequirementId, Name, Value) VALUES
('REQ_NW_DIS_NEXT_IMPROVEMENT_DREAM_POOL', 'ImprovementType', 'IMPROVEMENT_DREAM_POOL'),
('REQ_NW_DIS_NEXT_IMPROVEMENT_DREAM_POOL', 'MaxRange', '1'),
('REQ_NW_DIS_NEXT_IMPROVEMENT_DREAM_POOL', 'MinRange', '1');


