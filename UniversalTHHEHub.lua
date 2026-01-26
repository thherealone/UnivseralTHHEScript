local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- DEVICE CHECK
local IsMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, game:GetService("UserInputService"):GetPlatform()) ~= nil
local DeviceType = IsMobile and "Mobile" or "PC"

local Window = Rayfield:CreateWindow({
    Name = "THHE Hub | v4.5 Original Style",
    Icon = 0,
    LoadingTitle = "Initializing Original Hub",
    LoadingSubtitle = "Detected: " .. DeviceType,
    Theme = "Default", -- Zurück zum Standard-Blau/Grau
    ConfigurationSaving = { Enabled = true, FolderName = "THHE_Configs", FileName = "Config" },
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    ShowText = "Menu"
})

-- SERVICES
local lplr = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- SETTINGS
local Settings = {
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_TeamCheck = false,
    ESP_Color = Color3.fromRGB(255, 255, 255),
    Aimbot_Enabled = false,
    Aimbot_MobileLock = false,
    Aimbot_Smooth = 0.1,
    Aimbot_FOV = 100,
    Aimbot_Part = "Head",
    HitboxSize = 2, -- NEU
    Fly_Enabled = false,
    Fly_Speed = 50,
    FlyUp = false, -- NEU für Steuerung
    FlyDown = false, -- NEU für Steuerung
    Invisible = false, -- NEU
    AntiAFK = true
}

-- MOBILE OVERLAY (UP/DOWN BUTTONS)
if IsMobile then
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    
    local function CreateMobileBtn(text, pos)
        local b = Instance.new("TextButton", ScreenGui)
        b.Size = UDim2.new(0, 80, 0, 40)
        b.Position = pos
        b.Text = text
        b.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        b.TextColor3 = Color3.new(1,1,1)
        b.Draggable = true
        return b
    end

    local AimBtn = CreateMobileBtn("Aim: OFF", UDim2.new(0.1, 0, 0.4, 0))
    local UpBtn = CreateMobileBtn("UP", UDim2.new(0.85, 0, 0.4, 0))
    local DownBtn = CreateMobileBtn("DOWN", UDim2.new(0.85, 0, 0.5, 0))

    AimBtn.MouseButton1Click:Connect(function()
        Settings.Aimbot_MobileLock = not Settings.Aimbot_MobileLock
        AimBtn.Text = Settings.Aimbot_MobileLock and "Aim: ON" or "Aim: OFF"
    end)
    UpBtn.MouseButton1Down:Connect(function() Settings.FlyUp = true end)
    UpBtn.MouseButton1Up:Connect(function() Settings.FlyUp = false end)
    DownBtn.MouseButton1Down:Connect(function() Settings.FlyDown = true end)
    DownBtn.MouseButton1Up:Connect(function() Settings.FlyDown = false end)
end

-- TABS
local CharTab = Window:CreateTab("Character", 4483362458)
local VisTab = Window:CreateTab("Visuals", 4483362458)
local AimTab = Window:CreateTab("Combat", 4483362458)

--- COMBAT (HITBOX INKLUSIVE) ---
AimTab:CreateToggle({
    Name = "Aimbot Enabled",
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot_Enabled = v end
})

AimTab:CreateSlider({
    Name = "Hitbox Expander", -- NEU
    Range = {2, 25},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(v) Settings.HitboxSize = v end
})

AimTab:CreateSlider({
    Name = "Aimbot Smoothness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(v) Settings.Aimbot_Smooth = (11 - v) / 10 end
})

AimTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 600},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(v) Settings.Aimbot_FOV = v end
})

--- VISUALS ---
VisTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Callback = function(v) Settings.ESP_Box = v end
})

VisTab:CreateToggle({
    Name = "Skeleton ESP",
    CurrentValue = false,
    Callback = function(v) Settings.ESP_Skeleton = v end
})

VisTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.ESP_Color,
    Callback = function(v) Settings.ESP_Color = v end
})

--- CHARACTER & MOVEMENT (FLY & INVISIBLE) ---
CharTab:CreateToggle({
    Name = "Elite Fly (Space/Shift)", -- VERBESSERT
    CurrentValue = false,
    Callback = function(v) Settings.Fly_Enabled = v end
})

CharTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(v) Settings.Fly_Speed = v end
})

CharTab:CreateToggle({
    Name = "Invisible Mode", -- NEU
    CurrentValue = false,
    Callback = function(v)
        Settings.Invisible = v
        if lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
            if v then
                lplr.Character.HumanoidRootPart.RootJoint.C1 = CFrame.new(0, 500, 0) -- Schiebt Charakter-Modell weg
            else
                lplr.Character.HumanoidRootPart.RootJoint.C1 = CFrame.new(0, 0, 0)
            end
        end
    end
})

CharTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) if lplr.Character then lplr.Character.Humanoid.WalkSpeed = v end end
})

CharTab:CreateSlider({
    Name = "JumpHeight",
    Range = {50, 300},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) 
        if lplr.Character then 
            lplr.Character.Humanoid.UseJumpPower = false
            lplr.Character.Humanoid.JumpHeight = v 
        end 
    end
})

-- LOGIC CORE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Filled = false

local function GetClosest()
    local target, dist = nil, Settings.Aimbot_FOV
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lplr and p.Character and p.Character:FindFirstChild(Settings.Aimbot_Part) then
            local pos, vis = camera:WorldToViewportPoint(p.Character[Settings.Aimbot_Part].Position)
            if vis then
                local magnitude = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if magnitude < dist then target = p; dist = magnitude end
            end
        end
    end
    return target
end

-- MAIN ENGINE
local PlayerDrawings = {}

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.Aimbot_Enabled
    FOVCircle.Radius = Settings.Aimbot_FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = Settings.ESP_Color

    -- Fly Engine (Vollständige Höhensteuerung)
    if Settings.Fly_Enabled and lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lplr.Character.HumanoidRootPart
        local hum = lplr.Character.Humanoid
        local vertical = 0
        
        if UIS:IsKeyDown(Enum.KeyCode.Space) or Settings.FlyUp then vertical = Settings.Fly_Speed end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or Settings.FlyDown then vertical = -Settings.Fly_Speed end
        
        hrp.Velocity = (hum.MoveDirection * Settings.Fly_Speed) + Vector3.new(0, vertical + 1.2, 0)
    end

    -- Hitbox & ESP Loop
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lplr and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Hitbox Expander
                hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                hrp.Transparency = 0.8 -- Leicht sichtbar zur Kontrolle
                
                -- Box ESP Rendering
                if not PlayerDrawings[p] then PlayerDrawings[p] = Drawing.new("Square") end
                local box = PlayerDrawings[p]
                local pos, vis = camera:WorldToViewportPoint(hrp.Position)
                
                if vis and Settings.ESP_Box then
                    local s = 2500 / pos.Z
                    box.Visible = true
                    box.Size = Vector2.new(s, s * 1.5)
                    box.Position = Vector2.new(pos.X - s/2, pos.Y - (s*1.5)/2)
                    box.Color = Settings.ESP_Color
                else box.Visible = false end
            end
        end
    end

    -- Aimbot Execution
    if Settings.Aimbot_Enabled and (UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or Settings.Aimbot_MobileLock) then
        local t = GetClosest()
        if t and t.Character then
            local targetPos = t.Character[Settings.Aimbot_Part].Position
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, targetPos), Settings.Aimbot_Smooth)
        end
    end
end)

-- ANTI-AFK (Fixed)
lplr.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

Rayfield:Notify({Title = "Ready!", Content = "Original Style v4.5 Loaded. Hitboxes & Elite Fly active.", Duration = 4})
