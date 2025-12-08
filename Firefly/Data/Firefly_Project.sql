-- Firefly_Project
-- Author: Pen
-- DateCreated: 2024/7/26 15:58:52
--------------------------------------------------------------
insert or replace into Types
(Type,													Kind)
values
('PROJECT_PEN_GLAMOTH_TITANIA_DREAM',			    	'KIND_PROJECT');

insert or replace into Projects
(ProjectType,											Name,														ShortName,															Description,														Cost,		CostProgressionModel,			        	CostProgressionParam1,	WMD,	RequiredBuilding,	AdvisorType,			UnlocksFromEffect)
values 
('PROJECT_PEN_GLAMOTH_TITANIA_DREAM',				    'LOC_PROJECT_PEN_GLAMOTH_TITANIA_DREAM_NAME',				'LOC_PROJECT_PEN_GLAMOTH_TITANIA_DREAM_SHORT_NAME',					'LOC_PROJECT_PEN_GLAMOTH_TITANIA_DREAM_DESCRIPTION',				50,			'COST_PROGRESSION_GAME_PROGRESS',			1500,					0,		null,				'ADVISOR_CONQUEST',		1);