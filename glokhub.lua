repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- SETTINGS
local fileName = "glokhubv9_settings.json"

local Settings = {
    Notifier = false,
    AutoGrab = false,
    ServerHop = false,
    AutoTPBase = false,
    ESPPlayers = false,
    ESPBrainrot = false,
    XRay = false,
    Desync = false,
    Speed = 16,  -- default walkspeed
}

pcall(function()
    if isfile(fileName) then
        local data = HttpService:JSONDecode(readfile(fileName))
        for k, v in pairs(data) do Settings[k] = v end
    end
end)

local function saveSettings()
    writefile(fileName, HttpService:JSONEncode(Settings))
end

local basePosition = nil
local visitedServers = {}
local brainrotList = {}  -- for hunter tab

-- NOTIFY
local function notify(title, msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {Title = title or "Glok Hub v9", Text = msg, Duration = 6})
    end)
end

-- Remove old GUI
if CoreGui:FindFirstChild("GlokHubV9") then CoreGui.GlokHubV9:Destroy() end

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "GlokHubV9"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999

local mainFrame = Instance.new("Frame", gui)
mainFrame.Size = UDim2.new(0, 340, 0, 460)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "GLOK HUB V9"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold

-- Tabs
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1, 0, 0, 35)
tabFrame.Position = UDim2.new(0, 0, 0, 40)
tabFrame.BackgroundTransparency = 1

local mainTab = Instance.new("ScrollingFrame", mainFrame)
mainTab.Size = UDim2.new(1, 0, 1, -80)
mainTab.Position = UDim2.new(0, 0, 0, 75)
mainTab.BackgroundTransparency = 1
mainTab.ScrollBarThickness = 4
mainTab.CanvasSize = UDim2.new(0,0,0,300)

local hunterTab = mainTab:Clone()
hunterTab.Parent = mainFrame
hunterTab.Visible = false
hunterTab.CanvasSize = UDim2.new(0,0,0,0)

local function createTabButton(text, posX, targetTab)
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(0.5, 0, 1, 0)
    btn.Position = UDim2.new(posX, 0, 0, 0)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        mainTab.Visible = false
        hunterTab.Visible = false
        targetTab.Visible = true
    end)
end

createTabButton("Main", 0, mainTab)
createTabButton("Brainrot Hunter", 0.5, hunterTab)

-- UI Helpers
local yOffset = 10
local function addToggle(parent, name, setting, y)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y or yOffset)
    btn.Text = name
    btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.new(1,1,1)

    btn.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        btn.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(50, 50, 50)
        saveSettings()
    end)
    yOffset += 45
    return btn
end

local function addButton(parent, name, callback, y)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y or yOffset)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(callback)
    yOffset += 45
end

local function addSlider(parent, name, setting, min, max, y)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, y or yOffset)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1,0,0.5,0)
    label.Text = name .. ": " .. Settings[setting]
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1,1,1)

    local slider = Instance.new("TextButton", frame)
    slider.Size = UDim2.new(1,0,0.5,0)
    slider.Position = UDim2.new(0,0,0.5,0)
    slider.BackgroundColor3 = Color3.fromRGB(60,60,60)

    -- Simple slider logic (you can improve with dragging)
    slider.MouseButton1Click:Connect(function()
        local val = math.clamp(Settings[setting] + 4, min, max)
        Settings[setting] = val
        label.Text = name .. ": " .. val
        saveSettings()
        if setting == "Speed" and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = val
        end
    end)
    yOffset += 60
end

-- Main Tab
yOffset = 10
addToggle(mainTab, "Notifier", "Notifier")
addToggle(mainTab, "Auto Grab", "AutoGrab")
addToggle(mainTab, "Server Hop (when no good brainrot)", "ServerHop")
addToggle(mainTab, "Auto TP to Base", "AutoTPBase")
addToggle(mainTab, "Desync (Anti-Detection)", "Desync")
addSlider(mainTab, "WalkSpeed", "Speed", 16, 150)

addButton(mainTab, "Set Base Position", function()
    if hrp then
        basePosition = hrp.Position
        notify("Base Set", "Position saved!")
    end
end)

-- Hunter Tab (will be populated dynamically)
local hunterList = Instance.new("ScrollingFrame", hunterTab)
hunterList.Size = UDim2.new(1, -20, 1, -10)
hunterList.Position = UDim2.new(0, 10, 0, 10)
hunterList.BackgroundTransparency = 1
hunterList.ScrollBarThickness = 6
hunterList.CanvasSize = UDim2.new(0,0,0,0)

-- Simple Desync (makes movement look laggy to server)
local desyncConnection
local function toggleDesync(enable)
    if desyncConnection then desyncConnection:Disconnect() end
    if not enable then return end

    desyncConnection = RunService.Heartbeat:Connect(function()
        if Settings.Desync and hrp then
            hrp.AssemblyLinearVelocity = hrp.AssemblyLinearVelocity + Vector3.new(math.random(-5,5), 0, math.random(-5,5))
        end
    end)
end

-- Improved Brainrot Finder
local function findHighValueBrainrots()
    brainrotList = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("TextLabel") and string.find(string.lower(obj.Text), "sec") then
            local valStr = string.lower(obj.Text)
            local num = tonumber(valStr:match("%d+%.?%d*")) or 0
            if valStr:find("b") then num = num * 1000 end
            if num >= 100 and num <= 1000 then  -- 100M to 1B
                local model = obj:FindFirstAncestorWhichIsA("Model") or obj.Parent
                if model then
                    table.insert(brainrotList, {model = model, value = num, text = obj.Text})
                end
            end
        end
    end
end

-- Create Hunter Entry
local function createHunterEntry(brainrot)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, 0, 0, 90)
    entry.BackgroundColor3 = Color3.fromRGB(30,30,30)

    -- Picture (try to find image or use placeholder)
    local img = Instance.new("ImageLabel", entry)
    img.Size = UDim2.new(0, 70, 0, 70)
    img.Position = UDim2.new(0, 10, 0, 10)
    img.BackgroundTransparency = 1
    -- Try to find a thumbnail in the model (common in tycoon/steal games)
    local thumb = brainrot.model:FindFirstChild("Thumbnail") or brainrot.model:FindFirstChildWhichIsA("ImageLabel") or brainrot.model:FindFirstChildWhichIsA("Decal")
    if thumb and thumb.Image then
        img.Image = thumb.Image
    else
        img.Image = "rbxassetid://0"  -- replace with a brainrot placeholder id if you want
        img.BackgroundColor3 = Color3.fromRGB(100,0,100)
    end

    local valLabel = Instance.new("TextLabel", entry)
    valLabel.Size = UDim2.new(0.6, 0, 0, 30)
    valLabel.Position = UDim2.new(0.3, 0, 0, 10)
    valLabel.Text = brainrot.value .. "M/sec"
    valLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    valLabel.BackgroundTransparency = 1
    valLabel.TextScaled = true

    local joinBtn = Instance.new("TextButton", entry)
    joinBtn.Size = UDim2.new(0.6, 0, 0, 30)
    joinBtn.Position = UDim2.new(0.3, 0, 0, 50)
    joinBtn.Text = "Join & Steal"
    joinBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)

    joinBtn.MouseButton1Click:Connect(function()
        notify("Stealing", "Going for " .. brainrot.value .. "M/sec brainrot...")
        
        -- TP to brainrot in current server first (if already here)
        if brainrot.model and hrp then
            tweenTo(brainrot.model:GetPivot().Position + Vector3.new(0, 5, 0))
        end

        -- Auto Grab sequence
        task.spawn(function()
            if Settings.Desync then toggleDesync(true) end

            -- Auto grab logic (your original + improvements)
            task.wait(0.5)
            local prompt = brainrot.model:FindFirstChildOfClass("ProximityPrompt", true)
            if prompt then
                fireproximityprompt(prompt)
            end

            -- Wait for steal timer (adjust this value based on game)
            task.wait(8)  -- typical steal timer in many games

            if Settings.AutoTPBase and basePosition then
                tweenTo(basePosition)
            end

            toggleDesync(false)
            notify("Steal Complete", "Returned to base")
        end)
    end)

    entry.Parent = hunterList
end

-- Tween TP (smooth, low detection)
local function tweenTo(pos)
    if not hrp then return end
    local dist = (hrp.Position - pos).Magnitude
    local tween = TweenService:Create(hrp, TweenInfo.new(dist / 120, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- Main Loop
spawn(function()
    while task.wait(3) do
        findHighValueBrainrots()

        if Settings.Notifier and #brainrotList > 0 then
            notify("Brainrot Found!", #brainrotList .. " high value detected!")
        end

        -- Update Hunter UI
        for _, child in ipairs(hunterList:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        hunterList.CanvasSize = UDim2.new(0,0,0, #brainrotList * 100)

        for i, br in ipairs(brainrotList) do
            createHunterEntry(br)
        end

        -- Auto Grab in current server (your original logic)
        if Settings.AutoGrab and #brainrotList > 0 then
            for _, br in ipairs(brainrotList) do
                tweenTo(br.model:GetPivot().Position + Vector3.new(0,3,0))
                task.wait(0.5)
                -- fire prompt / click / touch here (same as before)
                local prompt = br.model:FindFirstChildOfClass("ProximityPrompt", true)
                if prompt then fireproximityprompt(prompt) end
                task.wait(1)
            end
        end

        -- Server Hop logic (only if no good brainrot and toggle on)
        if Settings.ServerHop and #brainrotList == 0 then
            -- your original server hop code here
            pcall(function()
                local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                local data = HttpService:JSONDecode(game:HttpGet(url))
                for _, s in ipairs(data.data or {}) do
                    if s.playing < s.maxPlayers and not visitedServers[s.id] then
                        visitedServers[s.id] = true
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
                        break
                    end
                end
            end)
        end

        -- Speed
        if character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = Settings.Speed
        end
    end
end)

-- Desync toggle listener
Settings.DesyncChanged = Settings.Desync  -- dummy, better to use connection on toggle
addToggle(mainTab, "Desync", "Desync")  -- move this if needed

notify("GlokHub v9 Loaded", "Brainrot Hunter tab is ready!")
