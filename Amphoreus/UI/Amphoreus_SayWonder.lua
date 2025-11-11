----------------------------------------------------------------
-- Am_SW
----------------------------------------------------------------
include( "PlayerTargetLogic" );
include( "ToolTipHelper" );
include( "MapTacks" );
----------------------------------------------------------------  
-- Globals
----------------------------------------------------------------
local m_iCurrentPlayerID = Game.GetLocalPlayer()
local m_pCurrentPlayer = Players[m_iCurrentPlayerID]

local g_iconPulldownOptions = {};
local g_iconOptionEntries = {};
local g_desiredIconName = "";
local g_playerTarget = { targetType = ChatTargetTypes.CHATTARGET_PLAYER, targetID = Game.GetLocalPlayer() };


-- ===========================================================================
-- 设置奇观图标
function SetIcon(imageControl , mapPinIconName )
	if(imageControl ~= nil and mapPinIconName ~= nil) then
		imageControl:SetIcon( mapPinIconName, 80 )
	end
end

-- ===========================================================================
-- 获得奇观图标
-- 奇观未建成且未被预言
local g_playerWonderIconsCache = {};
function WonderIconOptions(playerID)
	local pPlayer = Players[playerID]
	local grid = {};
	for item in GameInfo.Buildings() do
		if item.IsWonder then
			table.insert(grid, MapTacks.Icon(item));
		end
	end
	g_playerWonderIconsCache[playerID] = grid;
	return grid;
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
-- 奇观图标
function PopulateIconOptions()
	local wondersHasBuilt = GetWonderBuilt()
	g_iconPulldownOptions = WonderIconOptions(m_iCurrentPlayerID);
	g_iconOptionEntries = {};
	Controls.IconOptionStack:DestroyAllChildren();
	local MIN_COLS = 8;
	local MAX_COLS = 16;
	local MAX_ROWS = 12;
	local columns = MAX_COLS;
	local nMinBlanks = MAX_COLS * MAX_ROWS;
	for i = MIN_COLS,MAX_COLS do
		local nBlanks = 0;
		local nRows = 0;
		nRows = nRows + math.ceil(#g_iconPulldownOptions / i);
		local remainder = #g_iconPulldownOptions % i;
		if remainder > 0 then
			nBlanks = nBlanks + (i - remainder);
		end
		if nBlanks < nMinBlanks and nRows <= MAX_ROWS then
			nMinBlanks = nBlanks;
			columns = i;
		end
	end
	local controlTable = {};
	local newIconEntry = {};
	g_iconOptionEntries = {};
	local sectionTable = {};
	ContextPtr:BuildInstanceForControl( "IconOptionRowInstance", sectionTable, Controls.IconOptionStack );
	local ht = math.floor((#g_iconPulldownOptions + columns - 1) / columns);
	local wd = columns;
	sectionTable.IconOptionRowStack:SetWrapWidth(100 * wd);
	for i, pair in ipairs(g_iconPulldownOptions) do
		controlTable = {};
		newIconEntry = {};
		ContextPtr:BuildInstanceForControl( "IconOptionInstance", controlTable, sectionTable.IconOptionRowStack );
		SetIcon(controlTable.Icon, pair.name);
		-- 设置状态
		if wondersHasBuilt[pair.tooltip] then
			controlTable.IconState:SetText( '[COLOR:ResGoldLabelCS]已建成[ENDCOLOR]' );
			controlTable.IconOptionButton:SetEnabled(false)
		elseif m_pCurrentPlayer:GetProperty('NW_AM_SAY_WONDER_'..pair.tooltip) then
			controlTable.IconState:SetText( '[COLOR:ResScienceLabelCS]已预言[ENDCOLOR]' );
			controlTable.IconOptionButton:SetEnabled(false)
		else
			controlTable.IconOptionButton:RegisterCallback(Mouse.eLClick, OnIconOption);
			controlTable.IconOptionButton:SetVoids(i, 1);
			controlTable.StateContainer:SetHide( true );
		end

		if pair.tooltip then
			local tooltip = ToolTipHelper.GetToolTip(pair.tooltip, Game.GetLocalPlayer()) or Locale.Lookup(pair.tooltip);
			controlTable.IconOptionButton:SetToolTipString(tooltip);
		end
		newIconEntry.IconName = pair.name;
		newIconEntry.Instance = controlTable;
		g_iconOptionEntries[i] = newIconEntry;
		UpdateIconOptionColor(i);
		if (#g_iconPulldownOptions % wd) ~= 0 then
			if (i % wd) == 0 and (i / wd) == (ht - 1) then
				sectionTable = {};
				ContextPtr:BuildInstanceForControl( "IconOptionRowInstance", sectionTable, Controls.IconOptionStack );
				sectionTable.IconOptionRowStack:SetWrapWidth(100 * wd);
			end
		end
	end

	Controls.Window:SetSizeX(100 * columns + 30);
	Controls.OptionsStack:SetWrapWidth(100 * columns + 8);
	Controls.IconOptionStack:CalculateSize();
	Controls.OptionsStack:CalculateSize();
	Controls.WindowContentsStack:CalculateSize();
	Controls.WindowStack:CalculateSize();
end

-- ===========================================================================
-- 更新图标信息
function UpdateIconOptionColor(index)
	local iconEntry  = g_iconOptionEntries[index];
	if(iconEntry ~= nil) then
		if(iconEntry.IconName == g_desiredIconName) then
			iconEntry.Instance.IconOptionButton:SetSelected(true);
		else
			iconEntry.Instance.IconOptionButton:SetSelected(false);
		end
	end
end

-- ===========================================================================
-- 图标被选中
function OnIconOption( index )
	local iconOptions  = g_iconPulldownOptions[index];
	if(iconOptions) then
		local newIconName = iconOptions.name;
		g_desiredIconName = newIconName;
		for i, icon in ipairs(g_iconOptionEntries) do
			UpdateIconOptionColor( i );
		end
	end
end

-- ===========================================================================
-- 点击确认按钮
function OnOk()
	if UIManager:IsInPopupQueue(ContextPtr) then
		-- 获得给定奇观
		local sBuilding = string.gsub(g_desiredIconName, "ICON_", '')
		UI.RequestPlayerOperation(m_iCurrentPlayerID, PlayerOperations.EXECUTE_SCRIPT, {
			OnStart = "NW_RequestProphecy",
			sBuilding = sBuilding
		});
		UIManager:DequeuePopup( ContextPtr );
		g_desiredIconName = nil;
	end
end

-- ===========================================================================
-- 点击取消按钮：本回合跳过
function OnCancel()
	UIManager:DequeuePopup( ContextPtr );
	g_desiredIconName = nil;
end

function RequestProphecy(iPlayer)
	if iPlayer ~= m_iCurrentPlayerID then return end
	if not UIManager:IsInPopupQueue(ContextPtr) then
		PopulateIconOptions();
		UIManager:QueuePopup(ContextPtr, PopupPriority.Current,{
			RenderAtCurrentParent = true;
			InputAtCurrentParent = true;
			AlwaysVisibleInQueue = true;
		});
		UI.PlaySound("UI_Screen_Open");
	end
	LuaEvents.SayWonder_QueuePopup();
end

-- ===========================================================================
--	INITIALIZE
-- ===========================================================================
function Initialize()
	LuaEvents.SayWonder_RequestProphecy.Add(RequestProphecy);
	Controls.SkipButton:RegisterCallback(Mouse.eLClick, OnCancel);
	Controls.SkipButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
	Controls.OkButton:RegisterCallback(Mouse.eLClick, OnOk);
	Controls.OkButton:RegisterCallback( Mouse.eMouseEnter, function() UI.PlaySound("Main_Menu_Mouse_Over"); end);
end
Initialize();


