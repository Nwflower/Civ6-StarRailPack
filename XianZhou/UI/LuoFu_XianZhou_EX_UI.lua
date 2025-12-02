-- LuoFu_XianZhou_UI
-- Author: Pen
-- DateCreated: 2024/2/12 14:57:45
--------------------------------------------------------------
local NotHasBarbarians 		= GameConfiguration.GetValue("GAME_NO_BARBARIANS")			--true or false
local HasBarbariansClans	= GameConfiguration.GetValue("GAMEMODE_BARBARIAN_CLANS")	--true or false


--If plot has luxury
function IsPlotDistrict(pPlot)
	--print("Plot Resource is:",pPlot:GetResourceType())
	local pDistrictType = pPlot:GetDistrictType()
	if pDistrictType ~= -1 then
		local DistrictType = GameInfo.Districts['DISTRICT_XIANZHOU_TENLORDS_COMMISSION'].Index
		--print(ResourceClassType)
		if pDistrictType == DistrictType then
			--print("Plot Resource is Luxury:",pPlot:GetResourceType())
			return true;
		end
	end
	return false;
end
--If plot owned
function IsPlotOwned()
	local pUnit = UI.GetHeadSelectedUnit()
	if pUnit == nil then return false; end
	local playerID = pUnit:GetOwner()
	if playerID == -1 or playerID ~= Game.GetLocalPlayer() then return false; end
	local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
	if pPlot:GetOwner() ~= playerID then
		return false;
	end
	return true;
end

function OnXianZhouAvtiveHuoHuoButtonClicked()
	local pUnit = UI.GetHeadSelectedUnit()
	local iPlayer = pUnit:GetOwner()
	if iPlayer ~= Game.GetLocalPlayer() then return; end
	if pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') == nil or pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') <= 0 then
		return;
	end
	
	local iX = pUnit:GetX()
	local iY = pUnit:GetY()
	local unitID = pUnit:GetID()
	
	local pPlot = Map.GetPlot(iX, iY)
	if IsPlotOwned() and IsPlotDistrict(pPlot)  then
		local tParameters = {}
		tParameters.UnitID = unitID
		tParameters.X = iX
		tParameters.Y = iY
		tParameters.OnStart = 'XianZhouAvtiveHuoHuoOperation'
		UI.RequestPlayerOperation(iPlayer, PlayerOperations.EXECUTE_SCRIPT, tParameters)
		
		Controls.XianZhouAvtiveHuoHuoGrid:SetHide(true)
	end
end

function Refresh()
	local pUnit = UI.GetHeadSelectedUnit()
	if pUnit ~= nil then
		local UnitID = pUnit:GetID()
		local PlayerID = pUnit:GetOwner()
		local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
		--print("Refresh:",pUnit:GetMovementMovesRemaining(),IsPlotOwned(),IsPlotDistrict(pPlot))
		if	(pUnit:GetMovementMovesRemaining() == 0 or (pUnit:GetProperty("XIANZHOU_SPIRITUAL_DOMINATION") == nil or pUnit:GetProperty("XIANZHOU_SPIRITUAL_DOMINATION") == 0)) and (not IsPlotDistrict(pPlot) or not IsPlotOwned()) then
			Controls.XianZhouAvtiveHuoHuoGrid:SetHide(true)
	elseif	pUnit:GetMovementMovesRemaining() >= 0 and IsPlotOwned() and IsPlotDistrict(pPlot) and (pUnit:GetProperty("XIANZHOU_SUPPRESS_HELIOBI") == nil or pUnit:GetProperty("XIANZHOU_SUPPRESS_HELIOBI") == 0) then--没有附身的单位位于区域时可以查看区域内岁阳数量
			Controls.XianZhouAvtiveHuoHuoGrid:SetHide(false)
			Controls.XianZhouAvtiveHuoHuoButton:SetDisabled(true)
			local tooltip = Locale.Lookup('LOC_XIANZHOU_SPIRITUAL_DOMINATION_TOOLTIP')
			local HeliobiNum = pPlot:GetProperty('XIANZHOU_DISTRICT_HELIOBI') or 0
			Controls.XianZhouAvtiveHuoHuoButton:SetToolTipString(tooltip .. '[NEWLINE][NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_SUPPRESS_HELIOBI_TOOLTIP', HeliobiNum))
		else
			Controls.XianZhouAvtiveHuoHuoGrid:SetHide(false)
			local tooltip = Locale.Lookup('LOC_XIANZHOU_SPIRITUAL_DOMINATION_TOOLTIP')
			if IsPlotOwned() and IsPlotDistrict(pPlot) then
				Controls.XianZhouAvtiveHuoHuoButton:SetDisabled(false)
				local HeliobiNum = pPlot:GetProperty('XIANZHOU_DISTRICT_HELIOBI') or 0
				Controls.XianZhouAvtiveHuoHuoButton:SetToolTipString(tooltip .. '[NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_SUPPRESS_HELIOBI_TOOLTIP', HeliobiNum) .. Locale.Lookup('LOC_XIANZHOU_SUPPRESS_HELIOBI_BUTTON_TOOLTIP'))
			else	
				Controls.XianZhouAvtiveHuoHuoButton:SetDisabled(true)
				local HeliobiNum = pUnit:GetProperty('XIANZHOU_SUPPRESS_HELIOBI') or 0
				local pUnitExperience = pUnit:GetExperience()
				local Level = pUnitExperience:GetLevel()
				if	pUnit:GetProperty("XIANZHOU_SOOTHING_HELIOBI") ~= nil and pUnit:GetProperty("XIANZHOU_SOOTHING_HELIOBI") > 0  then
					Controls.XianZhouAvtiveHuoHuoButton:SetToolTipString(tooltip .. '[NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_HELIOBI_UPPER_BODY_TOOLTIP', 0))
				else
					Controls.XianZhouAvtiveHuoHuoButton:SetToolTipString(tooltip .. '[NEWLINE]' .. Locale.Lookup('LOC_XIANZHOU_HELIOBI_UPPER_BODY_TOOLTIP', (HeliobiNum+Level*2)*2))
				end
			end
		end
	end
end

function XianZhouUnitSimPositionChanged( playerID:number, unitID:number, worldX:number, worldY:number, worldZ:number, bVisible:boolean, isComplete:boolean )
	if playerID ~= Game.GetLocalPlayer() then
		return
	end
	local kUnit:table = nil;
	if isComplete then
		local pPlayer:table = Players[playerID];
		if pPlayer ~= nil then
			-- If the unit that just finished moving is STILL the selected unit,
			-- then it has more moves to make, update the move radius...
			kUnit = pPlayer:GetUnits():FindID(unitID);
			if kUnit == UI.GetHeadSelectedUnit() then
				Refresh()
			end
		end
	end
end
--Move
function OnXianZhouUnitMoveComplete(playerID, unitID, iX, iY)
	if playerID ~= Game.GetLocalPlayer() then
		return
	end
	Refresh()
end
--Select
function OnXianZhouUnitSelectionChanged(PlayerID, UnitID, plotX, plotY, plotZ, bSelected, bEditable)
	if PlayerID ~= Game.GetLocalPlayer() then return; end
    if bSelected then
        Refresh()
    end
end

function OnXianZhouUnitMove(playerID, unitID, iX, iY, locallyVisible, stateChange)
	--print('OnXianZhouUnitMove',HasBarbariansClans)
	if HasBarbariansClans then
		return
	end
	local pPlayer = Players[playerID];
	--判断是藿藿
	if pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == nil or pPlayer:GetProperty('XIANZHOU_ATTRACT_BARBARIAN') == 0 then
		return;
	end
	local pUnit = UnitManager.GetUnit(playerID, unitID)
	--local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
	local pPlot = Map.GetPlot(iX, iY)
	--print('OnXianZhouUnitMove',pPlot:GetImprovementType())--UI环境能抓到
	if	pPlot:GetImprovementType() == GameInfo.Improvements['IMPROVEMENT_BARBARIAN_CAMP'].Index then
		local pUnitList:table = Units.GetUnitsInPlotLayerID(pPlot:GetX(),pPlot:GetY(),MapLayers.ANY)
		--print('OnXianZhouUnitMove',pUnitList)
		if pUnitList ~= nil then 
			for _,NeighborUnit in ipairs(pUnitList) do
				--print(NeighborUnit,NeighborUnit:GetOwner())
				if  NeighborUnit:GetOwner() == playerID then
					print("Find Friendly Unit:", NeighborUnit)
					if NeighborUnit then
						--print("Find adj Unit", NeighborUnit)
						--print("Find adj Unit", adjPlot:IsWater())
						if GameInfo.Units[NeighborUnit:GetType()].FormationClass == "FORMATION_CLASS_LAND_COMBAT" then
							local tParameters = {}
							tParameters.UnitID = NeighborUnit:GetID()
							tParameters.PlayerID = playerID
							tParameters.OnStart = 'XianZhouRemoveBarbCamp'
							UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, tParameters)
							break;
						end
					end
			elseif	NeighborUnit:GetOwner() == 63 then--由XianZhouUnitKilledInCombat调用时蛮族单位在ui还未死亡,单元格读取为蛮族单位，此时选用进攻单位
					if pUnit then
						print("XianZhou kill move:", pUnit)
						if GameInfo.Units[NeighborUnit:GetType()].FormationClass == "FORMATION_CLASS_LAND_COMBAT" then
							local tParameters = {}
							tParameters.UnitID = pUnit:GetID()
							tParameters.PlayerID = playerID
							tParameters.OnStart = 'XianZhouRemoveBarbCamp'
							UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, tParameters)
							break;
						end
					end
				end
			end
		end
	end
end

function XianZhouUnitKilledInCombat(pCombatResult)
	local attacker		= pCombatResult[CombatResultParameters.ATTACKER];
	local defender		= pCombatResult[CombatResultParameters.DEFENDER];
	local attackeradvance = pCombatResult[CombatResultParameters.ATTACKER_ADVANCES]--近战攻击为true
	local atkplayerID       = attacker[CombatResultParameters.ID].player;
	local defplayerID       = defender[CombatResultParameters.ID].player;
	
	--print('XianZhouUnitKilledInCombat',atkplayerID,defplayerID)
	local playerID		= nil
	local UnitID		= nil
	local BarbID		= nil
	local BarbUnitID	= nil
	local BarbUnitFDT	= nil
	if	atkplayerID == Game.GetLocalPlayer() and defplayerID ==63 then--如果被攻击是野蛮人
		playerID = atkplayerID
		UnitID = attacker[CombatResultParameters.ID].id
		BarbID = defplayerID
		BarbUnitID = defender[CombatResultParameters.ID].id
		BarbUnitFDT = defender[CombatResultParameters.FINAL_DAMAGE_TO]
elseif	defplayerID == Game.GetLocalPlayer() and atkplayerID ==63  then--如果攻击的是野蛮人
		playerID = defplayerID
		UnitID = defender[CombatResultParameters.ID].id
		BarbID = atkplayerID
		BarbUnitID = attacker[CombatResultParameters.ID].id
		BarbUnitFDT = attacker[CombatResultParameters.FINAL_DAMAGE_TO]
	else
		return; 
	end
	--print(playerID)
	if	playerID ~= nil and playerID ~= -1 then
		local pPlayer:table = Players[playerID]
		--print('XianZhouUnitKilledInCombat',pPlayer:GetProperty('XIANZHOU_BARBARIAN_CAMP_PRODUCTION'))
		if pPlayer and pPlayer:GetProperty('XIANZHOU_BARBARIAN_CAMP_PRODUCTION') == nil or pPlayer:GetProperty('XIANZHOU_BARBARIAN_CAMP_PRODUCTION') == 0 then
			return;
		end
		--print(killedPlayerID)
		--if BarbID == 63 then
		--print(UnitID, BarbID, BarbUnitID, BarbUnitFDT)
		local pkilledUnit = UnitManager.GetUnit(BarbID, BarbUnitID)
		--local pUnit = UnitManager.GetUnit(playerID, UnitID)
		local killedUnitCombat = pkilledUnit:GetCombat()--GameInfo.Units[pkilledUnit:GetType()].Combat
		--print('XianZhouUnitKilledInCombat',pkilledUnit,killedUnitCombat)
		--print((pkilledUnit:GetMaxDamage()-pkilledUnit:GetDamage()),BarbUnitFDT)
		if	pkilledUnit:GetMaxDamage() <= BarbUnitFDT then
			print('XianZhouUnitKilledInCombat',pkilledUnit,killedUnitCombat)
			local tParameters = {}
			tParameters.UnitID = UnitID
			tParameters.PlayerID = playerID
			tParameters.killedUnitCombat = killedUnitCombat
			tParameters.OnStart = 'XianZhouKillBarbProduction'
			UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, tParameters)
			if	playerID == atkplayerID and attackeradvance then--防止野蛮人被远程击杀时获得能力
				OnXianZhouUnitMove(playerID,UnitID,pkilledUnit:GetX(),pkilledUnit:GetY())
			end
		end
    end
end

function XianZhouButtonEXInitialize()
	local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
	if pContext ~= nil then
		Controls.XianZhouAvtiveHuoHuoGrid:ChangeParent(pContext)
		Controls.XianZhouAvtiveHuoHuoButton:RegisterCallback(Mouse.eLClick, OnXianZhouAvtiveHuoHuoButtonClicked)
	end

	Events.UnitSelectionChanged.Add(OnXianZhouUnitSelectionChanged)
	Events.UnitMoveComplete.Add(OnXianZhouUnitMoveComplete)
	Events.UnitSimPositionChanged.Add(XianZhouUnitSimPositionChanged)
	--
	--Events.ImprovementRemovedFromMap.Add(XianZhouImprovementRemoved)
	--Events.UnitEnteredBarbarianCamp.Add(XianZhouUnitEnteredBarbarianCamp)
	Events.UnitMoved.Add(OnXianZhouUnitMove)
	--Events.UnitKilledInCombat.Add(OnXianZhouUnitKilledInCombat)
	Events.Combat.Add(XianZhouUnitKilledInCombat)
end

Events.LoadGameViewStateDone.Add(XianZhouButtonEXInitialize);