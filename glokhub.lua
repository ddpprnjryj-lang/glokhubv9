repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- SETTINGS FILE
local fileName = "glokhub_settings.json"

local Settings = {
    Notifier = false,
    AutoGrab = false,
    AutoExecute = false,
    ServerHop = false,
    AutoTPBase = false,
    ESPPlayers = false,
    ESPBrainrot = false,
    XRay = false
}

-- LOAD SETTINGS
pcall(function()
    if readfile(fileName) then
        local data = HttpService:JSONDecode(readfile(fileName))
        for i,v in pairs(data) do
            Settings[i] = v
        end
    end
end)

-- SAVE SETTINGS
local function saveSettings()
    writefile(fileName, HttpService:JSONEncode(Settings))
end

local basePosition = nil
local visitedServers = {}

-- NOTIFY
local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "glok hub",
            Text = msg,
            Duration = 5
        })
    end)
end

-- REMOVE OLD GUI
if CoreGui:FindFirstChild("GlokHub") then
    CoreGui.GlokHub:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "GlokHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,400)
frame.Position = UDim2.new(0.5,-150,0.5,-200)
frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "GLOK HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- TABS
local tab1 = Instance.new("Frame", frame)
tab1.Size = UDim2.new(1,0,1,-60)
tab1.Position = UDim2.new(0,0,0,60)
tab1.BackgroundTransparency = 1

local tab2 = tab1:Clone()
tab2.Parent = frame
tab2.Visible = false

local function makeTabButton(name, x, tab)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.5,0,0,30)
    b.Position = UDim2.new(x,0,0,30)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)

    b.MouseButton1Click:Connect(function()
        tab1.Visible = false
        tab2.Visible = false
        tab.Visible = true
    end)
end

makeTabButton("Main", 0, tab1)
makeTabButton("ESP", 0.5, tab2)

-- BUTTON MAKER
local function toggleButton(parent, name, y, setting)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)

    local function update()
        if Settings[setting] then
            b.BackgroundColor3 = Color3.fromRGB(0,170,0)
        else
            b.BackgroundColor3 = Color3.fromRGB(40,40,40)
        end
    end
    update()

    b.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        update()
        saveSettings()
    end)
end

local function button(parent, name, y, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(70,70,70)
    b.MouseButton1Click:Connect(callback)
end

-- TAB 1 (MAIN)
toggleButton(tab1, "Notifier", 10, "Notifier")
toggleButton(tab1, "Auto Grab", 50, "AutoGrab")
toggleButton(tab1, "Auto Execute", 90, "AutoExecute")
toggleButton(tab1, "Server Hop", 130, "ServerHop")
toggleButton(tab1, "Auto TP Base", 170, "AutoTPBase")

button(tab1, "Set Base", 210, function()
    basePosition = player.Character.HumanoidRootPart.Position
    notify("Base Set")
end)

-- TAB 2 (ESP)
toggleButton(tab2, "ESP Players", 10, "ESPPlayers")
toggleButton(tab2, "ESP Brainrot", 50, "ESPBrainrot")
toggleButton(tab2, "X-Ray", 90, "XRay")

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

-- FIND BRAINROT USING TEXTLABEL "/sec"
local function findBrainrot()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("TextLabel") and string.find(string.lower(v.Text), "/sec") then
            local num = tonumber(string.match(v.Text, "%d+"))
            if num and num >= 100 then -- 100M+
                return v:FindFirstAncestorOfClass("Model"), num
            end
        end
    end
end

-- LOOP
spawn(function()
    while task.wait(2) do
        local model, value = findBrainrot()

        if model then
            if Settings.Notifier then
                notify("Brainrot Found: "..value.."M/sec")
            end

            if Settings.ESPBrainrot then
                if not model:FindFirstChild("Highlight") then
                    Instance.new("Highlight", model)
                end
            end

            if Settings.AutoExecute and Settings.AutoGrab then
                local hrp = player.Character.HumanoidRootPart
                hrp.CFrame = model:GetPivot() + Vector3.new(0,3,0)
                task.wait(0.5)

                local prompt = model:FindFirstChildOfClass("ProximityPrompt", true)
                if prompt then
                    fireproximityprompt(prompt)
                end

                if Settings.AutoTPBase and basePosition then
                    hrp.CFrame = CFrame.new(basePosition)
                end
            end
        end

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
