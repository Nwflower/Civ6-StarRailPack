--  FILE: Amphoreus_Script.lua
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni
--  Copyright (c) 2025.
--      All rights reserved.
--  DateCreated: 2025/10/26 15:31:52
--======================================================================
function HasTrait_Property(sTrait, iPlayer)
    local pPlayer = Players[iPlayer];
    local ePro = pPlayer:GetProperty('PROPERTY_' .. sTrait) or 0
    if ePro > 0 then
        return true
    end
    return false
end
--======================================================================
AmphoreusDistrictCompleted = {
    -- 龙骸古城
    DISTRICT_THANATOS = function(pPlayer, pCity, index)
        if index == 1 then
            local NATURAL_HISTORY_INDEX = GameInfo.Civics['CIVIC_NATURAL_HISTORY'].Index
            if not pPlayer:GetCulture():HasCivic(NATURAL_HISTORY_INDEX) then
                local Cost = pPlayer:GetCulture():GetCultureCost(NATURAL_HISTORY_INDEX);
                pPlayer:GetCulture():SetCulturalProgress(NATURAL_HISTORY_INDEX, Cost);
            end
            if not pCity:GetBuildings():HasBuilding(GameInfo.Buildings['BUILDING_DISTRICT_THANATOS'].Index) then
                pCity:GetBuildQueue():CreateBuilding(GameInfo.Buildings['BUILDING_DISTRICT_THANATOS'].Index);
            end
        end
        return true
    end
}
function NW_AmphoreusDistrictCompleted(iPlayerID, params)
    if AmphoreusDistrictCompleted[params.districtType] then
        local pPlayer = Players[params.playerID]
        local pCity = CityManager.GetCity(params.playerID, params.cityID);
        local index = pPlayer:GetProperty('PROPERTY_' .. params.districtType) or 0
        local result = AmphoreusDistrictCompleted[params.districtType](pPlayer, pCity, index)
        print('Gameplay Event NW_AmphoreusDistrictCompleted',params.playerID,params.cityID,params.districtType,index)
        -- 回传结果，表明该事件已完成
        ReportingEvents.SendLuaEvent('NW_ADC_Events_END', {
            playerId = params.playerID,
            cityID = params.cityID,
            districtType = params.districtType,
            result = result
        });
    end
end

--======================================================================
-- 缇宝
-- 单位传送
function NW_Teleport(iPlayerID, params)
    local pUnit = Players[iPlayerID]:GetUnits():FindID(params.iUnit)
    local pPlot = Map.GetPlotByIndex(params.iPlot)
    UnitManager.PlaceUnit(pUnit, pPlot:GetX(), pPlot:GetY())
    ReportingEvents.SendLuaEvent('NW_AM_TIBAO_HIDE_BUTTON', {
        playerId = iPlayerID
    });
end
--======================================================================
function initialize()
    GameEvents.NW_AmphoreusDistrictCompleted.Add(NW_AmphoreusDistrictCompleted);
    GameEvents.NW_Teleport.Add(NW_Teleport);
end

Events.LoadScreenClose.Add(initialize);
