--[[
    Mythic+ GUI - Server-Side Eluna Script

    This script sends mythic+ progress data to clients via addon messages.
    Place this file in your server's lua_scripts folder.

    Requires: Eluna (https://github.com/ElunaLuaEngine/Eluna)
]]

local ADDON_PREFIX = "MythicPlus"

-- Store active mythic instances
local MythicInstances = {}

-- Register the addon prefix
RegisterServerEvent(14, function(event) -- ELUNA_EVENT_ON_OPEN_STATE_CHANGE
    RegisterAddonMessagePrefix(ADDON_PREFIX)
end)

-- Helper: Send addon message to player
local function SendMythicData(player, msgType, data)
    local message = msgType .. ":" .. data
    player:SendAddonMessage(ADDON_PREFIX, message, 0, player) -- 0 = CHAT_MSG_ADDON
end

-- Helper: Send to all players in instance
local function SendToInstance(instanceId, msgType, data)
    local instance = MythicInstances[instanceId]
    if not instance then return end

    for guid, _ in pairs(instance.players) do
        local player = GetPlayerByGUID(guid)
        if player then
            SendMythicData(player, msgType, data)
        end
    end
end

-- Register a new mythic instance
function RegisterMythicInstance(instanceId, dungeonName, mythicLevel, timerMinutes, totalBosses, affixes)
    MythicInstances[instanceId] = {
        dungeonName = dungeonName,
        mythicLevel = mythicLevel,
        timerSeconds = timerMinutes * 60,
        totalBosses = totalBosses,
        bossesKilled = 0,
        startTime = os.time(),
        affixes = affixes or "",
        players = {},
        active = true
    }
end

-- Add player to mythic instance
function AddPlayerToMythicInstance(player, instanceId)
    local instance = MythicInstances[instanceId]
    if not instance then return end

    instance.players[player:GetGUID()] = true

    -- Send initial data to player
    local data = string.format("%s|%d|%d|%d|%d|%s",
        instance.dungeonName,
        instance.mythicLevel,
        instance.timerSeconds,
        instance.totalBosses,
        instance.bossesKilled,
        instance.affixes
    )
    SendMythicData(player, "INIT", data)

    -- Send start time
    SendMythicData(player, "START", tostring(instance.startTime))
end

-- Record boss kill
function RecordMythicBossKill(instanceId, bossName)
    local instance = MythicInstances[instanceId]
    if not instance then return end

    instance.bossesKilled = instance.bossesKilled + 1

    local data = string.format("%d|%d|%s",
        instance.bossesKilled,
        instance.totalBosses,
        bossName or "Boss"
    )
    SendToInstance(instanceId, "BOSS", data)

    -- Check if complete
    if instance.bossesKilled >= instance.totalBosses then
        local elapsed = os.time() - instance.startTime
        local inTime = elapsed <= instance.timerSeconds
        SendToInstance(instanceId, "COMPLETE", inTime and "1" or "0")
    end
end

-- End mythic run
function EndMythicInstance(instanceId)
    local instance = MythicInstances[instanceId]
    if not instance then return end

    SendToInstance(instanceId, "END", "")
    instance.active = false

    -- Cleanup after delay
    CreateLuaEvent(function()
        MythicInstances[instanceId] = nil
    end, 5000, 1)
end

-- Player enters dungeon map
local function OnPlayerEnterMap(event, player, newMap, oldMap)
    -- Check if entering a dungeon
    if not newMap:IsDungeon() then return end

    local instanceId = player:GetInstanceId()
    local instance = MythicInstances[instanceId]

    if instance and instance.active then
        AddPlayerToMythicInstance(player, instanceId)
    end
end

-- Player leaves map
local function OnPlayerLeaveMap(event, player, newMap, oldMap)
    if not oldMap:IsDungeon() then return end

    local instanceId = player:GetInstanceId()
    local instance = MythicInstances[instanceId]

    if instance then
        instance.players[player:GetGUID()] = nil
        SendMythicData(player, "LEAVE", "")
    end
end

-- Creature dies (for boss tracking)
local function OnCreatureDeath(event, creature, killer)
    if not creature:IsDungeonBoss() then return end

    local map = creature:GetMap()
    if not map or not map:IsDungeon() then return end

    local instanceId = creature:GetInstanceId()
    if MythicInstances[instanceId] then
        RecordMythicBossKill(instanceId, creature:GetName())
    end
end

-- Periodic timer update (every 1 second)
local function UpdateTimers()
    for instanceId, instance in pairs(MythicInstances) do
        if instance.active then
            local elapsed = os.time() - instance.startTime
            SendToInstance(instanceId, "TIME", tostring(elapsed))
        end
    end
end

-- Register events
RegisterPlayerEvent(28, OnPlayerEnterMap)   -- PLAYER_EVENT_ON_MAP_CHANGE
RegisterPlayerEvent(28, OnPlayerLeaveMap)   -- Same event, checks old vs new
RegisterCreatureEvent(0, 4, OnCreatureDeath) -- CREATURE_EVENT_ON_JUST_DIED (0 = all creatures)

-- Start timer update loop
CreateLuaEvent(UpdateTimers, 1000, 0) -- Every 1 second, forever

-- Command to manually start a mythic run (for testing or NPC integration)
local function MythicStartCommand(event, player, command)
    if command:sub(1, 12) ~= "mythicstart " then return end

    local args = command:sub(13)
    local dungeonName, level, timer, bosses = args:match("(%S+)%s+(%d+)%s+(%d+)%s+(%d+)")

    if not dungeonName then
        player:SendBroadcastMessage("Usage: .mythicstart <dungeonName> <level> <timerMinutes> <bossCount>")
        return false
    end

    local instanceId = player:GetInstanceId()
    RegisterMythicInstance(instanceId, dungeonName, tonumber(level), tonumber(timer), tonumber(bosses), "Fortified")
    AddPlayerToMythicInstance(player, instanceId)

    player:SendBroadcastMessage("Mythic+ " .. dungeonName .. " +" .. level .. " started!")
    return false
end

RegisterPlayerEvent(42, MythicStartCommand) -- PLAYER_EVENT_ON_COMMAND

print("[Eluna] Mythic+ GUI Server Script loaded!")
