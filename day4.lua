function ParseGameCard(s)
    -- get to colon
    local i = 1

    while string.sub(s, i, i) ~= ":" do i = i + 1 end
    -- add 1 for the colon and 1 for the space
    local winning_numbers_start = i + 2

    i = i + 1

    while string.sub(s, i, i) ~= "|" do i = i + 1 end
    -- add 1 for the | and 1 for the space
    local played_numbers_start = i + 2

    local winning_numbers_str = string.sub(s, winning_numbers_start, played_numbers_start - 3)
    local played_numbers_str = string.sub(s, played_numbers_start)

    local winning_numbers = {}

    for n in string.gmatch(winning_numbers_str, "(%d+)") do
        winning_numbers[n] = true
    end

    local num_matches = 0
    for n in string.gmatch(played_numbers_str, "(%d+)") do
        if winning_numbers[n] then
            num_matches = num_matches + 1
        end
    end

    return num_matches
end

function AddUpPoints()
    local cur_game = io.read("*l")
    local total = 0
    while cur_game ~= nil do
        local num_matches = ParseGameCard(cur_game)
        if num_matches > 0 then
            total = total + (2 ^ (num_matches - 1))
        end
        cur_game = io.read("*l")
    end
    return total
end

function AddUpCards()
    local cur_game = io.read("*l")
    local cards = {}
    local cur_game_number = 1
    while cur_game ~= nil do
        local num_cards = 1
        if cards[cur_game_number] ~= nil then
            num_cards = cards[cur_game_number] + 1
        end

        cards[cur_game_number] = num_cards

        local num_matches = ParseGameCard(cur_game)
        for i=1,num_matches do
            if cards[cur_game_number + i] ~= nil then
                cards[cur_game_number + i] = cards[cur_game_number + i] + num_cards
            else
                cards[cur_game_number + i] = num_cards
            end
        end

        cur_game_number = cur_game_number + 1
        cur_game = io.read("*l")
    end

    local total = 0
    for _, num_cards in pairs(cards) do
        total = total + num_cards
    end
    return total
end

io.input("day4.in")
-- correct answer is 17803
--print(AddUpPoints())
-- correct answer is 5554894
print(AddUpCards())

