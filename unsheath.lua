local addonName, ns = ...

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

local ticker
-- local _, playerClass = UnitClass("player")

local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey
local playerClass = charKey

local defaults = {
}


f:RegisterEvent("PLAYER_LOGIN")
function f:PLAYER_LOGIN(event)
    _G.AutoUnsheathDB = _G.AutoUnsheathDB or {}
    ns.SetupDefaults(AutoUnsheathDB, defaults)

    self:ReconfTicker()

    local loader = CreateFrame('Frame', nil, InterfaceOptionsFrame)
    loader:SetScript('OnShow', function(self)
        self:SetScript('OnShow', nil)

        if not f.optionsPanel then
            f.optionsPanel = f:CreateGUI("AutoUnsheath")
            InterfaceOptions_AddCategory(f.optionsPanel);
        end
    end)

    SLASH_AUTOUNSHEATH1= "/autounsheath"
    SlashCmdList["AUTOUNSHEATH"] = f.ConsoleToggle
end

f:RegisterEvent("PLAYER_LOGOUT")
function f:PLAYER_LOGOUT(event)
    ns.RemoveDefaults(AutoUnsheathDB, defaults)
end



local unsheath = function()
    if GetSheathState() ~= 2 then
        ToggleSheath()
    end
end



f.MERCHANT_CLOSED = unsheath
f.LOOT_CLOSED = unsheath




function f:ReconfTicker(event)
    local db = AutoUnsheathDB
    local spec = GetSpecialization()
    local enabled = db[playerClass] and db[playerClass][spec]

    if enabled then
        f:Enable()
    else
        f:Disable()
    end
    -- if class == "DRUID"
end

f.SPELLS_CHANGED = f.ReconfTicker
f:RegisterEvent("SPELLS_CHANGED")

function f:Enable()
    -- self:RegisterEvent("PLAYER_ENTERING_WORLD")
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

function f:ToggleForSpec(specIndex)
    local db = AutoUnsheathDB
    db[playerClass] = db[playerClass] or {}
    db[playerClass][specIndex] = not db[playerClass][specIndex]
    f:ReconfTicker()
end
function f.ConsoleToggle()
    local spec = GetSpecialization()
    f:ToggleForSpec(spec)
end


local function MakeCheckbox(name, parent, icon, text)
    local cb = CreateFrame("CheckButton", name, parent, "UICheckButtonTemplate")
    cb:SetWidth(25)
    cb:SetHeight(25)
    cb:Show()

    local cblabel = cb:CreateFontString(nil, "OVERLAY")
    cblabel:SetFontObject("GameFontHighlight")
    cblabel:SetPoint("LEFT", cb,"RIGHT", 5,0)
    cblabel:SetText(text)
    cb.label = cblabel

    local cbtex = cb:CreateTexture(nil, "ARTWORK")
    cbtex:SetTexture(icon)
    cbtex:SetSize(25, 25)
    cbtex:SetPoint("RIGHT", cb, "LEFT", -5, 0)
    cb.icon = cbtex

    return cb
end

function f:CreateGUI(name, parent)
    local frame = CreateFrame("Frame", nil, InterfaceOptionsFrame)
    frame:Hide()

    frame.parent = parent
    frame.name = name

    frame:SetScript("OnShow", function(self)
        local db = AutoUnsheathDB
        for specIndex, cb in ipairs(self.content.specCheckBoxes) do
            local enabled = db[playerClass] and db[playerClass][specIndex]
            cb:SetChecked(enabled)
        end
    end)

    local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	label:SetPoint("TOPLEFT", 10, -15)
	label:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 10, -45)
	label:SetJustifyH("LEFT")
    label:SetJustifyV("TOP")

    label:SetText(name)

	local content = CreateFrame("Frame", "CADOptionsContent", frame)
	content:SetPoint("TOPLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", -10, 10)

    frame.content = content

    content.specCheckBoxes = {}

    for specIndex=1,GetNumSpecializations() do
        local id, specName, description, icon = GetSpecializationInfo(specIndex)
        local _, class = UnitClass('player')

        local cb = MakeCheckbox(nil, content, icon, specName)
        cb:SetPoint("TOPLEFT", 35, -10 - (specIndex*30))
        cb.specID = specIndex
        cb:SetScript("OnClick",function(self,button)
            f:ToggleForSpec(self.specID)
        end)

        table.insert(content.specCheckBoxes, cb)
    end

    return frame
end


function ns.SetupDefaults(t, defaults)
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            else
                ns.SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
        end
    end
end
function ns.RemoveDefaults(t, defaults)
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            ns.RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end
