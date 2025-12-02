fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'danny_ai_emote'
author 'Danny / 2ndHomeRP'
description '2ndHomeRP AI Emote menu powered by DeepMotion'

dependencies {
    'scully_emotemenu'
}

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'web/ui.html'

files {
    'web/ui.html',
    'web/ui.js',
    'web/ui.css'
}
