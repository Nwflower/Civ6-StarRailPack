-- Amphoreus_UA
-- Author: Nwflower
-- SpecialThanks:Flactine
-- DateCreated: 2025/3/23 18:09:27

local m_iCurrentPlayerID = Game.GetLocalPlayer()
local m_pCurrentPlayer = Players[m_iCurrentPlayerID]

local isJanusActive = false
local targetPlots = {}
g_HexColoringMovement = UILens.CreateLensLayerHash("Hex_Coloring_Movement");

function HasTrait_Property(sTrait, iPlayer)
    local pPlayer = Players[iPlayer];
    local ePro = pPlayer:GetProperty('PROPERTY_' .. sTrait) or 0
    if ePro > 0 then
        return true
    end
    return false
end

-----------------------------------------------------------------------
--- 按钮显示的具体条件，包括所选单位是否能用传送能力，也包括所在地点是否能是传送起点的判断
-----------------------------------------------------------------------
-- 检查传送按钮是否可用
-- 1.单位是否能使用传送功能：处于市中心、且为缇宝的单位
-- 2.合法目的地个数是否大于0
function IsJanusButtonActive(pUnit)
    if not HasTrait_Property('TRAIT_LEADER_NW_TRIBIOS_JANUS', m_iCurrentPlayerID) then
        return false
    end
    local UnitInfo = GameInfo.Units[pUnit:GetType()]
    if pUnit then
        -- 单位本身无移动机制
        if UnitInfo.IgnoreMoves == 1 then
            return false
        end
        -- 伟人or英雄
        if string.sub(UnitInfo.UnitType, 1, 11) == 'UNIT_GREAT_' or string.sub(UnitInfo.UnitType, 1, 10) == 'UNIT_HERO_' then
            return false
        end
        -- 单位没有剩余移动力，返回
        if pUnit:GetMovesRemaining() <= 0 then
            return false
        end
        -- 当前格位的区域是市中心
        local pDistrict = CityManager.GetDistrictAt(Map.GetPlotByIndex(pUnit:GetPlotId()))
        if (not pDistrict) or pDistrict:GetOwner() ~= m_iCurrentPlayerID or pDistrict:IsComplete() ~= true or pDistrict:GetType() ~= GameInfo.Districts['DISTRICT_CITY_CENTER'].Index then
            return false
        end
        if #GetTeleportTarget(pUnit) <= 0 then
            return false
        end
        return true
    end
    return false
end

-----------------------------------------------------------------------
--- 单位按钮通用函数
-----------------------------------------------------------------------
-- 单位移动完成时刷新界面
function OnUnitMoveComplete(playerID, unitID, iX, iY)
    if playerID ~= m_iCurrentPlayerID then
        return
    end
    Refresh(playerID)
end

-- 单位选择变化时刷新界面
function OnUnitSelectionChanged(playerID, unitID, plotX, plotY, plotZ, bSelected, bEditable)
    if playerID ~= m_iCurrentPlayerID then
        return
    end
    Refresh(playerID)
end

-- 刷新按钮状态
function Refresh(playerID)
    local pUnit = UI.GetHeadSelectedUnit()
    if pUnit == nil then
        return
    end
    if IsJanusButtonActive(pUnit) then
        Controls.UnitJanusGrid:SetHide(false)
    else
        Controls.UnitJanusGrid:SetHide(true)
    end
end

-----------------------------------------------------------------------
--- 单位按钮点击效果
-----------------------------------------------------------------------
function OnUnitJanusButtonClicked()
    local pUnit = UI.GetHeadSelectedUnit()
    if isJanusActive then
        isJanusActive = false
    else
        isJanusActive = true
        targetPlots = GetTeleportTarget(pUnit)
    end
    FixTeleUI()
end


---------------------------------------------------------------------------------------------
---检查可行的传送目的地，这部分需要根据需求自行修改，以下展示可以传送到市中心及其周边--------------
----------------------------------------------------------------------------------------------
function GetTeleportTarget(pUnit)
    local result = {}
	local sUnitFormationClass = GameInfo.Units[pUnit:GetType()].FormationClass
    for _,pCity in m_pCurrentPlayer:GetCities():Members() do
        if pCity then
			local pPlot = Map.GetPlot(pCity:GetX(), pCity:GetY());
			local flag = false;
			-- 海洋单位只能传送到沿海城市
			if GameInfo.Units[pUnit:GetType()].Domain == 'DOMAIN_SEA' then
				flag = true;
				local tNeighborPlots = Map.GetAdjacentPlots(pCity:GetX(), pCity:GetY());
				for _, pNeighborPlot in ipairs(tNeighborPlots) do
					if pNeighborPlot:IsWater() then
						flag = false;
						break;
					end
				end
			end
			-- 目的地市中心不能拥有相同FormationClass的单位
			for loop, pUnitInTargetPlot in ipairs(Units.GetUnitsInPlot(pPlot)) do
				if(pUnitInTargetPlot ~= nil) then
					if GameInfo.Units[pUnitInTargetPlot:GetType()].FormationClass == sUnitFormationClass then
						flag = true;
						break;
					end
				end
			end
			if not flag then
				table.insert(result,pPlot:GetIndex());
			end
        end
    end
    return result
end

function FixTeleUI()
    local cMode = UI.GetInterfaceMode();
	if isJanusActive then
        UI.SetInterfaceMode( InterfaceModeTypes.WB_SELECT_PLOT );
        if #targetPlots ~= 0 then
			local eLocalPlayer = Game.GetLocalPlayer();
			UILens.ToggleLayerOn(g_HexColoringMovement);
            UILens.SetLayerHexesArea(g_HexColoringMovement, eLocalPlayer, targetPlots);
		end
	else
        UI.SetInterfaceMode( InterfaceModeTypes.SELECTION );
        UILens.ToggleLayerOff( g_HexColoringMovement );
	    UILens.ClearLayerHexes( g_HexColoringMovement );
 	end
end

--如果目的地单元格可以传送，则进行传送，否则退出传送模式
function OnSelectPlot(plotId, plotEdge, boolParam)
    if not isJanusActive then
		return
    end
    local pUnit = UI.GetHeadSelectedUnit()
    Teleport(plotId,pUnit)
	isJanusActive = false
	FixTeleUI()
end

--传送的实行
function Teleport(iPlot,pUnit)
    for _,v in pairs(targetPlots) do
        if iPlot == v then
            UI.RequestPlayerOperation(m_iCurrentPlayerID, PlayerOperations.EXECUTE_SCRIPT, {
                OnStart = "NW_Teleport",
                iPlot = iPlot,
                iUnit = pUnit:GetID()
            });
            return true
        end
    end
    return false
end

function OnUiModChange( )
	local cMode = UI.GetInterfaceMode();
	if isJanusActive and cMode == InterfaceModeTypes.WB_SELECT_PLOT then
        return
    end
    if isJanusActive then
        isJanusActive = false
        FixTeleUI()
    end
end

-----------------------------------------------------------------------
--- UI界面初始化
-----------------------------------------------------------------------
function Initialize()
    local pContext = ContextPtr:LookUpControl("/InGame/UnitPanel/StandardActionsStack")
    if pContext ~= nil then
        Controls.UnitJanusGrid:ChangeParent(pContext)
        Controls.UnitJanusButton:RegisterCallback(Mouse.eLClick, OnUnitJanusButtonClicked)
    end

    LuaEvents.WorldInput_WBSelectPlot.Add( OnSelectPlot )
    Events.InterfaceModeChanged.Add( OnUiModChange )
    Events.UnitTeleported.Add(OnUnitMoveComplete)
    Events.UnitSelectionChanged.Add(OnUnitSelectionChanged)
    Events.UnitMoveComplete.Add(OnUnitMoveComplete)
end

Events.LoadGameViewStateDone.Add(Initialize)