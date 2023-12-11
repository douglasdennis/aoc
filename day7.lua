CardValue = {
    ["A"]=13,
    ["K"]=12,
    ["Q"]=11,
    ["T"]=9,
    ["9"]=8,
    ["8"]=7,
    ["7"]=6,
    ["6"]=5,
    ["5"]=4,
    ["4"]=3,
    ["3"]=2,
    ["2"]=1,
    ["J"]=0,
}

HandTypeValue = {
    ["five of a kind"] = 6,
    ["four of a kind"] = 5,
    ["full house"] = 4,
    ["three of a kind"] = 3,
    ["two pair"] = 2,
    ["one pair"] = 1,
    ["high card"] = 0,
}

function GetHandType(hand)
    local card_counts = {}
    for k, _ in pairs(CardValue) do
        card_counts[k] = 0
    end

    for i=1,#hand do
        local card = string.sub(hand, i, i)
        card_counts[card] = card_counts[card] + 1
    end

    local max_counts = {0, 0}
    for card, count in pairs(card_counts) do
        if card ~= "J" then
            if count >= max_counts[1] then
                max_counts[2] = max_counts[1]
                max_counts[1] = count
            elseif count > max_counts[2] then
                max_counts[2] = count
            end
        end
    end

    if card_counts["J"] == 5 or card_counts["J"] == 4 then
        return "five of a kind"
    end

    if max_counts[1] == 5 then
        return "five of a kind"
    elseif max_counts[1] == 4 then
        if card_counts["J"] == 1 then
            return "five of a kind"
        end
        return "four of a kind"
    elseif max_counts[1] == 3 then
        if card_counts["J"] == 2 then
            return "five of a kind"
        elseif card_counts["J"] == 1 then
            return "four of a kind"
        elseif max_counts[2] == 2 then
            return "full house"
        else
            return "three of a kind"
        end
    elseif max_counts[1] == 2 then
        if card_counts["J"] == 3 then
            return "five of a kind"
        elseif card_counts["J"] == 2 then
            return "four of a kind"
        elseif card_counts["J"] == 1 then
            if max_counts[2] == 2 then
                return "full house"
            else
                return "three of a kind"
            end
        elseif max_counts[2] == 2 then
            return "two pair"
        else
            return "one pair"
        end
    end
    if card_counts["J"] == 3 then
        return "four of a kind"
    elseif card_counts["J"] == 2 then
        return "three of a kind"
    elseif card_counts["J"] == 1 then
        return "one pair"
    end
    return "high card"
end

function EmbedHands(hands)
    local embedded_hands = {}
    for i, hand in pairs(hands) do
        local hand_type_value = HandTypeValue[GetHandType(hand.cards)]
        local card_values = {}
        for value_i=1,5 do
            card_values[value_i] = CardValue[string.sub(hand.cards, value_i, value_i)]
        end
        local hand_embedding =
         (hand_type_value << 20) |
         (card_values[1] << 16) |
         (card_values[2] << 12) |
         (card_values[3] << 8) |
         (card_values[4] << 4) |
         card_values[5]
        embedded_hands[i] = {cards=hand.cards, value=hand_embedding, bid=hand.bid}
    end
    return embedded_hands
end

function ParseHands()
    local hands = {}
    local line = io.read("*l")
    while line ~= nil do
        local cards = string.match(line, "(.+) ")
        local bid = tonumber(string.match(line, " (%d+)"))
        hands[#hands+1] = {cards=cards, bid=bid}
        line = io.read("*l")
    end
    return hands
end

function CompareHands(a, b)
    return a.value < b.value
end

io.input("day7.in")
local hands = ParseHands()
local embedded_hands = EmbedHands(hands)
table.sort(embedded_hands, CompareHands)
local total = 0
local subtotal = 0
for i, hand in pairs(embedded_hands) do
    if string.match(hand.cards, "J") then
        print(i, hand.cards, hand.bid, hand.value, GetHandType(hand.cards))
    end
    total = total + hand.bid * i
end

-- 249748283
-- 248457642 (too high)
-- 248581739 (too high)
-- 248457642 (too high)
-- 248029057
print(subtotal)
print(total)
