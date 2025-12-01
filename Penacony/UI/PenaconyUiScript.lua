-- PenaconyUis
-- Author: Nwflower
-- DateCreated: 2025-5-13 19:25:13
--------------------------------------------------------------
--||=======================include========================||--

--||====================c=================================||--
local localPlayerID = Game.GetLocalPlayer()
local localPlayer = Players[localPlayerID];

--||====================base functions====================||--
function HasTrait_Property(sTrait, iPlayer)
	local pPlayer = Players[iPlayer];
	local ePro = pPlayer:GetProperty('PROPERTY_'..sTrait) or 0
	if ePro > 0 then
		return true
	end
	return false
end


--||======================initialize======================||--

function Initialize()
    -----------------------Events-----------------------
    print('PenaconyUis Initial success')
end

Initialize()
