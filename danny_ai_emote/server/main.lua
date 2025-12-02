local playerAIEmotes = {}  -- [src] = { emoteTable, ... }

local function debugPrint(msg)
    print(('[danny_ai_emote] %s'):format(msg))
end

-- For now this is a simple in-memory store.
-- Later, this function will call your backend / DeepMotion pipeline.
local function getEmotesForPlayer(src, cb)
    -- Right now: return what we already have in memory for them.
    cb(playerAIEmotes[src] or {})
end

RegisterNetEvent('danny_ai_emote:requestEmotes', function()
    local src = source

    getEmotesForPlayer(src, function(emotes)
        playerAIEmotes[src] = emotes or {}
        TriggerClientEvent('danny_ai_emote:syncEmotes', src, playerAIEmotes[src])
        debugPrint(('Synced %d AI emotes to player %d'):format(#(playerAIEmotes[src]), src))
    end)
end)

-- Cleanup on disconnect
AddEventHandler('playerDropped', function()
    local src = source
    playerAIEmotes[src] = nil
end)

---------------------------------------------------------------------
-- ADMIN TEST COMMANDS (so you can SEE it working today)
-- These do NOT use DeepMotion yet. They just simulate a generated emote.
---------------------------------------------------------------------

-- /give_test_ai_emote [id]
-- Example: /give_test_ai_emote 1
RegisterCommand('give_test_ai_emote', function(source, args)
    local src = source
    if src == 0 then
        print('[danny_ai_emote] Use this command in-game as a player.')
        return
    end

    local testId = tonumber(args[1]) or 1

    -- This is a fake example emote using a base game anim.
    -- Once DeepMotion is wired, these will be replaced by actual generated anims.
    local newEmote = {
        -- This format matches how many DP / Scully emote tables look:
        -- { dict, anim, Label, AnimationOptions = { ... } }
        "anim@mp_player_intcelebrationmale@salute",
        "salute",
        ('AI Emote #%d (Demo)'), -- Label shown in menu
        AnimationOptions = {
            EmoteLoop = false,
            EmoteMoving = false,
        }
    }

    playerAIEmotes[src] = playerAIEmotes[src] or {}
    table.insert(playerAIEmotes[src], newEmote)

    TriggerClientEvent('danny_ai_emote:syncEmotes', src, playerAIEmotes[src])

    debugPrint(('Gave player %d test AI emote #%d'):format(src, testId))

    TriggerClientEvent('chat:addMessage', src, {
        color = { 0, 255, 0 },
        args = { '2ndHomeRP', ('You received a demo AI emote (ID %d). Check the "2ndHomeRP AI Emotes" tab!'):format(testId) }
    })
end, false)

---------------------------------------------------------------------
-- CREATE PLAYER-SPECIFIC UPLOAD URL – paste this AT THE BOTTOM
---------------------------------------------------------------------

local function getIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 7) == "license" then
            return id
        end
    end
    return "unknown"
end

RegisterNetEvent('danny_ai_emote:requestUploadUrl', function()
    local src = source
    local identifier = getIdentifier(src)

    -- CHANGE THIS to your actual backend domain later
    local baseUrl = 'https://your-backend-domain.com'

    local url = string.format('%s/upload?license=%s', baseUrl, identifier)

    TriggerClientEvent('danny_ai_emote:sendUploadUrl', src, url)
end)
