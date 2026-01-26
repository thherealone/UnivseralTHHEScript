local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- DEVICE CHECK
local IsMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, game:GetService("UserInputService"):GetPlatform()) ~= nil
local DeviceType = IsMobile and "Mobile" or "PC"

local Window = Rayfield:CreateWindow({
    Name = "THHE Hub | v1.0 Release",
    Icon = 0,
    LoadingTitle = "Loading Original Hub",
    LoadingSubtitle = "Optimization for " .. DeviceType,
    Theme = "Default",
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
    ESP_Color = Color3.fromRGB(255, 255, 255),
    Aimbot_Enabled = false,
    Aimbot_MobileLock = false,
    Aimbot_Smooth = 0.1,
    Aimbot_FOV = 120,
    HitboxSize = 2,
    Fly_Enabled = false,
    Fly_Speed = 60,
    FlyUp = false,
    FlyDown = false,
    Noclip = false, -- NEU
    AntiAFK = true
}

-- MOBILE OVERLAY (OPTIMIERT)
if IsMobile then
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    
    local function CreateMobileBtn(text, pos, color)
        local b = Instance.new("TextButton", ScreenGui)
        b.Size = UDim2.new(0, 90, 0, 45)
        b.Position = pos
        b.Text = text
        b.BackgroundColor3 = color or Color3.fromRGB(35, 35, 35)
        b.TextColor3 = Color3.new(1,1,1)
        b.BorderSizePixel = 2
        b.Draggable = true -- Wichtig für Mobile!
        return b
    end

    local AimBtn = CreateMobileBtn("AIM: OFF", UDim2.new(0.05, 0, 0.4, 0), Color3.fromRGB(60, 0, 0))
    local UpBtn = CreateMobileBtn("FLY UP", UDim2.new(0.85, 0, 0.4, 0))
    local DownBtn = CreateMobileBtn("FLY DOWN", UDim2.new(0.85, 0, 0.5, 0))

    AimBtn.MouseButton1Click:Connect(function()
        Settings.Aimbot_MobileLock = not Settings.Aimbot_MobileLock
        AimBtn.Text = Settings.Aimbot_MobileLock and "AIM: ON" or "AIM: OFF"
        AimBtn.BackgroundColor3 = Settings.Aimbot_MobileLock and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(60, 0, 0)
    end)
    
    UpBtn.MouseButton1Down:Connect(function() Settings.FlyUp = true end)
    UpBtn.MouseButton1Up:Connect(function() Settings.FlyUp = false end)
    DownBtn.MouseButton1Down:Connect(function() Settings.FlyDown = true end)
    DownBtn.MouseButton1Up:Connect(function() Settings.FlyDown = false end)
end

-- TABS
local CombatTab = Window:CreateTab("Combat", 4483362458)
local VisTab = Window:CreateTab("Visuals", 4483362458)
local CharTab = Window:CreateTab("Movement", 4483362458)

--- COMBAT ---
CombatTab:CreateToggle({
    Name = "Aimbot Enabled",
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot_Enabled = v end
})

CombatTab:CreateSlider({
    Name = "Hitbox Expander",
    Range = {2, 30},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(v) Settings.HitboxSize = v end
})

CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {50, 800},
    Increment = 10,
    CurrentValue = 120,
    Callback = function(v) Settings.Aimbot_FOV = v end
})

--- VISUALS ---
VisTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Callback = function(v) Settings.ESP_Box = v end
})

VisTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.ESP_Color,
    Callback = function(v) Settings.ESP_Color = v end
})

--- MOVEMENT & NOCLIP ---
CharTab:CreateToggle({
    Name = "No-Clip (Walk through Walls)",
    CurrentValue = false,
    Callback = function(v) Settings.Noclip = v end
})

CharTab:CreateToggle({
    Name = "Fly (Mobile Buttons / Space-Shift)",
    CurrentValue = false,
    Callback = function(v) Settings.Fly_Enabled = v end
})

CharTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 10,
    CurrentValue = 60,
    Callback = function(v) Settings.Fly_Speed = v end
})

CharTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v) if lplr.Character then lplr.Character.Humanoid.WalkSpeed = v end end
})

CharTab:CreateSlider({
    Name = "JumpHeight",
    Range = {50, 400},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) 
        if lplr.Character then 
            lplr.Character.Humanoid.UseJumpPower = false
            lplr.Character.Humanoid.JumpHeight = v 
        end 
    end
})

-- LOGIC SYSTEMS
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 100
FOVCircle.Filled = false

local function GetClosest()
    local target, dist = nil, Settings.Aimbot_FOV
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lplr and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local m = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if m < dist then target = p; dist = m end
            end
        end
    end
    return target
end

-- RENDER LOOP (Noclip, Fly, Hitbox, Aimbot)
local PlayerDrawings = {}

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Settings.Aimbot_Enabled
    FOVCircle.Radius = Settings.Aimbot_FOV
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = Settings.ESP_Color

    -- 1. Fly Logic
    if Settings.Fly_Enabled and lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lplr.Character.HumanoidRootPart
        local hum = lplr.Character.Humanoid
        local vertical = 0
        if UIS:IsKeyDown(Enum.KeyCode.Space) or Settings.FlyUp then vertical = Settings.Fly_Speed end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or Settings.FlyDown then vertical = -Settings.Fly_Speed end
        hrp.Velocity = (hum.MoveDirection * Settings.Fly_Speed) + Vector3.new(0, vertical + 1, 0)
    end

    -- 2. Noclip (Loop durch alle Parts)
    if Settings.Noclip and lplr.Character then
        for _, part in pairs(lplr.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- 3. Players Loop (Hitbox & ESP)
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= lplr and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Hitbox
                hrp.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                hrp.Transparency = 0.8
                
                -- Box ESP
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

    -- 4. Aimbot Execution
    if Settings.Aimbot_Enabled and (UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or Settings.Aimbot_MobileLock) then
        local t = GetClosest()
        if t then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, t.Character.Head.Position), 0.15)
        end
    end
end)

-- ANTI-AFK (Fixed)
lplr.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

Rayfield:Notify({Title = "Mobile v5.0 Loaded", Content = "No-Clip & Fly Master ready!", Duration = 4})
