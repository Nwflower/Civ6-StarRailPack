
CREATE TEMPORARY TABLE IF NOT EXISTS NW_Amphoreus_Districts
(
    LeaderType           TEXT NOT NULL PRIMARY KEY,
    DistrictType         TEXT NOT NULL,
    ReplacesDistrictType TEXT NOT NULL
);
INSERT OR IGNORE INTO NW_Amphoreus_Districts(LeaderType, DistrictType, ReplacesDistrictType)
VALUES
-- 缇宝 刻法勒广场 门径
('LEADER_NW_TRIBIOS', 'DISTRICT_JANUS', 'DISTRICT_HOLY_SITE'),
-- 万敌 悬锋竞技场 纷争
('LEADER_NW_MYDEI', 'DISTRICT_NIKADOR', 'DISTRICT_ENCAMPMENT'),
-- 阿格莱雅 云石天宫 浪漫
('LEADER_NW_AGLAEA', 'DISTRICT_MNESTIA', 'DISTRICT_AQUEDUCT'),
-- 那刻夏 树庭 理性
('LEADER_NW_ANAXA', 'DISTRICT_CERCES', 'DISTRICT_CAMPUS'),
-- 遐蝶 龙骸古城 死亡
('LEADER_NW_CASTORICE', 'DISTRICT_THANATOS', 'DISTRICT_ENTERTAINMENT_COMPLEX'),
-- 风堇 疗愈之庭 天空
('LEADER_NW_HYACINTHIA', 'DISTRICT_AQUILA', 'DISTRICT_SPACEPORT'),
-- 赛飞儿 云石市集 诡计
('LEADER_NW_CIFERA', 'DISTRICT_ZAGREUS', 'DISTRICT_COMMERCIAL_HUB'),
-- 白厄 创世涡心 负世
('LEADER_NW_PHAINON', 'DISTRICT_KEPHALE', 'DISTRICT_GOVERNMENT'),
-- 海瑟音 浮影海庭 海洋
('LEADER_NW_HELEKTRA', 'DISTRICT_PHAGOUSA', 'DISTRICT_HARBOR'),
-- 刻律德菈 预言书库 律法
('LEADER_NW_CERYDRA', 'DISTRICT_TALANTON', 'DISTRICT_DIPLOMATIC_QUARTER'),
-- 长夜月 长梦宸扉 岁月
('LEADER_NW_EVERNIGHT', 'DISTRICT_ORONYX', 'DISTRICT_THEATER'),
-- 丹恒•腾荒 万壑岩心 大地
('LEADER_NW_DANHENGPT', 'DISTRICT_GEORIOS', 'DISTRICT_INDUSTRIAL_ZONE');

INSERT INTO IconTextureAtlases(Name,IconSize,Filename)SELECT
'ATLAS_ICON_'||LeaderType,'32','ICON_'||LeaderType||'_32'
FROM NW_Amphoreus_Districts UNION SELECT
'ATLAS_ICON_'||LeaderType,'45','ICON_'||LeaderType||'_45'
FROM NW_Amphoreus_Districts UNION SELECT
'ATLAS_ICON_'||LeaderType,'48','ICON_'||LeaderType||'_48'
FROM NW_Amphoreus_Districts UNION SELECT
'ATLAS_ICON_'||LeaderType,'50','ICON_'||LeaderType||'_50'
FROM NW_Amphoreus_Districts UNION SELECT
'ATLAS_ICON_'||LeaderType,'55','ICON_'||LeaderType||'_55'
FROM NW_Amphoreus_Districts UNION SELECT
'ATLAS_ICON_'||LeaderType,'64','ICON_'||LeaderType||'_64'
FROM NW_Amphoreus_Districts UNION SELECT
'ATLAS_ICON_'||LeaderType,'80','ICON_'||LeaderType||'_80'
FROM NW_Amphoreus_Districts UNION SELECT
'ATLAS_ICON_'||LeaderType,'256','ICON_'||LeaderType||'_256'
FROM NW_Amphoreus_Districts;

INSERT INTO IconDefinitions(Name,Atlas,'Index')SELECT
'ICON_'||LeaderType,'ATLAS_ICON_'||LeaderType,0
FROM NW_Amphoreus_Districts;
