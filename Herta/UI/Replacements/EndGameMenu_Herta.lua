-- EndGameMenu_Herta
-- Author: Konomi
-- DateCreated: 9/6/2022 1:37:02
--------------------------------------------------------------

local ORIGINAL_PlayerDefeatedData = PlayerDefeatedData;
local ORIGINAL_TeamVictoryData = TeamVictoryData;
-- ===========================================================================
function PlayerDefeatedData(playerID, defeatType)
	local data = ORIGINAL_PlayerDefeatedData(playerID, defeatType)

	local pPlayerConfig = PlayerConfigurations[playerID]
	local leaderType = pPlayerConfig:GetLeaderTypeName()
	local endGameInfo = GameInfo.Mod_EndGameInfo and GameInfo.Mod_EndGameInfo[leaderType]
	if endGameInfo and endGameInfo.EndGameImage then
		data.PlayerPortrait = endGameInfo.EndGameImage
	end
	return data
end
-- ===========================================================================
function TeamVictoryData(winningTeamID, victoryType)
	local data = ORIGINAL_TeamVictoryData(winningTeamID, victoryType)

	local playerToShow = localPlayerID; -- default to local player, if something weird happens.
	local team = Teams[winningTeamID];
	for i, v in ipairs(team) do
		local player = Players[v];
		if(player:IsAlive()) then
			playerToShow = v;
			break;
		end
	end
	local pPlayerConfig = PlayerConfigurations[playerToShow]
	local leaderType = pPlayerConfig:GetLeaderTypeName()
	local endGameInfo = GameInfo.Mod_EndGameInfo and GameInfo.Mod_EndGameInfo[leaderType]
	if endGameInfo and endGameInfo.EndGameImage then
		data.PlayerPortrait = endGameInfo.EndGameImage
	end

	return data
end
