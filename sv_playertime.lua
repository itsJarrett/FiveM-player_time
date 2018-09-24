local playerTimes = {}
local waitTime = 120000 -- We wait this amount in milliseconds until we check their time, (some people like to drop their connection A LOT).
local waitTimeSeconds = waitTime * .001
local SAST, BCSO, LSPD, FIRE, CIV = 5, 4, 3, 2, 1

function inPlayerTimes(steamID)
  for i, playerTime in pairs(playerTimes) do
    if playerTime[1] == steamID then
      return true
    end
  end
  return false
end

function clockTime(steamID, endTime)
  for i, playerTime in pairs(playerTimes) do
    if playerTime[1] == steamID then
      MySQL.Sync.execute('INSERT INTO main_timeclock (steamhex, timein, timeout, deptflag) VALUES (@steamID, @timein, @timeout, @deptflag)',
      {['@steamID'] = steamID, ['@timein'] = playerTime[2], ['@timeout'] = endTime, ['@deptflag'] = playerTime[3]})
      playerTimes[i] = nil
    end
  end
end

Citizen.CreateThread(function()
  RegisterServerEvent("playerTimeStart")
  AddEventHandler("playerTimeStart", function(role)
    local currTime = os.time()
    local _source = source
    local steamID = GetPlayerIdentifier(source, 0)
    steamID = steamID:gsub('steam:', '')
    if not inPlayerTimes(steamID) then
      table.insert(playerTimes, {steamID, currTime, role})
    else
      clockTime(steamID, currTime)
      table.insert(playerTimes, {steamID, currTime, role})
    end
  end)
end)

Citizen.CreateThread(function()
  AddEventHandler('playerDropped', function(playerName)
    local _source = source
    local steamID = GetPlayerIdentifier(source, 0)
    steamID = steamID:gsub('steam:', '')
    local dropTime = os.time()
    if inPlayerTimes(steamID) then
      clockTime(steamID, dropTime)
    end
  end)
end)

Citizen.CreateThread(function()
  RegisterServerEvent("afkKick")
  AddEventHandler("afkKick", function(role)
    DropPlayer(source, "You were AFK for too long and have been kicked as a result.")
  end)
end)
