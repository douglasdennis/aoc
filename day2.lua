-- This isn't working right now, I stopped midway through a refactor to a better state machine implementation
NumCubes = {
    ["red"] = 12,
    ["green"] = 13,
    ["blue"] = 14,
}

GameParser = {
    ["seeking number"] = function (next_char, cur_buffer, game)
        local state = "seeking number"
        local observed_cubes = nil
        if next_char == " " then
            if cur_buffer ~= nil then
                observed_cubes = cur_buffer
                cur_buffer = nil
                state = "seeking color"
            end
        else
            if cur_buffer ~= nil then
                cur_buffer = cur_buffer .. next_char
            else
                cur_buffer = next_char
            end
        end
        return state, cur_buffer, observed_cubes
    end;
    ["seeking color"] = function (next_char, cur_buffer, game)
            if next_char == "," then
                if game["revelations"][next_revelation_index] == nil then
                    game["revelations"][next_revelation_index] = {[buffer] = tonumber(observed_cubes)}
                else
                    game["revelations"][next_revelation_index][buffer] = tonumber(observed_cubes)
                end
                observed_cubes = nil
                buffer = nil
                state = "seeking number"
            elseif next_character == ";" or i == #game_revelations then
                if i == #game_revelations then
                    buffer = buffer .. next_character
                end
                if game["revelations"][next_revelation_index] == nil then
                    game["revelations"][next_revelation_index] = {[buffer] = tonumber(observed_cubes)}
                else
                    game["revelations"][next_revelation_index][buffer] = tonumber(observed_cubes)
                end
                observed_cubes = nil
                buffer = nil
                if game["revelations"][next_revelation_index]["red"] == nil then
                    game["revelations"][next_revelation_index]["red"] = 0
                end
                if game["revelations"][next_revelation_index]["green"] == nil then
                    game["revelations"][next_revelation_index]["green"] = 0
                end
                if game["revelations"][next_revelation_index]["blue"] == nil then
                    game["revelations"][next_revelation_index]["blue"] = 0
                end
                next_revelation_index = next_revelation_index + 1
                state = "seeking number"
            elseif next_character ~= " " then
                if buffer == nil then
                    buffer = next_character
                else
                    buffer = buffer .. next_character
                end
            end
}

function ParseGame(game)
    -- array of tables, each table is a table of revelations({"red": xx, "green": xx, "blue": xx})
    local _, title_length, game_number = string.find(game, "^Game (%d+):%s*")
    local game_revelations = string.sub(game, title_length + 1)
    local state = "seeking number"
    local buffer = nil
    local observed_cubes = nil
    local next_revelation_index = 1
    local game = {
        ["number"] = game_number,
        ["revelations"] = {}
    }
    for i=1,#game_revelations do
        local next_character = string.sub(game_revelations, i, i)
        if state == "seeking number" then
            state, buffer, observed_cubes = GameParser[state](next_character, buffer)
        elseif state == "seeking color" then
            if next_character == "," then
                if game["revelations"][next_revelation_index] == nil then
                    game["revelations"][next_revelation_index] = {[buffer] = tonumber(observed_cubes)}
                else
                    game["revelations"][next_revelation_index][buffer] = tonumber(observed_cubes)
                end
                observed_cubes = nil
                buffer = nil
                state = "seeking number"
            elseif next_character == ";" or i == #game_revelations then
                if i == #game_revelations then
                    buffer = buffer .. next_character
                end
                if game["revelations"][next_revelation_index] == nil then
                    game["revelations"][next_revelation_index] = {[buffer] = tonumber(observed_cubes)}
                else
                    game["revelations"][next_revelation_index][buffer] = tonumber(observed_cubes)
                end
                observed_cubes = nil
                buffer = nil
                if game["revelations"][next_revelation_index]["red"] == nil then
                    game["revelations"][next_revelation_index]["red"] = 0
                end
                if game["revelations"][next_revelation_index]["green"] == nil then
                    game["revelations"][next_revelation_index]["green"] = 0
                end
                if game["revelations"][next_revelation_index]["blue"] == nil then
                    game["revelations"][next_revelation_index]["blue"] = 0
                end
                next_revelation_index = next_revelation_index + 1
                state = "seeking number"
            elseif next_character ~= " " then
                if buffer == nil then
                    buffer = next_character
                else
                    buffer = buffer .. next_character
                end
            end
        end
    end
    return game
end

function ReadGames()
    local line = io.read("*l")
    local games = {}
    while line ~= nil do
        local game = ParseGame(line)
        games[game["number"]] = game
        line = io.read("*l")
    end
    return games
end

function CubesAreValid(revelation, color)
    return (revelation[color] >= 0 and revelation[color] <= NumCubes[color])
end

function GameIsValid(game)
    for _, revelation in pairs(game["revelations"]) do
        if not (CubesAreValid(revelation, "red") and CubesAreValid(revelation, "green") and CubesAreValid(revelation, "blue")) then
            return false
        end
    end
    return true
end

function CalcPowerMinSet(game)
    local red_max = 0
    local green_max = 0
    local blue_max = 0

    for _, revelation in pairs(game["revelations"]) do
        red_max = revelation["red"] > red_max and revelation["red"] or red_max
        green_max = revelation["green"] > green_max and revelation["green"] or green_max
        blue_max = revelation["blue"] > blue_max and revelation["blue"] or blue_max
    end

    return red_max * green_max * blue_max
end

local games_file = "day2_input.txt"
io.input(games_file)
local games = ReadGames()
local total = 0
for game_num, game in pairs(games) do
--    if GameIsValid(game) then
--        total = total + game_num
--    end
    total = total + CalcPowerMinSet(game)
end
-- Star 1: 2061
-- Star 2: 72596
print(total)
