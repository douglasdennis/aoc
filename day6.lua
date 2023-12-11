function ParseRace()
    local time_line = io.read("*l")
    local distance_line = io.read("*l")

    local times = {}
    for time in string.gmatch(time_line, "(%d+)") do
        times[#times+1] = tonumber(time)
    end

    local distances = {}
    for distance in string.gmatch(distance_line, "(%d+)") do
        distances[#distances+1] = tonumber(distance)
    end

    local races = {}
    for i=1,#times do
        races[i] = {time=times[i], distance=distances[i]}
    end

    return races
end


function ParseRaceWithBadKerning()
    local time_line = io.read("*l")
    local distance_line = io.read("*l")

    local complete_time = ""
    for time in string.gmatch(time_line, "(%d+)") do
        complete_time = complete_time .. time
    end

    local complete_distance = ""
    for distance in string.gmatch(distance_line, "(%d+)") do
        complete_distance = complete_distance .. distance
    end

    return {{time=tonumber(complete_time), distance=tonumber(complete_distance)}}
end


function FindNumberOfWinningMoves(race)
    -- Gonna do some math here
    -- t_hold := amount of time to hold the button
    -- t_max := maximum amount of time in the race
    -- d := distance traveled in the race
    -- v := velocity
    -- 
    -- v = t_hold
    -- d = v * (t_max - t_hold) <-- velocity times the total time left in the race to travel
    --   = t_hold * (t_max - t_hold)
    --   = -(t_hold**2) + t_max * t_hold
    -- 
    -- d_best := best distance reached
    -- t_hold_best := time to hold the button that results in the d_best
    --
    -- d_best = d(t_hold_best) = -(t_hold_best**2) + t_max * t_hold_best
    --                       0 = -(t_hold_best**2) + t_max * t_hold_best - d_best
    --
    -- applying the quadratic formula to find t_hold_best:
    -- t_hold_best = (-t_max \pm sqrt(t_max**2 - 4 * (-1) * (-d_best))) / -2
    --             = -(t_max \pm sqrt(t_max**2 - 4 * d_best)) / -2  <-- note that by extracting the negative I have flipped the meaning of \pm
    --             = (t_max \pm sqrt(t_max**2 - 4 * d_best)) / 2

    local t_max = race.time
    local d_best = race.distance
    local t_hold_best = {
        (t_max - math.sqrt(t_max * t_max - 4 * d_best)) / 2,
        (t_max + math.sqrt(t_max * t_max - 4 * d_best)) / 2,
    }

    local min_hold_time = math.ceil(t_hold_best[1])
    local max_hold_time = math.floor(t_hold_best[2])

    if min_hold_time == t_hold_best[1] then
        min_hold_time = min_hold_time + 1
    end

    if max_hold_time == t_hold_best[2] then
        max_hold_time = max_hold_time - 1
    end

    return max_hold_time - min_hold_time + 1
end


io.input("day6.in")
-- 1660968
-- local races = ParseRace()
-- 26499773
local races = ParseRaceWithBadKerning()
local num_permutations = 1
for _, race in pairs(races) do
    num_permutations = num_permutations * FindNumberOfWinningMoves(race)
end
print(num_permutations)
