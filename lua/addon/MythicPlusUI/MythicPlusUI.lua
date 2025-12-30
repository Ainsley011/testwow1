--[[
    Mythic+ UI Client Addon

    Displays a progress frame during Mythic+ dungeon runs showing:
    - Dungeon name and key level
    - Timer with countdown
    - Boss progress (X/Y killed)
    - Active affixes

    Install: Copy MythicPlusUI folder to Interface/AddOns/
]]

local ADDON_PREFIX = "MythicPlus"
local addon = CreateFrame("Frame", "MythicPlusUI", UIParent)

-- Saved variables
MythicPlusDB = MythicPlusDB or {
    locked = false,
    scale = 1.0,
    alpha = 0.9,
}

-- Current run data
local currentRun = {
    active = false,
    dungeonName = "",
    mythicLevel = 0,
    timerSeconds = 0,
    totalBosses = 0,
    bossesKilled = 0,
    startTime = 0,
    elapsed = 0,
    affixes = "",
    complete = false,
    inTime = false,
}

-- Colors
local COLORS = {
    gold = {1, 0.82, 0},
    green = {0, 1, 0},
    red = {1, 0, 0},
    white = {1, 1, 1},
    gray = {0.5, 0.5, 0.5},
    blue = {0.3, 0.6, 1},
}

-- Affix colors
local AFFIX_COLORS = {
    ["Fortified"] = "|cff00ff00",
    ["Tyrannical"] = "|cffff0000",
    ["Bolstering"] = "|cffff8000",
    ["Raging"] = "|cffff4400",
    ["Sanguine"] = "|cff880000",
    ["Bursting"] = "|cff8800ff",
    ["Necrotic"] = "|cff00cc00",
    ["Explosive"] = "|cffff6600",
    ["Quaking"] = "|cff6666ff",
    ["Volcanic"] = "|cffff3300",
    ["Grievous"] = "|cff990099",
}

-------------------------------------------------
-- Create the main frame
-------------------------------------------------
local MainFrame = CreateFrame("Frame", "MythicPlusMainFrame", UIParent)
MainFrame:SetSize(280, 120)
MainFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
MainFrame:SetMovable(true)
MainFrame:EnableMouse(true)
MainFrame:RegisterForDrag("LeftButton")
MainFrame:SetScript("OnDragStart", function(self)
    if not MythicPlusDB.locked then
        self:StartMoving()
    end
end)
MainFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)
MainFrame:Hide()

-- Background
local bg = MainFrame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture(0, 0, 0, 0.7)

-- Border
local border = CreateFrame("Frame", nil, MainFrame, "BackdropTemplate")
border:SetAllPoints()
border:SetBackdrop({
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4},
})
border:SetBackdropBorderColor(1, 0.82, 0, 1) -- Gold border

-- Header: Dungeon Name + Level
local headerText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
headerText:SetPoint("TOP", MainFrame, "TOP", 0, -8)
headerText:SetTextColor(1, 0.82, 0) -- Gold
headerText:SetText("Mythic+ Dungeon")

-- Timer display
local timerFrame = CreateFrame("Frame", nil, MainFrame)
timerFrame:SetSize(260, 30)
timerFrame:SetPoint("TOP", headerText, "BOTTOM", 0, -5)

local timerText = timerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
timerText:SetPoint("CENTER")
timerText:SetTextColor(0, 1, 0) -- Green
timerText:SetText("00:00 / 00:00")

-- Boss progress bar background
local bossBarBG = MainFrame:CreateTexture(nil, "ARTWORK")
bossBarBG:SetSize(240, 20)
bossBarBG:SetPoint("TOP", timerFrame, "BOTTOM", 0, -5)
bossBarBG:SetTexture(0.2, 0.2, 0.2, 1)

-- Boss progress bar fill
local bossBarFill = MainFrame:CreateTexture(nil, "OVERLAY")
bossBarFill:SetSize(0, 18)
bossBarFill:SetPoint("LEFT", bossBarBG, "LEFT", 1, 0)
bossBarFill:SetTexture(0.3, 0.6, 1, 1) -- Blue

-- Boss progress text
local bossText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
bossText:SetPoint("CENTER", bossBarBG, "CENTER")
bossText:SetTextColor(1, 1, 1)
bossText:SetText("Bosses: 0 / 0")

-- Affix display
local affixText = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
affixText:SetPoint("TOP", bossBarBG, "BOTTOM", 0, -5)
affixText:SetTextColor(0.8, 0.8, 0.8)
affixText:SetText("Affixes: None")

-- Completion overlay
local completeFrame = CreateFrame("Frame", nil, MainFrame)
completeFrame:SetAllPoints()
completeFrame:Hide()

local completeBG = completeFrame:CreateTexture(nil, "OVERLAY")
completeBG:SetAllPoints()
completeBG:SetTexture(0, 0, 0, 0.8)

local completeText = completeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
completeText:SetPoint("CENTER")
completeText:SetText("|cff00ff00COMPLETED!|r")

-------------------------------------------------
-- Helper functions
-------------------------------------------------
local function FormatTime(seconds)
    local mins = math.floor(seconds / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d", mins, secs)
end

local function FormatAffixes(affixString)
    if not affixString or affixString == "" then
        return "None"
    end

    local result = ""
    for affix in affixString:gmatch("[^,]+") do
        affix = affix:match("^%s*(.-)%s*$") -- Trim whitespace
        local color = AFFIX_COLORS[affix] or "|cffffffff"
        if result ~= "" then
            result = result .. " "
        end
        result = result .. color .. affix .. "|r"
    end
    return result
end

local function UpdateDisplay()
    if not currentRun.active then
        MainFrame:Hide()
        return
    end

    MainFrame:Show()

    -- Header
    headerText:SetText(string.format("|cffff8000%s +%d|r", currentRun.dungeonName, currentRun.mythicLevel))

    -- Timer
    local remaining = currentRun.timerSeconds - currentRun.elapsed
    local timerStr

    if remaining >= 0 then
        timerStr = FormatTime(currentRun.elapsed) .. " / " .. FormatTime(currentRun.timerSeconds)
        timerText:SetTextColor(0, 1, 0) -- Green
    else
        timerStr = FormatTime(currentRun.elapsed) .. " |cffff0000+" .. FormatTime(-remaining) .. "|r"
        timerText:SetTextColor(1, 0, 0) -- Red
    end
    timerText:SetText(timerStr)

    -- Boss progress
    bossText:SetText(string.format("Bosses: %d / %d", currentRun.bossesKilled, currentRun.totalBosses))

    -- Update progress bar
    local progress = 0
    if currentRun.totalBosses > 0 then
        progress = currentRun.bossesKilled / currentRun.totalBosses
    end
    local barWidth = 238 * progress
    bossBarFill:SetWidth(math.max(1, barWidth))

    -- Change bar color based on progress
    if progress >= 1 then
        bossBarFill:SetTexture(0, 1, 0, 1) -- Green when complete
    elseif progress >= 0.5 then
        bossBarFill:SetTexture(1, 0.82, 0, 1) -- Gold at 50%+
    else
        bossBarFill:SetTexture(0.3, 0.6, 1, 1) -- Blue
    end

    -- Affixes
    affixText:SetText("Affixes: " .. FormatAffixes(currentRun.affixes))

    -- Completion state
    if currentRun.complete then
        completeFrame:Show()
        if currentRun.inTime then
            completeText:SetText("|cff00ff00COMPLETED IN TIME!|r")
        else
            completeText:SetText("|cffff8000COMPLETED (Overtime)|r")
        end
    else
        completeFrame:Hide()
    end
end

-------------------------------------------------
-- Message handlers
-------------------------------------------------
local function HandleAddonMessage(prefix, message, channel, sender)
    if prefix ~= ADDON_PREFIX then return end

    local msgType, data = message:match("^(%w+):(.*)$")
    if not msgType then return end

    if msgType == "INIT" then
        -- Parse: dungeonName|mythicLevel|timerSeconds|totalBosses|bossesKilled|affixes
        local name, level, timer, total, killed, affixes = data:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)|?(.*)")
        if name then
            currentRun.active = true
            currentRun.dungeonName = name
            currentRun.mythicLevel = tonumber(level) or 0
            currentRun.timerSeconds = tonumber(timer) or 1800
            currentRun.totalBosses = tonumber(total) or 1
            currentRun.bossesKilled = tonumber(killed) or 0
            currentRun.affixes = affixes or ""
            currentRun.complete = false
            currentRun.elapsed = 0

            UpdateDisplay()
            print("|cffff8000[Mythic+]|r " .. name .. " +" .. level .. " started!")
        end

    elseif msgType == "START" then
        currentRun.startTime = tonumber(data) or GetServerTime()

    elseif msgType == "TIME" then
        currentRun.elapsed = tonumber(data) or 0
        UpdateDisplay()

    elseif msgType == "BOSS" then
        -- Parse: bossesKilled|totalBosses|bossName
        local killed, total, bossName = data:match("([^|]+)|([^|]+)|?(.*)")
        if killed then
            currentRun.bossesKilled = tonumber(killed) or currentRun.bossesKilled
            currentRun.totalBosses = tonumber(total) or currentRun.totalBosses
            bossName = bossName or "Boss"

            UpdateDisplay()

            -- Flash effect
            UIFrameFlash(bossBarFill, 0.2, 0.2, 0.6, true, 0, 0)

            -- Play sound
            PlaySound(8459) -- RAID_BOSS_EMOTE

            print(string.format("|cffff8000[Mythic+]|r |cff00ff00%s defeated!|r Progress: %d/%d",
                bossName, currentRun.bossesKilled, currentRun.totalBosses))
        end

    elseif msgType == "COMPLETE" then
        currentRun.complete = true
        currentRun.inTime = data == "1"
        UpdateDisplay()

        -- Play victory sound
        if currentRun.inTime then
            PlaySound(8455) -- LEVEL_UP
        else
            PlaySound(8192) -- Ready check
        end

    elseif msgType == "LEAVE" or msgType == "END" then
        -- Hide after a delay
        C_Timer.After(5, function()
            if not currentRun.complete then
                currentRun.active = false
                MainFrame:Hide()
            end
        end)
    end
end

-------------------------------------------------
-- Slash commands
-------------------------------------------------
SLASH_MYTHICPLUS1 = "/mythicplus"
SLASH_MYTHICPLUS2 = "/mplus"
SlashCmdList["MYTHICPLUS"] = function(msg)
    local cmd = msg:lower():match("^(%S+)")

    if cmd == "lock" then
        MythicPlusDB.locked = true
        print("|cffff8000[Mythic+]|r Frame locked.")
    elseif cmd == "unlock" then
        MythicPlusDB.locked = false
        print("|cffff8000[Mythic+]|r Frame unlocked. Drag to move.")
    elseif cmd == "scale" then
        local scale = tonumber(msg:match("scale%s+(%S+)"))
        if scale and scale >= 0.5 and scale <= 2.0 then
            MythicPlusDB.scale = scale
            MainFrame:SetScale(scale)
            print("|cffff8000[Mythic+]|r Scale set to " .. scale)
        else
            print("|cffff8000[Mythic+]|r Usage: /mplus scale 0.5-2.0")
        end
    elseif cmd == "reset" then
        MainFrame:ClearAllPoints()
        MainFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
        print("|cffff8000[Mythic+]|r Frame position reset.")
    elseif cmd == "test" then
        -- Test mode
        currentRun = {
            active = true,
            dungeonName = "The Nexus",
            mythicLevel = 15,
            timerSeconds = 1800, -- 30 minutes
            totalBosses = 4,
            bossesKilled = 2,
            startTime = GetServerTime() - 600,
            elapsed = 600,
            affixes = "Fortified,Bolstering,Quaking",
            complete = false,
            inTime = false,
        }
        UpdateDisplay()
        print("|cffff8000[Mythic+]|r Test mode activated.")
    elseif cmd == "hide" then
        currentRun.active = false
        MainFrame:Hide()
        print("|cffff8000[Mythic+]|r Frame hidden.")
    else
        print("|cffff8000[Mythic+ UI Commands]|r")
        print("  /mplus lock - Lock frame position")
        print("  /mplus unlock - Unlock frame for moving")
        print("  /mplus scale <0.5-2.0> - Set frame scale")
        print("  /mplus reset - Reset frame position")
        print("  /mplus test - Show test display")
        print("  /mplus hide - Hide the frame")
    end
end

-------------------------------------------------
-- Event handling
-------------------------------------------------
addon:RegisterEvent("CHAT_MSG_ADDON")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_LOGIN")

addon:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        HandleAddonMessage(...)
    elseif event == "PLAYER_LOGIN" then
        -- Apply saved settings
        MainFrame:SetScale(MythicPlusDB.scale or 1.0)
        MainFrame:SetAlpha(MythicPlusDB.alpha or 0.9)

        -- Register prefix (WotLK 3.3.5 method)
        if RegisterAddonMessagePrefix then
            RegisterAddonMessagePrefix(ADDON_PREFIX)
        end

        print("|cffff8000[Mythic+ UI]|r Loaded! Type /mplus for commands.")
    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Hide frame when entering non-dungeon zones
        local _, instanceType = IsInInstance()
        if instanceType ~= "party" and instanceType ~= "raid" then
            if not currentRun.complete then
                currentRun.active = false
                MainFrame:Hide()
            end
        end
    end
end)

-- Timer for updating elapsed time locally (smoother updates)
local updateTimer = 0
addon:SetScript("OnUpdate", function(self, elapsed)
    if not currentRun.active then return end

    updateTimer = updateTimer + elapsed
    if updateTimer >= 1 then
        updateTimer = 0
        -- Increment elapsed locally for smooth countdown
        if not currentRun.complete then
            currentRun.elapsed = currentRun.elapsed + 1
            UpdateDisplay()
        end
    end
end)

print("|cffff8000[Mythic+ UI]|r Addon initialized.")
