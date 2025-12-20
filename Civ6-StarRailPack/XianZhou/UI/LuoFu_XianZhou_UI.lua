-- LuoFu_XianZhou_UI
-- Author: Pen
-- DateCreated: 2024/2/12 14:57:45
--------------------------------------------------------------
include('XianZhouFuctions')
--------------------------------------------------------------
function OnXianZhouShowAvailableClicked()
	--m_unitEntryIM:ResetInstances()
	if	Controls.XianZhouDivinationContainer:IsHidden() then
		Controls.XianZhouDivinationButton:SetSelected(true)
		Controls.XianZhouDivinationContainer:SetHide(false)
		local pCity = UI.GetHeadSelectedCity()
		local iPlayer = pCity:GetOwner()
		if	iPlayer == Game.GetLocalPlayer() then
			local localPlayer = Players[iPlayer]
			if	localPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') and localPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') > 0 then 
				local DivinationPoint = localPlayer:GetProperty('XIANZHOU_DIVINATION_POINT') or 0
				if	DivinationPoint >= 0 then
					Controls.XianZhouDivinationButton:SetToolTipString(Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_NAME') .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_TOOLTIP', math.floor(DivinationPoint*10)/10) .. '[NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_CITY_YIELD_TOOLTIP'))
					if	localPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE_FOR_YIELD_PRODUCTION') and localPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE_FOR_YIELD_PRODUCTION') > 0 then 
						local ProductionInfo:table = DivinationCityBuildQueue(iPlayer, pCity:GetID())	
						local ImproveCost = DivinationCityGetImproCost(iPlayer, pCity:GetID())
						local FixCostToolTip = Locale.Lookup('LOC_XIANZHOU_DIVINATION_CITYBUILDQUEUE_FIX_INFO', (100-DIVINATION_TO_PRODUCTION-ImproveCost))
						Controls.XianZhouDivinationProductionButton:SetToolTipString(Locale.Lookup('LOC_XIANZHOU_DIVINATION_CITYBUILDQUEUE_INFO', ProductionInfo.Name,math.floor(ProductionInfo.Progress),ProductionInfo.Cost) .. '[NEWLINE][NEWLINE]' .. FixCostToolTip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_PRODUCTION_TOOLTIP', math.floor(DivinationPoint*(100-DIVINATION_TO_PRODUCTION-ImproveCost)/100)))
					end
				end
			end
		end
	else
		Controls.XianZhouDivinationButton:SetSelected(false)
		Controls.XianZhouDivinationContainer:SetHide(true)
	end
end

function OnXianZhouShowSummaryClicked()--参考文献：笑笑的顶部显示粮锤
	local ePlayer		:number = Game.GetLocalPlayer();
	local localPlayer	:table= nil;
	if	ePlayer ~= -1 then
		localPlayer = Players[ePlayer];
		if	localPlayer == nil then
			return;
		end
	else
		return;
	end
	if	Controls.XianZhouDivinationButton:IsSelected() then
		Controls.XianZhouDivinationButton:SetSelected(false)
		Controls.XianZhouDivinationContainer:SetHide(true)
		if	localPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') and localPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') > 0 then 
			local DivinationPoint = localPlayer:GetProperty('XIANZHOU_DIVINATION_POINT') or 0
			if	DivinationPoint >= 0 then
				Controls.XianZhouDivinationButton:SetToolTipString(Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_NAME') .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_TOOLTIP', math.floor(DivinationPoint*10)/10) .. '[NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_CITY_YIELD_TOOLTIP'))
			end
		end
	else
		Controls.XianZhouDivinationButton:SetSelected(true)
		Controls.XianZhouDivinationContainer:SetHide(true)
		
		if	localPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') and localPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') > 0 then 
			local totalDivination = 0;
			local totalScienceDivination = 0;
			local totalCultureDivination = 0;
			local DivinationTooltip = "";
			for _, city in localPlayer:GetCities():Members() do
				if	city:GetProperty('CITY_ENABLE_MATRIX_OF_PRESCIENCE') and city:GetProperty('CITY_ENABLE_MATRIX_OF_PRESCIENCE') > 0 then
					local totalCityDivination = 0--城市锤总产
					for YieldType,YieldID in pairs(DivinationYieldType) do
						local CityDivinationPoint = 0
						CityDivinationPoint = UpdateCityYieldToDivinationPoint(ePlayer, city:GetID(), city:GetYieldToolTip(YieldID), YieldType)--单一产出城市总和
						totalCityDivination = math.floor((totalCityDivination + CityDivinationPoint)*10+0.5)/10
					end
					--print("ShowSummary:",totalCityDivination)
					totalDivination = totalDivination + totalCityDivination
					DivinationTooltip = DivinationTooltip .. "[NEWLINE][ICON_Bullet]" .. FormatValuePerTurn(totalCityDivination) .. "[ICON_XIANZHOU_MATRIX_OF_PRESCIENCE]" .. Locale.Lookup("LOC_XIANZHOU_DIVINATION_POINT_FROM_CITY",Locale.Lookup(city:GetName()));
				end
			end
			DivinationTooltip = Locale.Lookup("LOC_XIANZHOU_DIVINATION_POINT_SUMMARY") .. FormatValuePerTurn(totalDivination) .. "[ICON_XIANZHOU_MATRIX_OF_PRESCIENCE]" .. "[NEWLINE]" .. DivinationTooltip;
			Controls.XianZhouDivinationButton:SetToolTipString( DivinationTooltip )
		end
	end
end

function Refresh()
	local pCity = UI.GetHeadSelectedCity()
	if	pCity then
		local pPlayer = Players[pCity:GetOwner()]
		if	pCity:GetProperty('CITY_ENABLE_MATRIX_OF_PRESCIENCE') == nil or pCity:GetProperty('CITY_ENABLE_MATRIX_OF_PRESCIENCE') == 0 then 
			Controls.XianZhouDivinationGrid:SetHide(true)

		else
			Controls.XianZhouDivinationGrid:SetHide(false)
			Controls.XianZhouDivinationButton:SetHide(false)
			Controls.XianZhouDivinationButton:SetSelected(false)
			Controls.XianZhouDivinationContainer:SetHide(true)
			if	pPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') and pPlayer:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') > 0 then 
				Controls.XianZhouDivinationButton:SetDisabled(false)
				local DivinationPoint = pPlayer:GetProperty('XIANZHOU_DIVINATION_POINT') or 0
				if	DivinationPoint >= 0 then
					Controls.XianZhouDivinationButton:SetToolTipString(Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_NAME') .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_TOOLTIP', math.floor(DivinationPoint*10)/10) .. '[NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_CITY_YIELD_TOOLTIP'))
				end
			else
				Controls.XianZhouDivinationButton:SetDisabled(true)
				Controls.XianZhouDivinationButton:SetToolTipString(Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_NAME') .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_DIVINATION_POINT_BUTTON_DISABLE_TOOLTIP'))
			end
		end
	end
end

function OnTurnBegin(ePlayer, isFirstTimeThisTurn)
	if	ePlayer ~= Game.GetLocalPlayer() then return; end
	if	not isFirstTimeThisTurn then return; end--如果不是第一次
	local player = Players[ePlayer]
	if	player:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') then
		local totalDivination = 0;
		local totalScienceDivination = 0;
		local totalCultureDivination = 0;
		for _, pCity in player:GetCities():Members() do
			if	player:GetProperty('XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE') then
				if	pCity:GetProperty('CITY_ENABLE_MATRIX_OF_PRESCIENCE') and pCity:GetProperty('CITY_ENABLE_MATRIX_OF_PRESCIENCE') > 0 then
					for YieldType,YieldID in pairs(DivinationYieldType) do
						CityDivinationPoint = UpdateCityYieldToDivinationPoint(ePlayer, pCity:GetID(), pCity:GetYieldToolTip(YieldID), YieldType)--单一产出城市总和
						totalDivination = totalDivination + CityDivinationPoint
					end
				end
			end
		end

		totalDivination = totalDivination
		local PROP_DIVINATION = 'XIANZHOU_DIVINATION_POINT'  
		local tParameters = {}
		tParameters.Propertykey = PROP_DIVINATION
		tParameters.PointNum = math.floor(totalDivination*10+0.5)/10
		tParameters.OnStart = 'XianZhouSetDivinationPoint'
		UI.RequestPlayerOperation(player:GetID(), PlayerOperations.EXECUTE_SCRIPT, tParameters)
	end
	if player:GetProperty('XIANZHOU_CAN_SLOT_GOLDEN_POLICIES') ~= nil then
		if	player:GetProperty('XianZhouHasUnlockPolicies') == nil then
			local tParameters = {}
			tParameters.OnStart = 'XianZhouUnlockPolicy'
			UI.RequestPlayerOperation(player:GetID(), PlayerOperations.EXECUTE_SCRIPT, tParameters)
		end
	end
end

function DivinationProductionComplete()
	local pCity = UI.GetHeadSelectedCity()
	local iPlayer = pCity:GetOwner()
	if	iPlayer ~= Game.GetLocalPlayer() then return; end
	local CityID = pCity:GetID()
	--print("DivinationProductionComplete:",iPlayer,CityID,pCity)
	local pPlayer = Players[iPlayer]
	local DivinationPoint = pPlayer:GetProperty('XIANZHOU_DIVINATION_POINT') or 0
	local pCityBuildQueue = pCity:GetBuildQueue()
	
	if	pCityBuildQueue then
		local currentProductionInfo:table = DivinationCityBuildQueue( iPlayer, CityID )
		local NoProductionName = Locale.Lookup("LOC_HUD_CITY_NOTHING_PRODUCED")--如果为nil也不影响后续
		if	currentProductionInfo and currentProductionInfo.Cost >= 0 and currentProductionInfo.Name ~= NoProductionName then
			print("DivinationComplete:",currentProductionInfo.Name,'Playerid and Cityid:',iPlayer,CityID,'Cost and hasProgress:',currentProductionInfo.Cost,currentProductionInfo.Progress)
			local PROP_DIVINATION = 'XIANZHOU_DIVINATION_POINT'  
			local tParameters = {}
			tParameters.Propertykey = PROP_DIVINATION
			tParameters.CityID = CityID
			tParameters.Type = currentProductionInfo.Type
			tParameters.Index = currentProductionInfo.Index
			tParameters.Hash = currentProductionInfo.Hash
			tParameters.PercentComplete = currentProductionInfo.PercentComplete
			tParameters.Cost = currentProductionInfo.Cost
			tParameters.Progress = currentProductionInfo.Progress
			tParameters.OnStart = 'DivinationPointToProduction'
			UI.RequestPlayerOperation(iPlayer, PlayerOperations.EXECUTE_SCRIPT, tParameters)
			--Refresh()
		end
		Refresh()
	end
end

function OnDivinationLater(playerID, cityID)
	local pPlayer = Players[playerID]
	if	playerID ~= Game.GetLocalPlayer() then return; end
	if	pPlayer:GetProperty("XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE") and pPlayer:GetProperty("XIANZHOU_ENABLE_MATRIX_OF_PRESCIENCE") > 0 then 
		local pCity = CityManager.GetCity(playerID, cityID)
		if	pCity and pCity:GetProperty("CITY_ENABLE_MATRIX_OF_PRESCIENCE") and pCity:GetProperty("CITY_ENABLE_MATRIX_OF_PRESCIENCE") > 0 then

			local pCityBuildQueue = pCity:GetBuildQueue()
			if	pCityBuildQueue and pCity:GetProperty("DivinationProduction") then
				local currentProductionInfo:table = DivinationCityBuildQueue( playerID, cityID )
				if	currentProductionInfo then
					local PROP_DIVINATION = 'XIANZHOU_DIVINATION_POINT'  
					local tParameters = {}
					tParameters.Propertykey = PROP_DIVINATION
					tParameters.CityID = cityID
					tParameters.Type = currentProductionInfo.Type
					tParameters.Index = currentProductionInfo.Index
					tParameters.Hash = currentProductionInfo.Hash
					tParameters.PercentComplete = currentProductionInfo.PercentComplete
					tParameters.Cost = currentProductionInfo.Cost
					tParameters.Progress = currentProductionInfo.Progress
					tParameters.OnStart = 'DivinationPointToProductionLater'
					UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, tParameters)
					Refresh()
				end
			end

		end
	end
end

function OnXianZhouImprovementChanged(locationX, locationY, improvementType, improvementOwner, resource, isPillaged, isWorked)   
	if	improvementOwner ~= Game.GetLocalPlayer() then return; end
	if GameInfo.Improvements[improvementType].ImprovementType == "IMPROVEMENT_XIANZHOU_MATRIX_OF_PRESCIENCE" and isPillaged == true then
		Refresh()
	end
end

function OnXianZhouSelectionChanged( ownerPlayerID:number, cityID:number, i:number, j:number, k:number, isSelected:boolean, isEditable:boolean)   
	if	ownerPlayerID ~= Game.GetLocalPlayer() then return; end
	if	isSelected then
		--print("OnXianZhouSelectionChanged:",ownerPlayerID,cityID)
		Refresh()
	end
end

function OnDivinationQueueChanged(playerID, cityID, changeType, queueIndex)   
	if playerID ~= Game.GetLocalPlayer() then
		return;
	end
	local pCity:table = CityManager.GetCity(playerID, cityID);
	if pCity ~= nil and pCity:GetProperty("CITY_ENABLE_MATRIX_OF_PRESCIENCE") and pCity:GetProperty("CITY_ENABLE_MATRIX_OF_PRESCIENCE") > 0 then
		Refresh()
	end
end

function XianZhouGameEraChanged(previousEraIndex, newEraIndex)
	
	local pAllPlayerIDs : table = PlayerManager.GetAliveIDs()
	for	k, iPlayerID in ipairs(pAllPlayerIDs) do
		local pPlayer = Players[iPlayerID]
		if pPlayer:GetProperty('XIANZHOU_CAN_SLOT_GOLDEN_POLICIES') == nil or pPlayer:GetProperty('XIANZHOU_CAN_SLOT_GOLDEN_POLICIES') == 0 then
			return;
		end
		if	pPlayer:GetProperty('XianZhouHasUnlockPolicies') == nil then
				for row in GameInfo.CommemorationTypes() do 
					local pPlayerCulture = pPlayer:GetCulture()
					pPlayerCulture:UnlockPolicy(GameInfo.Policies['POLICY_XIANZHOU_'..row.CommemorationType].Index); --解锁政策卡
				end
			pPlayer:SetProperty('XianZhouHasUnlockPolicies',1)
		end
	end
end

function XianZhouButtonInitialize()
	local pContext = ContextPtr:LookUpControl("/InGame/CityPanel/ActionStack")
	if	pContext ~= nil then
		Controls.XianZhouDivinationGrid:ChangeParent(pContext)
		Controls.XianZhouDivinationButton:RegisterCallback(Mouse.eLClick, OnXianZhouShowAvailableClicked)
		Controls.XianZhouDivinationButton:RegisterCallback(Mouse.eRClick, OnXianZhouShowSummaryClicked)
		
		Controls.XianZhouDivinationProductionButton:RegisterCallback(Mouse.eLClick, DivinationProductionComplete)
		Controls.XianZhouDivinationProductionButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over") end);
	end
	Events.CitySelectionChanged.Add(OnXianZhouSelectionChanged)
	Events.PlayerTurnActivated.Add(OnTurnBegin)
	Events.CityPropertyChanged.Add(OnDivinationLater)
	Events.ImprovementChanged.Add(OnXianZhouImprovementChanged);
	Events.CityProductionQueueChanged.Add(OnDivinationQueueChanged)
	Events.GameEraChanged.Add(XianZhouGameEraChanged)
end

Events.LoadGameViewStateDone.Add(XianZhouButtonInitialize);