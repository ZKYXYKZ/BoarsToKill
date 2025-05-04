L = L or {}
local lastXP = 0
local lastXPChange = 0
local frame = getglobal("BoarsToKillFrame")
local text = getglobal("BoarsToKillText")
local timeText = getglobal("BoarsToKillTimeText")
local updateInterval = 3
local timeSinceLastUpdate = 0
local lastKillTime = nil
local firstKillTime = nil
local killCount = 0
local BoarsToKill_Active = false
local BoarsToKill_Initialized = false
local BoarsToKill_JustLoaded = true
local lastLevel = 0


if not BoarsToKillDB then BoarsToKillDB = {} end

if BoarsToKillDB.totalBoarsKilled == nil then
    BoarsToKillDB.totalBoarsKilled = 0
end
if BoarsToKillDB.lastXP == nil then
    BoarsToKillDB.lastXP = 0
end
if BoarsToKillDB.lastXPChange == nil then
    BoarsToKillDB.lastXPChange = 0
end
if BoarsToKillDB.firstKillTime == nil then
    BoarsToKillDB.firstKillTime = nil
end
if BoarsToKillDB.killCount == nil then
    BoarsToKillDB.killCount = 0
end

local firstKillTime = BoarsToKillDB.firstKillTime or nil
local killCount = BoarsToKillDB.killCount or 0
local sessionBoarsKilled = 0

function BoarsToKill_FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor(math.mod(seconds, 3600) / 60)
    local remainingSeconds = math.floor(math.mod(seconds, 60))
    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, remainingSeconds)
    else
        return string.format("%ds", remainingSeconds)
    end
end

function BoarsToKill_CalculateBoars()
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local remainingXP = maxXP - currentXP
    if lastXPChange == 0 then
        return 0
    end
    local boarsNeeded = math.ceil(remainingXP / lastXPChange)
    return boarsNeeded
end

function BoarsToKill_UpdateDisplay()
    local text = getglobal("BoarsToKillText")
    local timeText = getglobal("BoarsToKillTimeText")
    local frame = getglobal("BoarsToKillFrame")
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local remainingXP = maxXP - currentXP
    local now = GetTime()
    local currentLevel = UnitLevel("player")
    if BoarsToKill_JustLoaded then
        lastXP = currentXP
        lastLevel = currentLevel
        BoarsToKill_JustLoaded = false
    elseif (currentXP > lastXP) or (currentLevel > lastLevel) then
        lastXPChange = (currentLevel > lastLevel) and (maxXP - lastXP + currentXP) or (currentXP - lastXP)
        if not firstKillTime then
            firstKillTime = now
            killCount = 1
        else
            killCount = killCount + 1
        end
        BoarsToKillDB.totalBoarsKilled = (BoarsToKillDB.totalBoarsKilled or 0) + 1
        sessionBoarsKilled = sessionBoarsKilled + 1
    end
    local boarsNeeded = BoarsToKill_CalculateBoars()
    local estimatedTime = boarsNeeded * 20
    local timePerBoar = 20
    if firstKillTime and killCount > 0 then
        local elapsed = now - firstKillTime
        timePerBoar = elapsed / killCount
        estimatedTime = boarsNeeded * timePerBoar
    end
    local boarLine = "|cffffcc00"..BoarsToKill_Loc.BOARS.."|r|cffffff00"..boarsNeeded.."|r"
    local xpLine = "|cff80ff80"..BoarsToKill_Loc.XP.."|r|cffffffff"..currentXP.."|r|cffaaaaaa/|r|cffffffff"..maxXP.."|r"
    local boarsKilledSessionLine = "|cffff8800Boars killed this session : |r|cffffff00"..sessionBoarsKilled.."|r"
    local boarsKilledTotalLine = "|cffff8800Total boars killed : |r|cffffff00"..(BoarsToKillDB.totalBoarsKilled or 0).."|r"
    local timeLine
    if lastXPChange > 0 then
        timeLine = "|cff80c0ff"..BoarsToKill_Loc.TIME.."|r|cffffffff"..BoarsToKill_FormatTime(estimatedTime).."|r |cffaaaaaa("..BoarsToKill_Loc.PER_BOAR..lastXPChange..")|r"
        BoarsToKillDB.firstKillTime = firstKillTime
        BoarsToKillDB.killCount = killCount
    else
        timeLine = "|cffff8888"..BoarsToKill_Loc.START.."|r"
        firstKillTime = nil
        killCount = 0
        BoarsToKillDB.firstKillTime = nil
        BoarsToKillDB.killCount = 0
    end
    local showStats = (sessionBoarsKilled > 0) or ((BoarsToKillDB.totalBoarsKilled or 0) > 0)
    if showStats then
        text:SetText(boarLine.."\n"..xpLine)
        timeText:SetText(timeLine.."\n"..boarsKilledSessionLine.."\n"..boarsKilledTotalLine)
    else
        text:SetText(boarLine.."\n"..xpLine)
        timeText:SetText(timeLine)
    end
    text:SetJustifyH("CENTER")
    text:SetJustifyV("TOP")
    text:SetShadowColor(0,0,0,1)
    text:SetShadowOffset(1,-1)
    timeText:SetJustifyH("CENTER")
    timeText:SetJustifyV("TOP")
    timeText:SetShadowColor(0,0,0,1)
    timeText:SetShadowOffset(1,-1)
    lastXP = currentXP
    BoarsToKillDB.lastXP = lastXP
    BoarsToKillDB.lastXPChange = lastXPChange
    BoarsToKillDB.totalBoarsKilled = BoarsToKillDB.totalBoarsKilled or 0
    BoarsToKillDB.firstKillTime = firstKillTime
    BoarsToKillDB.killCount = killCount
    local maxWidth = text:GetStringWidth()
    if timeText:GetStringWidth() > maxWidth then
        maxWidth = timeText:GetStringWidth()
    end

    local numLines, lineHeight
    if lastXPChange > 0 and showStats then
        numLines = 5    
        lineHeight = 18
    elseif lastXPChange > 0 then
        numLines = 3
        lineHeight = 18
    elseif showStats then
        numLines = 4
        lineHeight = 15
    else
        numLines = 3
        lineHeight = 15
    end
    local verticalPaddingBottom = 12
    local height = lineHeight + numLines * lineHeight + verticalPaddingBottom
    local fixedHeight = 110
    local width = math.max(180, maxWidth + 30)
    frame:SetWidth(width)
    frame:SetHeight(fixedHeight)

    text:ClearAllPoints()
    text:SetPoint("TOP", frame, "TOP", 0, -18)
    timeText:ClearAllPoints()
    timeText:SetPoint("TOP", text, "BOTTOM", 0, -5)
    lastLevel = currentLevel
end

function BoarsToKill_OnEvent(event, arg1)
    if event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" then
        BoarsToKill_UpdateDisplay()
    elseif event == "PLAYER_LOGOUT" then
        BoarsToKillDB.lastXP = lastXP
        BoarsToKillDB.lastXPChange = lastXPChange
    end
end

StaticPopupDialogs = StaticPopupDialogs or {}
StaticPopupDialogs["BOARSTOKILL_SETUP"] = {
    text = BoarsToKill_Loc.POPUP,
    button1 = BoarsToKill_Loc.POPUP_YES,
    button2 = BoarsToKill_Loc.POPUP_NO,
    OnAccept = function()
        BoarsToKillDB.active = true
        BoarsToKillFrame:Show()
        BoarsToKill_Active = true
        lastXP = UnitXP("player")
        BoarsToKill_JustLoaded = true
        BoarsToKill_UpdateDisplay()
    end,
    OnCancel = function()
        BoarsToKillDB.active = false
        BoarsToKillFrame:Hide()
        BoarsToKill_Active = false
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function BoarsToKill_Init()
    if BoarsToKillDB.active == nil then
        BoarsToKillFrame:Hide()
        StaticPopup_Show("BOARSTOKILL_SETUP")
    elseif BoarsToKillDB.active == true then
        BoarsToKillFrame:Show()
        BoarsToKill_Active = true
        BoarsToKill_UpdateDisplay()
    else
        BoarsToKillFrame:Hide()
        BoarsToKill_Active = false
    end
end

local BoarsToKillFrameInit = CreateFrame("Frame")
BoarsToKillFrameInit:RegisterEvent("VARIABLES_LOADED")
function BoarsToKillFrameInit_OnEvent()
    if event == "VARIABLES_LOADED" then
        if not BoarsToKillDB then BoarsToKillDB = {} end
        if BoarsToKillDB.totalBoarsKilled == nil then BoarsToKillDB.totalBoarsKilled = 0 end
        if BoarsToKillDB.lastXP == nil then BoarsToKillDB.lastXP = 0 end
        if BoarsToKillDB.lastXPChange == nil then BoarsToKillDB.lastXPChange = 0 end
        if BoarsToKillDB.firstKillTime == nil then BoarsToKillDB.firstKillTime = nil end
        if BoarsToKillDB.killCount == nil then BoarsToKillDB.killCount = 0 end
        BoarsToKill_Init()
    end
end
BoarsToKillFrameInit:SetScript("OnEvent", BoarsToKillFrameInit_OnEvent)

SLASH_BOARSTOKILL1 = "/btk"
SlashCmdList["BOARSTOKILL"] = function(msg)
    if msg == "setup" then
        StaticPopup_Show("BOARSTOKILL_SETUP")
    elseif msg == "debug" then
        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        DEFAULT_CHAT_FRAME:AddMessage("[BoarsToKill] Current XP : "..currentXP.."/"..maxXP)
        DEFAULT_CHAT_FRAME:AddMessage("[BoarsToKill] Total boars killed : "..(BoarsToKillDB.totalBoarsKilled or 0))
    else
        DEFAULT_CHAT_FRAME:AddMessage("[BoarsToKill] Commandes : /btk setup, /btk debug")
    end
end

function BoarsToKill_OnLoad()
    BoarsToKill_RestorePosition()
    if BoarsToKillDB.lastXP then lastXP = BoarsToKillDB.lastXP end
    if BoarsToKillDB.lastXPChange then lastXPChange = BoarsToKillDB.lastXPChange end
    if BoarsToKillDB.firstKillTime then firstKillTime = BoarsToKillDB.firstKillTime end
    if BoarsToKillDB.killCount then killCount = BoarsToKillDB.killCount end
    sessionBoarsKilled = 0
    lastLevel = UnitLevel("player")
    BoarsToKill_JustLoaded = true
    if BoarsToKill_Active then
        BoarsToKill_UpdateDisplay()
    end
end

function BoarsToKill_OnUpdate(elapsed)
    if not BoarsToKill_Active then return end
    local elapsed = elapsed or 0.1
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= updateInterval then
        BoarsToKill_UpdateDisplay()
        timeSinceLastUpdate = 0
    end
end

function BoarsToKill_SavePosition()
    local point, _, _, x, y = BoarsToKillFrame:GetPoint()
    BoarsToKillDB.pos = {point=point, x=x, y=y}
end

function BoarsToKill_RestorePosition()
    if BoarsToKillDB.pos then
        BoarsToKillFrame:ClearAllPoints()
        BoarsToKillFrame:SetPoint(BoarsToKillDB.pos.point, UIParent, BoarsToKillDB.pos.x, BoarsToKillDB.pos.y)
    end
end

local BoarsToKillFrame = CreateFrame("Frame", "BoarsToKillFrame", UIParent)
BoarsToKillFrame:SetFrameStrata("HIGH")
BoarsToKillFrame:SetMovable(true)
BoarsToKillFrame:EnableMouse(true)
BoarsToKillFrame:SetWidth(200)
BoarsToKillFrame:SetHeight(70)
BoarsToKillFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 10, -10)
BoarsToKillFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})

local BoarsToKillText = BoarsToKillFrame:CreateFontString("BoarsToKillText", "OVERLAY", "GameFontNormal")
BoarsToKillText:SetPoint("TOP", BoarsToKillFrame, "TOP", 0, -10)

local BoarsToKillTimeText = BoarsToKillFrame:CreateFontString("BoarsToKillTimeText", "OVERLAY", "GameFontNormal")
BoarsToKillTimeText:SetPoint("TOP", BoarsToKillText, "BOTTOM", 0, -5)

BoarsToKillFrame:SetScript("OnMouseDown", function()
    if arg1 == "LeftButton" then this:StartMoving() end
end)
BoarsToKillFrame:SetScript("OnMouseUp", function()
    this:StopMovingOrSizing()
    BoarsToKill_SavePosition()
end)
BoarsToKillFrame:SetScript("OnLoad", nil)
BoarsToKillFrame:SetScript("OnEvent", function()
    BoarsToKill_OnEvent(event)
end)
BoarsToKillFrame:SetScript("OnUpdate", function()
    BoarsToKill_OnUpdate(arg1)
end)
BoarsToKillFrame:RegisterEvent("PLAYER_XP_UPDATE")
BoarsToKillFrame:RegisterEvent("PLAYER_LEVEL_UP")
BoarsToKillFrame:RegisterEvent("PLAYER_LOGOUT")

lastXP = 0
lastXPChange = 0
firstKillTime = nil
killCount = 0
sessionBoarsKilled = 0

if BoarsToKillDB and type(BoarsToKillDB) == "table" then
    if BoarsToKillDB.lastXP then lastXP = BoarsToKillDB.lastXP end
    if BoarsToKillDB.lastXPChange then lastXPChange = BoarsToKillDB.lastXPChange end
    if BoarsToKillDB.firstKillTime then firstKillTime = BoarsToKillDB.firstKillTime end
    if BoarsToKillDB.killCount then killCount = BoarsToKillDB.killCount end
end

local BoarsToKill_EnteringWorldFrame = CreateFrame("Frame")
BoarsToKill_EnteringWorldFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
BoarsToKill_EnteringWorldFrame:SetScript("OnEvent", function()
    BoarsToKill_OnLoad()
end)

local fallback = {
    BOARS = "Boars left : ",
    XP = "Current XP : ",
    TIME = "Estimated time : ",
    PER_BOAR = "XP/boar : ",
    START = "Kill a boar to start",
    POPUP = "Enable Boaring Adventure tracking for this character?",
    POPUP_YES = "Yes",
    POPUP_NO = "No"
}
for k, v in pairs(fallback) do
    if not BoarsToKill_Loc[k] then BoarsToKill_Loc[k] = v end
end 