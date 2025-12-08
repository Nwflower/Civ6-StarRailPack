

local m_iCurrentPlayerID = Game.GetLocalPlayer()
local m_pCurrentPlayer = Players[m_iCurrentPlayerID]
local DisCache = {}

function HasTrait_Property(sTrait, iPlayer)
    local pPlayer = Players[iPlayer];
    local ePro = pPlayer:GetProperty('PROPERTY_' .. sTrait) or 0
    if ePro > 0 then
        return true
    end
    return false
end

function onDistrictCompleted(playerID, districtID, cityID, iX, iY, districtType, era, civilization, percentComplete, iAppeal, isPillaged)
    if playerID ~= m_iCurrentPlayerID then return end
    local sDistrictType = GameInfo.Districts[districtType].DistrictType;
    if percentComplete == 100 and GameInfo.NW_Amphoreus_Districts[sDistrictType]  and GameInfo.NW_Amphoreus_Districts[sDistrictType].DistrictType == sDistrictType then
        if DisCache[playerID] and DisCache[playerID][cityID] and DisCache[playerID][cityID][districtType] then
            -- do nothing
            return
        else
            DisCache[playerID] = DisCache[playerID] or {}
            DisCache[playerID][cityID] = DisCache[playerID][cityID] or {}
            DisCache[playerID][cityID][districtType] = 1
            UI.RequestPlayerOperation(playerID, PlayerOperations.EXECUTE_SCRIPT, {
                OnStart = 'NW_AmphoreusDistrictCompleted',
                playerID = playerID,
                districtType = sDistrictType,
                cityID = cityID
            })
        end
    end
end

-- 对于AI，由房主发起对应逻辑
function onDistrictCompletedAI(playerID, districtID, cityID, iX, iY, districtType, era, civilization, percentComplete, iAppeal, isPillaged)
    if m_iCurrentPlayerID ~= 0 then return end
    if not Players[playerID]:IsAI() then return end
    local sDistrictType = GameInfo.Districts[districtType].DistrictType;
    if percentComplete == 100 and GameInfo.NW_Amphoreus_Districts[sDistrictType]  and GameInfo.NW_Amphoreus_Districts[sDistrictType].DistrictType == sDistrictType then
        if DisCache[playerID] and DisCache[playerID][cityID] and DisCache[playerID][cityID][districtType] then
            -- do nothing
            return
        else
            DisCache[playerID] = DisCache[playerID] or {}
            DisCache[playerID][cityID] = DisCache[playerID][cityID] or {}
            DisCache[playerID][cityID][districtType] = 1
            UI.RequestPlayerOperation(m_iCurrentPlayerID, PlayerOperations.EXECUTE_SCRIPT, {
                OnStart = 'NW_AmphoreusDistrictCompleted',
                playerID = playerID,
                districtType = sDistrictType,
                cityID = cityID
            })
        end
    end
end

-- 由于区域建成事件比较特殊，相关逻辑会触发两次该事件，因此在这里写一个回调逻辑
-- 即UI传GP后，后续相同传递将锁定，除非GP端执行完并发回回调结果
function NW_ADC_Events_END(playerId, cityID, districtType, result)
    if DisCache[playerId] and DisCache[playerId][cityID] and DisCache[playerId][cityID][districtType] then
        DisCache[playerId][cityID][districtType] = nil
    end
end

-----------------------------------------------------------------------
--- UI界面初始化
-----------------------------------------------------------------------
function Initialize()
    LuaEvents.NW_ADC_Events_END.Add(NW_ADC_Events_END);
    Events.DistrictBuildProgressChanged.Add(onDistrictCompleted);
    Events.DistrictBuildProgressChanged.Add(onDistrictCompletedAI);
end

Events.LoadGameViewStateDone.Add(Initialize)