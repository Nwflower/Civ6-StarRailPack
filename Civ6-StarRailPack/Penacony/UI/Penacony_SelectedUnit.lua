-- PenaconyUis
-- Author: Nwflower
-- DateCreated: 2025-5-13 19:25:13
--------------------------------------------------------------
-- =================================================================================
-- Import base file
-- =================================================================================
local files = {
    "SelectedUnit.lua",
}

for _, file in ipairs(files) do
    include(file)
    if Initialize then
        print("PN Loading " .. file .. " as base file");
        break
    end
end
-- =================================================================================
-- Cache base functions
-- =================================================================================
BASE_RealizeGreatPersonLens = RealizeGreatPersonLens;

-- =================================================================================
-- Overrides
-- 摇滚乐队高亮修复
-- =================================================================================
function RealizeGreatPersonLens(kUnit)
    UILens.ClearLayerHexes(m_HexColoringGreatPeople);
    if UILens.IsLayerOn( m_HexColoringGreatPeople ) then
        UILens.ToggleLayerOff(m_HexColoringGreatPeople);
    end
    if kUnit ~= nil and ( not UI.IsGameCoreBusy() ) then
        local playerID = kUnit:GetOwner();
        if playerID == Game.GetLocalPlayer() then
            local kUnitRockBand = kUnit:GetRockBand();
            if kUnitRockBand ~= nil and GameInfo.Units[kUnit:GetUnitType()].UnitType == "UNIT_DREAM_BUILDER" then
                local activationPlots = {};
                local rawActivationPlots = kUnitRockBand:GetActivationHighlightPlots();
                for _,plotIndex in ipairs(rawActivationPlots) do
                    table.insert(activationPlots, {"Great_People", plotIndex});
                end
                UILens.SetLayerHexesArea(m_HexColoringGreatPeople, playerID, {}, activationPlots);
                UILens.ToggleLayerOn(m_HexColoringGreatPeople);
                return
            end
        end
    end
    BASE_RealizeGreatPersonLens(kUnit);
end

-----------------------Events-----------------------
print('PenaconyUis Initial success')