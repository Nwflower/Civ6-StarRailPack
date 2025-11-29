-- KNM_Herta_MISC
-- Author: Konomi
-- DateCreated: 6/5/2023 21:54:36
--------------------------------------------------------------

local KEY_KNM_LEADER_ASTA = 'KNM_LEADER_ASTA'
local KEY_KNM_LEADER_HERTA = 'KNM_LEADER_HERTA'


local m_CodeOfLawsCivicIndex = GameInfo.Civics['CIVIC_CODE_OF_LAWS'] and GameInfo.Civics['CIVIC_CODE_OF_LAWS'].Index or -1
-- ===========================================================================
function OnResearchQueueChanged(playerId, techType)
	if Game.GetLocalPlayer() ~= playerId then
		return
	end
	local pPlayer = Players[playerId]
	if pPlayer and pPlayer:IsTurnActive() and pPlayer:GetProperty(KEY_KNM_LEADER_HERTA) ~= nil then
		local playerTechs = pPlayer:GetTechs()
		local nodeIds = playerTechs:GetResearchQueue()
		if #nodeIds == 1 then
			return
		end
		local techInfo = GameInfo.Technologies[nodeIds[#nodeIds]]
		if techInfo and (techInfo.EraType == 'ERA_ANCIENT' or techInfo.EraType == 'ERA_CLASSICAL' ) and not playerTechs:HasTech(techInfo.Index) and not techInfo.Repeatable and playerTechs:IsTechRevealed(techInfo.Index) then
			UI.RequestPlayerOperation(playerId, PlayerOperations.EXECUTE_SCRIPT, {
				OnStart = 'KnmHertaSetTech',
				TechID = techInfo.Index,
				Spend = -1,
			})
		end
	end
end
-- ===========================================================================
function OnUnitPromotionAvailable(playerID, unitID, promotionID)
	if playerID == Game.GetLocalPlayer() then
		local pUnit = UnitManager.GetUnit(playerID, unitID)
		if pUnit and GameInfo.Units[pUnit:GetType()].UnitType == 'UNIT_KNM_HERTA_PUPPET' and UnitManager.GetActivityType(pUnit) == ActivityTypes.ACTIVITY_SLEEP then
			UnitManager.RequestCommand(pUnit, 200562917)
		end
	end
end
-- ===========================================================================
function OnUnitPromoted(playerID, unitID)
	local pUnit = UnitManager.GetUnit(playerID, unitID)
	if pUnit and GameInfo.Units[pUnit:GetType()].UnitType == 'UNIT_KNM_HERTA_PUPPET' then
		local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
		if pPlot:IsCity() then
			UnitManager.RequestOperation(pUnit, -41338758)
		end
	end
end
-- ===========================================================================
function MoveGreatWork(playerID, unitID, iCityPlotX, iCityPlotY, buildingID, greatWorkID)
	local pCity = CityManager.GetCityAt(iCityPlotX, iCityPlotY)
	local pCityBuildings = pCity:GetBuildings()
	local slotNum = pCityBuildings:GetNumGreatWorkSlots(buildingID)

	for i = 0, slotNum - 1 do 
		if pCityBuildings:GetGreatWorkInSlot(buildingID, i) == greatWorkID then
			local tParameters = {}
			tParameters[PlayerOperations.PARAM_PLAYER_ONE] = playerID
			tParameters[PlayerOperations.PARAM_CITY_SRC] = pCity:GetID()
			tParameters[PlayerOperations.PARAM_CITY_DEST] = pCity:GetID()
			tParameters[PlayerOperations.PARAM_BUILDING_SRC] = buildingID
			tParameters[PlayerOperations.PARAM_BUILDING_DEST] = buildingID
			tParameters[PlayerOperations.PARAM_GREAT_WORK_INDEX] = greatWorkID
			tParameters[PlayerOperations.PARAM_SLOT] = i
			UI.RequestPlayerOperation(playerID, PlayerOperations.MOVE_GREAT_WORK, tParameters)
			return
		end
	end	
end
-- ===========================================================================
function OnInit( isReload )
	if isReload then
	end
end
-- ===========================================================================
function Initialize()
	Events.GreatWorkCreated.Add(MoveGreatWork)
	Events.UnitPromotionAvailable.Add(OnUnitPromotionAvailable)
	Events.UnitPromoted.Add(OnUnitPromoted)

	local pPlayer = Players[Game.GetLocalPlayer()]
	if pPlayer and pPlayer:GetProperty(KEY_KNM_LEADER_HERTA) ~= nil then
		Events.ResearchQueueChanged.Add(OnResearchQueueChanged)
	end
end
Initialize();


