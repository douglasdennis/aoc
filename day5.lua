AlmanacParser = {
    ["seeking table"] = function(line)
        if line ~= "" then
            return "reading table"
        end
        return "seeking table"
    end,
    ["reading table"] = function(line)

    end,
}


function ParseAlmanac()
    -- parse the seeds line
    local i = 1

    local seed_line = io.read("*l")
    local cur_line = io.read("*l")
    local lines = {}
    while cur_line do
        lines[i] = cur_line
        i = i + 1
        cur_line = io.read("*l")
    end

    local min_location = nil
    for seed_start, seed_range in string.gmatch(seed_line, "(%d+) (%d+)") do
        for seed=tonumber(seed_start),(tonumber(seed_start) + seed_range - 1) do
            local value_updated = false
            local value = seed
            for _, line in pairs(lines) do
                local dest, src, range = string.match(line, "^(%d+) (%d+) (%d+)$")
                if dest and range and src then
                    if not value_updated and value >= tonumber(src) and value < src + range then
                        value = dest + value - src
                        value_updated = true
                    end
                else
                    value_updated = false
                end
            end
            if min_location == nil or value < min_location then
                min_location = value
            end
        end
    end

    print(min_location)

end

io.input("day5.in")
ParseAlmanac()
