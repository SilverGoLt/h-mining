generatedRocks = {}


-- Need to finish it
RockThread = function()

    CreateThread(function ()
        while true do
            Wait(10 * 60000) -- Check rocks every 10 minutes

            -- Let's fucking heal the rocks lul
            for _,v in pairs(generatedRocks) do
                if v.health < 100 then
                    v.health += 20 -- Regenerate 20 health per 10 minutes
                end
            end

        end
    end)

end

---Rock Generation
GenerateRocks = function()
    local r = math.random(7, 15)

    -- Start generating rocks
    for i = 1, r do
        local x = math.random(Config.Area.minX, Config.Area.maxX) + 5
        local y = math.random(Config.Area.minY, Config.Area.maxY) + 3

        local id = #generatedRocks + 1
        generatedRocks[id] = {
            x = converToFloat(x),
            y = converToFloat(y),
            prop = Config.Rock.prop,
            id = id,
            health = 100
        }

    end
end

MineRock = function(source, id)
    local rock = generatedRocks[id]

    if rock then
        local item = GetItem()
        print(string.format('%s mined %s', source, item))
    end
end

GetItem = function()
    total_sum = 0
    for _, v in pairs(Config.Ores) do
        total_sum = total_sum + v.chance
    end
    RNG = math.random(0, total_sum)
    sum = 0
    item = 0
    for i, v in pairs(Config.Ores) do
        sum = sum + v.chance
        item = v.item
        if RNG >= sum - v.chance and RNG < sum then
            break
        end
    end
    return item
end


-- Callback to get rock data
lib.callback.register('mining:getRocks', function()
    return generatedRocks
end)


-- Callback to update rock health, currently needs to somehow update it for all players :think:
lib.callback.register('mining:setHealth', function(source, id, amount)
    local rock = generatedRocks[id]
    local close, closeRock = getClosestRock(source)

    if rock then
        if rock.id == closeRock.id then
            rock.health = amount
            MineRock(source, id)
            updatePlayers(150, rock)
            return true
        else
            return false
        end
    else
        return false
    end
end)


function converToFloat(x)
    return x + 0.0
end

function updatePlayers(radius, rock)
    local players = GetPlayers()
    local rPos = vec3(rock.x, rock.y, 42.0)
    local updated = 0

    for _, id in pairs(players) do
        local ped = GetPlayerPed(id)
        local pos = GetEntityCoords(ped)

        dist = #(pos - rPos)
        if dist < radius then
            updated += 1
            TriggerClientEvent('mining:updateRock', id, rock)
        end
    end

    print('Updated ' .. updated .. ' players')
end

function getClosestRock(source)
    local ped = GetPlayerPed(source)
    local pos = GetEntityCoords(ped)

    for i = 1, #generatedRocks do
        local rock = generatedRocks[i]
        dist = #(pos - vec3(rock.x, rock.y, 42.0))

        if dist < 3 then
            return true, rock
        end
    end
end


AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        GenerateRocks()
        RockThread()
    end
end)