-- Firefly_UI
-- Author: Pen
-- DateCreated: 2024/7/26 15:59:49
--------------------------------------------------------------
local FireflySum			= GameInfo.Units['UNIT_PEN_FIREFLY_SAMU'].Index

function OnFireflyUnitSelection(PlayerID, UnitID, hexI, hexJ, hexK, bSelected, bEditable)
	if (PlayerID == nil) or (PlayerID ~= Game.GetLocalPlayer()) or (not bSelected) then return; end
	local pUnit = UnitManager.GetUnit(PlayerID, UnitID)
	if pUnit ~= nil then
		local pUnitType = pUnit:GetType()
		if pUnitType and pUnitType == FireflySum then
			--print("SELECT_UNIT_PEN_FIREFLY_SAMU")
			--播放音效
			UI.PlaySound("Play_Unit_Selcet_PEN_GLAMOTH")
			--Refresh()
		end
	end
end

--移除地貌行动
--最后一次只有UI能读
function FireflyUnitOperationStarted(playerID, unitID, operationID)
	if (playerID == nil) or (playerID ~= Game.GetLocalPlayer()) then return; end
	local pUnit = UnitManager.GetUnit(playerID, unitID)
	if pUnit ~= nil then
		local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
		if pPlot ~= nil then
			local OperationType = GameInfo.UnitOperations[operationID].OperationType
			--建立城市
			if	pPlot:GetOwner() >= 0 then
				local ownerplayer = Players[pPlot:GetOwner()]--是否在流萤领土(防止帮城邦改地触发)
				if ownerplayer:GetProperty('PEN_FIREFLY_ALL_VOLCANIC_SOIL') and ownerplayer:GetProperty('PEN_FIREFLY_ALL_VOLCANIC_SOIL') > 0 then
					if	OperationType == 'UNITOPERATION_REMOVE_FEATURE' then
						local tParameters = {}
						tParameters.PlotIndex = pPlot:GetIndex()
						tParameters.OnStart = 'FireflyRemoveFeature'
						UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, tParameters)
					end
				end
			end
		end
	end
end

function FireflyButtonEXInitialize()
	print("Firefly Load!")
	Events.UnitSelectionChanged.Add(OnFireflyUnitSelection)
	Events.UnitOperationStarted.Add(FireflyUnitOperationStarted)
end

Events.LoadGameViewStateDone.Add(FireflyButtonEXInitialize);