--  FILE: Amphoreus_Script.lua
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni
--  Copyright (c) 2025.
--      All rights reserved.
--  DateCreated: 2025/10/26 15:31:52

include('NwflowerMODCore')


--======================================================================

local DistrictCount = {}

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
    DISTRICT_THANATOS = function(pPlayer, pCity)
        local NATURAL_HISTORY_INDEX = GameInfo.Civics['CIVIC_NATURAL_HISTORY'].Index
        if not pPlayer:GetCulture():HasCivic(NATURAL_HISTORY_INDEX) then
            local Cost = pPlayer:GetCulture():GetCultureCost(NATURAL_HISTORY_INDEX);
            pPlayer:GetCulture():SetCulturalProgress(NATURAL_HISTORY_INDEX, Cost);
        end
        return true
    end,
    -- 预言次数 + 1
    DISTRICT_TALANTON = function(pPlayer, pCity)
        local iDISTRICT_TALANTON = pPlayer:GetProperty('DISTRICT_TALANTON') or 0
        pPlayer:SetProperty('DISTRICT_TALANTON', iDISTRICT_TALANTON + 1)
        return true
    end
}
function onDistrictCompleted(playerID, districtID, cityID, iX, iY, districtType, era, civilization, percentComplete, iAppeal, isPillaged)
    local sDistrictType = GameInfo.Districts[districtType].DistrictType;
    if percentComplete == 100 and AmphoreusDistrictCompleted[sDistrictType] then
        -- 由于区域建成时该方法会被调用两次，因此在这里写一个计数器
        if DistrictCount[sDistrictType] and DistrictCount[sDistrictType] == 1 then
            local pPlayer = Players[playerID]
            local pCity = CityManager.GetCity(playerID, cityID);
            AmphoreusDistrictCompleted[sDistrictType](pPlayer, pCity)
            DistrictCount[sDistrictType] = 0
        else
            DistrictCount[sDistrictType] = 1
        end
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
-- 白厄
-- 政策卡解锁
function Nw_AM_TRAIT_LEADER_NW_PHAINON_KEPHALE(iPlayerID, params)
    local pPlayer = Players[params.iPlayer];
    local pPlayerCulture	=	pPlayer:GetCulture();
    pPlayerCulture:UnlockPolicy(GameInfo.Policies['POLICY_TRAIT_LEADER_NW_PHAINON'].Index);
end

--======================================================================
-- 刻律德菈
-- 预言奇观
function NW_RequestProphecy(iPlayerID, params)
    local pPlayer = Players[iPlayerID];
    pPlayer:SetProperty('NW_AM_SAY_WONDER_' .. params.sBuilding, true)
    local iNW_AM_SAID_WONDER_NUM = pPlayer:GetProperty('NW_AM_SAID_WONDER_NUM') or 0
    pPlayer:SetProperty('NW_AM_SAID_WONDER_NUM', iNW_AM_SAID_WONDER_NUM + 1)
end
-- 奇观奖励
function NW_KL_GrantGoody(iPlayerID, params)
    local pPlayer = Players[params.iPlayer];
    -- 提供3个随机单位
    local pCity = pPlayer:GetCities():GetCapitalCity();
    local sUnits = {}
    for row in GameInfo.Units() do
        if row.FormationClass == 'FORMATION_CLASS_LAND_COMBAT' and pPlayer:GetTechs():HasTech(GameInfo.Technologies[row.PrereqTech].Index) then
            table.insert(sUnits, row.UnitType)
        end
    end
    for i = 1, 3 do
        UnitManager.InitUnit(iPlayerID, sUnits[Game.GetRandNum(#sUnits) + 1], pCity:GetX(), pCity:GetY())
    end
end

--======================================================================
function initialize()
    Events.DistrictBuildProgressChanged.Add(onDistrictCompleted);

    GameEvents.NW_Teleport.Add(NW_Teleport);
    GameEvents.NW_RequestProphecy.Add(NW_RequestProphecy);
    GameEvents.NW_KL_GrantGoody.Add(NW_KL_GrantGoody);
    GameEvents.Nw_AM_TRAIT_LEADER_NW_PHAINON_KEPHALE.Add(Nw_AM_TRAIT_LEADER_NW_PHAINON_KEPHALE);
end

Events.LoadScreenClose.Add(initialize);
