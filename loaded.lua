-- รอจนกว่าเกมจะโหลดเสร็จ
if not game:IsLoaded() then
    game.Loaded:Wait()
end
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")
--repeat wait(1) until game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main")

-- รอจนกว่าจะมี LocalPlayer
local Players = game:GetService("Players")
repeat wait() until Players.LocalPlayer

-------------------------------------------------------------------------
local playerName = game.Players.LocalPlayer.Name
local player = Players.LocalPlayer
local TeleportService = game:GetService("TeleportService")

local WebSocket = WebSocket or (syn and syn.websocket) or nil

if not WebSocket then
    warn("[Client] ไม่รองรับ WebSocket ใน exploit นี้")
    return
end

--local ws = WebSocket.connect("ws://127.0.0.1:8765")
_G.ws = WebSocket.connect("ws://127.0.0.1:8765")
if not _G.ws then
    warn("[Client] ไม่สามารถเชื่อมต่อ WebSocket ได้")
    return
end

-- สร้างข้อมูลแบบ form-urlencoded
--local playerName = game.Players.LocalPlayer.Name
--local jobId = game.JobId or "unknown"
--local message = playerName .. "|" .. jobId

local function getMessage()
    local playerName = game.Players.LocalPlayer.Name
    local jobId = game.JobId or "unknown"
    return playerName .. "|" .. jobId
end

-- รอรับข้อมูลตอบกลับอย่างต่อเนื่อง
_G.ws.OnMessage:Connect(function(msg)
    -- รับข้อมูล แต่ไม่ทำอะไร
end)

-- จัดการเมื่อการเชื่อมต่อถูกปิด
_G.ws.OnClose:Connect(function()
    warn("[Client] การเชื่อมต่อถูกปิด")
end)


local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local currentPlaceId = game.PlaceId
local currentJobId = game.JobId -- JobId ของเซิร์ฟเวอร์นี้

local function teleportSameJob()
    local success, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(currentPlaceId, currentJobId, player)
    end)

    --if success then
    --    print("Teleport ไปยัง Job เดิมสำเร็จ!")
    --else
    --    warn("Teleport ล้มเหลว: " .. tostring(errorMessage))
    --    game:Shutdown()
    --end
end

local GuiService = game:GetService("GuiService")

local function testkick()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer

    -- Kick the local player with a message
    player:Kick("You have been kicked from the game.")
end

local function checkdiscon()
    local errorCode = GuiService:GetErrorCode()
    local errorValue = errorCode.Value
    local errorName = errorCode.Name

    -- พิมพ์ข้อมูลข้อผิดพลาด
    --print("New Error Detected!")
    --print("Error Name:", errorName)
    --print("Error Code:", errorValue)

    if (string.find(errorName, "Disconnect") or
    string.find(errorName, "Shutdown") or
    string.find(errorName, "End") or
    string.find(errorName, "auth")) and
    not string.find(errorName, "Request") then
        --print("True")
        _G.ws:Close() -- ปิดการเชื่อมต่อ WebSocket
        testkick()
        wait(4)
        teleportSameJob() -- เรียกฟังก์ชันเพื่อ teleport ไปเซิร์ฟเวอร์ใหม่
        --game:Shutdown()
        return true
    end
    return false
end -- <- this 'end' was missing!

-- เชื่อมต่อเหตุการณ์ ErrorMessageChanged
GuiService.ErrorMessageChanged:Connect(function()
    checkdiscon()
end)


if not game:IsLoaded() then game.Loaded:Wait(20) end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function showMessage(message, duration)
    local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    local textLabel = Instance.new("TextLabel", screenGui)
    
    textLabel.Size = UDim2.new(0.5, 0, 0.1, 0)
    textLabel.Position = UDim2.new(0.25, 0, 0.4, 0)
    textLabel.Text = message
    textLabel.TextScaled = true
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    textLabel.TextColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    
    task.wait(duration)
    screenGui:Destroy()
end

local function addHalfPlayersAsFriends()
    local allPlayers = Players:GetPlayers()
    local totalPlayers = #allPlayers
    
    if totalPlayers > 1 then
        local halfCount = math.floor(totalPlayers / 1)
        local count = 0
        
        for _, player in ipairs(allPlayers) do
            if player ~= LocalPlayer then
                LocalPlayer:RequestFriendship(player)
                count += 1
                showMessage("Sent friend request to " .. count .. " players.", 1)
                if count >= halfCount then
                    break
                end
            end
        end
        
        showMessage("Add friends Sent Amount : " .. count .. " Players.", 3)
    else
        showMessage("Not enough players to add friends.", 3)
    end
end


local message = getMessage()
-- ส่งข้อมูล
_G.ws:Send(message)

local LogsCheck = HorstConfig["EnableLog"]
local HorstWhitescreen = HorstConfig["Whitescreen"]
local addfriends = HorstConfig["EnableAddFriends"]
---- Lock Fps
local lockEnabled = HorstConfig["LockFps"]["EnableLockFps"]
local fpsAmount = HorstConfig["LockFps"]["LockFpsAmount"]

if lockEnabled and lockEnabled == true then
    setfpscap(tonumber(fpsAmount)) -- หรือ math.floor(fpsAmount) ก็ได้
end

if HorstWhitescreen and HorstWhitescreen == true then
    game:GetService("RunService"):Set3dRenderingEnabled(false)
end

local PlaceId = game.PlaceId
task.spawn(function()
    local timer_xyz = 0

    while true do
        -- ส่งข้อความ keep alive และเช็คการตัดการเชื่อมต่อ
        pcall(function()
            _G.ws:Send("keep alive")
            checkdiscon()
        end)

        -- ตรวจสอบเงื่อนไขทุก 14 รอบ (70 วินาที)
        if timer_xyz >= 14 then
            if LogsCheck == true then
                if PlaceId == 2753915549 or PlaceId == 4442272183 or PlaceId == 7449423635 then
                    task.spawn(function()
                        local success, err = pcall(function()
                            loadstring(game:HttpGet("https://raw.githubusercontent.com/HorstSpaceX/api/refs/heads/main/programscript.lua"))()
                        end)
                        -- if not success then
                        --     warn("Error loading script:", err)
                        -- end
                    end)
                end
            end

            if addfriends and addfriends == true then
                addHalfPlayersAsFriends()
            end

            timer_xyz = 0
        end

        task.wait(5)
        timer_xyz = timer_xyz + 1
    end
end)
