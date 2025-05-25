function checksword_mastery_json()
    local materials = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("getInventory")
    local HttpService = game:GetService("HttpService")

    local swordList = {}
    local fruits = {}
    local Accessory = {}
    local Materials = {}

    for _, item in pairs(materials) do
        if item.Type == "Sword" and item.Rarity >= 3 or item.Type == "Gun" and item.Rarity >= 3 then
            local displayName = string.format("%s[%s]", item.Name, tostring(item.Mastery))
            table.insert(swordList, displayName)

        elseif item.Type == "Blox Fruit" and item.Rarity >= 3 then
            table.insert(fruits, item.Name)

        elseif item.Type == "Wear" and item.Rarity >= 3 then
            table.insert(Accessory, item.Name)

        elseif item.Type == "Material" and item.Rarity >= 3 then
            local Material = string.format("%s[%s]", item.Name, tostring(item.Count))
            table.insert(Materials, Material)
        end
    end

    return swordList, fruits, Accessory, Materials

end

-- เช็คใน Character และ Backpack เพื่อดึง Mastery ของผลปีศาจ
function checkfruitsMastery()
    local fruitName = game.Players.LocalPlayer.Data.DevilFruit.Value

    if game.Players.LocalPlayer.Backpack:FindFirstChild(fruitName) then
        return game.Players.LocalPlayer.Backpack:FindFirstChild(fruitName).Level.Value
    elseif game.Players.LocalPlayer.Character:FindFirstChild(fruitName) then
        return game.Players.LocalPlayer.Character:FindFirstChild(fruitName).Level.Value
    end
end


function check_melee()
    melee_list = {
        "Godhuman", "Sharkman Karate", "Death Step", "Electric Claw", "Dragon Talon",
        "Superhuman", "Dragon Claw", "Fishman Karate", "Electro", "Black Leg", "Combat"
    }
    -- ตรวจสอบใน Character
    for _, child in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
        if table.find(melee_list, child.Name) then  -- ค้นหาชื่อใน melee_list
            return child.Name
        end
    end

    -- ตรวจสอบใน Backpack
    for _, child in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
        if table.find(melee_list, child.Name) then  -- ค้นหาชื่อใน melee_list
            return child.Name
        end
    end
end

-- เช็คว่ามีผลปีศาจถืออยู่หรืออยู่ในกระเป๋า
function checkfruits()
    for _, child in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
        if string.find(child.Name, "-") then
            return child.Name
        end
    end

    for _, child in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
        if string.find(child.Name, "-") then
            return child.Name
        end
    end
end

-- เช็คว่าผลปีศาจที่ใช้ปลุกพลังอะไรบ้าง
function checkawaken()
    local awakened = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("getAwakenedAbilities")
    local awakenedIndices = {}

    if awakened then
        for i, weapon in pairs(awakened) do
            if weapon.Awakened == true then
                table.insert(awakenedIndices, i)
            end
        end
    end

    return awakenedIndices -- หรือ table.concat(awakenedIndices, ", ") ถ้าต้องการเป็น string
end


--function cutLastPartByDash(str)
--    local lastDash = str:match(".*()%-")
--    if lastDash then
--        return str:sub(1, lastDash - 1)
--    end
--    return str
--end

function cutLastPartByDash(str)
    local count = 0
    for i = 1, #str do
        if str:sub(i, i) == "-" then
            count = count + 1
            if count == 2 then
                return str:sub(1, i - 1)
            end
        end
    end
    -- ถ้ามีน้อยกว่า 2 ตัว ให้ใช้แบบตัดตัวแรก
    return string.match(str, "^(.-)-") or str
end

function processcheckDevilfruits()
    local devilfruit = checkfruits()
    if devilfruit then
        -- ตรวจสอบว่ามีกี่ตัว '-'
        local _, dashCount = string.gsub(devilfruit, "-", "")
        
        local shortName
        if dashCount >= 2 then
            shortName = cutLastPartByDash(devilfruit)
        else
            shortName = string.match(devilfruit, "^(.-)-")
        end

        -- เรียกดู Mastery
        local mas = checkfruitsMastery()
        
        -- แสดงผลในรูปแบบ shortName[mas]
        local result = string.format("%s[%d]", shortName, mas)
        
        -- ตรวจสอบ Awakening
        local awakening_skill = checkawaken()
        if awakening_skill == '' then
            awakening_skill = '-'
        end

        return result, awakening_skill
    else 
        return "-", "-"
    end
end


function checkworld()
    if game.PlaceId == 2753915549 then
        return 1
    elseif game.PlaceId == 4442272183 then
        return 2 
    elseif game.PlaceId == 7449423635 then
        return 3
    end
end

function checkrace()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RacePlayer = Players.LocalPlayer.Data.Race.Value
    if game:GetService("Players").LocalPlayer.Data.Race:FindFirstChild("Evolved") then
        Isv2 = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("Wenlocktoad","info")

        if typeof(Isv2) == "string" and string.find(Isv2, "haven") then
            return RacePlayer .. " V2"
        end

        local check,result = ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check")
        if result then
            local V4_T = string.format(" V4[T%s]", result)
            return RacePlayer .. V4_T
        else
            return RacePlayer .. " V3"
        end

    else
        return RacePlayer .. " V1"
    end
end


function shortenNumber(num)
    local absNum = math.abs(num)
    local suffix = ""
    local formatted

    if absNum >= 1e9 then
        formatted = num / 1e9
        suffix = "B"
    elseif absNum >= 1e6 then
        formatted = num / 1e6
        suffix = "M"
    elseif absNum >= 1e3 then
        formatted = num / 1e3
        suffix = "K"
    else
        return tostring(num) -- ไม่ต้องแปลง
    end

    -- ถ้าลงตัวไม่ต้องใส่ทศนิยม เช่น 150.0 → 150
    if formatted == math.floor(formatted) then
        return string.format("%d%s", formatted, suffix)
    else
        return string.format("%.1f%s", formatted, suffix)
    end
end

function encode_inventory_to_json()
    local HttpService = game:GetService("HttpService")
    local lever = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("CheckTempleDoor")
    local melee = check_melee()
    local world = checkworld()
    local swords, fruits, accessories, materials = checksword_mastery_json()
    local Lv = game:GetService("Players").LocalPlayer.Data.Level.Value
    --- calculate -----
    local Beli_2 = game:GetService("Players")["LocalPlayer"].Data.Beli.Value
    local Beli = shortenNumber(Beli_2)
    local Fragment_2 = game:GetService("Players")["LocalPlayer"].Data.Fragments.Value
    local Fragment = shortenNumber(Fragment_2)
    -------- end calculate ------
    local PlayerRace = checkrace()
    local bounty_2 = game:GetService("Players")["LocalPlayer"].leaderstats["Bounty/Honor"].Value
    local bounty = shortenNumber(bounty_2)
    --------- Devil Player ------
    local Devil_Fruits, Awakening_Skill = processcheckDevilfruits()
    local result = {
        PlayerLevel = Lv or "-",
        Money = Beli or "-",
        Fragment = Fragment or "-",
        Meelee = melee or "-",
        DevilFruits = Devil_Fruits or "-",
        AwakeningSkill = Awakening_Skill or "-",
        Race = PlayerRace or "-",
        Weapons = swords or "-",
        fruits = fruits or "-",
        Accessory = accessories or "-",
        Materials = materials or "-",
        World = world or "-",
        Lever = lever,
        Bounty = bounty,
    }
    print("Sent data 22222 !!")
    return HttpService:JSONEncode(result)
end

local js_string = encode_inventory_to_json()
print(js_string)
_G.ws:Send(playerName .. ">>" .. "BF".. ">>" .. js_string)
