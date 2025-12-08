-- Firefly_Gameplay
-- Author: Pen
-- DateCreated: 2024/7/26 16:00:05
--------------------------------------------------------------
local FireflySum = GameInfo.Units['UNIT_PEN_FIREFLY_SAMU'].Index

function FindNearestTargetCity( eTargetPlayer, iX, iY )
    local pCity = nullptr;
    local iShortestDistance = 10000;
	local pPlayer = Players[eTargetPlayer];
	local pPlayerCities:table = pPlayer:GetCities()
	for i, pLoopCity in pPlayerCities:Members() do
		local iDistance = Map.GetPlotDistance(iX, iY, pLoopCity:GetX(), pLoopCity:GetY());
		if (iDistance < iShortestDistance) then
			pCity = pLoopCity;
			iShortestDistance = iDistance
		end
	end

	if (pCity == nullptr) then
		print ("No target city found of player " .. tostring(eTargetPlayer) .. "in attack from " .. tostring(iX) .. ", " .. tostring(iY));
	end
   
    return pCity;
end

function FireflyVolcanicSoilCreate(playerID, pPlot)
	if (pPlot:GetFeatureType() == -1) 
	and GameInfo.TerrainClasses[pPlot:GetTerrainClassType()].TerrainClassType ~= "FEATURE_VTERRAIN_CLASS_MOUNTAINOLCANIC" --不为山脉
	and not pPlot:IsWater() then--不为水域
		TerrainBuilder.SetFeatureType(pPlot,GameInfo.Features["FEATURE_VOLCANIC_SOIL"].Index);
	end
end

function FireflyCityBuilt(playerID,cityID )
	local pPlayer = Players[playerID]
	if pPlayer ~= nil then
		if pPlayer:GetProperty('PEN_FIREFLY_ALL_VOLCANIC_SOIL') == nil or pPlayer:GetProperty('PEN_FIREFLY_ALL_VOLCANIC_SOIL') == 0 then
			return;
		end
		local pCity = CityManager.GetCity(playerID, cityID)
		if pCity ~= nil then
			local pPlot = Map.GetPlot(pCity:GetX(), pCity:GetY())
			--local pCityPlots = pCity:GetOwnedPlots()
			--local pCityName = Locale.Lookup(pCity:GetName())
			--for k, pPlot in pairs(pCityPlots) do
				--if	pPlot ~= nil then
					FireflyVolcanicSoilCreate(playerID, pPlot)
				--end
			--end
		end
	end
end

function FireflyProjectCompleted(playerID:number, cityID:number, projectIndex, buildingIndex:number, locX:number, locY:number, bCanceled:boolean)
	local pPlayer = Players[playerID];
	if (playerID == PlayerTypes.NONE) then
		return;	-- Nobody there to watch; just exit.
	end
	local sCompleteProject = GameInfo.Projects[projectIndex].ProjectType
	if sCompleteProject ~= nil and sCompleteProject == "PROJECT_PEN_GLAMOTH_TITANIA_DREAM" then
		local IsFireFly = pPlayer:GetProperty('PEN_GLAMOTH_GAIN_CAVALRY_FROM_PROJECT')
		local pCity = CityManager.GetCity(playerID, cityID);
		if IsFireFly ~= nil and pCity ~= nil then
			local PopNum = (pCity:GetPopulation()-1)*IsFireFly 
			if PopNum >= 0 then--防止城市人口掉为负数
				for i = 0,PopNum do--执行多次
					pPlayer:GetUnits():Create(FireflySum, pCity:GetX(), pCity:GetY())
				end
				pCity:ChangePopulation(-1);
			end
		end
	end 
end

function FireflyRemoveFeature(playerID,params)
	local pPlayer = Players[playerID]
	local PlotIndex = params.PlotIndex
	local pPlot = Map.GetPlotByIndex(PlotIndex)
	if	pPlot ~= nil then
		FireflyVolcanicSoilCreate(playerID, pPlot)
	end
end

function FireflyRemoveBarbCamp(PlotX, PlotY, playerID)
	local pPlayer = Players[playerID]
    if pPlayer == nil or (not pPlayer:IsBarbarian()) then
		return--仅当PlayerID为蛮族时进行下面程序
	end
	local pPlot = Map.GetPlot(PlotX, PlotY)
	local Hasfindunit = false
	if pPlot:IsUnit() then
		--单元格上有单位
		for _, pUnit in ipairs(Units.GetUnitsInPlot(pPlot)) do
			if pUnit ~= nil then
				local unitPlayerID = pUnit:GetOwner();
				local unitPlayer = Players[unitPlayerID];
				if (unitPlayer ~= nil) and unitPlayer:IsMajor() then
					Hasfindunit = true--如果在蛮寨上存在非蛮族单位，则视为找到清除蛮寨的单位
					if unitPlayer:GetProperty("PEN_GLAMOTH_GAIN_CAVALRY_FROM_BARB") ~= nil and unitPlayer:GetProperty("PEN_GLAMOTH_GAIN_CAVALRY_FROM_BARB") > 0 then
						local pCity = FindNearestTargetCity(unitPlayerID,pUnit:GetX(),pUnit:GetY())
						if pCity ~= nil then
							local CityX = pCity:GetX()
							local CityY = pCity:GetY()
							UnitManager.InitUnitValidAdjacentHex(unitPlayerID, "UNIT_PEN_FIREFLY_SAMU", CityX, CityY, 1)
							break;
						end
					end
				end
			end
		end	
	end
	--若未找到蛮寨单元格上清除蛮寨的单位，考虑海军掠夺
	if	not Hasfindunit then
		local NeighborPlots = Map.GetNeighborPlots(pPlot:GetX(),pPlot:GetY(), 1)--搜寻周围1个内的地块
		for _, adjPlot in ipairs(NeighborPlots) do
			for _, pUnit in ipairs(Units.GetUnitsInPlot(pPlot)) do
				if pUnit ~= nil and GameInfo.Units[pUnit:GetType()].FormationClass == 'FORMATION_CLASS_NAVAL' then
					local unitPlayerID = pUnit:GetOwner();
					local unitPlayer = Players[unitPlayerID];
					if (unitPlayer ~= nil) and unitPlayer:IsMajor() then
						if unitPlayer:GetProperty("PEN_GLAMOTH_GAIN_CAVALRY_FROM_BARB") ~= nil and unitPlayer:GetProperty("PEN_GLAMOTH_GAIN_CAVALRY_FROM_BARB") > 0 then
							local pCity = FindNearestTargetCity(unitPlayerID,pUnit:GetX(),pUnit:GetY())
							if pCity ~= nil then
								local CityX = pCity:GetX()
								local CityY = pCity:GetY()
								UnitManager.InitUnitValidAdjacentHex(unitPlayerID, "UNIT_PEN_FIREFLY_SAMU", CityX, CityY, 1)
								return;--break只能跳一层循环，用return跳两层for
							end
						end
					end
				end
			end
		end
	end
end


function Initialize()
	Events.CityProjectCompleted.Add(FireflyProjectCompleted)
	GameEvents.CityBuilt.Add(FireflyCityBuilt)

	Events.ImprovementRemovedFromMap.Add(FireflyRemoveBarbCamp)
	
	GameEvents.FireflyRemoveFeature.Add(FireflyRemoveFeature)
end
Events.LoadGameViewStateDone.Add(Initialize);