resource_manifest_version '679-996150c95a1d251a5c0c7841ab2f0276878334f7'
description 'Player Time Tracker'
server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'sv_playertime.lua'
}
client_scripts {
  'cl_playertime.lua'
}
