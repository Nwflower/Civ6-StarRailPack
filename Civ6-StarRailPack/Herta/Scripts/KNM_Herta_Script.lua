-- KNM_Herta_Script
-- Author: Konomi
-- DateCreated: 6/5/2023 22:03:29
--------------------------------------------------------------

-- ===========================================================================
-- UNIT_KNM_HERTA_PUPPET
-- ===========================================================================
function OnDistrictConstructed(playerID, districtID, iX, iY)
	local districtInfo = GameInfo.Districts[districtID]
	if districtInfo and districtInfo.RequiresPopulation then
		local pCity = Cities.GetPlotPurchaseCity(iX, iY)
		local pPlot = Map.GetPlot(pCity:GetX(), pCity:GetY())
		if pCity and pPlot then
			local property = pCity:GetProperty('KNM_HERTA_DISTRICT_' .. tostring(districtID))
			if property ~= 1 then
				for _, unit in ipairs(Units.GetUnitsInPlot(pPlot)) do
					if unit and GameInfo.Units[unit:GetType()].UnitType == 'UNIT_KNM_HERTA_PUPPET' then
						local exps = unit:GetExperience():GetExperienceForNextLevel()
						unit:GetExperience():ChangeExperience(exps)
						pCity:SetProperty('KNM_HERTA_DISTRICT_' .. tostring(districtID), 1)
						return
					end
				end
			end
		end
	end
end
-- ===========================================================================
function KnmHertaSetTech(playerID, params)
	if Players[playerID] then
		if params.TechID ~= nil then
			if params.Spend > 0 then
				Players[playerID]:GetTechs():SetResearchProgress(params.TechID, params.Cost)
				Players[playerID]:GetTreasury():ChangeGoldBalance(-params.Spend)
			elseif params.Spend == -1 then
				Players[playerID]:GetTechs():SetResearchingTech(params.TechID)
				Players[playerID]:SetProperty('KnmIgnoreTechReq', params.TechID)
			end
		end
	end
end
-- ===========================================================================
function Initialize()
	GameEvents.KnmHertaSetTech.Add(KnmHertaSetTech)
	GameEvents.OnDistrictConstructed.Add(OnDistrictConstructed)
	for _, playerId in ipairs(PlayerManager.GetWasEverAliveMajorIDs()) do
		local config = PlayerConfigurations[playerId]
		if Players[playerId]:GetProperty('KNM_LEADER_ASTA') ~= nil and Players[playerId]:GetProperty('KNM_ASTA_NOTIFICATION_SENT') == nil then
			NotificationManager.SendNotification(playerId, DB.MakeHash('NOTIFICATION_KNM_HERTA_HOW_TO_PURCHASE'))
			Players[playerId]:SetProperty('KNM_ASTA_NOTIFICATION_SENT', 1)
		end
	end
end
-- ===========================================================================
Events.LoadGameViewStateDone.Add(Initialize)
