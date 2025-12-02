local aiEmotes = {}  -- local cache for this player

local function debugPrint(msg)
    print(('[danny_ai_emote] %s'):format(msg))
end

-- Create AI Emote section in Scully's menu
local function createAISection()
    local option = {
        Label = Config.AISectionLabel,   -- "2ndHomeRP AI Emotes"
        Key   = Config.AISectionKey,     -- "ai_emotes"
        Icon  = 'fa-solid fa-robot',     -- will be ignored if Scully doesn’t use icons, harmless
    }

    local ok = pcall(function()
        if exports['scully_emotemenu'] and exports['scully_emotemenu'].addEmoteMenuOption then
            exports['scully_emotemenu']:addEmoteMenuOption(option)
        else
            -- Fallback to event, in case export name changes
            TriggerEvent('scully_emotemenu:addEmoteMenuOption', option)
        end
    end)

    if ok then
        debugPrint('AI Emote section created: ' .. Config.AISectionLabel)
    else
        debugPrint('Failed to add AI Emote section (export not found?)')
    end
end

-- Apply current AI emotes into that section
local function applyAIEmotes()
    if not next(aiEmotes) then
        debugPrint('No AI emotes to apply yet.')
        return
    end

    local ok = pcall(function()
        if exports['scully_emotemenu'] and exports['scully_emotemenu'].addEmotesToMenu then
            exports['scully_emotemenu']:addEmotesToMenu(Config.AISectionKey, aiEmotes)
        else
            TriggerEvent('scully_emotemenu:addEmotesToMenu', Config.AISectionKey, aiEmotes)
        end
    end)

    if ok then
        debugPrint(('Applied %d AI emotes to section "%s"'):format(#(aiEmotes), Config.AISectionKey))
    else
        debugPrint('Failed to apply AI emotes to menu.')
    end
end

-- Receive emotes from server
RegisterNetEvent('danny_ai_emote:syncEmotes', function(emoteList)
    aiEmotes = emoteList or {}
    applyAIEmotes()
end)

-- Small helper: show branding in chat when player wants
RegisterCommand('aiemote_info', function()
    TriggerEvent('chat:addMessage', {
        color = { 255, 215, 0 },
        multiline = true,
        args = {
            '2ndHomeRP',
            ('^6%s^7\n^5%s^7'):format(Config.BrandingTitle, Config.BrandingFooter)
        }
    })
end, false)

-- On client start, set everything up
CreateThread(function()
    -- Give Scully's menu a moment to boot
    Wait(5000)

    createAISection()

    -- Ask the server for AI emotes for this player
    TriggerServerEvent('danny_ai_emote:requestEmotes')

    -- Optional: remind player of branding & DeepMotion
    debugPrint(Config.BrandingTitle .. ' - ' .. Config.BrandingFooter)
end)

---------------------------------------------------------------------
-- QR UI SYSTEM – paste this AT THE BOTTOM OF main.lua
---------------------------------------------------------------------

local uiOpen = false

local function openQR(url)
    if uiOpen then return end
    uiOpen = true

    SetNuiFocus(true, true)

    SendNUIMessage({
        type = 'show',
        url = url
    })
end

local function closeQR()
    uiOpen = false
    SetNuiFocus(false, false)

    SendNUIMessage({
        type = 'hide'
    })
end

RegisterNUICallback('close', function(_, cb)
    closeQR()
    cb({})
end)

-- Command to open the QR upload link
RegisterCommand('aiemote_qr', function()
    TriggerServerEvent('danny_ai_emote:requestUploadUrl')
end, false)

-- Server sends back URL for this player
RegisterNetEvent('danny_ai_emote:sendUploadUrl', function(url)
    if not url or url == '' then
        print('[danny_ai_emote] No upload URL received from server.')
        return
    end

    openQR(url)
end)
