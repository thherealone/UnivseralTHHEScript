local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

-- SERVICES
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lplr = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- SETTINGS
local Options = {
    -- Combat
    Aimbot = false,
    AimPart = "Head",
    AimSmooth = 0.1,
    AimFOV = 120,
    ShowAimFOV = true,
    HitboxExpander = 2,
    -- Movement
    Fly = false,
    FlySpeed = 60,
    Noclip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    -- Visuals (JETZT VOLLSTÄNDIG)
    BoxESP = false,
    Names = false,
    Chams = false,
    ESPColor = Color3.fromRGB(255, 255, 255),
    -- Internal
    SelectedPlayer = nil
}

-- WINDOW
local Window = Fluent:CreateWindow({
    Title = "THHE Hub",
    SubTitle = "feel free",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

-- TABS
local Tabs = {
    Aimbot = Window:AddTab({ Title = "Aimbot", Icon = "crosshair" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "zap" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" })
}

--- MISC TAB ---
Tabs.Misc:AddParagraph({
    Title = "⚠️ ATTENTION ⚠️",
    Content = "This script is new and universal so dont use it in games with good anticheat!\n\nDeveloper: THHE Owner"
})

--- AIMBOT TAB ---
Tabs.Aimbot:AddToggle("AimToggle", {Title = "Aimbot Enabled", Default = false}):OnChanged(function(v) Options.Aimbot = v end)
Tabs.Aimbot:AddToggle("ShowFOV", {Title = "Show Aimbot FOV", Default = true}):OnChanged(function(v) Options.ShowAimFOV = v end)
Tabs.Aimbot:AddSlider("FOVSize", {Title = "FOV Size", Default = 120, Min = 10, Max = 800, Rounding = 0}):OnChanged(function(v) Options.AimFOV = v end)
Tabs.Aimbot:AddSlider("Hitbox", {Title = "Hitbox Expander", Default = 2, Min = 2, Max = 40, Rounding = 0}):OnChanged(function(v) Options.HitboxExpander = v end)

--- TELEPORTS TAB ---
local PlayerDropdown = Tabs.Teleports:AddDropdown("SelectPlayer", {
    Title = "Select Player",
    Values = {},
    Default = nil,
    Callback = function(v) Options.SelectedPlayer = v end
})

Tabs.Teleports:AddButton({
    Title = "Refresh & Teleport",
    Callback = function()
        local newList = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= lplr then table.insert(newList, p.Name) end end
        PlayerDropdown:SetValues(newList)
        if Options.SelectedPlayer then
            local target = Players:FindFirstChild(Options.SelectedPlayer)
            if target and target.Character then lplr.Character:MoveTo(target.Character.HumanoidRootPart.Position) end
        end
    end
})

--- MOVEMENT TAB ---
Tabs.Movement:AddSlider("Speed", {Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 0}):OnChanged(function(v) 
    Options.WalkSpeed = v
    if lplr.Character then lplr.Character.Humanoid.WalkSpeed = v end 
end)

Tabs.Movement:AddSlider("JumpP", {Title = "JumpPower", Default = 50, Min = 50, Max = 500, Rounding = 0}):OnChanged(function(v) 
    Options.JumpPower = v
    if lplr.Character then lplr.Character.Humanoid.UseJumpPower = true; lplr.Character.Humanoid.JumpPower = v end 
end)

Tabs.Movement:AddToggle("FlyT", {Title = "Elite Fly", Default = false}):OnChanged(function(v) Options.Fly = v end)
Tabs.Movement:AddToggle("NocT", {Title = "No-Clip", Default = false}):OnChanged(function(v) Options.Noclip = v end)

--- VISUALS TAB (NEU AUFGEBAUT) ---
Tabs.Visuals:AddToggle("BoxT", {Title = "Box ESP", Default = false}):OnChanged(function(v) Options.BoxESP = v end)
Tabs.Visuals:AddToggle("NameT", {Title = "Nametags", Default = false}):OnChanged(function(v) Options.Names = v end)
Tabs.Visuals:AddToggle("ChamT", {Title = "Chams ", Default = false}):OnChanged(function(v) Options.Chams = v end)
Tabs.Visuals:AddColorpicker("ESPCol", {Title = "ESP Color", Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function(v) Options.ESPColor = v end)

-- DRAWING ENGINE FOR BOX & NAMES
local ESP_Objects = {}

local function CreateESP(p)
    local objects = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Highlight = Instance.new("Highlight")
    }
    
    objects.Box.Visible = false
    objects.Box.Thickness = 1
    objects.Box.Filled = false
    
    objects.Name.Visible = false
    objects.Name.Size = 14
    objects.Name.Center = true
    objects.Name.Outline = true
    
    objects.Highlight.Enabled = false
    
    ESP_Objects[p] = objects
end

local function UpdateESP()
    for p, obj in pairs(ESP_Objects) do
        if p and p.Parent and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local hrp = char.HumanoidRootPart
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            -- Box & Name Logic
            if onScreen and (Options.BoxESP or Options.Names) then
                local sizeY = (camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3.5, 0)).Y - camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 4.5, 0)).Y)
                local sizeX = sizeY / 1.5
                
                obj.Box.Visible = Options.BoxESP
                obj.Box.Size = Vector2.new(sizeX, sizeY)
                obj.Box.Position = Vector2.new(pos.X - sizeX / 2, pos.Y - sizeY / 2)
                obj.Box.Color = Options.ESPColor
                
                obj.Name.Visible = Options.Names
                obj.Name.Text = p.Name
                obj.Name.Position = Vector2.new(pos.X, pos.Y - sizeY / 2 - 15)
                obj.Name.Color = Options.ESPColor
            else
                obj.Box.Visible = false
                obj.Name.Visible = false
            end
            
            -- Chams Logic
            if Options.Chams then
                obj.Highlight.Parent = char
                obj.Highlight.Enabled = true
                obj.Highlight.FillColor = Options.ESPColor
                obj.Highlight.OutlineColor = Color3.new(0,0,0)
            else
                obj.Highlight.Enabled = false
            end
        else
            obj.Box.Visible = false
            obj.Name.Visible = false
            obj.Highlight.Enabled = false
        end
    end
end

-- LOGIC CORE
local AimFOV = Drawing.new("Circle")
AimFOV.Thickness = 1
AimFOV.Color = Color3.fromRGB(255, 255, 255)

RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    AimFOV.Visible = Options.Aimbot and Options.ShowAimFOV
    AimFOV.Radius = Options.AimFOV
    AimFOV.Position = UIS:GetMouseLocation()

    if lplr.Character then
        if Options.Fly then
            local v = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) then v = Options.FlySpeed end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then v = -Options.FlySpeed end
            lplr.Character.HumanoidRootPart.Velocity = (lplr.Character.Humanoid.MoveDirection * Options.FlySpeed) + Vector3.new(0, v + 1, 0)
        end
        if Options.Noclip then
            for _, p in pairs(lplr.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
        
        -- Hitbox
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lplr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(Options.HitboxExpander, Options.HitboxExpander, Options.HitboxExpander)
            end
        end
    end

    -- Aimbot Exec
    if Options.Aimbot and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = nil
        local dist = Options.AimFOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= lplr and p.Character and p.Character:FindFirstChild(Options.AimPart) then
                local pos, vis = camera:WorldToViewportPoint(p.Character[Options.AimPart].Position)
                if vis then
                    local m = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                    if m < dist then target = p; dist = m end
                end
            end
        end
        if target then
            camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, target.Character[Options.AimPart].Position), 0.1)
        end
    end
end)

-- INITIALIZE ESP FOR PLAYERS
for _, p in pairs(Players:GetPlayers()) do if p ~= lplr then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

Fluent:Notify({ Title = "THHE Hub", Content = "Universal Visuals & Combat Loaded.", Duration = 5 })
