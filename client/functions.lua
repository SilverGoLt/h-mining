_Mine = {}

_Interactions = {
    mine = {},
    refine = nil,
    sell = nil,
}

RegisterCommand('closeRockData', function()
    local check, rock = _Mine.closestRock()
    if check then
        print(json.encode(rock))
    end
end)

_Mine.tryMining = function ()
    local check, rock = _Mine.closestRock()

    if not _Info.mining and check then
        _Info.mining = true
        _Mine.startMining(rock)
    end
end

_Mine.startMining = function (data)
    local rock = data
    local hasItem = QBCore.Functions.HasItem('mining_drill')
    local minus = math.random(1, 15)
    local close = _Mine.playersClose(2.0)

    if rock.spawned and hasItem and not close then
        if rock.health > 0 then
            -- Attach Prop and start FX (KEK)
            _Mine.attachDrill()

            local dict, anim = 'anim@heists@fleeca_bank@drilling', 'drill_straight_idle' -- TODO better animations
            if lib.progressCircle({
                duration = 5000,
                position = 'bottom',
                useWhileDead = false,
                canCancel = false,
                disable = {
                    car = true,
                    move = true
                },
                anim = {
                    dict = dict,
                    clip = anim
                },
            }) then
                local newHealth = rock.health - minus

                DeleteEntity(_Info.drill)
                _Info.drill = nil

                if newHealth <= 0 then
                    newHealth = 0
                end

                _Info.mining = false
                -- Update rock health
                lib.callback('mining:setHealth', false, function(state)
                    if state then
                        print('[Mining] Rock health updated')
                        _Mine.updateDisplay(rock.id, newHealth)
                    else
                        print('[Mining] Rock health update failed')
                    end
                end, rock.id, newHealth)
            else
                _Info.mining = false
                DeleteEntity(_Info.drill)
                _Info.drill = nil
            end
        end
    else
        _Info.mining = false
        DeleteEntity(_Info.drill)
        _Info.drill = nil
        QBCore.Functions.Notify('Seems like a person is next to you! Careful not to hurt him', 'primary', 3000)
    end
end

_Mine.closestRock = function ()
    local pos = GetEntityCoords(PlayerPedId())

    for _,v in pairs(_Rocks) do
        dist = #(pos - v.sPos)
        if dist < 1.6 then
            return true, v
        end
    end
end

_Mine.attachDrill = function ()
    if not _Info.drill then
        _Info.drill = CreateObject(`hei_prop_heist_drill`, GetEntityCoords(PlayerPedId(), true), true, true, true)
		AttachEntityToEntity(_Info.drill, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0, -0.01, 90.0, -90.0, 180.0, true, true, false, true, 1, true)
    end
end

_Mine.rockInteraction = function (pos, data)
        -- Reigster interaction on the rocks
        local rockInteraction = {
            name = 'Mining_Interaction',
            text = 'Mine Rock [E]',
            pos = vec3(pos.x, pos.y, pos.z + 0.7),
            action = function()
                _Mine.tryMining()
            end,
            secondText = 'HP: '..data.health,
            dist = 1.3,
        }

        local id = exports['ax-utils']:registerInteraction(rockInteraction)

        return id
end

_Mine.updateDisplay = function(id, value)
    if _Rocks[id] then
        local rock = _Rocks[id]
        -- Update Interaction Info
        exports['ax-utils']:modifySecond(rock.inter, 'HP: '..value)
    end
end

RegisterCommand('checkPlayers', function()
    print(_Mine.playersClose(2.0))
end)

_Mine.playersClose = function(radius)
    local pos = GetEntityCoords(PlayerPedId())
    local players = GetActivePlayers()

    for i = 1, #players do
        local player = players[i]
        local ped = GetPlayerPed(player)
        local dist = #(pos - GetEntityCoords(ped))

        if dist < radius and ped ~= PlayerPedId() then
            return true
        end
    end
    -- Let's return false if there's no one close
    return false
end