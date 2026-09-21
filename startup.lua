local mon = peripheral.find("monitor")

if not mon then
    error("Monitor not found!")
end

mon.setTextScale(0.6)

local tank = peripheral.wrap("left")

local lastFuel = nil
local fuelBurnRate = 0
local lastCheckTime = os.clock()

function getFuelData()
    if not tank then return "No Tank", "--:--" end

    local tanks = tank.tanks()
    if tanks and #tanks > 0 and tanks[1].amount then
        local currentFuel = tanks[1].amount
        local currentTime = os.clock()
        local timeDelta = currentTime - lastCheckTime

        if timeDelta >= 1.0 and lastFuel then
            local fuelDelta = lastFuel - currentFuel
            if fuelDelta > 0 then
                fuelBurnRate = fuelDelta / timeDelta
            else
                fuelBurnRate = 0
            end
            lastFuel = currentFuel
            lastCheckTime = currentTime
        elseif not lastFuel then
            lastFuel = currentFuel
        end

        local etaStr = "INF"
        if fuelBurnRate > 0 then
            local secondsLeft = currentFuel / fuelBurnRate
            local hours = math.floor(secondsLeft / 3600)
            local minutes = math.floor((secondsLeft % 3600) / 60)
            local seconds = math.floor(secondsLeft % 60)
            
            if hours > 0 then
                etaStr = string.format("%d:%02d:%02d", hours, minutes, seconds)
            else
                etaStr = string.format("%d:%02d", minutes, seconds)
            end
        end

        return currentFuel .. " mB", etaStr
    end
    return "0 mB", "--:--"
end

while true do
    local pose = sublevel.getLogicalPose()
    local pos = pose.position

    local engine = rs.getAnalogInput("top")

    local vel = sublevel.getLinearVelocity()

    local speed = math.sqrt(vel.x^2 + vel.z^2)
    
    local vs = vel.y

    local fuelStr, etaStr = getFuelData()

    mon.setBackgroundColor(colors.black)
    mon.clear()

    mon.setCursorPos(1,1)
    mon.setTextColor(colors.cyan)
    mon.write("HTS Rudementary")

    mon.setCursorPos(1,3)
    mon.setTextColor(colors.red)
    mon.write("A-SPEED ")
    mon.write(math.floor(speed))

    mon.setCursorPos(1,4)
    mon.setTextColor(colors.red)
    mon.write("V-SPEED ")
    mon.write(math.floor(vs))

    mon.setCursorPos(1,5)
    mon.setTextColor(colors.red)
    mon.write("ALT ")
    mon.write(math.floor(pos.y))

    mon.setCursorPos(1,7)
    mon.setTextColor(colors.red)
    mon.write("FUEL ")
    mon.write(fuelStr)

    mon.setCursorPos(1,8)
    mon.setTextColor(colors.red)
    mon.write("ETA ")
    mon.write(etaStr)

    mon.setCursorPos(1,10)
    mon.setTextColor(colors.red)
    mon.write("X:" .. math.floor(pos.x) .. " Z:" .. math.floor(pos.z))

    sleep(0.1)
end
