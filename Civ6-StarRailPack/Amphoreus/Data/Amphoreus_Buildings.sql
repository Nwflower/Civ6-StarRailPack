--	FILE: Amphoreus_Buildings.sql
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni
--	Copyright (c) 2025.
--	All rights reserved.
--  DateCreated: 2025/10/26 15:31:52
--------------------------------------------------------------------------------
--  作者： 千川白浪
--  特别鸣谢： 优妮
------------------------------------------------------------------------------


INSERT INTO Types    (Type, Kind)
VALUES ('BUILDING_DISTRICT_THANATOS', 'KIND_BUILDING');
INSERT INTO Buildings    (BuildingType, Name, Cost, InternalOnly, MustPurchase)
VALUES ('BUILDING_DISTRICT_THANATOS', 'LOC_DISTRICT_THANATOS_NAME', 1, 1, 1);
