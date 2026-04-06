repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

getgenv().Settings = {
    Notifier = false,
    AutoGrab = false,
    AutoExecute = false,
    ServerHop = false,
    AutoTPBase = false,
    ESPPlayers = false,
    ESPBrainrot = false,
    XRay = false,
    Desync = false
}

local basePosition = nil
local visitedServers = {}

-- NOTIFY + SOUND
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "glok hub",
            Text = msg,
            Duration = 5
        })
    end)

    local sound = Instance.new("Sound", workspace)
    sound.SoundId = "rbxassetid://9118823104"
    sound.Volume = 3
    sound:Play()
    game.Debris:AddItem(sound, 3)
end

-- REMOVE OLD GUI
if CoreGui:FindFirstChild("GlokHub") then
    CoreGui.GlokHub:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GlokHub"
gui.Parent = CoreGui
gui.ResetOnSpawn = false
gui.DisplayOrder = 999

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,260,0,450)
frame.Position = UDim2.new(0.5,-130,0.5,-225)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "GLOK HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- X BUTTON
local close = Instance.new("TextButton", frame)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(80,0,0)

-- GH BUTTON
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,60,0,30)
openBtn.Position = UDim2.new(0.5,-30,0,50)
openBtn.Text = "GH"
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
openBtn.Visible = false

close.MouseButton1Click:Connect(function()
    frame.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    frame.Visible = true
    openBtn.Visible = false
end)

-- BUTTONS
local function toggleButton(name, y, setting)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)

    b.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        if Settings[setting] then
            b.BackgroundColor3 = Color3.fromRGB(0,170,0)
        else
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        end
    end)
end

local function normalButton(name, y, callback)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(70,70,70)
    b.MouseButton1Click:Connect(callback)
end

toggleButton("Notifier", 40, "Notifier")
toggleButton("Auto Grab", 80, "AutoGrab")
toggleButton("Auto Execute", 120, "AutoExecute")
toggleButton("Server Hop", 160, "ServerHop")
toggleButton("Auto TP Base", 200, "AutoTPBase")
toggleButton("ESP Players", 240, "ESPPlayers")
toggleButton("ESP Brainrot", 280, "ESPBrainrot")
toggleButton("X-Ray", 320, "XRay")
toggleButton("Desync", 360, "Desync")

normalButton("Set Base", 400, function()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        basePosition = player.Character.HumanoidRootPart.Position
        notify("Base Set!")
    end
end)

-- PLAYER ESP
RunService.RenderStepped:Connect(function()
    if Settings.ESPPlayers then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                if not p.Character:FindFirstChild("Highlight") then
                    Instance.new("Highlight", p.Character)
                end
            end
        end
    end
end)

-- XRAY
RunService.RenderStepped:Connect(function()
    if Settings.XRay then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                v.LocalTransparencyModifier = 0.5
            end
        end
    end
end)

-- BRAINROT SCAN ($100M - $1B)
local function scanBrainrots()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "MoneyPerSecond" or v.Name == "$/sec" or v.Name == "CashPerSecond" then
            local val = tonumber(v.Value)
            if val and val >= 100000000 and val <= 1000000000 then

                local model = v:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChild("HumanoidRootPart") then

                    if Settings.Notifier then
                        notify("Brainrot Found: $"..math.floor(val/1000000).."M/sec")
                    end

                    if Settings.ESPBrainrot then
                        if not model:FindFirstChild("Highlight") then
                            local hl = Instance.new("Highlight")
                            hl.FillColor = Color3.new(1,1,1)
                            hl.Parent = model
                        end
                    end

                    if Settings.AutoExecute and Settings.AutoGrab then
                        local hrp = player.Character.HumanoidRootPart
                        hrp.CFrame = model.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                        task.wait(0.4)

                        local prompt = model:FindFirstChildOfClass("ProximityPrompt")
                        if prompt then
                            fireproximityprompt(prompt)
                        end

                        if Settings.AutoTPBase and basePosition then
                            hrp.CFrame = CFrame.new(basePosition)
                        end
                    end
                end
            end
        end
    end
end

spawn(function()
    while task.wait(1) do
        scanBrainrots()

        if Settings.ServerHop then
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            local data = HttpService:JSONDecode(game:HttpGet(url))

            for _, s in pairs(data.data) do
                if s.playing < s.maxPlayers and not visitedServers[s.id] then
                    visitedServers[s.id] = true
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                    break
                end
            end
        end
    end
end)
