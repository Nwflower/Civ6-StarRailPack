--	FILE: Amphoreus_Config.sql
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni
--	Copyright (c) 2025.
--      All rights reserved.
--  DateCreated: 2025/10/26 15:31:52
--======================================================================
--  作者： 千川白浪
--  特别鸣谢： 优妮
--======================================================================

CREATE TEMPORARY TABLE IF NOT EXISTS NW_Amphoreus_Config
(
    LeaderType   TEXT NOT NULL PRIMARY KEY,
    DistrictType TEXT NOT NULL,
    TraitType    TEXT NOT NULL
);
INSERT OR IGNORE INTO NW_Amphoreus_Config(LeaderType, DistrictType, TraitType)
VALUES
-- 缇宝 刻法勒广场 门径
('LEADER_NW_TRIBIOS', 'DISTRICT_JANUS', 'JANUS'),
-- 万敌 悬锋竞技场 纷争
('LEADER_NW_MYDEI', 'DISTRICT_NIKADOR', 'NIKADOR'),
-- 阿格莱雅 云石天宫 浪漫
('LEADER_NW_AGLAEA', 'DISTRICT_MNESTIA', 'MNESTIA'),
-- 那刻夏 树庭 理性
('LEADER_NW_ANAXA', 'DISTRICT_CERCES', 'CERCES'),
-- 遐蝶 龙骸古城 死亡
('LEADER_NW_CASTORICE', 'DISTRICT_THANATOS', 'THANATOS'),
-- 风堇 疗愈之庭 天空
('LEADER_NW_HYACINTHIA', 'DISTRICT_AQUILA', 'AQUILA'),
-- 赛飞儿 云石市集 诡计
('LEADER_NW_CIFERA', 'DISTRICT_ZAGREUS', 'ZAGREUS'),
-- 白厄 创世涡心 负世
('LEADER_NW_PHAINON', 'DISTRICT_KEPHALE', 'KEPHALE'),
-- 海瑟音 浮影海庭 海洋
('LEADER_NW_HELEKTRA', 'DISTRICT_PHAGOUSA', 'PHAGOUSA'),
-- 刻律德菈 预言书库 律法
('LEADER_NW_CERYDRA', 'DISTRICT_TALANTON', 'TALANTON'),
-- 长夜月 长梦宸扉 岁月
('LEADER_NW_EVERNIGHT', 'DISTRICT_ORONYX', 'ORONYX'),
-- 丹恒•腾荒 万壑岩心 大地
('LEADER_NW_DANHENGPT', 'DISTRICT_GEORIOS', 'GEORIOS');


INSERT OR IGNORE INTO Players(Domain, CivilizationType, LeaderType, CivilizationName, CivilizationIcon, LeaderName,
                              LeaderIcon,
                              CivilizationAbilityName, CivilizationAbilityDescription, CivilizationAbilityIcon,
                              LeaderAbilityName,
                              LeaderAbilityDescription, LeaderAbilityIcon, Portrait, PortraitBackground)
SELECT 'Players:Expansion2_Players',
       'CIVILIZATION_NW_AMPHOREUS',
       LeaderType,
       'LOC_CIVILIZATION_NW_AMPHOREUS_NAME',
       'ICON_CIVILIZATION_NW_AMPHOREUS',
       'LOC_' || LeaderType || '_NAME',
       'ICON_' || LeaderType,
       'LOC_TRAIT_CIVILIZATION_NW_AMPHOREUS_NAME',
       'LOC_TRAIT_CIVILIZATION_NW_AMPHOREUS_DESCRIPTION',
       'ICON_CIVILIZATION_NW_AMPHOREUS',
       'LOC_TRAIT_' || LeaderType || '_' || TraitType || '_NAME',
       'LOC_TRAIT_' || LeaderType || '_' || TraitType || '_DESCRIPTION',
       'ICON_' || LeaderType,
       LeaderType || '_NEUTRAL',
       LeaderType || '_BACKGROUND'
FROM NW_Amphoreus_Config;

INSERT OR IGNORE INTO PlayerItems(Domain, CivilizationType, LeaderType, Type, Icon, Name, Description, SortIndex)
SELECT 'Players:Expansion2_Players',
        'CIVILIZATION_NW_AMPHOREUS',
        LeaderType,
        DistrictType,
        'ICON_'||DistrictType,
        'LOC_'||DistrictType||'_NAME',
        'LOC_'||DistrictType||'_DESCRIPTION',
        10
FROM NW_Amphoreus_Config UNION SELECT 
       'Players:Expansion2_Players',
        'CIVILIZATION_NW_AMPHOREUS',
        LeaderType,
        'BUILDING_NW_REMEMBRANCE',
        'ICON_BUILDING_NW_REMEMBRANCE',
        'LOC_BUILDING_NW_REMEMBRANCE_NAME',
        'LOC_BUILDING_NW_REMEMBRANCE_DESCRIPTION',
        21
FROM NW_Amphoreus_Config UNION SELECT
       'Players:Expansion2_Players',
        'CIVILIZATION_NW_AMPHOREUS',
        LeaderType,
        'BUILDING_NW_ERUDITION',
        'ICON_BUILDING_NW_ERUDITION',
        'LOC_BUILDING_NW_ERUDITION_NAME',
        'LOC_BUILDING_NW_ERUDITION_DESCRIPTION',
        22
FROM NW_Amphoreus_Config UNION SELECT
       'Players:Expansion2_Players',
        'CIVILIZATION_NW_AMPHOREUS',
        LeaderType,
        'BUILDING_NW_DESTRUCTION',
        'ICON_BUILDING_NW_DESTRUCTION',
        'LOC_BUILDING_NW_DESTRUCTION_NAME',
        'LOC_BUILDING_NW_DESTRUCTION_DESCRIPTION',
        23
FROM NW_Amphoreus_Config UNION SELECT 
       'Players:Expansion2_Players',
        'CIVILIZATION_NW_AMPHOREUS',
        LeaderType,
        'UNIT_GOLD_SON',
        'ICON_UNIT_GOLD_SON',
        'LOC_UNIT_GOLD_SON_NAME',
        'LOC_UNIT_GOLD_SON_DESCRIPTION',
        40
FROM NW_Amphoreus_Config
