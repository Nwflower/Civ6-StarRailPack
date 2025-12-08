-- TechTree_Herta
-- Author: Konomi
-- DateCreated: 7/23/2024 11:18:56
--------------------------------------------------------------
include( "PopupDialog" );

local files = {
	"TechTree_CQUI.lua",
	"TechTree_TPT.lua",
	"DL_TechTree.lua",
	"TechTree_Expansion2.lua",
	"TechTree_Expansion1.lua",
	"TechTree.lua"
}

for _, file in ipairs(files) do
	include(file);
	if Initialize then
		print("TechTree_Herta Loading " .. file .. " as base file");
		break;
	end
end

local ORIGIN_PopulateNode = PopulateNode;

local PURCHASE_TECH_MULTIPLIER = GlobalParameters.KNM_ASTA_PURCHASE_TECH_MULTIPLIER or 2
local m_GoldPurchaseBonusIndex = GameInfo.GovernmentBonusNames['GOVERNMENTBONUS_GOLD_PURCHASES'] and GameInfo.GovernmentBonusNames['GOVERNMENTBONUS_GOLD_PURCHASES'].Index or -1
-- ===========================================================================
function GetPurchaseModifier(playerId, spend)
	local pPlayer = Players[playerId]
	local modifier = pPlayer:GetCulture():GetFlatBonus(m_GoldPurchaseBonusIndex)	
	spend = spend * (100 - modifier) / 100
	if spend < 1 then
		return 1
	end
	return math.floor(spend)
end
-- ===========================================================================
function PopulateNode(uiNode, playerTechData)
	ORIGIN_PopulateNode(uiNode, playerTechData);
	local item = g_kItemDefaults[uiNode.Type];
	local live = playerTechData[DATA_FIELD_LIVEDATA][uiNode.Type];
	local status = live.IsRevealed and live.Status or ITEM_STATUS.UNREVEALED;
	local playerId = Game.GetLocalPlayer()
	local pPlayer = Players[playerId]
	local techInfo = GameInfo.Technologies[item.Index]
	if IsTutorialRunning()==false and pPlayer:GetProperty('KNM_LEADER_ASTA') ~= nil and techInfo and not techInfo.Repeatable  and (techInfo.EraType == 'ERA_ANCIENT' or techInfo.EraType == 'ERA_CLASSICAL' )  and
		status ~= ITEM_STATUS.RESEARCHED and status ~= ITEM_STATUS.UNREVEALED then
		uiNode.NodeButton:ClearCallback(Mouse.eRClick);
		uiNode.OtherStates:ClearCallback(Mouse.eRClick);
		function OnRightClick() 
			local playerTechs = pPlayer:GetTechs()
			local progress = playerTechs:GetResearchProgress(techInfo.Index)
			local cost = playerTechs:GetResearchCost(techInfo.Index)
			local spend = GetPurchaseModifier(playerId, (cost - progress) * PURCHASE_TECH_MULTIPLIER)
			local gold = pPlayer:GetTreasury():GetGoldBalance()
			if gold >= spend then
				local popupDialog = PopupDialogInGame:new( "KnmHertaPanelPopupDialog" );
				popupDialog:ShowOkCancelDialog(Locale.Lookup('LOC_UNIT_KNM_HERTA_PURCHASE_TECH', spend, Locale.Lookup(techInfo.Name)), function ()
					UI.RequestPlayerOperation(playerId, PlayerOperations.EXECUTE_SCRIPT, {
						OnStart = 'KnmHertaSetTech',
						TechID = techInfo.Index,
						Spend = spend,
						Cost = cost,
					})
				end)
			else
				local popupDialog = PopupDialogInGame:new( "KnmHertaPanelPopupDialog" );
				popupDialog:ShowOkDialog(Locale.Lookup('LOC_UNIT_KNM_HERTA_PURCHASE_TECH_NO_BALANCE', spend, Locale.Lookup(techInfo.Name)))
			end
		end
		uiNode.NodeButton:RegisterCallback(Mouse.eRClick, OnRightClick)
		uiNode.OtherStates:RegisterCallback(Mouse.eRClick, OnRightClick)
	end
end;
