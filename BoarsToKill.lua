-- Global variables
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

-- SavedVariables management
if BoarsToKillDB == nil then
    BoarsToKillDB = {}
end
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

-- Variables de session
local firstKillTime = BoarsToKillDB.firstKillTime
local killCount = BoarsToKillDB.killCount

-- Variable locale pour le nombre de sangliers tués dans la session
local sessionBoarsKilled = 0

-- Table de traductions
local L = {}
local locale = GetLocale()
if locale == "frFR" then
    L.BOARS = "Sangliers restants : "
    L.XP = "XP actuelle : "
    L.TIME = "Temps estimé : "
    L.PER_BOAR = "XP/sanglier : "
    L.START = "Tuez un sanglier pour commencer"
elseif locale == "deDE" then
    L.BOARS = "Verbleibende Eber : "
    L.XP = "Aktuelle EP : "
    L.TIME = "Geschätzte Zeit : "
    L.PER_BOAR = "EP/Eber : "
    L.START = "Töte ein Eber, um zu beginnen"
elseif locale == "esES" or locale == "esMX" then
    L.BOARS = "Jabalíes restantes : "
    L.XP = "XP actual : "
    L.TIME = "Tiempo estimado : "
    L.PER_BOAR = "XP/jabalí : "
    L.START = "Mata un jabalí para empezar"
elseif locale == "zhCN" or locale == "zhTW" then
    L.BOARS = "剩余野猪："
    L.XP = "当前经验："
    L.TIME = "预计时间："
    L.PER_BOAR = "每只野猪经验："
    L.START = "击杀一只野猪以开始"
elseif locale == "ptBR" then
    L.BOARS = "Javalis restantes : "
    L.XP = "XP atual : "
    L.TIME = "Tempo estimado : "
    L.PER_BOAR = "XP/javali : "
    L.START = "Mate um javali para começar"
elseif locale == "itIT" then
    L.BOARS = "Cinghiali restanti : "
    L.XP = "XP attuale : "
    L.TIME = "Tempo stimato : "
    L.PER_BOAR = "XP/cinghiale : "
    L.START = "Uccidi un cinghiale per iniziare"
elseif locale == "ruRU" then
    L.BOARS = "Осталось кабанов : "
    L.XP = "Текущий опыт : "
    L.TIME = "Оценочное время : "
    L.PER_BOAR = "Опыта/кабан : "
    L.START = "Убей кабана, чтобы начать"
else
    L.BOARS = "Boars left : "
    L.XP = "Current XP : "
    L.TIME = "Estimated time : "
    L.PER_BOAR = "XP/boar : "
    L.START = "Kill a boar to start"
end

-- Function to format time as h/m/s
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

-- Function to calculate boars left
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

-- Fonction pour mettre à jour l'affichage
function BoarsToKill_UpdateDisplay()
    local text = getglobal("BoarsToKillText")
    local timeText = getglobal("BoarsToKillTimeText")
    local frame = getglobal("BoarsToKillFrame")
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local remainingXP = maxXP - currentXP
    local now = GetTime()
    if lastXP > 0 and currentXP > lastXP then
        lastXPChange = currentXP - lastXP
        if not firstKillTime then
            firstKillTime = now
            killCount = 1
        else
            killCount = killCount + 1
        end
        -- Récupère la valeur actuelle avant d'incrémenter
        BoarsToKillDB.totalBoarsKilled = (BoarsToKillDB.totalBoarsKilled or 0) + 1
        sessionBoarsKilled = sessionBoarsKilled + 1
    end
    local boarsNeeded = BoarsToKill_CalculateBoars()
    -- Calcul dynamique du temps moyen par sanglier
    local estimatedTime = boarsNeeded * 20 -- valeur par défaut
    local timePerBoar = 20
    if firstKillTime and killCount > 0 then
        local elapsed = now - firstKillTime
        timePerBoar = elapsed / killCount
        estimatedTime = boarsNeeded * timePerBoar
    end
    -- Mise en forme moderne et colorée avec traduction
    local boarLine = "|cffffcc00"..L.BOARS.."|r|cffffff00"..boarsNeeded.."|r"
    local xpLine = "|cff80ff80"..L.XP.."|r|cffffffff"..currentXP.."|r|cffaaaaaa/|r|cffffffff"..maxXP.."|r"
    local boarsKilledSessionLine = "|cffff8800Boars killed this session : |r|cffffff00"..sessionBoarsKilled.."|r"
    local boarsKilledTotalLine = "|cffff8800Total boars killed : |r|cffffff00"..(BoarsToKillDB.totalBoarsKilled or 0).."|r"
    local timeLine
    if lastXPChange > 0 then
        timeLine = "|cff80c0ff"..L.TIME.."|r|cffffffff"..BoarsToKill_FormatTime(estimatedTime).."|r |cffaaaaaa("..L.PER_BOAR..lastXPChange..")|r"
        BoarsToKillDB.firstKillTime = firstKillTime
        BoarsToKillDB.killCount = killCount
    else
        timeLine = "|cffff8888"..L.START.."|r"
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
    -- Centrage et ombre
    text:SetJustifyH("CENTER")
    text:SetJustifyV("TOP")
    text:SetShadowColor(0,0,0,1)
    text:SetShadowOffset(1,-1)
    timeText:SetJustifyH("CENTER")
    timeText:SetJustifyV("TOP")
    timeText:SetShadowColor(0,0,0,1)
    timeText:SetShadowOffset(1,-1)
    lastXP = currentXP
    -- Sauvegarde à chaque update
    BoarsToKillDB.lastXP = lastXP
    BoarsToKillDB.lastXPChange = lastXPChange
    -- Mesure la largeur réelle de chaque ligne
    local maxWidth = text:GetStringWidth()
    if timeText:GetStringWidth() > maxWidth then
        maxWidth = timeText:GetStringWidth()
    end

    -- Calcul dynamique du nombre de lignes et de l'espacement
    local numLines, lineHeight
    if lastXPChange > 0 and showStats then
        numLines = 5 -- boarLine, xpLine, timeLine, session, total
        lineHeight = 18
    elseif lastXPChange > 0 then
        numLines = 3 -- boarLine, xpLine, timeLine
        lineHeight = 18
    elseif showStats then
        numLines = 4 -- boarLine, xpLine, message rouge, session, total
        lineHeight = 15
    else
        numLines = 3 -- boarLine, xpLine, message rouge
        lineHeight = 15
    end
    local height = lineHeight + numLines * lineHeight
    local width = math.max(180, maxWidth + 30)
    frame:SetWidth(width)
    frame:SetHeight(height)

    -- Centre verticalement le texte
    text:ClearAllPoints()
    text:SetPoint("TOP", frame, "TOP", 0, -18)
    timeText:ClearAllPoints()
    timeText:SetPoint("TOP", text, "BOTTOM", 0, -5)
end

-- Gestionnaire d'événements
function BoarsToKill_OnEvent()
    if event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" then
        BoarsToKill_UpdateDisplay()
    elseif event == "PLAYER_LOGOUT" then
        -- Sauvegarde à la déconnexion
        BoarsToKillDB.lastXP = lastXP
        BoarsToKillDB.lastXPChange = lastXPChange
    end
end

-- Initialisation
function BoarsToKill_OnLoad()
    -- Restauration des variables sauvegardées
    if BoarsToKillDB.lastXP then lastXP = BoarsToKillDB.lastXP end
    if BoarsToKillDB.lastXPChange then lastXPChange = BoarsToKillDB.lastXPChange end
    if BoarsToKillDB.firstKillTime then firstKillTime = BoarsToKillDB.firstKillTime end
    if BoarsToKillDB.killCount then killCount = BoarsToKillDB.killCount end
    sessionBoarsKilled = 0 -- reset session à chaque /reload ou déco
    BoarsToKill_UpdateDisplay()
end

function BoarsToKill_OnUpdate(elapsed)
    local elapsed = elapsed or 0.1
    timeSinceLastUpdate = timeSinceLastUpdate + elapsed
    if timeSinceLastUpdate >= updateInterval then
        BoarsToKill_UpdateDisplay()
        timeSinceLastUpdate = 0
    end
end

-- Affichage debug du total de sangliers tués
SLASH_BOARSTOKILL1 = "/boarsleft"
SlashCmdList["BOARSTOKILL"] = function(msg)
    if msg == "debug" then
        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        DEFAULT_CHAT_FRAME:AddMessage("[BoarsToKill] Current XP : "..currentXP.."/"..maxXP)
        DEFAULT_CHAT_FRAME:AddMessage("[BoarsToKill] Total boars killed : "..(BoarsToKillDB.totalBoarsKilled or 0))
    else
        DEFAULT_CHAT_FRAME:AddMessage("[BoarsToKill] Commands : /boarsleft debug")
    end
end 