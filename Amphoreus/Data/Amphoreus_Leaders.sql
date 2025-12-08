--	FILE: Amphoreus_Leader.sql
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni
--	Copyright (c) 2025.
--	All rights reserved.
--  DateCreated: 2025/10/26 15:31:52
--======================================================================
--  作者： 千川白浪
--  特别鸣谢： 优妮
--======================================================================

CREATE TEMPORARY TABLE IF NOT EXISTS NW_Amphoreus_Config
(
    LeaderType   TEXT NOT NULL PRIMARY KEY,
    DistrictType TEXT NOT NULL,
    TraitType    TEXT NOT NULL,
    CapitalName  TEXT DEFAULT 'LOC_CITY_NAME_AMPHOREUS_1',
    Sex TEXT DEFAULT 'Female'
);
INSERT OR IGNORE INTO NW_Amphoreus_Config(LeaderType, DistrictType, TraitType, CapitalName)
VALUES
-- 缇宝 刻法勒广场 门径
('LEADER_NW_TRIBIOS', 'DISTRICT_JANUS', 'JANUS','LOC_CITY_NAME_NW_AMPHOREUS_2'),
-- 万敌 悬锋竞技场 纷争
('LEADER_NW_MYDEI', 'DISTRICT_NIKADOR', 'NIKADOR', 'LOC_CITY_NAME_NW_AMPHOREUS_XUANFENG'),
-- 阿格莱雅 云石天宫 浪漫
('LEADER_NW_AGLAEA', 'DISTRICT_MNESTIA', 'MNESTIA','LOC_CITY_NAME_NW_AMPHOREUS_AOHEMA'),
-- 那刻夏 树庭 理性
('LEADER_NW_ANAXA', 'DISTRICT_CERCES', 'CERCES', 'LOC_CITY_NAME_NW_AMPHOREUS_SHENWUSHUTING'),
-- 遐蝶 龙骸古城 死亡
('LEADER_NW_CASTORICE', 'DISTRICT_THANATOS', 'THANATOS', 'LOC_CITY_NAME_NW_AMPHOREUS_13'),
-- 风堇 疗愈之庭 天空
('LEADER_NW_HYACINTHIA', 'DISTRICT_AQUILA', 'AQUILA', 'LOC_CITY_NAME_NW_AMPHOREUS_AOHEMA'),
-- 赛飞儿 云石市集 诡计
('LEADER_NW_CIFERA', 'DISTRICT_ZAGREUS', 'ZAGREUS', 'LOC_CITY_NAME_NW_AMPHOREUS_AOHEMA'),
-- 白厄 创世涡心 负世
('LEADER_NW_PHAINON', 'DISTRICT_KEPHALE', 'KEPHALE', 'LOC_CITY_NAME_NW_AMPHOREUS_6'),
-- 海瑟音 浮影海庭 海洋
('LEADER_NW_HELEKTRA', 'DISTRICT_PHAGOUSA', 'PHAGOUSA', 'LOC_CITY_NAME_NW_AMPHOREUS_7'),
-- 刻律德菈 预言书库 律法
('LEADER_NW_CERYDRA', 'DISTRICT_TALANTON', 'TALANTON', 'LOC_CITY_NAME_NW_AMPHOREUS_AOHEMA'),
-- 长夜月 长梦宸扉 岁月
('LEADER_NW_EVERNIGHT', 'DISTRICT_ORONYX', 'ORONYX', 'LOC_CITY_NAME_NW_AMPHOREUS_AOHEMA'),
-- 丹恒•腾荒 万壑岩心 大地
('LEADER_NW_DANHENGPT', 'DISTRICT_GEORIOS', 'GEORIOS', 'LOC_CITY_NAME_NW_AMPHOREUS_AOHEMA');

UPDATE NW_Amphoreus_Config SET Sex = 'Male' WHERE LeaderType IN ('LEADER_NW_MYDEI','LEADER_NW_ANAXA','LEADER_NW_PHAINON','LEADER_NW_DANHENGPT');

INSERT INTO Types (Type, Kind)
SELECT LeaderType, 'KIND_LEADER'
FROM NW_Amphoreus_Config
UNION
SELECT 'TRAIT_' || LeaderType || '_' || TraitType,
       'KIND_TRAIT'
FROM NW_Amphoreus_Config
UNION
SELECT 'TRAIT_' || DistrictType,
       'KIND_TRAIT'
FROM NW_Amphoreus_Config;

INSERT INTO Leaders (LeaderType, Name, InheritFrom, Sex, SceneLayers)
SELECT LeaderType, 'LOC_' || LeaderType || '_NAME', 'LEADER_DEFAULT', Sex, 4
FROM NW_Amphoreus_Config;

INSERT INTO LeaderQuotes (LeaderType, Quote)
SELECT LeaderType, 'LOC_' || LeaderType || '_QUOTE'
FROM NW_Amphoreus_Config;

INSERT INTO LoadingInfo(LeaderType, ForegroundImage, BackgroundImage, PlayDawnOfManAudio, LeaderText)
SELECT LeaderType,
       LeaderType || '_NEUTRAL',
       LeaderType || '_BACKGROUND',
       1,
       'LOC_LOADING_INFO_'||LeaderType
FROM NW_Amphoreus_Config;


INSERT INTO Traits (TraitType, Name, Description)
SELECT 'TRAIT_' || LeaderType || '_' || TraitType,
       'LOC_TRAIT_' || LeaderType || '_' || TraitType || '_NAME',
       'LOC_TRAIT_' || LeaderType || '_' || TraitType || '_DESCRIPTION'
FROM NW_Amphoreus_Config;
INSERT INTO Traits (TraitType)
SELECT 'TRAIT_' || DistrictType
FROM NW_Amphoreus_Config;

INSERT INTO LeaderTraits (LeaderType, TraitType)
SELECT LeaderType, 'TRAIT_' || LeaderType || '_' || TraitType
FROM NW_Amphoreus_Config UNION
SELECT LeaderType, 'TRAIT_' || DistrictType
FROM NW_Amphoreus_Config;


INSERT INTO CivilizationLeaders (CivilizationType, LeaderType, CapitalName)
SELECT 'CIVILIZATION_NW_AMPHOREUS', LeaderType, CapitalName
FROM NW_Amphoreus_Config;