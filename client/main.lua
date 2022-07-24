QBCore = exports['qb-core']:GetCoreObject()

local loaded = false

_Info = {
    mining = false,
    drill = nil
}

_Rocks = {}

-- ROCK SPAWNING SECTION
spawnRocks = function()
    local model = `prop_rock_4_c_2`
    local pos = GetEntityCoords(PlayerPedId())

    RequestModel(model)

    while (not HasModelLoaded(model)) do
        Wait(1)
    end

    -- Spawning rocks or deleting them on dist check
    for _,v in pairs(_Rocks) do
        dist = #(pos - vec3(v.x, v.y, Config.Area.z))
        if not v.spawned and dist < 150 then
            local ground, groundZ = GetGroundZFor_3dCoord(v.x + 0.0, v.y + 0.0, Config.Area.z + 0.0, Citizen.ReturnResultAnyway())
            local rock = CreateObject(`prop_rock_4_c_2`, vec3(v.x, v.y, groundZ), false, false, false)
            FreezeEntityPosition(rock, true)
            PlaceObjectOnGroundProperly(rock)
            v.entity = rock
            v.sPos = vec3(v.x, v.y, groundZ)

            if not v.inter then
                v.inter = _Mine.rockInteraction(v.sPos, v)
            end

            v.spawned = true
        elseif v.spawned and dist > 150 then
            DeleteEntity(rock)
            v.spawned = false
        end
    end
end

-- Rock spawning thread
RockThread = function()
    CreateThread(function ()
        while true do
            spawnRocks()
            Wait(1000) -- Check rocks every minute
        end
    end)
end
-- SECTION END

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if not loaded then
        loaded = true

        local result = lib.callback.await('mining:getRocks', false)

        -- Start rock checking thread
        if #result > 1 then
            _Rocks = result
            Wait(5000)
            RockThread()
        end
    end
end)

RegisterNetEvent('mining:updateRock', function(data)
    local rock = GetRockFromId(data.id)
    if rock then
        rock.health = data.health
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        loaded = false

        for _,v in pairs(_Rocks) do
            if v.spawned then
                while DoesEntityExist(v.entity) do
                    DeleteEntity(v.entity)
                    Wait(0)
                end
            end
        end
    end
end)

GetRockFromId = function(id)
    for _,v in pairs(_Rocks) do
        if v.id == id then
            return v
        end
    end
    return false
end

WaitForModel = function(model)
    if not IsModelValid(model) then
        return
    end

	if not HasModelLoaded(model) then
		RequestModel(model)
	end
	
	while not HasModelLoaded(model) do
		Citizen.Wait(0)
	end
end


