-- LuoFu_XianZhou_Gameplay
-- Author: Pen
-- DateCreated: 2024/2/12 14:58:04
--------------------------------------------------------------
include("SupportFunctions");
--------------------------------------------------------------
local SpeedMul = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].CostMultiplier/100 or 1;--游戏速度
local NotHasBarbarians 		= GameConfiguration.GetValue("GAME_NO_BARBARIANS")			--true or false
local HasBarbariansClans	= GameConfiguration.GetValue("GAMEMODE_BARBARIAN_CLANS")	--true or false
local XianZhouHeliobiRebelMessage	= { Type = 'NOTIFICATION_XIANZHOU_HUOHUO',	Message = "LOC_XIANZHOU_NOTIFICATION_HELIOBI_REBEL_MAP_MESSAGE", 	Summary = "LOC_XIANZHOU_NOTIFICATION_HELIOBI_REBEL_MA_SUMMARY"};
local BarbariansCamppawnChance = 50
local BarbariansNavalWeight = 0.20
local HeliobiExp = 0.3;
local iDifficulty = 0;

local YIELD_COLORS = {
	YIELD_SCIENCE = '[COLOR_FLOAT_SCIENCE]',
	YIELD_CULTURE = '[COLOR_FLOAT_CULTURE]',
	YIELD_PRODUCTION = '[COLOR_FLOAT_PRODUCTION]',
	--YIELD_FOOD = '[COLOR_FLOAT_FOOD]',
	YIELD_FAITH = '[COLOR_FLOAT_FAITH]',
	YIELD_GOLD = '[COLOR_FLOAT_GOLD]',
}

function XianZhouGameEraChanged(previousEraIndex, newEraIndex)
	local pAllPlayerIDs : table = PlayerManager.GetAliveIDs()
	for	k, iPlayerID in ipairs(pAllPlayerIDs) do
		local pPlayer = Players[iPlayerID]
		if pPlayer:GetProperty('XIANZHOU_CAN_SLOT_GOLDEN_POLICIES') == nil or pPlayer:GetProperty('XIANZHOU_CAN_SLOT_GOLDEN_POLICIES') == 0 then
			return;
		end
		--print("XianZhouGameEraChanged",iPlayerID)
		if	pPlayer:GetProperty('XianZhouHasUnlockPolicies') == nil then
			--local tResults: table = DB.Query("SELECT * FROM CommemorationTypes");
			--print(tResults)
			--if tResults and #tResults > 0 then--如果查询到
				for row in GameInfo.CommemorationTypes() do 
					local pPlayerCulture = pPlayer:GetCulture()
					--print(row.CommemorationType)
					pPlayerCulture:UnlockPolicy(GameInfo.Policies['POLICY_XIANZHOU_'..row.CommemorationType].Index); --解锁政策卡
				end
			--end
			pPlayer:SetProperty('XianZhouHasUnlockPolicies',1)
		end
	end
end

function XianZhouCityPopulationChanged(playerID, cityID, ChangeAmount)
	local pPlayer = Players[playerID];
	--print(playerID,cityID,ChangeAmount)
	--判断是镜流
	if pPlayer:GetProperty('XIANZHOU_LEADER_QUEST_PER_POPULATION_GROW') == nil or pPlayer:GetProperty('XIANZHOU_LEADER_QUEST_PER_POPULATION_GROW') == 0 then
		return;
	end
	--print("XianZhouCityPopulationChanged",playerID,cityID,ChangeAmount)
	local pCity = CityManager.GetCity(playerID, cityID);
	if pCity then
		local CityPlot = Map.GetPlot(pCity:GetX(), pCity:GetY());
		local pCityGrowth	:table = pCity:GetGrowth();
		local FoodSurplus = pCityGrowth:GetFoodSurplus();--检测余粮
		local isStarving = pCityGrowth:GetTurnsUntilGrowth() ~= -1;
		if ChangeAmount > 0 then
			local pGameEra = Game.GetEras()
			local ReduceEraScore = pPlayer:GetProperty('XIANZHOU_LEADER_QUEST_PER_POPULATION_GROW')
			pGameEra:ChangePlayerEraScore(playerID, ReduceEraScore)--减少时代分
		end
	end
end

function XianZhouFirstCityBuilt(playerID, cityID, iX, iY)
	--local pAllPlayerIDs : table = PlayerManager.GetAliveIDs();
	--for k, iPlayerID in ipairs(pAllPlayerIDs) do
		local pPlayer = Players[playerID];
		--判断是镜流
		if pPlayer:GetProperty('XIANZHOU_LEADER_FIRST_CITY_REDUCE_ERASCORE') == nil or pPlayer:GetProperty('XIANZHOU_LEADER_FIRST_CITY_REDUCE_ERASCORE') == 0 then
			return;
		end
		if  pPlayer:GetProperty('XianZhouHasCapital') == nil then
			local pGameEra = Game.GetEras()
			pGameEra:ChangePlayerEraScore(playerID, pPlayer:GetProperty('XIANZHOU_LEADER_FIRST_CITY_REDUCE_ERASCORE'))--减少时代分
			pPlayer:SetProperty('XianZhouHasCapital',1)
		end
	--end
end

function XianZhouSendNotificationPlot (notificationData :table, pPlot :table, iNotifyPlayer :number)
	if (pPlot == nil) then
		return;
	end
	local msgString = Locale.Lookup(notificationData.Message);
	local sumString = Locale.Lookup(notificationData.Summary);
	--print("1:",#pPlotTable)
	if(iNotifyPlayer ~= nil) then
		local iPlot = Map.GetPlotByIndex(iPlotIndex);
		NotificationManager.SendNotification(iNotifyPlayer, notificationData.Type, msgString, sumString, pPlot:GetX(), pPlot:GetY());
	end
end

--Reference from BBG
function XianZhouPlaceOriginalBarbCamps()
	
	--local BarbsSetting = GameConfiguration.GetValue("BARBS_SETTING")
	local base = PlayerManager.GetAliveMajorsCount()
	base = tonumber(base)
	--local placed_camps = 0
	print("PlaceOriginalBarbCamps",base)
	if base > 0 then
		local iCount = Map.GetPlotCount();
		local validPlots = {};
		-- Scan all the Map
		for plotIndex = 0, iCount-1, 1 do
			local pPlot = Map.GetPlotByIndex(plotIndex)
			local bValid = false
			local bValidTerrain = true
			local iTargetID = -1
			-- First Check
			if pPlot:IsWater() or pPlot:IsImpassable() or pPlot:IsNaturalWonder() or pPlot:GetOwner() ~= -1 then
				bValidTerrain = false
			end

			-- Assign Players
			--首先找到藿藿出生点7格范围内符合条件的单元格
			if bValidTerrain == true then
				for i, playerID in ipairs(PlayerManager.GetAliveIDs()) do
					if Players[playerID] ~= nil then
						if Players[playerID]:IsMajor() then
							if Players[playerID]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') ~= nil and Players[playerID]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') > 0 then
								local sPlot = Players[playerID]:GetStartingPlot()
								if Map.GetPlotDistance(pPlot:GetX(),pPlot:GetY(),sPlot:GetX(),sPlot:GetY()) == 7 then
									bValid = true
									iTargetID = playerID
									break
								end
							end
						end
					end
				end	
			end
			-- We have a plot within 6 tiles of a spawn check it is not near than 6 of another Major
			--判断该单元格不在别的文明7格范围内
			if bValid == true then
				for i, playerID in ipairs(PlayerManager.GetAliveIDs()) do
					if Players[playerID] ~= nil then
						local pPlayerConfig:table = PlayerConfigurations[playerID];
						if pPlayerConfig and pPlayerConfig:GetLeaderTypeName() ~= "LEADER_SPECTATOR" then
							local sPlot = Players[playerID]:GetStartingPlot()
							if sPlot ~= nil then
								if (Map.GetPlotDistance(pPlot:GetX(),pPlot:GetY(),sPlot:GetX(),sPlot:GetY()) < 6 and Players[playerID]:IsMajor()) or Map.GetPlotDistance(pPlot:GetX(),pPlot:GetY(),sPlot:GetX(),sPlot:GetY()) < 4 then
									bValid = false
									--print("Barbs: Can't Place Here it Would Be Next To Another Player",PlayerConfigurations[playerID]:GetLeaderTypeName(),sPlot:GetX(),sPlot:GetY())
									break
								end
							end
						end
					end
				end	
			end
			
			-- Insert 
			--符合条件的单元格记录在table里
			if bValid == true then
				local tmp = {plot = pPlot, id = iTargetID} 
				--print("Barbs: Valid Plot!",pPlot:GetX(), pPlot:GetY(),id)
				table.insert(validPlots, tmp)
			end
		end
		
		-- Place on the map
		if validPlots ~= nil then
			for i, playerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
				if Players[playerID] ~= nil then
					if (Players[playerID]:IsMajor()) and Players[playerID]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') ~= nil and Players[playerID]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') > 0 then
							local rng = RandRange(1, 100, "PEN - Place Original Camp()");
							rng = rng / 100
						--print("Barbs: Valid Plot rng!",playerID,rng,(iDifficulty/BarbariansCamppawnChance*10))
						if	rng < (iDifficulty/BarbariansCamppawnChance*10) then
							for j, plotTable in ipairs(validPlots) do
								if plotTable.id == playerID then
									local pPlot = plotTable.plot
									print("Barbs: Valid Plot!",j,plotTable.id,pPlot:GetX(), pPlot:GetY())
									-- Only place Improvement
									XianZhouPlaceBarbarianCamp(pPlot:GetX(), pPlot:GetY(),playerID,2)
									break
								end
							end
						end
					end
				end	
			end	
		end
		
	end
end

function XianZhouAddBarbCamps()
	--print("		AddBarbCamps()")			
	local rng = RandRange(1, 100, "PEN - AddBarbCamps()");
	rng = rng / 100
	local iCount = Map.GetPlotCount();
	local validPlots = {};
	local currentTurn = Game.GetCurrentGameTurn()
	local startTurn = GameConfiguration.GetStartTurn()
	--local BarbsSetting = GameConfiguration.GetValue("BARBS_SETTING")
	local bNaval = true
	if rng < BarbariansNavalWeight then
		if  currentTurn > startTurn + 10 then
		-- Coastal
		-- Any Coastal tiles at least 5 plots away from anyone
			for plotIndex = 0, iCount-1, 1 do
				local pPlot = Map.GetPlotByIndex(plotIndex)
				local bValid = false
				-- Check Coastal
				if pPlot:IsCoastalLand() == true and pPlot:IsImpassable() == false and pPlot:IsNaturalWonder() == false and pPlot:IsLake() == false  and pPlot:GetOwner() == -1 then
					bValid = true
				end
				if bValid == true then
					local count = 0
					for i = 1, 36 do
						local plotScanned = GetAdjacentTiles(pPlot, i)
						if plotScanned ~= nil then
							if plotScanned:IsWater() == true then
								count = count + 1
							end
							if plotScanned:GetImprovementType() ~= -1 then
								bValid = false
								--print("Barbs: Can't Place Here it: Too close to other Barbs",plotScanned:GetX(),plotScanned:GetY())
								break
							end
						end
					end
					if count < 6 then
						bValid = false
					end
				end
				-- Check Vision
				--[[
				if bValid == true then
					for i, playerID in ipairs(PlayerManager.GetAliveIDs()) do
						if playerID < 60 then
							local pVis = PlayerVisibilityManager.GetPlayerVisibility(playerID)
							if pVis ~= nil then
								if pVis:GetState(plotIndex) == RevealedState.VISIBLE then
									bValid = false
									break
								end
							end
						end	
					end
				end
				]]
				-- Check Buffer
				if bValid == true then
					for i, playerID in ipairs(PlayerManager.GetAliveIDs()) do
						if Players[playerID] ~= nil then
							if Players[playerID]:IsMajor() then
								--local pPlayerConfig:table = PlayerConfigurations[playerID];
								if	Players[playerID]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') ~= nil and Players[playerID]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') > 0 then
									local playerCities = Players[playerID]:GetCities()
									for j, city in playerCities:Members() do
										if Map.GetPlotDistance(pPlot:GetX(),pPlot:GetY(),city:GetX(),city:GetY()) < 4 then
											bValid = false
											break
										end
									end
									if bValid == false then
										break
									end
								end
							end
						end
					end	
				end	

				-- Insert 
				if bValid == true then
					--print("Barbs Add: Valid Plot!",pPlot:GetX(), pPlot:GetY())
					local tmp = {plot = pPlot, id = -1, bNaval = bNaval, horse = bHorse} 
					table.insert(validPlots, tmp)
				end		
			end
			
		end
	else
		bNaval = false
		-- Non-Coastal
		for plotIndex = 0, iCount-1, 1 do
			local pPlot = Map.GetPlotByIndex(plotIndex)
			local bValid = false
			local bValidTerrain = true
			local bHorse = false
			local iTargetID = -1
			-- First Check
			if pPlot:IsWater() or pPlot:IsImpassable() or pPlot:IsNaturalWonder() or pPlot:GetOwner() ~= -1 then
				bValidTerrain = false
			end
			--[[
			-- Check Vision
			if bValidTerrain == true then
				for i, playerID in ipairs(PlayerManager.GetAliveIDs()) do
					if playerID < 60 then
						local pVis = PlayerVisibilityManager.GetPlayerVisibility(playerID)
						if pVis ~= nil then
							if pVis:GetState(plotIndex) == RevealedState.VISIBLE then
								bValidTerrain = false
								break
							end
						end
					end	
				end
			end
			]]	
			-- Assign Players
			if bValidTerrain == true then
				for i, playerID in ipairs(PlayerManager.GetAliveIDs()) do
					if Players[playerID] ~= nil then
						if Players[playerID]:IsMajor() then
							--local pPlayerConfig:table = PlayerConfigurations[playerID];
							if 	Players[playerID]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') ~= nil and Players[playerID]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') > 0 then
								local playerCities = Players[playerID]:GetCities()
								for j, city in playerCities:Members() do
									if 3 < Map.GetPlotDistance(pPlot:GetX(),pPlot:GetY(),city:GetX(),city:GetY()) and Map.GetPlotDistance(pPlot:GetX(),pPlot:GetY(),city:GetX(),city:GetY()) <= 7 then
										bValid = true
										iTargetID = playerID
										break
									end
								end
								if bValid == true then
									break
								end
							end
						end
					end
				end	
			end
			-- Check no other barbs are too close
			if bValid == true then
				for i = 1, 36 do
					local plotScanned = GetAdjacentTiles(pPlot, i)
					if plotScanned ~= nil then
						if plotScanned:GetImprovementType() ~= -1 then
							bValid = false
							--print("Barbs: Can't Place Here it: Too close to other Barbs",plotScanned:GetX(),plotScanned:GetY())
							break
						end
					end
				end
			end
			--Now Check there is no Horses nearby do it would not turn as a Horse camp
			if bValid == true and currentTurn > startTurn + 10 then
				for i = 1, 36 do
					local plotScanned = GetAdjacentTiles(pPlot, i)
					if plotScanned ~= nil then
						if plotScanned:GetResourceType() == 42 then
							bHorse = true
							--print("Barbs: Can't Place Here it Would Turn into Horse Camp",plotScanned:GetResourceType(),plotScanned:GetX(),plotScanned:GetY())
							break
						end
					end
				end
			end
			
			-- Insert 
			if bValid == true then
				--print("Barbs: Valid Plot!",pPlot:GetX(), pPlot:GetY())
				local tmp = {plot = pPlot, id = iTargetID, bNaval = bNaval, horse = bHorse} 
				table.insert(validPlots, tmp)
			end
		end	
	end
	
	local shuffledPlots = GetShuffledCopyOfTable(validPlots)
	--print('XianZhouAddBarbCamps',shuffledPlots,bNaval)
	-- Place on the map: Naval
	if shuffledPlots ~= nil then
		for j, plotTable in ipairs(shuffledPlots) do
			--print(plotTable.id)
			--print(Players[plotTable.id]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN'))
			if 	plotTable.id ~= nil and plotTable.id >= 0 and Players[plotTable.id]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') ~= nil and Players[plotTable.id]:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') > 0  then
				local pPlot = plotTable.plot
				print("Barbs: Valid Plot Add!",j,plotTable.id,pPlot:GetX(), pPlot:GetY())
				-- PLACE TRIBE NAVAL IF UNTARGETTED
				if	bNaval then
					XianZhouPlaceBarbarianCamp(pPlot:GetX(), pPlot:GetY(),plotTable.id,0)
			elseif	horse then
					XianZhouPlaceBarbarianCamp(pPlot:GetX(), pPlot:GetY(),plotTable.id,1)
				else
					XianZhouPlaceBarbarianCamp(pPlot:GetX(), pPlot:GetY(),plotTable.id,2)
				end
				return
			end	
		end
	end
end

function XianZhouPlaceBarbarianCamp(iX, iY, playerID, tribeType)
	local BARBARIAN_ID = 62;
	local BARB_CAMP_ID = 0;
	local targetId = playerID;
	-- Check XML for any and all Improvements flagged as "Barb Camps" and distribute them.
	local pPlot = Map.GetPlot(iX,iY);	
	local iPlotIndex = pPlot:GetIndex()
	--ImprovementBuilder.SetImprovementType(pPlot, BARB_CAMP_ID, BARBARIAN_ID);

	for i = 0, 90 do
		local plotScanned = GetAdjacentTiles(pPlot, i)
		if plotScanned ~= nil then
			if plotScanned:GetImprovementType() == BARB_CAMP_ID then
				--print("Already has a Barbarian Camp Nearby")
				return
			end
		end
	end

	local pBarbManager = Game.GetBarbarianManager();
	ImprovementBuilder.SetImprovementType(pPlot, -1);   
	print('XianZhou HuoHuo Attract Barbarian!')
	local iTribeNumber = pBarbManager:CreateTribeOfType(tribeType, pPlot:GetIndex())
	--以最近城市为进攻目标
	local pTargetCity = FindNearestTargetCity(targetId, pPlot:GetX(), pPlot:GetY())
	pBarbManager:StartOperationWithCityTarget(iTribeNumber, "Barbarian City Assault", targetId, pTargetCity:GetID());
	local currentTurn = Game.GetCurrentGameTurn()
	if	currentTurn > 25 then--前25回合不给视野
		--揭示城市的视野
		local pVis = PlayersVisibility[63];
		local plots = Map.GetNeighborPlots(pPlot:GetX(), pPlot:GetY(), 6)
		local pCityPlot = pTargetCity:GetPlot()
		pVis:ChangeVisibilityCount(pCityPlot:GetIndex(), 1)
		pVis:ChangeVisibilityCount(pCityPlot:GetIndex(), -1)
		for i, adjPlot in ipairs(plots) do
			pVis:ChangeVisibilityCount(adjPlot:GetIndex(), 1)
			pVis:ChangeVisibilityCount(adjPlot:GetIndex(), -1)
		end
		--[[
		if	currentTurn > 50 then--前50回合不给额外单位
			for row in GameInfo.BarbarianAttackForces() do 
				if	tostring(row.AttackForceType):find('Raid') then
					local MinDifficulty = row.MinTargetDifficulty or 0
					local MaxDifficulty = row.MaxTargetDifficulty or 7
					if	(GameInfo.Difficulties[MinDifficulty].Index <= iDifficulty and iDifficulty <= GameInfo.Difficulties[MaxDifficulty].Index) or (7 <= GameInfo.Difficulties[MaxDifficulty].Index and GameInfo.Difficulties[MaxDifficulty].Index <= iDifficulty) then
						--print(GameInfo.Difficulties[MinDifficulty].Index)
						--print(GameInfo.Difficulties[MaxDifficulty].Index)
						if	tribeType == 0 and row.MeleeTag == 'CLASS_NAVAL_MELEE' then
							print(row.AttackForceType)
							XianZhouCreateTribeUnits(iTribeNumber, row, iPlotIndex, 3)
					elseif	tribeType == 1 and row.MeleeTag == 'CLASS_LIGHT_CAVALRY' then
							print(row.AttackForceType)
							XianZhouCreateTribeUnits(iTribeNumber, iPlotIndex, 3)
					elseif	tribeType == 2 and row.MeleeTag == 'CLASS_MELEE' then
							print(row.AttackForceType)
							XianZhouCreateTribeUnits(iTribeNumber, row, iPlotIndex, 3)
						end
					end
				end
			end
		end
		]]
	end
end

function XianZhouCreateTribeUnits(iTribeNumber, row, iPlotIndex, iRange)
	local pBarbManager = Game.GetBarbarianManager();
	if	row.MeleeTag ~= nil then
		pBarbManager:CreateTribeUnits(iTribeNumber, row.MeleeTag, row.NumMeleeUnits, iPlotIndex, iRange);
	end
	if	row.RangeTag ~= nil then
		pBarbManager:CreateTribeUnits(iTribeNumber, row.RangeTag, row.NumRangeUnits, iPlotIndex, iRange);
	end
	if	row.SiegeTag ~= nil then
		pBarbManager:CreateTribeUnits(iTribeNumber, row.SiegeTag, row.NumSiegeUnits, iPlotIndex, iRange);
	end
	if	row.SupportTag ~= nil then
		pBarbManager:CreateTribeUnits(iTribeNumber, row.SupportTag, row.NumSupportUnits, iPlotIndex, iRange);
	end
end

function XianZhouCheckBarbarians(iPlayerID)
	-- GameInfo.BarbarianTribes[0].TribeType
	local currentTurn = Game.GetCurrentGameTurn()
	local startTurn = GameConfiguration.GetStartTurn()
	--print('XianZhouCheckBarbarians')
	if	currentTurn == startTurn + 15 then
		print("Original Barb Placement")
		XianZhouPlaceOriginalBarbCamps()
		return
elseif	currentTurn < startTurn + 30 then
		return
	end

	local rng = RandRange(1, 100, "PEN - Check_Barbarians()");
	rng = rng / 100	
	--print("Barbs: Valid Plot rng!",iPlayerID,rng,(iDifficulty/BarbariansCamppawnChance))
	if  rng < (iDifficulty/BarbariansCamppawnChance) then
		print("Camp Will Add a Barb Camp")
		XianZhouAddBarbCamps()
		else
		--print("Total Camp",currentCamps,maxCamps,"No need to add Camp")
	end
end

function XianZhouGameTurnStarted(turn)
	--print('XianZhouGameTurnStarted',NotHasBarbarians)
	local pAllPlayerIDs : table = PlayerManager.GetAliveIDs()
	if NotHasBarbarians == nil or NotHasBarbarians then--如果为无蛮族则能力不生效
		return
	end
	for k, iPlayerID in ipairs(pAllPlayerIDs) do
		--判断是藿藿
		local pPlayer = Players[iPlayerID];
		if pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == nil or pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == 0 then
			return;
		end
		--print('XianZhouGameTurnStarted')
		XianZhouCheckBarbarians(iPlayerID)
		XianZhouHeliobiRebel(iPlayerID)
	end
end
--[[
function XianZhouPlayerTurnStarted(iPlayerID)
	--local pAllPlayerIDs : table = PlayerManager.GetAliveIDs()
	print('XianZhouPlayerTurnStarted')
	if HasBarbarians == nil or not HasBarbarians then--如果为无蛮族则能力不生效
		return
	end
	local pPlayer = Players[iPlayerID];
	--for k, iPlayerID in ipairs(pAllPlayerIDs) do
		--判断是藿藿
		if pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == nil or pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == 0 then
			return;
		end
		print('XianZhouPlayerTurnStarted')
		XianZhouCheckBarbarians(iPlayerID)
	--end
end
--]]
function FindNearestTargetCity( eTargetPlayer, iX, iY )
    local pCity = nullptr;
    local iShortestDistance = 10000;
	local pPlayer = Players[eTargetPlayer];
	local pPlayerCities:table = pPlayer:GetCities();
	for i, pLoopCity in pPlayerCities:Members() do
		local iDistance = Map.GetPlotDistance(iX, iY, pLoopCity:GetX(), pLoopCity:GetY());
		if (iDistance < iShortestDistance) then
			pCity = pLoopCity;
			iShortestDistance = iDistance;
		end
	end

	if (pCity == nullptr) then
		print ("No target city found of player " .. tostring(eTargetPlayer) .. "in attack from " .. tostring(iX) .. ", " .. tostring(iY));
	end
   
    return pCity;
end

function GetShuffledCopyOfTable(incoming_table)
	-- Designed to operate on tables with no gaps. Does not affect original table.
	local len = table.maxn(incoming_table);
	local copy = {};
	local shuffledVersion = {};
	-- Make copy of table.
	for loop = 1, len do
		copy[loop] = incoming_table[loop];
	end
	-- One at a time, choose a random index from Copy to insert in to final table, then remove it from the copy.
	local left_to_do = table.maxn(copy);
	for loop = 1, len do
		local random_index = 1 + TerrainBuilder.GetRandomNumber(left_to_do, "Shuffling table entry - Lua");
		table.insert(shuffledVersion, copy[random_index]);
		table.remove(copy, random_index);
		left_to_do = left_to_do - 1;
	end
	return shuffledVersion
end
--看不懂的函数
function GetAdjacentTiles(plot, index)
	-- This is an extended version of Firaxis, moving like a clockwise snail on the hexagon grids
	local gridWidth, gridHeight = Map.GetGridSize();
	local count = 0;
	local k = 0;
	local adjacentPlot = nil;
	local adjacentPlot2 = nil;
	local adjacentPlot3 = nil;
	local adjacentPlot4 = nil;
	local adjacentPlot5 = nil;
	-- Return Spawn if index < 0
	if(plot ~= nil and index ~= nil) then
		if (index < 0) then
			return plot;
		end

		else

		__Debug("GetAdjacentTiles: Invalid Arguments");
		return nil;
	end
	-- Return Starting City Circle if index between #0 to #5 (like Firaxis' GetAdjacentPlot) 
	for i = 0, 5 do
		if(plot:GetX() >= 0 and plot:GetY() < gridHeight) then
			adjacentPlot = Map.GetAdjacentPlot(plot:GetX(), plot:GetY(), i);
			if (adjacentPlot ~= nil and index == i) then
				return adjacentPlot
			end
		end
	end

	-- Return Inner City Circle if index between #6 to #17

	count = 5;
	for i = 0, 5 do
		if(plot:GetX() >= 0 and plot:GetY() < gridHeight) then
			adjacentPlot2 = Map.GetAdjacentPlot(plot:GetX(), plot:GetY(), i);
		end

		for j = i, i+1 do
			--__Debug(i, j)
			k = j;
			count = count + 1;

			if (k == 6) then
				k = 0;
			end

			if (adjacentPlot2 ~= nil) then
				if(adjacentPlot2:GetX() >= 0 and adjacentPlot2:GetY() < gridHeight) then
					adjacentPlot = Map.GetAdjacentPlot(adjacentPlot2:GetX(), adjacentPlot2:GetY(), k);

					else

					adjacentPlot = nil;
				end
			end
		

			if (adjacentPlot ~=nil) then
				if(index == count) then
					return adjacentPlot
				end
			end

		end
	end

	-- #18 to #35 Outer city circle
	count = 0;
	for i = 0, 5 do
		if(plot:GetX() >= 0 and plot:GetY() < gridHeight) then
			adjacentPlot = Map.GetAdjacentPlot(plot:GetX(), plot:GetY(), i);
			adjacentPlot2 = nil;
			adjacentPlot3 = nil;
			else
			adjacentPlot = nil;
			adjacentPlot2 = nil;
			adjacentPlot3 = nil;
		end
		if (adjacentPlot ~=nil) then
			if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
				adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i);
			end
			if (adjacentPlot3 ~= nil) then
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i);
				end
			end
		end

		if (adjacentPlot2 ~= nil) then
			count = 18 + i * 3;
			if(index == count) then
				return adjacentPlot2
			end
		end

		adjacentPlot2 = nil;

		if (adjacentPlot3 ~= nil) then
			if (i + 1) == 6 then
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), 0);
				end
				else
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i +1);
				end
			end
		end

		if (adjacentPlot2 ~= nil) then
			count = 18 + i * 3 + 1;
			if(index == count) then
				return adjacentPlot2
			end
		end

		adjacentPlot2 = nil;

		if (adjacentPlot ~= nil) then
			if (i+1 == 6) then
				if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), 0);
				end
				if (adjacentPlot3 ~= nil) then
					if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
						adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), 0);
					end
				end
				else
				if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i+1);
				end
				if (adjacentPlot3 ~= nil) then
					if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
						adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i+1);
					end
				end
			end
		end

		if (adjacentPlot2 ~= nil) then
			count = 18 + i * 3 + 2;
			if(index == count) then
				return adjacentPlot2;
			end
		end

	end

	--  #35 #59 These tiles are outside the workable radius of the city
	local count = 0
	for i = 0, 5 do
		if(plot:GetX() >= 0 and plot:GetY() < gridHeight) then
			adjacentPlot = Map.GetAdjacentPlot(plot:GetX(), plot:GetY(), i);
			adjacentPlot2 = nil;
			adjacentPlot3 = nil;
			adjacentPlot4 = nil;
			else
			adjacentPlot = nil;
			adjacentPlot2 = nil;
			adjacentPlot3 = nil;
			adjacentPlot4 = nil;
		end
		if (adjacentPlot ~=nil) then
			if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
				adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i);
			end
			if (adjacentPlot3 ~= nil) then
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i);
					if (adjacentPlot4 ~= nil) then
						if(adjacentPlot4:GetX() >= 0 and adjacentPlot4:GetY() < gridHeight) then
							adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), i);
						end
					end
				end
			end
		end

		if (adjacentPlot2 ~= nil) then
			terrainType = adjacentPlot2:GetTerrainType();
			if (adjacentPlot2 ~=nil) then
				count = 36 + i * 4;
				if(index == count) then
					return adjacentPlot2;
				end
			end

		end

		if (adjacentPlot3 ~= nil) then
			if (i + 1) == 6 then
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), 0);
				end
				else
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i +1);
				end
			end
		end

		if (adjacentPlot4 ~= nil) then
			if(adjacentPlot4:GetX() >= 0 and adjacentPlot4:GetY() < gridHeight) then
				adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), i);
				if (adjacentPlot2 ~= nil) then
					count = 36 + i * 4 + 1;
					if(index == count) then
						return adjacentPlot2;
					end
				end
			end


		end

		adjacentPlot4 = nil;

		if (adjacentPlot ~= nil) then
			if (i+1 == 6) then
				if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), 0);
				end
				if (adjacentPlot3 ~= nil) then
					if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
						adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), 0);
					end
				end
				else
				if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i+1);
				end
				if (adjacentPlot3 ~= nil) then
					if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
						adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i+1);
					end
				end
			end
		end

		if (adjacentPlot4 ~= nil) then
			if (adjacentPlot4:GetX() >= 0 and adjacentPlot4:GetY() < gridHeight) then
				adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), i);
				if (adjacentPlot2 ~= nil) then
					count = 36 + i * 4 + 2;
					if(index == count) then
						return adjacentPlot2;
					end

				end
			end

		end

		adjacentPlot4 = nil;
		if (adjacentPlot ~= nil) then
			if (i+1 == 6) then
				if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), 0);
				end
				if (adjacentPlot3 ~= nil) then
					if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
						adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), 0);
					end
				end
				else
				if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i+1);
				end
				if (adjacentPlot3 ~= nil) then
					if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
						adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i+1);
					end
				end
			end
		end
		if (adjacentPlot4 ~= nil) then
			if (adjacentPlot4:GetX() >= 0 and adjacentPlot4:GetY() < gridHeight) then
				if (i+1 == 6) then
					adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), 0);
					else
					adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), i+1);
				end
				if (adjacentPlot2 ~= nil) then
					count = 36 + i * 4 + 3;
					if(index == count) then
						return adjacentPlot2;
					end

				end
			end

		end

	end
	--  > #60 to #90
	local count = 0
	for i = 0, 5 do
		if(plot:GetX() >= 0 and plot:GetY() < gridHeight) then
			adjacentPlot = Map.GetAdjacentPlot(plot:GetX(), plot:GetY(), i); --first ring
			adjacentPlot2 = nil;
			adjacentPlot3 = nil;
			adjacentPlot4 = nil;
			adjacentPlot5 = nil;
			else
			adjacentPlot = nil;
			adjacentPlot2 = nil;
			adjacentPlot3 = nil;
			adjacentPlot4 = nil;
			adjacentPlot5 = nil;
		end
		if (adjacentPlot ~=nil) then
			if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
				adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i); --2nd ring
			end
			if (adjacentPlot3 ~= nil) then
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i); --3rd ring
					if (adjacentPlot4 ~= nil) then
						if(adjacentPlot4:GetX() >= 0 and adjacentPlot4:GetY() < gridHeight) then
							adjacentPlot5 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), i); --4th ring
							if (adjacentPlot5 ~= nil) then
								if(adjacentPlot5:GetX() >= 0 and adjacentPlot5:GetY() < gridHeight) then
									adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot5:GetX(), adjacentPlot5:GetY(), i); --5th ring
								end
							end
						end
					end
				end
			end
		end
		if (adjacentPlot2 ~= nil) then
			count = 60 + i * 5;
			if(index == count) then
				return adjacentPlot2; --5th ring
			end
		end
		adjacentPlot2 = nil;
		if (adjacentPlot5 ~= nil) then
			if (i + 1) == 6 then
				if(adjacentPlot5:GetX() >= 0 and adjacentPlot5:GetY() < gridHeight) then
					adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot5:GetX(), adjacentPlot5:GetY(), 0);
				end
				else
				if(adjacentPlot5:GetX() >= 0 and adjacentPlot5:GetY() < gridHeight) then
					adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot5:GetX(), adjacentPlot5:GetY(), i +1);
				end
			end
		end
		if (adjacentPlot2 ~= nil) then
			count = 60 + i * 5 + 1;
			if(index == count) then
				return adjacentPlot2;
			end

		end
		adjacentPlot2 = nil;
		if (adjacentPlot ~=nil) then
			if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
				adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i);
			end
			if (adjacentPlot3 ~= nil) then
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i);
					if (adjacentPlot4 ~= nil) then
						if(adjacentPlot4:GetX() >= 0 and adjacentPlot4:GetY() < gridHeight) then
							if (i+1 == 6) then
								adjacentPlot5 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), 0);
								else
								adjacentPlot5 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), i+1);
							end
							if (adjacentPlot5 ~= nil) then
								if(adjacentPlot5:GetX() >= 0 and adjacentPlot5:GetY() < gridHeight) then
									if (i+1 == 6) then
										adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot5:GetX(), adjacentPlot5:GetY(), 0);
										else
										adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot5:GetX(), adjacentPlot5:GetY(), i+1);
									end
								end
							end
						end
					end
				end
			end
		end
		if (adjacentPlot2 ~= nil) then
			count = 60 + i * 5 + 2;
			if(index == count) then
				return adjacentPlot2;
			end

		end
		if (adjacentPlot ~=nil) then
			if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
				if (i+1 == 6) then
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), 0); -- 2 ring
					else
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i+1); -- 2 ring
				end
			end
			if (adjacentPlot3 ~= nil) then
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					if (i+1 == 6) then
						adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), 0); -- 3ring
						else
						adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i+1); -- 3ring

					end
					if (adjacentPlot4 ~= nil) then
						if(adjacentPlot4:GetX() >= 0 and adjacentPlot4:GetY() < gridHeight) then
							if (i+1 == 6) then
								adjacentPlot5 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), 0); --4th ring
								else
								adjacentPlot5 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), i+1); --4th ring
							end
							if (adjacentPlot5 ~= nil) then
								if(adjacentPlot5:GetX() >= 0 and adjacentPlot5:GetY() < gridHeight) then
									adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot5:GetX(), adjacentPlot5:GetY(), i); --5th ring
								end
							end
						end
					end
				end
			end
		end
		if (adjacentPlot2 ~= nil) then
			count = 60 + i * 5 + 3;
			if(index == count) then
				return adjacentPlot2;
			end

		end
		adjacentPlot2 = nil
		if (adjacentPlot ~=nil) then
			if(adjacentPlot:GetX() >= 0 and adjacentPlot:GetY() < gridHeight) then
				if (i+1 == 6) then
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), 0); -- 2 ring
					else
					adjacentPlot3 = Map.GetAdjacentPlot(adjacentPlot:GetX(), adjacentPlot:GetY(), i+1); -- 2 ring
				end
			end
			if (adjacentPlot3 ~= nil) then
				if(adjacentPlot3:GetX() >= 0 and adjacentPlot3:GetY() < gridHeight) then
					if (i+1 == 6) then
						adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), 0); -- 3ring
						else
						adjacentPlot4 = Map.GetAdjacentPlot(adjacentPlot3:GetX(), adjacentPlot3:GetY(), i+1); -- 3ring

					end
					if (adjacentPlot4 ~= nil) then
						if(adjacentPlot4:GetX() >= 0 and adjacentPlot4:GetY() < gridHeight) then
							if (i+1 == 6) then
								adjacentPlot5 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), 0); --4th ring
								else
								adjacentPlot5 = Map.GetAdjacentPlot(adjacentPlot4:GetX(), adjacentPlot4:GetY(), i+1); --4th ring
							end
							if (adjacentPlot5 ~= nil) then
								if(adjacentPlot5:GetX() >= 0 and adjacentPlot5:GetY() < gridHeight) then
									if (i+1 == 6) then
										adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot5:GetX(), adjacentPlot5:GetY(), 0); --5th ring
										else
										adjacentPlot2 = Map.GetAdjacentPlot(adjacentPlot5:GetX(), adjacentPlot5:GetY(), i+1); --5th ring
									end
								end
							end
						end
					end
				end
			end
		end
		if (adjacentPlot2 ~= nil) then
			count = 60 + i * 5 + 4;
			if(index == count) then
				return adjacentPlot2;
			end
		end
	end
end
--[[
function XianZhouBarbarianRemove(iX, iY, eOwner)
	print('XianZhouBarbarianRemove',iX, iY, eOwner)
end
]]
--[[
function XianZhouUnitEnteredBarbarianCamp(playerID,unitID)
	print('XianZhouUnitEnteredBarbarianCamp',HasBarbariansClans)
	if HasBarbariansClans then
		return
	end
	--print('XianZhouUnitEnteredBarbarianCamp',playerID,plotIndex)
	local pPlayer = Players[playerID];
	--判断是藿藿
	if pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == nil or pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == 0 then
		return;
	end
	local pUnit = UnitManager.GetUnit(playerID, unitID)
	local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
	local pUnitList:table = Units.GetUnitsInPlotLayerID(pPlot:GetX(),pPlot:GetY(),MapLayers.ANY)
	print('XianZhouUnitEnteredBarbarianCamp',pUnitList)
	if pUnitList ~= nil then 
		for _,NeighborUnit in ipairs(pUnitList) do
			if  NeighborUnit:GetOwner() == playerID then
				print("Find Friendly Unit:", NeighborUnit)
				if NeighborUnit then
					--print("Find adj Unit", NeighborUnit)
					--print("Find adj Unit", adjPlot:IsWater())
					if GameInfo.Units[NeighborUnit:GetType()].FormationClass == "FORMATION_CLASS_LAND_COMBAT" then
						NeighborUnit:GetAbility():ChangeAbilityCount('ABILITY_XIANZHOU_SPIRITUAL_DOMINATION', 1)
						if	NeighborUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') == nil then
							NeighborUnit:SetProperty('XIANZHOU_SUPPRESS_HELIOBI',1)
						else
							NeighborUnit:SetProperty('XIANZHOU_SUPPRESS_HELIOBI',NeighborUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') + 1)
						end
						break;
					end
				end
			end
		end
	end
end
]]

function XianZhouHeliobiRebel (playerID)
	local pPlayer = Players[playerID]
	for i, pUnit in pPlayer:GetUnits():Members() do
		if	pUnit:GetProperty("XIANZHOU_SPIRITUAL_DOMINATION") ~= nil and pUnit:GetProperty("XIANZHOU_SPIRITUAL_DOMINATION") > 0  then
			local pUnitExperienceToNext = pUnit:GetExperience():GetExperienceForNextLevel()--30/4*(x^2+x)
			local Level = math.floor(math.sqrt(pUnitExperienceToNext*4/30))--不需要精确拟合，因此直接开平方获得近似值
			
			local RebelProbability = (pUnit:GetProperty("XIANZHOU_SUPPRESS_HELIOBI")+Level*2)*2
			local RandomNum = Game.GetRandNum(100)
			--print('XianZhouHeliobiRebel',RandomNum,RebelProbability)
			if	RandomNum < RebelProbability and (pUnit:GetProperty("XIANZHOU_SOOTHING_HELIOBI") == nil or pUnit:GetProperty("XIANZHOU_SOOTHING_HELIOBI") == 0) then--不在保护区6格内
				local iX = pUnit:GetX()
				local iY = pUnit:GetY()
				local pPlot = Map.GetPlot(iX, iY)
				local iPlotIndex = pPlot:GetIndex()
				local pBarbPlot = nil
				local iPlotIndex = nil
				if	pPlot:GetDistrictType() == GameInfo.Districts['DISTRICT_CITY_CENTER'].Index or (pPlot:GetDistrictType() >= 0 and GameInfo.Districts[pPlot:GetDistrictType()].HitPoints > 0) then--市中心或者其他有区域防御的区域
					local plots = Map.GetNeighborPlots(pPlot:GetX(), pPlot:GetY(), 1)
					for	 i, adjPlot in ipairs(plots) do--如果原地有区域,在两格范围内放置近战蛮寨
						--print('XianZhouHeliobiRebel',adjPlot:GetDistrictType())
						--print(GameInfo.Districts[adjPlot:GetDistrictType()])
						if	adjPlot:GetDistrictType() < 0  or (adjPlot:GetDistrictType() >= 0 and GameInfo.Districts[adjPlot:GetDistrictType()].HitPoints == 0) then
							pBarbPlot = adjPlot
							iPlotIndex = pBarbPlot:GetIndex()
							break;
						end
					end
				else--如果原地没有区域,原地放置近战蛮寨
					pBarbPlot = pPlot
					iPlotIndex = pBarbPlot:GetIndex()
				end
				if	pBarbPlot ~= nil then--如果周围没有符合条件的地块,那么强制不叛变
					UnitManager.Kill(pUnit, false)
					local pBarbManager = Game.GetBarbarianManager();
					ImprovementBuilder.SetImprovementType(pBarbPlot, -1)
					local tribeType = 2
					local iTribeNumber = pBarbManager:CreateTribeOfType(tribeType, pBarbPlot:GetIndex())
					local pTargetCity = FindNearestTargetCity(playerID, pBarbPlot:GetX(), pBarbPlot:GetY())
					pBarbManager:StartOperationWithCityTarget(iTribeNumber, "Barbarian City Assault", playerID, pTargetCity:GetID())
					print('XianZhouHeliobiRebel',Level,pBarbPlot:GetX(),pBarbPlot:GetY())
					local currentTurn = Game.GetCurrentGameTurn()	
					--[[
					if	currentTurn > 50 then
						for row in GameInfo.BarbarianAttackForces() do 
							if	tostring(row.AttackForceType):find('Raid') then
								local MinDifficulty = row.MinTargetDifficulty or 0
								local MaxDifficulty = row.MaxTargetDifficulty or 7
								--print(GameInfo.Difficulties[MinDifficulty].Index,GameInfo.Difficulties[MaxDifficulty].Index,iDifficulty)
								if	(GameInfo.Difficulties[MinDifficulty].Index <= iDifficulty and iDifficulty <= GameInfo.Difficulties[MaxDifficulty].Index) or (7 <= GameInfo.Difficulties[MaxDifficulty].Index and GameInfo.Difficulties[MaxDifficulty].Index <= iDifficulty) then
									--print(GameInfo.Difficulties[MinDifficulty].Index)
									--print(GameInfo.Difficulties[MaxDifficulty].Index)
									--print(tribeType,row.MeleeTag)
									if	tribeType == 0 and row.MeleeTag == 'CLASS_NAVAL_MELEE' then
										print(row.AttackForceType)
										XianZhouCreateTribeUnits(iTribeNumber, row, iPlotIndex, 3)
										break;
								elseif	tribeType == 1 and row.MeleeTag == 'CLASS_LIGHT_CAVALRY' then
										print(row.AttackForceType)
										XianZhouCreateTribeUnits(iTribeNumber, iPlotIndex, 3)
										break;
								elseif	tribeType == 2 and row.MeleeTag == 'CLASS_MELEE' then
										print(row.AttackForceType)
										XianZhouCreateTribeUnits(iTribeNumber, row, iPlotIndex, 3)
										break;
									end
								end
							end
						end
					end
					]]
					local notificationData = {};
					notificationData[NotificationParameterTypes.CanUserDismiss] = false;
					XianZhouSendNotificationPlot(XianZhouHeliobiRebelMessage, pPlot, playerID, notificationData);
				end
			end
		end
	end
end

function XianZhouUnitCommandStarted(playerID, unitID, hCommand, iData1)
	--print('XianZhouUnitCommandStarted',HasBarbariansClans)
	if not HasBarbariansClans then
		return
	end
	--print('XianZhouUnitCommandStarted',playerID, unitID, hCommand, iData1)
	local pPlayer = Players[playerID];
	--判断是藿藿
	--print('XianZhouUnitCommandStarted',pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN'))
	if pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == nil or pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == 0 then
		return;
	end
	--hCommand is hash
	print(GameInfo.UnitCommands[hCommand].CommandType)
	if	GameInfo.UnitCommands[hCommand] == nil or GameInfo.UnitCommands[hCommand].CommandType ~= 'UNITCOMMAND_TREAT_WITH_CLAN_DISPERSE' then
		return
	end
	--print(GameInfo.UnitCommands[hCommand].CommandType)
	local pUnit = UnitManager.GetUnit(playerID, unitID)
	local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
	local pUnitList:table = Units.GetUnitsInPlotLayerID(pPlot:GetX(),pPlot:GetY(),MapLayers.ANY)
	--print('XianZhouUnitCommandStarted',pUnitList)
	if pUnitList ~= nil then 
		for _,NeighborUnit in ipairs(pUnitList) do
			if  NeighborUnit:GetOwner() == playerID then
				print("Find Friendly Unit:", NeighborUnit)
				if NeighborUnit then
					--print("Find adj Unit", NeighborUnit)
					--print("Find adj Unit", adjPlot:IsWater())
					if GameInfo.Units[NeighborUnit:GetType()].FormationClass == "FORMATION_CLASS_LAND_COMBAT" then
						NeighborUnit:GetAbility():ChangeAbilityCount('ABILITY_XIANZHOU_SPIRITUAL_DOMINATION', 1)
						if	NeighborUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') == nil then
							NeighborUnit:SetProperty('XIANZHOU_SUPPRESS_HELIOBI',1)
						else
							NeighborUnit:SetProperty('XIANZHOU_SUPPRESS_HELIOBI',NeighborUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') + 1)
						end
						local pUnitExperience = NeighborUnit:GetExperience()
						local UnitExp = pUnitExperience:GetExperienceForNextLevel() - pUnitExperience:GetExperiencePoints()--需要减去已有
						--print(pUnitExperience:GetExperienceForNextLevel(),pUnitExperience:GetExperiencePoints(),UnitExp)
						pUnitExperience:ChangeExperience(UnitExp*HeliobiExp)
						break;
					end
				end
			end
		end
	end
end

function XianZhouRemoveBarbCamp(playerID, params)
	local UnitID = params.UnitID
	local pUnit = UnitManager.GetUnit(playerID, UnitID)
	--local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
	pUnit:GetAbility():ChangeAbilityCount('ABILITY_XIANZHOU_SPIRITUAL_DOMINATION', 1)
	if	pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') == nil then
		pUnit:SetProperty('XIANZHOU_SUPPRESS_HELIOBI',1)
	else
		pUnit:SetProperty('XIANZHOU_SUPPRESS_HELIOBI',pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') + 1)
	end
	local pUnitExperience = pUnit:GetExperience()
	local UnitExp = pUnitExperience:GetExperienceForNextLevel() - pUnitExperience:GetExperiencePoints()--需要减去已有
	--print(pUnitExperience:GetExperienceForNextLevel(),pUnitExperience:GetExperiencePoints(),UnitExp)
	pUnitExperience:ChangeExperience(UnitExp*HeliobiExp)
end

function XianZhouUnitPromoted(playerID, unitID)
	local pUnit = UnitManager.GetUnit(playerID, unitID)
	if pUnit:GetProperty('XIANZHOU_SPIRITUAL_DOMINATION') == nil or pUnit:GetProperty('XIANZHOU_SPIRITUAL_DOMINATION') == 0 then
		return;
	end
	local pUnitExperience = pUnit:GetExperience()
	local UnitExp = pUnitExperience:GetExperienceForNextLevel() - pUnitExperience:GetExperiencePoints()--需要减去已有
	--print(pUnitExperience:GetExperienceForNextLevel(),pUnitExperience:GetExperiencePoints(),UnitExp)
	pUnitExperience:ChangeExperience(UnitExp*HeliobiExp)
end

function XianZhouKillBarbProduction(playerID, params)
	local UnitID = params.UnitID
	local PlayerID = params.PlayerID
	local killedUnitCombat = params.killedUnitCombat
	local pUnit = UnitManager.GetUnit(playerID, UnitID)
	local pPlayer:table = Players[playerID]
	--print('XianZhouKillBarbProduction',pPlayer:GetProperty('XIANZHOU_BARBARIAN_CAMP_PRODUCTION'))
	if pPlayer:GetProperty('XIANZHOU_BARBARIAN_CAMP_PRODUCTION') == nil or pPlayer:GetProperty('XIANZHOU_BARBARIAN_CAMP_PRODUCTION') == 0 then
		return;
	end
	if pUnit then
		local pTargetCity = FindNearestTargetCity(playerID, pUnit:GetX(), pUnit:GetY())
		local pCityBuildQueue = pTargetCity:GetBuildQueue()
		local BARBARIAN_CAMP_PRODUCTION = pPlayer:GetProperty('XIANZHOU_BARBARIAN_CAMP_PRODUCTION')
		local yield = math.floor(killedUnitCombat*BARBARIAN_CAMP_PRODUCTION*SpeedMul/100)--50%
		print('XianZhouKillBarbProduction',yield)
		pCityBuildQueue:AddProgress(yield)
		Game.AddWorldViewText(0, YIELD_COLORS['YIELD_PRODUCTION'] .. '+' .. tostring(yield) .. ' '.. GameInfo.Yields['YIELD_PRODUCTION'].IconString .. '[ENDCOLOR]', pTargetCity:GetX(), pTargetCity:GetY())
	end
end

function XianZhouAvtiveHuoHuoOperation(playerID, params)
	local UnitID = params.UnitID
	local pUnit = UnitManager.GetUnit(playerID, UnitID)
	local pPlot = Map.GetPlot(params.X, params.Y)
	--print('XianZhouAvtiveHuoHuoOperation',pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI'))
	if	pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') ~= nil and pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') > 0 then
		local AbilityCount = math.min(pUnit:GetAbility():GetAbilityCount('ABILITY_XIANZHOU_SPIRITUAL_DOMINATION'),pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI'))
		print('XianZhouAvtiveHuoHuoOperation',pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI'), AbilityCount)
		pUnit:GetAbility():ChangeAbilityCount('ABILITY_XIANZHOU_SPIRITUAL_DOMINATION',-AbilityCount)
		if	pPlot:GetProperty('XIANZHOU_DISTRICT_HELIOBI') == nil then
			pPlot:SetProperty('XIANZHOU_DISTRICT_HELIOBI',AbilityCount)
		else
			pPlot:SetProperty('XIANZHOU_DISTRICT_HELIOBI',(pPlot:GetProperty('XIANZHOU_DISTRICT_HELIOBI') + AbilityCount))
		end
		pUnit:SetProperty('XIANZHOU_SUPPRESS_HELIOBI',0)
	end
end

function Initialize()
	num = 0
	for i, tmp in ipairs(PlayerConfigurations) do
		--print("Judge MudRock")
		if	Players[i]:IsMajor() then--排除计算野蛮人和城邦
			iDifficulty = iDifficulty + GameInfo.Difficulties[PlayerConfigurations[i]:GetHandicapTypeID()].Index
			num = num + 1
		end
	end
	iDifficulty = iDifficulty / num--所有文明平均难度
	print ("XianZhou Load! iDifficulty: ", tostring(iDifficulty))
	
	Events.GameEraChanged.Add(XianZhouGameEraChanged)
	GameEvents.OnCityPopulationChanged.Add(XianZhouCityPopulationChanged)
	GameEvents.CityBuilt.Add(XianZhouFirstCityBuilt)
	
	GameEvents.OnGameTurnStarted.Add(XianZhouGameTurnStarted)
	--Events.ImprovementRemovedFromMap.Add(XianZhouBarbarianRemove)
	--Events.UnitEnteredBarbarianCamp.Add(XianZhouUnitEnteredBarbarianCamp)
	Events.UnitCommandStarted.Add(XianZhouUnitCommandStarted)
	Events.UnitPromoted.Add(XianZhouUnitPromoted)
	
	GameEvents.XianZhouRemoveBarbCamp.Add(XianZhouRemoveBarbCamp)
	GameEvents.XianZhouKillBarbProduction.Add(XianZhouKillBarbProduction)
	GameEvents.XianZhouAvtiveHuoHuoOperation.Add(XianZhouAvtiveHuoHuoOperation)
end
Events.LoadGameViewStateDone.Add(Initialize);