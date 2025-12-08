-- XianZhou_Icon
-- Author: Pen
-- DateCreated: 2024/5/18 15:58:36
--------------------------------------------------------------
insert into IconAliases (Name,OtherName)
Select			'ICON_POLICY_XIANZHOU_'||Substr(IconDefinitions.Name, 6),	'ICON_POLICY_WILDCARD'		from IconDefinitions Where IconDefinitions.Name like 'ICON_COMMEMORATION_%';
--ICON_POLICY_DRAMATICAGES_GOLDEN_AGE
--insert into IconDefinitions (Name,Atlas,Index)
--Select			'ICON_POLICY_XIANZHOU_'||Substr(IconDefinitions.Name, 6),	'ICON_ATLAS_POLICIES',	3		from IconDefinitions Where IconDefinitions.Name like 'ICON_COMMEMORATION_%';