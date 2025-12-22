-- Penacony_GreatWorks
-- Author: Nwflower
-- DateCreated: 2025-5-14 13:31:42
--------------------------------------------------------------
--================
-- 伟人：知更鸟
--================
INSERT INTO Types (Type, Kind)
VALUES ('GREATWORK_ROBIN_0', 'KIND_GREATWORK'),
       ('GREATWORK_ROBIN_1', 'KIND_GREATWORK'),
       ('GREATWORK_ROBIN_2', 'KIND_GREATWORK'),
       ('GREATWORK_ROBIN_3', 'KIND_GREATWORK');

INSERT INTO GreatWorks (GreatWorkType, GreatWorkObjectType, GreatPersonIndividualType, Name, Audio, Tourism)
VALUES ('GREATWORK_ROBIN_0', 'GREATWORKOBJECT_MUSIC', 'GREAT_PERSON_INDIVIDUAL_ROBIN_0', 'LOC_GREATWORK_ROBIN_0_NAME',
        'Rb0', 8),
       ('GREATWORK_ROBIN_1', 'GREATWORKOBJECT_MUSIC', 'GREAT_PERSON_INDIVIDUAL_ROBIN_1', 'LOC_GREATWORK_ROBIN_1_NAME',
        'Rb1', 8),
       ('GREATWORK_ROBIN_2', 'GREATWORKOBJECT_MUSIC', 'GREAT_PERSON_INDIVIDUAL_ROBIN_2', 'LOC_GREATWORK_ROBIN_2_NAME',
        'Rb2', 8),
       ('GREATWORK_ROBIN_3', 'GREATWORKOBJECT_MUSIC', 'GREAT_PERSON_INDIVIDUAL_ROBIN_3', 'LOC_GREATWORK_ROBIN_3_NAME',
        'Rb3', 8);

INSERT INTO GreatWork_YieldChanges (GreatWorkType, YieldType, YieldChange)
VALUES ('GREATWORK_ROBIN_0', 'YIELD_CULTURE', 4),
       ('GREATWORK_ROBIN_1', 'YIELD_CULTURE', 4),
       ('GREATWORK_ROBIN_2', 'YIELD_CULTURE', 4),
       ('GREATWORK_ROBIN_3', 'YIELD_CULTURE', 4);

------------------------------------------------------------------
INSERT INTO GreatWorkModifiers (GreatWorkType, ModifierID)VALUES
('GREATWORK_ROBIN_0', 'MODIFIER_GREATWORK_ROBIN_0_TR');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_GREATWORK_ROBIN_0_TR', 'MODIFIER_PLAYER_ADJUST_TRADE_ROUTE_CAPACITY', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_GREATWORK_ROBIN_0_TR', 'Amount', '1');

INSERT INTO GreatWorkModifiers (GreatWorkType, ModifierID)VALUES
('GREATWORK_ROBIN_0', 'MODIFIER_GREATWORK_ROBIN_0_TR_1');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_GREATWORK_ROBIN_0_TR_1', 'MODIFIER_SINGLE_CITY_ADJUST_TRADE_ROUTE_YIELD_TO_OTHERS', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_GREATWORK_ROBIN_0_TR_1', 'Amount', '1'),
('MODIFIER_GREATWORK_ROBIN_0_TR_1', 'Domestic', '1'),
('MODIFIER_GREATWORK_ROBIN_0_TR_1', 'YieldType', 'YIELD_GOLD');

INSERT INTO GreatWorkModifiers (GreatWorkType, ModifierID)VALUES
('GREATWORK_ROBIN_0', 'MODIFIER_GREATWORK_ROBIN_0_TR_2');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MODIFIER_GREATWORK_ROBIN_0_TR_2', 'MODIFIER_SINGLE_CITY_ADJUST_TRADE_ROUTE_YIELD_TO_OTHERS', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MODIFIER_GREATWORK_ROBIN_0_TR_2', 'Amount', '1'),
('MODIFIER_GREATWORK_ROBIN_0_TR_2', 'Domestic', '0'),
('MODIFIER_GREATWORK_ROBIN_0_TR_2', 'YieldType', 'YIELD_GOLD');


------------------------------------------------------------------
INSERT INTO GreatWorkModifiers (GreatWorkType, ModifierID)
VALUES ('GREATWORK_ROBIN_1', 'MODIFIER_BUILDING_NW_ROBIN_1_GIVE_FREE_PROMOTIONS');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_BUILDING_NW_ROBIN_1_GIVE_FREE_PROMOTIONS', 'MODIFIER_CITY_TRAINED_UNITS_ADJUST_GRANT_EXPERIENCE', 0,
        0, 1, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_BUILDING_NW_ROBIN_1_GIVE_FREE_PROMOTIONS', 'Amount', -1);

------------------------------------------------------------------
INSERT INTO GreatWorkModifiers (GreatWorkType, ModifierID)
VALUES ('GREATWORK_ROBIN_2', 'MODFEAT_BUILDING_NW_ROBIN_2_MODIFIER1');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODFEAT_BUILDING_NW_ROBIN_2_MODIFIER1', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_BUILDING_NW_ROBIN_2_MODIFIER1', 'Amount', '1'),
       ('MODFEAT_BUILDING_NW_ROBIN_2_MODIFIER1', 'YieldType', 'YIELD_FAITH');

INSERT INTO GreatWorkModifiers (GreatWorkType, ModifierID)
VALUES ('GREATWORK_ROBIN_2', 'MODFEAT_BUILDING_NW_ROBIN_2_MODIFIER2');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODFEAT_BUILDING_NW_ROBIN_2_MODIFIER2', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, 0, NULL, 'PLOT_BREATHTAKING_APPEAL');
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_BUILDING_NW_ROBIN_2_MODIFIER2', 'Amount', '1'),
       ('MODFEAT_BUILDING_NW_ROBIN_2_MODIFIER2', 'YieldType', 'YIELD_SCIENCE');

------------------------------------------------------------------
INSERT INTO GreatWorkModifiers (GreatWorkType, ModifierID)
VALUES ('GREATWORK_ROBIN_3', 'MODFEAT_BUILDING_NW_ROBIN_3_MODIFIER1');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODFEAT_BUILDING_NW_ROBIN_3_MODIFIER1', 'MODIFIER_SINGLE_CITY_EXTRA_DISTRICT', 0, 0, 0, NULL, NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODFEAT_BUILDING_NW_ROBIN_3_MODIFIER1', 'Amount', 1);
INSERT INTO GreatWorkModifiers (GreatWorkType, ModifierID)
VALUES ('GREATWORK_ROBIN_3', 'MODIFIER_GREATWORK_ROBIN_3_DIS_PRO');
INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, NewOnly, OwnerRequirementSetId,
                       SubjectRequirementSetId)
VALUES ('MODIFIER_GREATWORK_ROBIN_3_DIS_PRO', 'MODIFIER_SINGLE_CITY_ADJUST_DISTRICT_PRODUCTION_MODIFIER', 0, 0, 0, NULL,
        NULL);
INSERT INTO ModifierArguments (ModifierId, Name, Value)
VALUES ('MODIFIER_GREATWORK_ROBIN_3_DIS_PRO', 'Amount', 15);