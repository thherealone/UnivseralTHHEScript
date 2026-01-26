local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- DEVICE CHECK
local IsMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, game:GetService("UserInputService"):GetPlatform()) ~= nil
local DeviceType = IsMobile and "Mobile" or "PC"

local Window = Rayfield:CreateWindow({
    Name = "Universal THHE Hub | " .. DeviceType,
    Icon = 0,
    LoadingTitle = "Universal System",
    LoadingSubtitle = "by THHE",
    Theme = "Default",
    ConfigurationSaving = { Enabled = true, FolderName = "THHE_Configs", FileName = "Config" },
    ToggleUIKeybind = Enum.KeyCode.RightShift,
    ShowText = "Open Menu"
})

-- SERVICES
local lplr = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- SETTINGS
local Settings = {
    ESP_Box = false,
    ESP_Skeleton = false,
    ESP_TeamCheck = false,
    ESP_Thickness = 2,
    ESP_Color = Color3.fromRGB(255, 255, 255),
    Aimbot_Enabled = false,
    Aimbot_TeamCheck = false,
    Aimbot_Color = Color3.fromRGB(255, 0, 0),
    FOV_Size = 100,
    AimSmooth = 0.1, -- Fixed Syntax
    AimPart = "Head",
    Fly_Enabled = false,
    Fly_Speed = 50
}

-- TABS
local CharTab = Window:CreateTab("Character", 4483362458)
local VisTab = Window:CreateTab("Visual", 4483362458)
local AimTab = Window:CreateTab("Aimbot", 4483362458)

--- CHARACTER ---
CharTab:CreateToggle({
    Name = "Infinity Jump",
    CurrentValue = false,
    Flag = "InfJump",
    Callback = function(v) _G.InfJump = v end
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
    Increment = 1,
    CurrentValue = 50,
    Callback = function(v) 
        if lplr.Character then 
            lplr.Character.Humanoid.UseJumpPower = false
            lplr.Character.Humanoid.JumpHeight = v 
        end 
    end
})

CharTab:CreateSection("Fly")
CharTab:CreateToggle({
    Name = "Fly Mode",
    CurrentValue = false,
    Callback = function(v) Settings.Fly_Enabled = v end
})

CharTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v) Settings.Fly_Speed = v end
})

--- VISUALS (ESP) ---
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

VisTab:CreateToggle({
    Name = "ESP Team Check",
    CurrentValue = false,
    Callback = function(v) Settings.ESP_TeamCheck = v end
})

VisTab:CreateSlider({
    Name = "ESP Thickness",
    Range = {1, 5},
    Increment = 1,
    CurrentValue = 2,
    Callback = function(v) Settings.ESP_Thickness = v end
})

VisTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Settings.ESP_Color,
    Callback = function(v) Settings.ESP_Color = v end
})

--- AIMBOT ---
AimTab:CreateParagraph({Title = "Warning", Content = "⚠️ This aimbot is new so be carefull!"})

AimTab:CreateToggle({
    Name = "Aimbot Enabled",
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot_Enabled = v end
})

AimTab:CreateToggle({
    Name = "Aimbot Team Check",
    CurrentValue = false,
    Callback = function(v) Settings.Aimbot_TeamCheck = v end
})

AimTab:CreateSlider({
    Name = "FOV Size",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(v) Settings.FOV_Size = v end
})

AimTab:CreateColorPicker({
    Name = "FOV Color",
    Color = Settings.Aimbot_Color,
    Callback = function(v) Settings.Aimbot_Color = v end
})

-- DRAWING UTILS
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Filled = false

local PlayerDrawings = {}

local function GetClosest()
    local target, dist = nil, Settings.FOV_Size
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= lplr and p.Character and p.Character:FindFirstChild(Settings.AimPart) then
            if Settings.Aimbot_TeamCheck and p.Team == lplr.Team then continue end
            local pos, vis = camera:WorldToViewportPoint(p.Character[Settings.AimPart].Position)
            if vis then
                local m = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if m < dist then target = p; dist = m end
            end
        end
    end
    return target
end

-- RENDER ENGINE
RunService.RenderStepped:Connect(function()
    -- FOV Update
    FOVCircle.Visible = Settings.Aimbot_Enabled
    FOVCircle.Radius = Settings.FOV_Size
    FOVCircle.Position = UIS:GetMouseLocation()
    FOVCircle.Color = Settings.Aimbot_Color

    -- Fly Logic
    if Settings.Fly_Enabled and lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart") then
        lplr.Character.HumanoidRootPart.Velocity = (lplr.Character.Humanoid.MoveDirection * Settings.Fly_Speed) + Vector3.new(0, 2, 0)
    end

    -- ESP Rendering
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= lplr then
            if not PlayerDrawings[p] then
                PlayerDrawings[p] = {
                    Box = Drawing.new("Square"),
                    Skel = Drawing.new("Line")
                }
            end
            local draw = PlayerDrawings[p]
            local char = p.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hrp = char.HumanoidRootPart
                local pos, vis = camera:WorldToViewportPoint(hrp.Position)
                local isTeammate = Settings.ESP_TeamCheck and p.Team == lplr.Team

                if vis and not isTeammate then
                    if Settings.ESP_Box then
                        local s = 2500 / pos.Z
                        draw.Box.Size = Vector2.new(s, s * 1.5)
                        draw.Box.Position = Vector2.new(pos.X - s/2, pos.Y - (s*1.5)/2)
                        draw.Box.Thickness = Settings.ESP_Thickness
                        draw.Box.Color = Settings.ESP_Color
                        draw.Box.Visible = true
                    else draw.Box.Visible = false end

                    if Settings.ESP_Skeleton and char:FindFirstChild("Head") then
                        local headPos = camera:WorldToViewportPoint(char.Head.Position)
                        draw.Skel.From = Vector2.new(headPos.X, headPos.Y)
                        draw.Skel.To = Vector2.new(pos.X, pos.Y)
                        draw.Skel.Thickness = Settings.ESP_Thickness
                        draw.Skel.Color = Settings.ESP_Color
                        draw.Skel.Visible = true
                    else draw.Skel.Visible = false end
                else
                    draw.Box.Visible = false
                    draw.Skel.Visible = false
                end
            else
                draw.Box.Visible = false
                draw.Skel.Visible = false
            end
        end
    end

    -- Aimbot Logic
    if Settings.Aimbot_Enabled and (UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or IsMobile) then
        local t = GetClosest()
        if t and t.Character and t.Character:FindFirstChild(Settings.AimPart) then
            if IsMobile then
                camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, t.Character[Settings.AimPart].Position), 0.1)
            else
                local tPos = camera:WorldToViewportPoint(t.Character[Settings.AimPart].Position)
                local mPos = UIS:GetMouseLocation()
                mousemoverel((tPos.X - mPos.X) * 0.2, (tPos.Y - mPos.Y) * 0.2)
            end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if _G.InfJump and lplr.Character then
        lplr.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Rayfield:Notify({Title = "Ready", Content = "THHE Hub is now active!", Duration = 3})
