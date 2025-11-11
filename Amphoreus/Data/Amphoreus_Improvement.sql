-- Amphoreus_Improvement
-- Author: Nwflower
-- DateCreated: 2025-3-30 14:34:01
--------------------------------------------------------------
--================
-- 种植天然林
--================
INSERT INTO Types(Type, Kind)
VALUES ('IMPROVEMENT_NAKEXIA_FOREST', 'KIND_IMPROVEMENT');

INSERT INTO Improvements(ImprovementType,
                         Name,
                         PrereqTech,
                         Buildable,
                         Description,
                         PlunderType,
                         PlunderAmount,
                         Icon,
                         TraitType,
                         Goody,
                         Capturable)
VALUES ('IMPROVEMENT_NAKEXIA_FOREST', -- ImprovementType
        'LOC_IMPROVEMENT_NAKEXIA_FOREST_NAME', -- Name
        NULL, -- PrereqTech
        1, -- Buildable
        'LOC_IMPROVEMENT_NAKEXIA_FOREST_DESCRIPTION', -- Description
        'NO_PLUNDER', -- PlunderType
        0, -- PlunderAmount
        'ICON_UNITOPERATION_PLANT_FOREST', -- Icon
        'TRAIT_CIVILIZATION_NO_PLAYER', -- TraitType
        0, -- Goody (Hide it on civilopedia)
        1);

INSERT INTO Improvement_ValidBuildUnits(ImprovementType, UnitType)
VALUES ('IMPROVEMENT_NAKEXIA_FOREST', 'UNIT_BUILDER');

INSERT INTO Improvement_ValidTerrains (ImprovementType, TerrainType)
VALUES ('IMPROVEMENT_NAKEXIA_FOREST', 'TERRAIN_PLAINS'),
       ('IMPROVEMENT_NAKEXIA_FOREST', 'TERRAIN_PLAINS_HILLS'),
       ('IMPROVEMENT_NAKEXIA_FOREST', 'TERRAIN_GRASS'),
       ('IMPROVEMENT_NAKEXIA_FOREST', 'TERRAIN_GRASS_HILLS'),
       ('IMPROVEMENT_NAKEXIA_FOREST', 'TERRAIN_TUNDRA'),
       ('IMPROVEMENT_NAKEXIA_FOREST', 'TERRAIN_TUNDRA_HILLS');

INSERT INTO Improvement_YieldChanges(ImprovementType, YieldType, YieldChange) VALUES
('IMPROVEMENT_NAKEXIA_FOREST', 'YIELD_PRODUCTION', 1);

INSERT INTO CivilopediaPageExcludes(SectionId, PageId)
VALUES ('IMPROVEMENTS', 'IMPROVEMENT_NAKEXIA_FOREST');