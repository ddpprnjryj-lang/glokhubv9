repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- SETTINGS SAVE
local fileName = "glokhub_settings.json"

local Settings = {
    Notifier = false,
    AutoGrab = false,
    ServerHop = false,
    AutoTPBase = false,
    ESPPlayers = false,
    ESPBrainrot = false,
    XRay = false
}

pcall(function()
    if readfile(fileName) then
        local data = HttpService:JSONDecode(readfile(fileName))
        for i,v in pairs(data) do
            Settings[i] = v
        end
    end
end)

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
gui.DisplayOrder = 999
gui.ResetOnSpawn = false

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

local function tabButton(name, x, tab)
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

tabButton("Main",0,tab1)
tabButton("ESP",0.5,tab2)

-- BUTTONS
local function toggle(parent,name,y,setting)
    local b = Instance.new("TextButton",parent)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)

    local function update()
        b.BackgroundColor3 = Settings[setting] and Color3.fromRGB(0,170,0) or Color3.fromRGB(40,40,40)
    end
    update()

    b.MouseButton1Click:Connect(function()
        Settings[setting] = not Settings[setting]
        update()
        saveSettings()
    end)
end

local function button(parent,name,y,callback)
    local b = Instance.new("TextButton",parent)
    b.Size = UDim2.new(1,-20,0,30)
    b.Position = UDim2.new(0,10,0,y)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(70,70,70)
    b.MouseButton1Click:Connect(callback)
end

-- MAIN TAB
toggle(tab1,"Notifier",10,"Notifier")
toggle(tab1,"Auto Grab",50,"AutoGrab")
toggle(tab1,"Server Hop",90,"ServerHop")
toggle(tab1,"Auto TP Base",130,"AutoTPBase")

button(tab1,"Set Base",170,function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        basePosition = char.HumanoidRootPart.Position
        notify("Base Set")
    end
end)

-- ESP TAB
toggle(tab2,"ESP Players",10,"ESPPlayers")
toggle(tab2,"ESP Brainrot",50,"ESPBrainrot")
toggle(tab2,"X-Ray",90,"XRay")

-- TWEEN TP (NO LAG BACK)
local function tweenTo(pos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local dist = (hrp.Position - pos).Magnitude
    local speed = 120

    local tween = TweenService:Create(hrp, TweenInfo.new(dist/speed,Enum.EasingStyle.Linear),{CFrame=CFrame.new(pos)})
    tween:Play()
    tween.Completed:Wait()
end

-- VALUE READER
local function getValue(text)
    text = string.lower(text)
    local num = tonumber(string.match(text,"%d+%.?%d*")) or 0
    if string.find(text,"b") then num = num * 1000 end
    return num
end

-- FIND BRAINROT
local function findBrainrot()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("TextLabel") and string.find(string.lower(v.Text),"sec") then
            local val = getValue(v.Text)
            if val >= 100 and val <= 1000 then
                local model = v:FindFirstAncestorOfClass("Model")
                if model then return model,val end
            end
        end
    end
end

-- MAIN LOOP
spawn(function()
    while task.wait(2) do
        local model,val = findBrainrot()

        if model then
            if Settings.Notifier then
                notify("Found: "..val.."M/sec")
            end

            if Settings.ESPBrainrot and not model:FindFirstChild("Highlight") then
                Instance.new("Highlight",model)
            end

            if Settings.AutoGrab then
                local hrp = player.Character.HumanoidRootPart

                tweenTo(model:GetPivot().Position + Vector3.new(0,3,0))
                task.wait(0.4)

                local prompt = model:FindFirstChildOfClass("ProximityPrompt",true)
                if prompt then
                    fireproximityprompt(prompt)
                else
                    local click = model:FindFirstChildOfClass("ClickDetector",true)
                    if click then
                        fireclickdetector(click)
                    else
                        for _,p in pairs(model:GetDescendants()) do
                            if p:IsA("BasePart") then
                                firetouchinterest(hrp,p,0)
                                firetouchinterest(hrp,p,1)
                            end
                        end
                    end
                end

                if Settings.AutoTPBase and basePosition then
                    tweenTo(basePosition)
                end
            end
        end

        if Settings.ServerHop and (not val or val < 100 or val > 1000) then
            local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
            local data = HttpService:JSONDecode(game:HttpGet(url))

            for _,s in pairs(data.data) do
                if s.playing < s.maxPlayers and not visitedServers[s.id] then
                    visitedServers[s.id] = true
                    TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id)
                    break
                end
            end
        end
    end
end)
