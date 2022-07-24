fx_version 'bodacious'

game 'gta5'

description 'AX-Jobs - Job Framework'

lua54 'true'

author 'Haroki'

server_scripts {
    'server/*.lua'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua'
}