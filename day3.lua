IsDigit = {
    ["0"] = true,
    ["1"] = true,
    ["2"] = true,
    ["3"] = true,
    ["4"] = true,
    ["5"] = true,
    ["6"] = true,
    ["7"] = true,
    ["8"] = true,
    ["9"] = true,
}

function IsSymbol(s)
    return not (s == "." or IsDigit[s])
end

function FillLine(n)
    local line = "."
    if n > 1 then
        for _=2,n do
            line = line .. "."
        end
    end
    return line
end

function ExtractNumber(line, i)
    local start_index = i
    local end_index = i

    -- explore left first
    local c = string.sub(line, i, i)

    while IsDigit[c] do
        i = i - 1
        c = string.sub(line, i, i)
    end

    start_index = i + 1

    -- explore right next
    i = end_index
    c = string.sub(line, i, i)

    while IsDigit[c] do
        i = i + 1
        c = string.sub(line, i, i)
    end

    end_index = i - 1

    local result = tonumber(string.sub(line, start_index, end_index))

    local left = ""
    local right = ""

    if start_index > 1 then
        left = string.sub(line, 1, start_index - 1)
    end

    if end_index < #line then
        right = string.sub(line, end_index + 1)
    end

    line = left .. FillLine(end_index - start_index + 1) .. right

    return result, line
end

function BooleanToInt(b)
    return b and 1 or 0
end

function ParseSchematicForGearRatios()
    local cur_line = io.read("*l")
    local next_line = io.read("*l")
    local prev_line = FillLine(#cur_line)
    local total = 0

    while cur_line ~= nil do
        for i=1,#cur_line do
            local c = string.sub(cur_line, i, i)
            if c == "*" then
                local left_is_digit = IsDigit[string.sub(cur_line, i - 1, i - 1)]
                local right_is_digit = IsDigit[string.sub(cur_line, i + 1, i + 1)]
                local up_left_is_digit = IsDigit[string.sub(prev_line, i - 1, i - 1)]
                local up_is_digit = IsDigit[string.sub(prev_line, i, i)]
                local up_right_is_digit = IsDigit[string.sub(prev_line, i + 1, i + 1)]
                local down_left_is_digit = IsDigit[string.sub(next_line, i - 1, i - 1)]
                local down_is_digit = IsDigit[string.sub(next_line, i, i)]
                local down_right_is_digit = IsDigit[string.sub(next_line, i + 1, i + 1)]

                local parts_above = 0
                if up_is_digit then
                    parts_above = 1
                else
                    parts_above = BooleanToInt(up_left_is_digit) + BooleanToInt(up_right_is_digit)
                end

                local parts_below = 0
                if down_is_digit then
                    parts_below = 1
                else
                    parts_below = BooleanToInt(down_left_is_digit) + BooleanToInt(down_right_is_digit)
                end

                local num_part_numbers = BooleanToInt(left_is_digit) + BooleanToInt(right_is_digit) + parts_above + parts_below

                local value = 0

                if num_part_numbers == 2 then
                    value = 1
                    if left_is_digit then
                        local next_value, _ = ExtractNumber(cur_line, i - 1)
                        value = value * next_value
                    end
                    if right_is_digit then
                        local next_value, _ = ExtractNumber(cur_line, i + 1)
                        value = value * next_value
                    end
                    if up_is_digit then
                        local next_value, _ = ExtractNumber(prev_line, i)
                        value = value * next_value
                    else
                        if up_left_is_digit then
                            local next_value, _ = ExtractNumber(prev_line, i - 1)
                            value = value * next_value
                        end
                        if up_right_is_digit then
                            local next_value, _ = ExtractNumber(prev_line, i + 1)
                            value = value * next_value
                        end
                    end
                    if down_is_digit then
                        local next_value, _ = ExtractNumber(next_line, i)
                        value = value * next_value
                    else
                        if down_left_is_digit then
                            local next_value, _ = ExtractNumber(next_line, i - 1)
                            value = value * next_value
                        end
                        if down_right_is_digit then
                            local next_value, _ = ExtractNumber(next_line, i + 1)
                            value = value * next_value
                        end
                    end
                end
                total = total + value
            end
        end
        prev_line = cur_line
        cur_line = next_line
        next_line = io.read("*l")
    end
    return total
end

function ParseSchematic()
    local cur_line = io.read("*l")
    local next_line = io.read("*l")
    local prev_line = FillLine(#cur_line)
    local total = 0

    while cur_line ~= nil do
        for i=1,#cur_line do
            local c = string.sub(cur_line, i, i)
            if IsSymbol(c) then
                if IsDigit[string.sub(cur_line, i - 1, i - 1)] then
                    local value, new_line = ExtractNumber(cur_line, i - 1)
                    cur_line = new_line
                    total = total + value
                end
                if IsDigit[string.sub(cur_line, i + 1, i + 1)] then
                    local value, new_line = ExtractNumber(cur_line, i + 1)
                    cur_line = new_line
                    total = total + value
                end
                if IsDigit[string.sub(prev_line, i, i)] then
                    local value, new_line = ExtractNumber(prev_line, i)
                    prev_line = new_line
                    total = total + value
                else
                    if IsDigit[string.sub(prev_line, i - 1, i - 1)] then
                        local value, new_line = ExtractNumber(prev_line, i - 1)
                        prev_line = new_line
                        total = total + value
                    end
                    if IsDigit[string.sub(prev_line, i + 1, i + 1)] then
                        local value, new_line = ExtractNumber(prev_line, i + 1)
                        prev_line = new_line
                        total = total + value
                    end
                end
                if IsDigit[string.sub(next_line, i, i)] then
                    local value, new_line = ExtractNumber(next_line, i)
                    next_line = new_line
                    total = total + value
                else
                    if IsDigit[string.sub(next_line, i - 1, i - 1)] then
                        local value, new_line = ExtractNumber(next_line, i - 1)
                        next_line = new_line
                        total = total + value
                    end
                    if IsDigit[string.sub(next_line, i + 1, i + 1)] then
                        local value, new_line = ExtractNumber(next_line, i + 1)
                        next_line = new_line
                        total = total + value
                    end
                end
            end
        end
        prev_line = cur_line
        cur_line = next_line
        next_line = io.read("*l")
    end
    return total
end

local input_file = "day3_input.txt"
io.input(input_file)

-- correct answer is 498559
-- print(ParseSchematic())

-- correct answer is 72246648
print(ParseSchematicForGearRatios())

