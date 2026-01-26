local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local safefolder = Instance.new("Folder")
safefolder.Name = "THHE_FOLDER"
safefolder.Parent = game:GetService("ReplicatedStorage")

local Window = Rayfield:CreateWindow({
	Name = "Universal THHE Hub",
	Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
	LoadingTitle = "Rayfield",
	LoadingSubtitle = "by THHE",
	ShowText = "Rayfield", -- for mobile users to unhide rayfield, change if you'd like
	Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

	ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

	ConfigurationSaving = {
		Enabled = true,
		FolderName = safefolder, -- Create a custom folder for your hub/game
		FileName = "THHE hub"
	},

	Discord = {
		Enabled = true, -- Prompt the user to join your Discord server if their executor supports it
		Invite = "https://discord.gg/gHeMcRQKSx", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
		RememberJoins = true -- Set this to false to make them join the discord every time they load it up
	},

	KeySystem = true, -- Set this to true to use our key system
	KeySettings = {
		Title = "THHE Universal",
		Subtitle = "Key System",
		Note = "Key is on the Discord :)", -- Use this to tell the user how to get a key
		FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
		SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
		GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
		Key = {"THHEKEY"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
	}
})


local CharacterTab = Window:CreateTab("Character", 58722388)
local VisualTab = Window:CreateTab("Visual", 5631279864)
local AimbotTab = Window:CreateTab("Aimbot", 3340612702)



Rayfield:Notify({
	Title = "Hey!",
	Content = "This script is new so there are bugs!",
	Duration = 7.5,
	Image = 4483362458,
})

local Toggle = CharacterTab:CreateToggle({
	Name = "Infinity Jump",
	CurrentValue = false,
	Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(FlyEnabled)
			game:GetService("UserInputService").JumpRequest:connect(function()
				if FlyEnabled then
					game:GetService"Players".LocalPlayer.Character.Humanoid.Jump = true
				end
			end)
		end,
})

local WalkspeedSlider = CharacterTab:CreateSlider({
	Name = "Walkspeed",
	Range = {0, 150},
	Increment = 1,
	Suffix = "Walkspeed",
	CurrentValue = 14,
	Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Walkspeed)
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Walkspeed
	end,
})

local JumpSlider = CharacterTab:CreateSlider({
	Name = "Jumppower",
	Range = {0, 150},
	Increment = 1,
	Suffix = "Jumppower",
	CurrentValue = 10,
	Flag = "Slider1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
	Callback = function(Jump)
		game.Players.Character.Humanoid.JumpPower = Jump
	end,
})
