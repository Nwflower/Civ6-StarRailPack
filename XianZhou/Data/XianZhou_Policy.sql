-- XianZhou_Policy
-- Author: Pen
-- DateCreated: 2024/5/18 15:43:27
--------------------------------------------------------------
insert or replace into Types
(		Type,												Kind)
Select	'POLICY_XIANZHOU_'||CommemorationTypes.CommemorationType,				'KIND_POLICY'
from	CommemorationTypes;
/*
-- CREATE TEMPORARY TABLE
create table if not exists XianZhouPolicyData (
	PolicyType		TEXT   NOT NULL,
	Name			TEXT,
	Description		TEXT,
	MinimumGameEra	TEXT,
	MaximumGameEra	TEXT,
    ModifierId		TEXT   NOT NULL,
    PRIMARY KEY (PolicyType, ModifierId)
);

INSERT INTO XianZhouPolicyData
(PolicyType,													Name,										Description,									MinimumGameEra,						MaximumGameEra,							ModifierId)
SELECT DISTINCT
'POLICY_XIANZHOU_'||CommemorationTypes.CommemorationType,		CommemorationTypes.CategoryDescription,		CommemorationTypes.GoldenAgeBonusDescription,	CommemorationTypes.MinimumGameEra,	CommemorationTypes.MaximumGameEra,		CommemorationModifiers.ModifierId
FROM CommemorationTypes
INNER JOIN CommemorationModifiers ON CommemorationTypes.CommemorationType = CommemorationModifiers.CommemorationType;
*/
insert or ignore into Policies_XP1
(				PolicyType,													MinimumGameEra,																	MaximumGameEra,																		RequiresDarkAge,	RequiresGoldenAge)
SELECT DISTINCT	'POLICY_XIANZHOU_'||CommemorationTypes.CommemorationType,	CASE	WHEN	CommemorationTypes.MinimumGameEra is null	THEN 'ERA_CLASSICAL'
																			ELSE	CommemorationTypes.MinimumGameEra					END ,				CASE	WHEN	CommemorationTypes.MaximumGameEra is null	THEN 'ERA_FUTURE'
																																									ELSE	CommemorationTypes.MaximumGameEra			END,					1,					0					from	CommemorationTypes;
insert or replace into Policies	
(				PolicyType,													Name,										Description,										GovernmentSlotType,		ExplicitUnlock)
SELECT DISTINCT	'POLICY_XIANZHOU_'||CommemorationTypes.CommemorationType,	CommemorationTypes.CategoryDescription,		CommemorationTypes.GoldenAgeBonusDescription,		'SLOT_WILDCARD',		1
from	CommemorationTypes;


insert or replace into PolicyModifiers	
(		PolicyType,																ModifierId)
Select	'POLICY_XIANZHOU_'||CommemorationModifiers.CommemorationType,			'XIANZHOU_POLICY_'||CommemorationModifiers.ModifierId
from CommemorationModifiers;

insert or replace into RequirementSets
(				RequirementSetId,											RequirementSetType)
Select			'XIANZHOU_DARKAGE_'||rs.RequirementSetId,					rs.RequirementSetType				
from	CommemorationModifiers cm
Join	Modifiers m on cm.ModifierId = m.ModifierId
Join	RequirementSets rs on (rs.RequirementSetId = m.OwnerRequirementSetId or rs.RequirementSetId = m.SubjectRequirementSetId);

insert or replace into RequirementSetRequirements
(				RequirementSetId,											RequirementId)
Select			'XIANZHOU_DARKAGE_'||rsq.RequirementSetId,	CASE	WHEN 	rsq.RequirementId = 'REQUIRES_PLAYER_HAS_GOLDEN_AGE'	THEN 'REQUIRES_PLAYER_HAS_DARK_AGE'
																	ELSE	rsq.RequirementId										END			
from	CommemorationModifiers cm
Join	Modifiers m on cm.ModifierId = m.ModifierId
Join	RequirementSetRequirements rsq on rsq.RequirementSetId = m.OwnerRequirementSetId or rsq.RequirementSetId = m.SubjectRequirementSetId;

insert or replace into Modifiers
(		ModifierId,							ModifierType,	RunOnce,					OwnerRequirementSetId,																							SubjectRequirementSetId,																				OwnerStackLimit,	SubjectStackLimit)
Select	'XIANZHOU_POLICY_'||cm.ModifierId,	m.ModifierType,	m.RunOnce,	CASE	WHEN 	m.OwnerRequirementSetId	like '%GOLDEN_AGE%'		THEN 'XIANZHOU_DARKAGE_'||m.OwnerRequirementSetId
																				ELSE	m.OwnerRequirementSetId							END,											CASE	WHEN 	m.SubjectRequirementSetId	like '%GOLDEN_AGE%'		THEN 'XIANZHOU_DARKAGE_'||m.SubjectRequirementSetId
																																																ELSE	m.SubjectRequirementSetId							END,												m.OwnerStackLimit,	m.SubjectStackLimit
from	CommemorationModifiers cm
Join	Modifiers m on cm.ModifierId = m.ModifierId;

insert or replace into ModifierArguments
(		ModifierId,								Name,			Value)
Select	'XIANZHOU_POLICY_'||ma.ModifierId,		ma.Name,		ma.Value		
from	CommemorationModifiers cm
Join	ModifierArguments ma on cm.ModifierId = ma.ModifierId;
/*
--Update	RequirementSetRequirements	Set	RequirementId = 'REQUIRES_XIANZHOU_HAS_GOLDEN_AGE'	where	RequirementId = 'REQUIRES_PLAYER_HAS_GOLDEN_AGE';--可能导致黑暗着力点触发黄金着力点效果
--禁止政策卡在黑暗时代外出现
insert or replace into Modifiers
(		ModifierId,								ModifierType,										OwnerRequirementSetId)
Select	'XIANZHOU_BAN_'||Policies.PolicyType,	'MODIFIER_XIANZHOU_ADJUST_BANNED_POLICY',			'XIANZHOU_NOT_DARK_AGE_BAN_POLICY'	from	Policies	where	Policies.PolicyType like 'POLICY_XIANZHOU_%';

insert or replace into ModifierArguments
(		ModifierId,								Name,					Value)
Select	'XIANZHOU_BAN_'||Policies.PolicyType,	'PolicyType',			Policies.PolicyType		from	Policies	where	Policies.PolicyType like 'POLICY_XIANZHOU_%';

INSERT INTO GameModifiers (ModifierId)
SELECT DISTINCT		ModifierId								from	Modifiers	where	ModifierId like 'XIANZHOU_BAN_POLICY_XIANZHOU_%' and ModifierId is not null;
*/