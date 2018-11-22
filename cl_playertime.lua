local waitTime = 120000 -- We wait this amount in milliseconds until we check their time, (some people like to drop their connection A LOT).
local afkKickTime = 900 -- Time In Seconds for kick
local SAST, BCSO, LSPD, FIRE, CIV = 5, 4, 3, 2, 1
local prefix = "~r~So~b~Cal~w~RP.net"
local hasRan = false
local currTime = afkKickTime
local currRole = 0
local currPos = 0
local prevPos = 1

function drawNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function getRoleInfo(modelHash)
	local role = 0
	local roleString = ""
	if getOutfitCategory() == "SAHP" or exports.eup_ui:getOutfit() == "SASP" then
		role = SAST
		roleString = "San Andreas Highway Patrol"
	elseif getOutfitCategory() == "LSSD" or exports.eup_ui:getOutfit() == "BCSO" then
		role = BCSO
		roleString = "Blaine County Sheriffs"
	elseif modelHash == GetHashKey('s_m_y_cop_01') or modelHash == GetHashKey('s_f_y_cop_01') or exports.eup_ui:getOutfit() == "LSPD" then
		role = LSPD
		roleString = "Los Santos Police Department"
	elseif modelHash == GetHashKey('aprpfire') or modelHash == GetHashKey('aprpems') then
		role = FIRE
		roleString = "San Andreas Fire Department"
	else
		role = CIV
		roleString = "Civilian"
	end
	return {role, roleString}
end

AddEventHandler('playerSpawned', function(spawnInfo)
  if hasRan == true then return end
  Citizen.Wait(waitTime)
	hasRan = true
  local modelHash = GetEntityModel(PlayerPedId())
	local roleInfo = getRoleInfo(modelHash)
	local role = roleInfo[1]
	local roleString = roleInfo[2]
	currRole = role
	drawNotification(prefix .. " Time Clock\nSuccessfully clocked in as: ~b~" .. roleString .. ".")
	print("Clocked in as: " .. roleString .. ".")
  TriggerServerEvent('playerTimeStart', role)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(waitTime + 10)
		local modelHash = GetEntityModel(PlayerPedId())
		local roleInfo = getRoleInfo(modelHash)
		local role = roleInfo[1]
		local roleString = roleInfo[2]
		if currRole ~= role and hasRan == true then
			currRole = role
			drawNotification(prefix .. " Time Clock\nWe see you have switched roles! Goodluck on your new endeavours!")
			drawNotification(prefix .. " Time Clock\nSuccessfully clocked in as: ~b~" .. roleString .. ".")
			print("Clocked in as: " .. roleString .. ".")
			TriggerServerEvent('playerTimeStart', role)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(1000)
		local playerPed = GetPlayerPed(-1)
		if playerPed then
			currPos = GetEntityCoords(playerPed, true)
			if currPos == prevPos then
				if currTime > 0 then
					if currTime == math.ceil(afkKickTime / 2) then
						drawNotification(prefix .. "\nYou will be kicked in " .. currTime .. " seconds for being AFK too long.")
					end
					currTime = currTime - 1
					print(currTime)
				else
					TriggerServerEvent("afkKick")
				end
			else
				currTime = afkKickTime
			end
			prevPos = currPos
		end
	end
end)
