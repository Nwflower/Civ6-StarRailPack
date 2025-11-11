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
    -- 云石天宫
    DISTRICT_MNESTIA = function(pPlayer,pCity)
		local peopleNow = pCity:GetPopulation();
		local peopleMax = pCity:GetGrowth():GetHousing();
		if peopleMax > peopleNow then
			pCity:ChangePopulation(peopleMax-peopleNow);
		end
        return true
    end,
    -- 树庭炸树
    DISTRICT_CERCES = function(pPlayer,pCity)
		for row in GameInfo.Buildings() do
			if row.OuterDefenseStrength and (row.OuterDefenseStrength > 0) and (row.PrereqDistrict == 'DISTRICT_CITY_CENTER') and (row.TraitType == nil) then
                if not pCity:GetBuildings():HasBuilding(row.Index) then
                    pCity:GetBuildQueue():CreateBuilding(row.Index);
                end
			end
		end
        local plots = Map.GetNeighborPlots(pCity:GetX(), pCity:GetY(), 2)
        local forestType = GameInfo.Features['FEATURE_FOREST'].Index
        for i, adjPlot in ipairs(plots) do
            if adjPlot:GetOwner()==pPlayer:GetID() and TerrainBuilder.CanHaveFeature(adjPlot, forestType) then
                TerrainBuilder.SetFeatureType(adjPlot, forestType)
            end
        end
        return true
    end,
    -- 龙骸古城
    DISTRICT_THANATOS = function(pPlayer,pCity)
        local iBuilding = GameInfo.Buildings['BUILDING_DISTRICT_THANATOS'].Index
        if not pCity:GetBuildings():HasBuilding(iBuilding) then
            pCity:GetBuildQueue():CreateBuilding(iBuilding);
        end
        local NATURAL_HISTORY_INDEX = GameInfo.Civics['CIVIC_NATURAL_HISTORY'].Index
        if not pPlayer:GetCulture():HasCivic(NATURAL_HISTORY_INDEX) then
			local Cost = pPlayer:GetCulture():GetCultureCost(NATURAL_HISTORY_INDEX);
			pPlayer:GetCulture():SetCulturalProgress(NATURAL_HISTORY_INDEX, Cost);
        end
        return true
    end,
    -- 浮影海庭
    DISTRICT_PHAGOUSA = function(pPlayer,pCity)
		for row in GameInfo.Buildings() do
			if row.BuildingType == 'BUILDING_FLOOD_BARRIER' or (row.PrereqDistrict == 'DISTRICT_HARBOR' and (row.TraitType == nil) )then
                if not pCity:GetBuildings():HasBuilding(row.Index) then
                    pCity:GetBuildQueue():CreateBuilding(row.Index);
                end
			end
		end
        return true
    end,
    -- 预言次数 + 1
    DISTRICT_TALANTON = function(pPlayer,pCity)
        local iDISTRICT_TALANTON = pPlayer:GetProperty('DISTRICT_TALANTON') or 0
        pPlayer:SetProperty('DISTRICT_TALANTON', iDISTRICT_TALANTON + 1)
        return true
    end
}
function onDistrictCompleted(playerID , districtID , cityID , iX , iY , districtType , era , civilization , percentComplete , iAppeal , isPillaged)
    local sDistrictType = GameInfo.Districts[districtType].DistrictType;
    if percentComplete==100 and AmphoreusDistrictCompleted[sDistrictType] then
        -- 由于区域建成时该方法会被调用两次，因此在这里写一个计数器
        if DistrictCount[sDistrictType] and DistrictCount[sDistrictType] == 1 then
            local pPlayer = Players[playerID]
            local pCity = CityManager.GetCity(playerID, cityID);
            AmphoreusDistrictCompleted[sDistrictType](pPlayer,pCity)
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
	local remainingMovement = pUnit:GetMovesRemaining()
	UnitManager.PlaceUnit(pUnit, pPlot:GetX(), pPlot:GetY())
	UnitManager.ChangeMovesRemaining(pUnit, remainingMovement)
end
--======================================================================
-- 那刻夏
-- 那刻夏种人工林
function onImprovementAddedToMap(iX, iY, iImprovement, iPlayer, iResource, Unknown1, Unknown2)
	if GameInfo.Improvements[iImprovement].ImprovementType == 'IMPROVEMENT_NAKEXIA_FOREST' then
		local pPlot = Map.GetPlot(iX, iY)
		if TerrainBuilder.CanHaveFeature(pPlot, GameInfo.Features['FEATURE_FOREST'].Index) then
			TerrainBuilder.SetFeatureType(pPlot, GameInfo.Features['FEATURE_FOREST'].Index)
		end
		ImprovementBuilder.SetImprovementType(pPlot, -1, NO_PLAYER);   --移除改良
	end
end

--======================================================================
-- 遐蝶
-- 单位在与非蛮族单位的战斗中死亡后，获得等于每回合 [ICON_FAITH] 信仰值收益的 [ICON_Science] 科技值、 [ICON_CULTURE] 文化值和[ICON_Gold] 金币，该单位9个单元格内信仰其他宗教的城市将皈依遐蝶的宗教。
function onUnitKilledInCombat(killedPlayerID,killedUnitID,playerID, unitID)
	if (HasTrait_Property('TRAIT_LEADER_NW_CASTORICE_THANATOS',killedPlayerID)) then
        local pPlayer = Players[killedPlayerID];
		pPlayer:AttachModifierByID('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_SCIENCE');
		pPlayer:AttachModifierByID('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_CULTURE');
		pPlayer:AttachModifierByID('MODIFIER_TRAIT_LEADER_NW_CASTORICE_THANATOS_GET_FAITH_GOLD');
	end
end
--======================================================================
-- 风堇
-- 每次完成时，将科技胜利进度推进至下一阶段。
function OnCityProjectCompleted(playerID,cityID,iProject)
	if (iProject == GameInfo.Projects["PROJECT_CLEAN_BLACK_WIND"].Index) then
        local Game_TechVictoryPreTechs	=	DB.Query("SELECT * FROM Projects WHERE SpaceRace = 1")
        local m_Index = 999
        local pPlayer = Players[playerID];
        local playerTechs = Players[playerID]:GetTechs();
		for i, row in ipairs(Game_TechVictoryPreTechs) do
            local iTech = GameInfo.Technologies[row.PrereqTech].Index
            if not (playerTechs:HasTech(iTech)) and iTech < m_Index then
                m_Index = iTech
            end
		end
        if m_Index ~= 999 then
            pPlayer:AttachModifierByID('MODIFIER_PROJECT_CLEAN_BLACK_WIND_GRANT_'..GameInfo.Technologies[m_Index].TechnologyType)
        end
	end
end
--======================================================================
-- 刻律德菈
-- 如果城市忠诚，则其溢出的忠诚度将转化为等量的 [ICON_GOLD] 金币。
function NW_LoyaltyToGold(iPlayerID, params)
    local pPlayer = Players[iPlayerID];
	pPlayer:GetTreasury():ChangeGoldBalance(params.iNum)
end
-- 预言奇观
function NW_RequestProphecy(iPlayerID, params)
    local pPlayer = Players[iPlayerID];
	pPlayer:SetProperty('NW_AM_SAY_WONDER_'..params.sBuilding, true)
    local iNW_AM_SAID_WONDER_NUM = pPlayer:GetProperty('NW_AM_SAID_WONDER_NUM') or 0
    pPlayer:SetProperty('NW_AM_SAID_WONDER_NUM', iNW_AM_SAID_WONDER_NUM + 1)
end
-- 奇观奖励
function NW_KL_GrantGoody(iPlayerID, params)
    local pPlayer = Players[params.iPlayer];
    -- 提供等同于该奇观生产力200%的文化值、金币和信仰值
    local Count = params.Count
    pPlayer:GetTreasury():ChangeGoldBalance(Count)
    pPlayer:GetReligion():ChangeFaithBalance(Count)
    pPlayer:GetCulture():ChangeCurrentCulturalProgress(Count)

    -- 提供3个随机单位
    local pCity = pPlayer:GetCities():GetCapitalCity();
    local sUnits = {}
    for row in GameInfo.Units() do
        if row.FormationClass == 'FORMATION_CLASS_LAND_COMBAT' then
            table.insert(sUnits,row.UnitType)
        end
    end
    for i = 1, 3 do
        UnitManager.InitUnit(iPlayerID, sUnits[Game.GetRandNum(#sUnits) + 1], pCity:GetX(), pCity:GetY())
    end
end

--======================================================================
function initialize()
	Events.DistrictBuildProgressChanged.Add(onDistrictCompleted);
	Events.ImprovementAddedToMap.Add(onImprovementAddedToMap);
	Events.UnitKilledInCombat.Add(onUnitKilledInCombat);
	Events.CityProjectCompleted.Add(OnCityProjectCompleted);

	GameEvents.NW_Teleport.Add(NW_Teleport);
    GameEvents.NW_LoyaltyToGold.Add(NW_LoyaltyToGold);
    GameEvents.NW_RequestProphecy.Add(NW_RequestProphecy);
    GameEvents.NW_KL_GrantGoody.Add(NW_KL_GrantGoody);
end

Events.LoadScreenClose.Add(initialize);
include('Amphoreus_Script_',true);
print('Amphoreus_Script Loaded Success.')