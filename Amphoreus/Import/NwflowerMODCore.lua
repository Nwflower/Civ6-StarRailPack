--	FILE: Amphoreus_Core.lua
--  VERSION: 1
--  Author: Nwflower
--  Spicial Thanks: Uni & HSbF6HSO3F
--	Copyright (c) 2025.
--	All rights reserved.
--  DateCreated: 2025/10/26 15:31:52
--------------------------------------------------------------

NwflowerMODCore = {}

local DEBUG = false;
local USE_CACHE = true;
local g_ObjectStateCache = {};

--||=========================Print========================||--
function NwflowerMODCore:__DEBUG(...)
    if DEBUG then
        print(...);
    end
end

-- 打印一层Table
function NwflowerMODCore:ShowTable(tTable)
    if tTable == nil then print("NwflowerMODCore:ShowTable: table is nil"); return; end
    for k,v in pairs(tTable) do
        print(k, type(v), tostring(v));
    end
end

-- 打印到指定层Table
function NwflowerMODCore:ShowRectable(tTable, iLevel)
	local level = 0;
	if iLevel ~= nil then level = iLevel; end
	for k,v in pairs(tTable) do
		print(string.rep("---:",level), k, type(v), tostring(v));
		if type(v) == "table" and level < 5 then self:ShowRectable(v, level+1); end
	end
end


--||====================GamePlay, UI======================||--

--判断领袖，玩家不为指定领袖类型则返回false (GamePlay, UI)
function NwflowerMODCore:CheckLeaderMatched(playerID, leaderType)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetLeaderTypeName() == leaderType
end

--判断文明，玩家文明不为指定文明类型则返回false (GamePlay, UI)
function NwflowerMODCore:CheckCivMatched(playerID, civilizationType)
    local pPlayerConfig = playerID and PlayerConfigurations[playerID]
    return pPlayerConfig and pPlayerConfig:GetCivilizationTypeName() == civilizationType
end

--数字四舍五入处理 (GamePlay, UI)
function NwflowerMODCore:Round(num)
    return math.floor((num + 0.05) * 10) / 10
end

--数字不小于其1位小数处理 (GamePlay, UI)
function NwflowerMODCore:Ceil(num)
    return math.ceil(num * 10) / 10
end

--数字不大于其1位小数处理 (GamePlay, UI)
function NwflowerMODCore:Floor(num)
    return math.floor(num * 10) / 10
end

--将输入的数字按照当前游戏速度进行修正 (GamePlay, UI)
function NwflowerMODCore:ModifyBySpeed(num)
    local gameSpeed = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()]
    if gameSpeed then num = num * gameSpeed.CostMultiplier / 100 end
    return num
end

--检查科技或者市政是否拥有提升 (GamePlay, UI)
function NwflowerMODCore:HasBoost(techOrCivic)
    for boost in GameInfo.Boosts() do
        if techOrCivic == boost.TechnologyType or techOrCivic == boost.CivicType then
            return true
        end
    end
    return false
end

--判断单元格是否可以放置指定单位 (GamePlay, UI)
function NwflowerMODCore:CanHaveUnit(plot, unitdef)
    if plot == nil then return false end
    local canHave = true
    for _, unit in ipairs(Units.GetUnitsInPlot(plot)) do
        if unit then
            local unitInfo = GameInfo.Units[unit:GetType()]
            if unitInfo then
                if unitInfo.IgnoreMoves == false then
                    if unitInfo.Domain == unitdef.Domain and unitInfo.FormationClass == unitdef.FormationClass then
                        canHave = false
                    end
                end
            end
        end
    end
    return canHave
end

--规范每回合价值显示 (GamePlay, UI)
function NwflowerMODCore:FormatValue(value)
    if value == 0 then
        return Locale.ToNumber(value)
    else
        return Locale.Lookup("{1: number +#,###.#;-#,###.#}", value)
    end
end

--数字百分比修正 (GamePlay, UI)
function NwflowerMODCore:ModifyByPercent(num, percent)
    return self:Round(num * (1 + percent / 100))
end

--获取玩家的区域数量 (GamePlay, UI)
function NwflowerMODCore:GetPlayerDistrictCount(playerID, index)
    local pPlayer, count = Players[playerID], 0
    if not pPlayer then return count end
    local districts = pPlayer:GetDistricts()
    for _, district in districts:Members() do
        if district:GetType() == index and district:IsComplete() and (not district:IsPillaged()) then
            count = count + 1
        end
    end
    return count
end

-- 传入table，根据权重返回筛选后的table合集
function NwflowerMODCore:WeightedRandomSelection(selection_tmp, num)
    -- 处理空输入
    if #selection_tmp == 0 then return {} end
    if #selection_tmp < num then return selection_tmp end
    local selection = {}
    -- 元素足够时，进行无放回的加权随机选择
    local totalWeight = 0
    local available = {}
    local availableCount = 0
    -- 初始化可用元素集合和总权重
    for _, item in ipairs(selection_tmp) do
        local weight = item.Weight or 1
        if weight > 0 then
            available[item] = true
            availableCount = availableCount + 1
            totalWeight = totalWeight + weight
        end
    end

    -- 处理所有权重<=0的情况
    if totalWeight <= 0 then totalWeight = availableCount end

    -- 选择num个不重复元素
    for i = 1, num do
        if availableCount == 0 then break end -- 没有可选元素时终止
        -- 生成随机位置
        local randomPoint = self:tableRandom(totalWeight) - 1
        local cumulative = 0
        local chosen = nil
        -- 遍历查找选中的元素
        for item, isAvailable in pairs(available) do
            if isAvailable then
                local weight = item.Weight or 1
                cumulative = cumulative + weight
                -- 找到满足条件的元素
                if cumulative >= randomPoint then
                    chosen = item
                    break
                end
            end
        end
        -- 如果由于浮点精度问题未选中，选择第一个可用元素
        if not chosen then
            for item, isAvailable in pairs(available) do
                if isAvailable then
                    chosen = item
                    break
                end
            end
        end
        if chosen then
            -- 添加选中的元素并更新状态
            table.insert(selection, chosen)
            available[chosen] = false
            availableCount = availableCount - 1
            totalWeight = totalWeight - (chosen.Weight or 1)
            -- 确保总权重不小于0
            if totalWeight < 0 then
                totalWeight = 0
            end
        end
    end
    return selection
end


--设置属性 (GamePlay, UI)
function NwflowerMODCore:SetObjectState(pObject, sPropertyName, value)
    if (sPropertyName == nil) then return nil; end

    if (pObject == nil) then
        print("NwflowerMODCore SET OBJECT STATE: ERROR: OBJECT IS NIL!");
        return nil;
    end

    if (USE_CACHE == true) then
        if (g_ObjectStateCache[pObject] == nil) then
            g_ObjectStateCache[pObject] = {};
        end
        g_ObjectStateCache[pObject][sPropertyName] = value;
    end

    if UI ~= nil then
        -- UI端无法直接修改
        local kParameters = {};
        kParameters.propertyName = sPropertyName;
        kParameters.value = value;
        kParameters.objectID = pObject:GetComponentID();
        kParameters.OnStart = "OnPlayerCommandSetObjectState";
        UI.RequestPlayerOperation(Game.GetLocalPlayer(), PlayerOperations.EXECUTE_SCRIPT, kParameters);
    else
        if (pObject.SetProperty ~= nil) then
            pObject:SetProperty(sPropertyName, value);
        end
    end
end

--||=====================GamePlay=======================||--

--随机数生成器，范围为[1,num+1] (GamePlay,UI)
function NwflowerMODCore:tableRandom(num)
    if UI ~= nil then
        return math.floor(math.random() * num) + 1
    else
        return Game.GetRandNum and (Game.GetRandNum(num) + 1) or 1
    end
end

--对单位造成伤害，超出生命值则死亡并返回true。 (GamePlay)
function NwflowerMODCore:DamageUnit(unit, damage)
    local maxDamage = unit:GetMaxDamage()
    if (unit:GetDamage() + damage) >= maxDamage then
        unit:SetDamage(maxDamage)
        UnitManager.Kill(unit, false)
        return true
    else
        unit:ChangeDamage(damage)
        return false
    end
end


-- ===========================================================================
function OnPlayerCommandSetObjectStateHandler(ePlayer, params)
	local pObject = Game.GetObjectFromComponentID(params.objectID);
	if pObject ~= nil then
		SetObjectState(pObject, params.propertyName, params.value);
	end
end

if UI == nil then
	GameEvents.OnPlayerCommandSetObjectState.Add( OnPlayerCommandSetObjectStateHandler );
end
