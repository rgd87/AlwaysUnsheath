local addonName, addonTable = ...

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

local unsheath = function()
    if GetSheathState() ~= 2 then
        ToggleSheath()
    end
end

local ticker

f.MERCHANT_CLOSED = unsheath
f.LOOT_CLOSED = unsheath


function f:SPELLS_CHANGED(event)
    local _, class = UnitClass("player")
    local spec = GetSpecialization()
    if class == "MONK" and spec == 1 then
        f:Enable()
    else
        f:Disable()
    end
    -- if class == "DRUID" 
end

f.PLAYER_LOGIN = f.SPELLS_CHANGED

f:RegisterEvent("SPELLS_CHANGED")
f:RegisterEvent("PLAYER_LOGIN")

function f:Enable()
    -- self:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- self:RegisterUnitEvent("UNIT_AURA", "player")
    -- self:RegisterEvent("QUEST_ACCEPTED")
    -- self:RegisterEvent("QUEST_FINISHED") 
    -- self:RegisterEvent("MERCHANT_CLOSED")
    self:RegisterEvent("LOOT_CLOSED")
    if not ticker then
        ticker = C_Timer.NewTicker(5, unsheath)
    end
end

function f:Disable()
    -- self:UnregisterEvent("MERCHANT_CLOSED")
    self:UnregisterEvent("LOOT_CLOSED")
    if ticker then
        ticker:Cancel()
        ticker = nil
    end
end
