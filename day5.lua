function ApplyTranslationToRange(src_start, src_end, trans_start, trans_end, translation)
    -- A: src_start, B: src_end, C: trans_start, D: trans_end
    -- | | | | -- | | | | -- | | | | -- | | | |
    -- A C B D -- A C D B -- C A D B __ C A B D
    local untranslated_regions = {}
    local translated_region = nil
    if src_start <= trans_start and src_end >= trans_start and src_end <= trans_end then
        -- case 1
        -- untranslated: (A, C)
        -- translated: (C, B)
        if src_start < trans_start then
            untranslated_regions[#untranslated_regions+1] = {src_start, trans_start - 1}
        end
        translated_region = {trans_start + translation, src_end + translation}
    elseif src_start <= trans_start and src_end >= trans_end then
        -- case 2
        -- untranslated_regions: (A, C), (D, B)
        -- translated: (C, D)
        if src_start < trans_start then
            untranslated_regions[#untranslated_regions+1] = {src_start, trans_start - 1}
        end
        if trans_end < src_end then
            untranslated_regions[#untranslated_regions+1] = {trans_end + 1, src_end}
        end
        translated_region = {trans_start + translation, trans_end + translation}
    elseif src_start >= trans_start and src_start <= trans_end and src_end >= trans_end then
        -- case 3
        -- untranslated_regions: (D, B)
        -- translation_region: (A, D)
        if src_end > trans_end then
            untranslated_regions[#untranslated_regions+1] = {trans_end + 1, src_end}
        end
        translated_region = {src_start + translation, trans_end + translation}
    elseif src_start >= trans_start and src_end <= trans_end then
        -- case 4
        -- untranslated: None
        -- translated: (A, B)
        translated_region = {src_start + translation, src_end + translation}
    else
        untranslated_regions = {{src_start, src_end}}
    end


    -- return untranslated ranges, translated range
    return untranslated_regions, translated_region
end

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
    local untranslated_regions = {}
    local translated_regions = {}
    for seed_start, seed_range in string.gmatch(seed_line, "(%d+) (%d+)") do
        untranslated_regions[#untranslated_regions+1] = {tonumber(seed_start), tonumber(seed_start) + tonumber(seed_range) - 1}
    end
    for _, line in pairs(lines) do
        local dest, src, range = string.match(line, "^(%d+) (%d+) (%d+)$")

        if dest and range and src then
            local trans_start = tonumber(src)
            local trans_end = tonumber(src) + tonumber(range) - 1
            local translation = tonumber(dest) - tonumber(src)
            local next_untranslated_regions = {}
            for _, untranslated_range in pairs(untranslated_regions) do
                local residual_untranslated_regions, additional_translated_region = ApplyTranslationToRange(untranslated_range[1], untranslated_range[2], trans_start, trans_end, translation)
                if #residual_untranslated_regions > 0 then
                    for _, residual in pairs(residual_untranslated_regions) do
                        next_untranslated_regions[#next_untranslated_regions+1] = residual
                    end
                end
                if additional_translated_region then
                    translated_regions[#translated_regions+1] = additional_translated_region
                end
            end
            untranslated_regions = next_untranslated_regions
        else
            -- left the current table
            for _, region in pairs(translated_regions) do
                untranslated_regions[#untranslated_regions+1] = region
            end
            translated_regions = {}
        end
    end

    -- add the translated regions from the final table
    for _, region in pairs(translated_regions) do
        untranslated_regions[#untranslated_regions+1] = region
    end

    -- search for the smallest location
    for _, region in pairs(untranslated_regions) do
        if min_location == nil or region[1] < min_location then
            min_location = region[1]
        end
    end

    print(min_location)

end
-- 2520479
io.input("day5.in")
ParseAlmanac()
