-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'https://github.com/LexTheGreat/TrainSportation'
description 'Drive trains!'
version '1.0.0'

-- What to run
client_scripts {
	'config.lua',
	'client/client.lua'
}

server_scripts {
    'config.lua',
	'server/server.lua'
}

export 'CreateTrain'