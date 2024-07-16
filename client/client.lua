local QBCore = exports['qb-core']:GetCoreObject()
local bike = nil
local hasbike = false
local closebike = false

local function PickUpBike(hash)
	local ped = PlayerPedId()
	local name = string.lower(GetDisplayNameFromVehicleModel(hash))
	RequestAnimDict("anim@heists@box_carry@")
	while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
		Wait(1)
	end
	TaskPlayAnim(ped, "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
	AttachEntityToEntity(bike, ped, GetPedBoneIndex(player, 60309), Config.Bikes[name].x, Config.Bikes[name].y, Config.Bikes[name].z, Config.Bikes[name].RotX, Config.Bikes[name].RotY, Config.Bikes[name].RotZ, true, false, false, true, 0, true)
	hasbike = true
	exports['karma-interaction']:showInteraction("G", "Drop Bike")
end

local function PressedKey(hash)
	CreateThread(function ()
		while not hasbike do
			local ped = PlayerPedId()
			if IsControlJustReleased(0, 38) then
				PickUpBike(hash)
			end
			Wait(1)
		end
	end)
end

CreateThread( function ()
	if Config.Interaction == "karma" then
		while true do
			local ped = PlayerPedId()
			local pos = GetEntityCoords(ped)
			bike = QBCore.Functions.GetClosestVehicle()
			for k, v in pairs(Config.Bikes) do
				local hash = GetHashKey(k)
				if GetEntityModel(bike) == hash then
					local bikepos = GetEntityCoords(bike)
                    local dist = #(pos - bikepos)
                    if dist <= 1.5 then
						if IsPedOnFoot(ped) and not closebike then
							closebike = true
							exports['karma-interaction']:showInteraction("E", "Pickup Bike")
							PressedKey(hash)
						end
					else
						closebike = false
						exports['karma-interaction']:hideInteraction()
					end
				end
			end
			Wait(1000)
		end
	else
		for k,v in pairs(Config.Bikes) do
			local hash = GetHashKey(k)
			exports['qb-target']:AddTargetModel(hash, {
				options = {
				{
					type = "client",
					event = "karma-pickupbikes:client:takeup",
					icon = "fas fa-bicycle",
					label = "Pick Up",
					hash = hash
				}
			},
				distance = 2.0,
			})
		end
	end
end)

RegisterNetEvent("karma-pickupbikes:client:takeup", function(data)
	local hash = data.hash
	bike = QBCore.Functions.GetClosestVehicle()
	PickUpBike(hash)
end)

RegisterCommand('dropbike', function()
	if IsEntityAttachedToEntity(bike, PlayerPedId()) then
		DetachEntity(bike, false, false)
		SetVehicleOnGroundProperly(bike)
		ClearPedTasks(PlayerPedId())
		hasbike = false
		closebike = false
		exports['karma-interaction']:hideInteraction()
	end
end)