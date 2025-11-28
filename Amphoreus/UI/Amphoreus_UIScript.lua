
local m_iCurrentPlayerID = Game.GetLocalPlayer()
local m_pCurrentPlayer = Players[m_iCurrentPlayerID]

local GAME_SPEED = GameConfiguration.GetGameSpeedType()
local GAME_SPEED_MULTIPLIER = GameInfo.GameSpeeds[GAME_SPEED] and GameInfo.GameSpeeds[GAME_SPEED].CostMultiplier / 100 or 1

function HasTrait_Property(sTrait, iPlayer)
    local pPlayer = Players[iPlayer];
    local ePro = pPlayer:GetProperty('PROPERTY_' .. sTrait) or 0
    if ePro > 0 then
        return true
    end
    return false
end

--======================================================================
-- 刻律德菈

-- 预言书库：如果拥有的预言次数大于已预言的奇观数，且存在既未建成、又未被预言的奇观，则回合开始时让玩家选择一个预言奇观
function ProphecyWonder(pPlayer)
    -- 对于AI：始终认为AI预言了所有奇观
    if pPlayer:IsAI() then return end
    -- 对于人类玩家：检查条件
    local iDISTRICT_TALANTON = pPlayer:GetProperty('DISTRICT_TALANTON') or 0
    local iNW_AM_SAID_WONDER_NUM = pPlayer:GetProperty('NW_AM_SAID_WONDER_NUM') or 0
    if iNW_AM_SAID_WONDER_NUM < iDISTRICT_TALANTON then
        local grid = {};
        local wondersHasBuilt = GetWonderBuilt()
        for item in GameInfo.Buildings() do
            if item.IsWonder and not wondersHasBuilt[item.BuildingType] and not pPlayer:GetProperty('NW_AM_SAY_WONDER_'..item.BuildingType) then
                -- 存在既未建成、又未被预言的奇观，则回合开始时让玩家选择一个预言奇观
                LuaEvents.SayWonder_RequestProphecy(pPlayer:GetID())
                break
            end
        end
    end
end

-- 奇观建成时提供奖励
-- 当被预言的奇观建成时，将获得3个部落村庄奖励，并提供等同于该奇观生产力200%的文化值、金币和信仰值。
function OnWonderCompleted(iX,iY,buildingIndex,playerIndex,cityID,iPercentComplete,iUnknown)
    -- 遍历玩家，如果玩家进行过预言
	local kPlayers = PlayerManager.GetAliveMajors()
    local Count = GameInfo.Buildings[buildingIndex].Cost * 2 * GAME_SPEED_MULTIPLIER
    for _, pPlayer in ipairs(kPlayers) do
        if iPercentComplete == 100 and HasTrait_Property('TRAIT_LEADER_NW_CERYDRA_TALANTON',pPlayer:GetID()) then
            -- 对于人类玩家
            if pPlayer:GetProperty('NW_AM_SAY_WONDER_'..GameInfo.Buildings[buildingIndex].BuildingType) and pPlayer:GetID()==m_iCurrentPlayerID then
                UI.RequestPlayerOperation(m_iCurrentPlayerID, PlayerOperations.EXECUTE_SCRIPT, {
                    iPlayer = pPlayer:GetID(),
                    OnStart = "NW_KL_GrantGoody",
                    Count = Count
                });
            end
            -- 对于AI
            if m_iCurrentPlayerID == 0 and pPlayer:IsAI() then
                UI.RequestPlayerOperation(m_iCurrentPlayerID, PlayerOperations.EXECUTE_SCRIPT, {
                    iPlayer = pPlayer:GetID(),
                    OnStart = "NW_KL_GrantGoody",
                    Count = Count
                });
            end
        end
    end
end

-- ===========================================================================
-- 奇观合法性扫描：返回已建成的奇观
function GetWonderBuilt()
	local buildings = {}
    local iW, iH = Map.GetGridSize();
    for k = 0, iH * iW - 1 do
        local pPlot = Map.GetPlotByIndex(k);
        local eWonderType = pPlot:GetWonderType()
		if eWonderType and eWonderType ~= -1 then
			-- 判断城市是否真的建成了该奇观
			local pCity = Cities.GetPlotPurchaseCity(pPlot)
			if pCity:GetBuildings():HasBuilding(eWonderType) then
				local building = GameInfo.Buildings[eWonderType].BuildingType
				buildings[building] = 1
			end
		end
    end
	return buildings
end

-- ===========================================================================
-- 该写法可对AI正常生效
function OnPlayerTurnActivated(playerID, isFirst)
	if m_iCurrentPlayerID == playerID and m_iCurrentPlayerID == 0 and isFirst then
		-- 遍历文明
		if GameConfiguration.GetStartTurn() == Game.GetCurrentGameTurn() then
			local kPlayers = PlayerManager.GetAliveMajors()
			for _, pPlayer in ipairs(kPlayers) do
				local iPlayer = pPlayer:GetID()
				if (HasTrait_Property('TRAIT_LEADER_NW_PHAINON_KEPHALE',iPlayer)) then
					UI.RequestPlayerOperation(m_pCurrentPlayer, PlayerOperations.EXECUTE_SCRIPT, {
						OnStart = "Nw_AM_TRAIT_LEADER_NW_PHAINON_KEPHALE",
						iPlayer = iPlayer
					});
				end
			end
		end
	end
end

-----------------------------------------------------------------------
--- UI界面初始化
-----------------------------------------------------------------------
function Initialize()
    Events.PlayerTurnActivated.Add(OnPlayerTurnActivated)
	Events.WonderCompleted.Add(OnWonderCompleted);
end

Events.LoadGameViewStateDone.Add(Initialize)