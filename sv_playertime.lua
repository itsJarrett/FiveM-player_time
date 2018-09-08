local playerTimes = {}
local waitTime = 60000 -- We wait this amount in milliseconds until we check their time, (some people like to drop their connection A LOT).

Citizen.CreateThread(function()
  AddEventHandler('playerConnecting', function(playerName)
    local _source = source
    local steamID = GetPlayerIdentifier(source ,0)
    steamID = steamID:gsub('steam:', '')
    local joinTime = os.time()
    Citizen.Wait(waitTime)
    table.insert(playerTimes, {steamID, joinTime})
  end)
end)

Citizen.CreateThread(function()
  AddEventHandler('playerDropped', function(playerName)
    local _source = source
    local steamID = GetPlayerIdentifier(source ,0)
    steamID = steamID:gsub('steam:', '')
    local dropTime = os.time()
    for _, playerTime in pairs(playerTimes) do
      if playerTime[1] == steamID then
        local totalTime = dropTime - playerTime[2]
        MySQL.Sync.execute('UPDATE player SET playtime=@totalTime WHERE steamhex=@steamID', {['@steamID'] = steamID, ['@totalTime'] = totalTime})
      end
    end
  end)
end)
