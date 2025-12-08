-- ActionPanel_Herta
-- Author: Konomi
-- DateCreated: 7/4/2024 10:29:01
--------------------------------------------------------------

-- ===========================================================================
-- INCLUDES
-- ===========================================================================
local files = {
	"ActionPanel_Expansion2.lua",
    "ActionPanel_Expansion1.lua",
    "ActionPanel.lua",
}

for _, file in ipairs(files) do
    include(file)
    if Initialize then
        print("Herta: Loading " .. file .. " as base file");
        break
    end
end

-- ===========================================================================
--	Overrides
-- ===========================================================================
local ORIGIN_OnRefresh = OnRefresh;
local ORIGIN_DoEndTurn = DoEndTurn;
local ORIGIN_OnLocalPlayerTurnEnd = OnLocalPlayerTurnEnd;
-- ===========================================================================
--	CONSTANTS
-- ===========================================================================
local reminderTitle 				 = Locale.Lookup("LOC_FF16_NEWPOLICY_TITLE");
local reminderDesc 					 = Locale.Lookup("LOC_FF16_NEWPOLICY_DESC");
local reminderChange 				 = Locale.Lookup("LOC_FF16_NEWPOLICY_CHANGE");
local reminderContinue 				 = Locale.Lookup("LOC_FF16_NEWPOLICY_CONTINUE");
-- ===========================================================================
--	MEMBERS
-- ===========================================================================
local m_activeBlockerId			= EndTurnBlockingTypes.NO_ENDTURN_BLOCKING;	-- Blocking notification receiving attention
-- local m_numberVisibleBlockers		= 0;
local m_visibleBlockerTypes			= {};
local m_kSoundsPlayed				= {};	
local m_overflowIM			 = InstanceManager:new( "TurnBlockerInstance",  "TurnBlockerButton", Controls.OverflowStack );

-- ===========================================================================
--	FUNCTIONS
-- ===========================================================================

function OnRefresh()
	ORIGIN_OnRefresh()

	m_numberVisibleBlockers = 1; -- Start at 1 to account for current main blocker
	m_visibleBlockerTypes = {};

	local pPlayer  = Players[Game.GetLocalPlayer()];
	if (pPlayer == nil or not pPlayer:IsAlive()) then
		return;
	end

	if not pPlayer:IsTurnActiveComplete() or UI.IsProcessingMessages() then
		SetEndTurnWaiting();			
		return;
	end
	
	Controls.EndTurnButton:SetDisabled( false );
	Controls.EndTurnButtonLabel:SetDisabled( false );	
	
	local message				;
	local icon					;
	local toolTipString			;
	local soundName				;
	local iFlashingState			= 0;	
	local m_activeBlockerId		 = 0;
	local kAllBlockingTypes_old			= NotificationManager.GetAllEndTurnBlocking( Game.GetLocalPlayer() );
	local kAllBlockingTypes = {}
	for _,blockingType in ipairs(kAllBlockingTypes_old) do 	
		if blockingType == EndTurnBlockingTypes.ENDTURN_BLOCKING_RESEARCH then
			if pPlayer:GetProperty('KnmIgnoreTechReq') ~= pPlayer:GetTechs():GetResearchingTech() then
				table.insert(kAllBlockingTypes, blockingType)
				if m_activeBlockerId == 0 then
					m_activeBlockerId = blockingType
				end
			end
		elseif blockingType == EndTurnBlockingTypes.ENDTURN_BLOCKING_CIVIC then
			if pPlayer:GetProperty('KnmIgnoreCivicReq') ~= pPlayer:GetCulture():GetProgressingCivic() then
				table.insert(kAllBlockingTypes, blockingType)
				if m_activeBlockerId == 0 then
					m_activeBlockerId = blockingType
				end
			end
		else
			table.insert(kAllBlockingTypes, blockingType)
			if m_activeBlockerId == 0 then
				m_activeBlockerId = blockingType
			end
		end
	end
	
	-- If there are any blockers shown, there will be at least 1
	table.insert(m_visibleBlockerTypes, m_activeBlockerId);

	-- Loop through all sounds that have just played.
	for _,blockingTypeSoundPlayed in ipairs(m_kSoundsPlayed) do 				
		-- If the blocking type is no longer in the block list
		local isStillInList = false;
		for _,blockingType in ipairs(kAllBlockingTypes) do
			if blockingType == blockingTypeSoundPlayed then
				isStillInList = true;
				break;
			end
		end
		-- If not found in list, remove it from the just played list.
		if not isStillInList then
			m_kSoundsPlayed[blockingTypeSoundPlayed] = nil;
		end
	end

	-- Play the ticker animation
	Controls.TickerAnim:SetToBeginning();
	Controls.TickerAnim:Play();

	-- Populate current blocker
	local kInfo		= g_kMessageInfo[m_activeBlockerId];
	if kInfo ~= nil then
		message			= kInfo.Message;
		icon			= kInfo.Icon;
		toolTipString	= kInfo.ToolTip;
		iFlashingState	= 1;
		soundName		= kInfo.Sound;
	elseif (CheckUnitsHaveMovesState()) then
		-- Special "Units Have Moves" state for when there are no end turn blockers but 
		-- there are units with partial movement remaining in 'auto end turn mode'.
		icon			= "ICON_NOTIFICATION_COMMAND_UNITS"
		message			= Locale.Lookup("LOC_ACTION_PANEL_UNIT_MOVES_REMAINING");
		toolTipString	= Locale.Lookup("LOC_ACTION_PANEL_UNIT_MOVES_REMAINING_TOOLTIP");
		iFlashingState	= 1;	
	elseif (CheckCityRangeAttackState()) then
		-- Special "City Ranged Attack" state for when there are no end turn blockers but 
		-- there is a city can that perform a ranged attack in 'auto end turn mode'.
		message			= Locale.Lookup("LOC_ACTION_PANEL_CITY_RANGED_ATTACK");
		icon            = "ICON_NOTIFICATION_CITY_RANGE_ATTACK";
		toolTipString	= Locale.Lookup("LOC_ACTION_PANEL_CITY_RANGED_ATTACK_TOOLTIP");
		iFlashingState	= 1;
	else
		message			= Locale.Lookup("LOC_ACTION_PANEL_NEXT_TURN");	
		icon			= "ICON_NOTIFICATION_NEXT_TURN";		
		toolTipString	= Locale.Lookup("LOC_ACTION_PANEL_NEXT_TURN_TOOLTIP");
		iFlashingState	= 1;
	end	

	-- Show controls and setup callbacks based on the notifications.

	local blockersInUIMax	 = math.min( table.count(kAllBlockingTypes), 4);
	local iControlNum		 = 2;
	local iBlocker			 = 0;
	for iBlocker = 1, blockersInUIMax, 1 do
		local endTurnBlockingId = kAllBlockingTypes[iBlocker];
		-- We only want to add blocker buttons for blockers that aren't represented already
		if  endTurnBlockingId ~= m_activeBlockerId and (not BlockerIsVisible(endTurnBlockingId)) then			
			local kAlphaControl = Controls["TurnBlockerAlpha"..tostring(iControlNum)];
			local kSlideControl = Controls["TurnBlockerSlide"..tostring(iControlNum)];
			local kButtonControl= Controls["TurnBlockerButton"..tostring(iControlNum)];

			if kAlphaControl:IsHidden() then
				kAlphaControl:SetHide(false);		
				kAlphaControl:SetToBeginning();
				kSlideControl:SetToBeginning();
				kAlphaControl:Play();
				kSlideControl:Play();
			elseif kAlphaControl:IsReversing() then
				kAlphaControl:Reverse();
				kSlideControl:Reverse();
				kAlphaControl:Play();
				kSlideControl:Play();
			end
			if g_kMessageInfo[endTurnBlockingId] then
				local tooltip = g_kMessageInfo[endTurnBlockingId].ToolTip;
				-- print('kAlphaControl:IsHidden(), tooltip', kAlphaControl:IsHidden(), tooltip)
				local icon	= g_kMessageInfo[endTurnBlockingId].Icon;
				if(icon ~= nil) then
					local textureOffsetX, textureOffsetY, textureSheet = IconManager:FindIconAtlas(icon,40);
					kButtonControl:SetTexture( textureOffsetX, textureOffsetY, textureSheet );
				end
				kButtonControl:SetToolTipString( tooltip );
				kButtonControl:RegisterCallback( Mouse.eLClick, 
					function()					
						DoEndTurn( endTurnBlockingId );
					end
				);
				iControlNum = iControlNum + 1;
				m_numberVisibleBlockers = m_numberVisibleBlockers + 1;
				table.insert(m_visibleBlockerTypes, endTurnBlockingId);
			else
				UI.DataError("Attempted to show turn blocking icon in ActionPanel but NIL in message info. id: "..tostring(endTurnBlockingId));
			end
		end		
	end
	-- Go through remaining controls (if any) and hide them if no longer showing.
	for iControlNum = iControlNum, 4, 1 do
		local kAlphaControl = Controls["TurnBlockerAlpha"..tostring(iControlNum)];
		if not kAlphaControl:IsHidden() and not kAlphaControl:IsReversing() then
			local kSlideControl = Controls["TurnBlockerSlide"..tostring(iControlNum)];
			kAlphaControl:Reverse();
			kSlideControl:Reverse();
			kAlphaControl:Play();
			kSlideControl:Play();
		end
	end


	-- If there are more blockers than room, then add to "+" area:
	if m_numberVisibleBlockers > 4 then
		Controls.OverflowCheckboxGroup:SetHide(false);
		m_overflowIM:ResetInstances();
		for iBlocker = 5, table.count(kAllBlockingTypes), 1 do
			-- We only want to add blocker buttons for blockers that aren't represented already
			local endTurnBlockingId	 = kAllBlockingTypes[iBlocker];
			if not BlockerIsVisible(endTurnBlockingId) then
				local title				 = g_kMessageInfo[endTurnBlockingId].Message;
				local kInst				  = m_overflowIM:GetInstance();			
				local tooltip			 = g_kMessageInfo[endTurnBlockingId].ToolTip;
				local icon				 = g_kMessageInfo[endTurnBlockingId].Icon;

				if(icon ~= nil) then
					local textureOffsetX, textureOffsetY, textureSheet = IconManager:FindIconAtlas(icon,40);
					kInst.TurnBlockerIcon:SetTexture( textureOffsetX, textureOffsetY, textureSheet );
				end

				kInst.TurnBlockerLabel:SetText( title );			
				kInst.TurnBlockerLabel:SetToolTipString( tooltip );
				kInst.TurnBlockerButton:RegisterCallback( Mouse.eLClick, 
					function()					
						DoEndTurn( endTurnBlockingId );
					end
				);
				table.insert(m_visibleBlockerTypes, endTurnBlockingId);
			end
		end
	else
		Controls.OverflowCheckboxGroup:SetHide(true);
	end

	-- Play associated sound if there is one (and it hasn't played yet; which can happen
	-- if a player chooses another action rather than the immediate blocking action.)
	if soundName ~= nil and soundName ~= "" then
		if m_kSoundsPlayed[m_activeBlockerId] == nil then
			UI.EnqueueNotificationSound( soundName );
			m_kSoundsPlayed[m_activeBlockerId] = true;
		end
	end

	TruncateStringWithTooltip(Controls.EndTurnText, 150, message); 
	Controls.EndTurnButton:SetToolTipString( toolTipString );

	-- Set big icon
	if(icon ~= nil) then
		local countActiveType	 = 0;
		Controls.CurrentTurnBlockerIcon:SetHide(false);
		Controls.CurrentTurnBlockerIcon:SetIcon(icon);
		
		countActiveType = GetNumNotificationsOfActiveBlocker();
		if  countActiveType >= 2 then
			Controls.Count:SetText(countActiveType);
			Controls.CountImage:SetHide(false);
		else
			Controls.CountImage:SetHide(true);
		end
	end

	SetEndTurnFlashing(iFlashingState);
end
-- ===========================================================================
function BlockerIsVisible(iBlocker)
	local currentType;

	for currentType=1, table.count(m_visibleBlockerTypes), 1 do
		if m_visibleBlockerTypes[currentType] == iBlocker then
			return true;
		end
	end

	return false;
end
-- ===========================================================================
function DoEndTurn( optionalNewBlocker )
	local pPlayer = Players[Game.GetLocalPlayer()];
	if (pPlayer == nil) then
		return;
	end


	local kCulture	= pPlayer:GetCulture();
	--FF16 - Get Civic unlocked this turn, if any. Used later to not prompt on Future Civic Completion.
	local lastCivicInfo = GameInfo.Civics[kCulture:GetCivicCompletedThisTurn()];
	if(lastCivicInfo == nil) then lastCivicInfo = "None"; end

	-- If the player can unready their turn, request that.
	-- CanUnreadyTurn() only checks the gamecore state. IsTurnTimerElapsed() is also required to ensure the local player still has turn time remaining.
	if pPlayer:CanUnreadyTurn()
		and not UI.IsTurnTimerElapsed(Game.GetLocalPlayer()) then
		UI.RequestAction(ActionTypes.ACTION_UNREADYTURN);	
		return;
	end

	if UI.IsProcessingMessages() then
		print("ActionPanel:DoEndTurn() The game is busy processing messages");
		return;
	end

	-- If not in selection mode; reset mode before performing the action.
	if UI.GetInterfaceMode() ~= InterfaceModeTypes.SELECTION then
		UI.SetInterfaceMode(InterfaceModeTypes.SELECTION);
	end


	-- Make sure if an active blocker is not set, to do one more check from the engine/authority.
	if optionalNewBlocker ~= nil then
		m_activeBlockerId = optionalNewBlocker;
	else
		local activeBlockerId = 0
		for _, blockingType in ipairs(NotificationManager.GetAllEndTurnBlocking( Game.GetLocalPlayer() )) do 	
			if blockingType == EndTurnBlockingTypes.ENDTURN_BLOCKING_RESEARCH then
				if pPlayer:GetProperty('KnmIgnoreTechReq') ~= pPlayer:GetTechs():GetResearchingTech() then
					activeBlockerId = blockingType
					break
				end
			elseif blockingType == EndTurnBlockingTypes.ENDTURN_BLOCKING_CIVIC then
				if pPlayer:GetProperty('KnmIgnoreCivicReq') ~= pPlayer:GetCulture():GetProgressingCivic() then
					activeBlockerId = blockingType
					break
				end
			else
				activeBlockerId = blockingType
				break
			end
		end
		if activeBlockerId == 0 then
			-- UI.RequestAction(ActionTypes.ACTION_ENDTURN, { REASON = "UserForced" } );
			-- return
			m_activeBlockerId = EndTurnBlockingTypes.NO_ENDTURN_BLOCKING
		else
			m_activeBlockerId = activeBlockerId
		end
		-- m_activeBlockerId = NotificationManager.GetFirstEndTurnBlocking(Game.GetLocalPlayer());
	end
	
	if m_activeBlockerId == EndTurnBlockingTypes.NO_ENDTURN_BLOCKING then
		if (CheckUnitsHaveMovesState()) then
			UI.SelectNextReadyUnit();
		elseif(CheckCityRangeAttackState()) then
			local attackCity = pPlayer:GetCities():GetFirstRangedAttackCity();
			if(attackCity ~= nil) then
				UI.SelectCity(attackCity);
				UI.SetInterfaceMode(InterfaceModeTypes.CITY_RANGE_ATTACK);
			else
				UI.DataError( "Unable to find selectable attack city while in CheckCityRangeAttackState()" );
			end
		--FF16~ Add a reminder about new policies being unlocked. 
		elseif( Modding.IsModActive('2778f75d-9c72-4919-a081-620f6482f5d6') and kCulture:CivicCompletedThisTurn() and not kCulture:PolicyChangeMade() and Game.GetCurrentGameTurn() ~= 1 and lastCivicInfo.CivicType ~= "CIVIC_FUTURE_CIVIC") then	  
			local m_kPopupDialog = PopupDialogInGame:new( "ContinueWithoutChangingPoliciesPrompt" );
			m_kPopupDialog:AddTitle(reminderTitle);
			m_kPopupDialog:AddText(reminderDesc);
			m_kPopupDialog:AddCancelButton(reminderChange, function() 
				LuaEvents.NotificationPanel_GovernmentOpenPolicies();
			end );
			m_kPopupDialog:AddConfirmButton(reminderContinue, function()
				UI.RequestAction(ActionTypes.ACTION_ENDTURN);		
				UI.PlaySound("Stop_Unit_Movement_Master");
			end );
			m_kPopupDialog:Open();	
		elseif NotificationManager.GetFirstEndTurnBlocking(Game.GetLocalPlayer()) ~= nil then
			UI.RequestAction(ActionTypes.ACTION_ENDTURN, { REASON = "UserForced" } );
			UI.PlaySound("Stop_Unit_Movement_Master");
		else
			UI.RequestAction(ActionTypes.ACTION_ENDTURN);		
			UI.PlaySound("Stop_Unit_Movement_Master");
		end
	
	elseif (   m_activeBlockerId == EndTurnBlockingTypes.ENDTURN_BLOCKING_STACKED_UNITS
			or m_activeBlockerId == EndTurnBlockingTypes.ENDTURN_BLOCKING_UNIT_NEEDS_ORDERS
			or m_activeBlockerId == EndTurnBlockingTypes.ENDTURN_BLOCKING_UNITS)	then

		UI.SelectNextReadyUnit();

	else		
		-- generic turn blocker, trigger the notification associated with the turn blocker.
		local pNotification  = NotificationManager.FindEndTurnBlocking(m_activeBlockerId, Game.GetLocalPlayer());
		-- print('pNotification', optionalNewBlocker, activeBlockerId, pNotification:GetID(), pNotification:GetType(), pNotification:GetMessage())
		if pNotification == nil then
			-- Notification is missing.  Use fallback behavior.
			if not UI.CanEndTurn() then
				UI.DataError("The UI thinks that we can't end turn, but the notification system disagrees.");
				return;
			end				
			UI.RequestAction(ActionTypes.ACTION_ENDTURN);		
			return;
		end
		
		-- Raise the event across the UI which may be listening for this particular notification.
		LuaEvents.ActionPanel_ActivateNotification( pNotification );
	end

end
-- ===========================================================================
function OnLocalPlayerTurnEnd()
	local pPlayerConfig 	= PlayerConfigurations[Game.GetLocalPlayer()];
	if(pPlayerConfig:IsAlive())then
		-- Only disable if not in multi-player, so turns can "unend"...
		if not GameConfiguration.IsAnyMultiplayer() then
			Controls.EndTurnButton:SetDisabled(true);
			Controls.EndTurnButtonLabel:SetDisabled(true);
		end

		SetEndTurnWaiting();
		UI.SetInterfaceMode(InterfaceModeTypes.SELECTION);
		m_kSoundsPlayed = {};
	end
end
