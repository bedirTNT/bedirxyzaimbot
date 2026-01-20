--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

--// GLOBAL SETTINGS
_G.Settings = _G.Settings or {}
_G.Settings.Blacklist = _G.Settings.Blacklist or {}

local Settings = _G.Settings
Settings.Enabled = Settings.Enabled ~= nil and Settings.Enabled or false
Settings.ShowFOV = Settings.ShowFOV ~= nil and Settings.ShowFOV or true
Settings.FOV = Settings.FOV or 80
Settings.Smoothness = Settings.Smoothness or 0.18
Settings.FOVColor = Settings.FOVColor or Color3.fromRGB(255, 255, 255)

--// FOV CIRCLE
local FOV = Drawing.new("Circle")
FOV.Thickness = 2
FOV.NumSides = 100
FOV.Radius = Settings.FOV
FOV.Color = Settings.FOVColor
FOV.Transparency = 1
FOV.Filled = false
FOV.Visible = true

--// GET CLOSEST
local function getClosest()
	local closest, dist = nil, math.huge
	local center = cam.ViewportSize / 2

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then

			if table.find(Settings.Blacklist, plr.Name) then
				continue
			end

			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			if not hum or hum.Health <= 0 then
				continue
			end

			local head = plr.Character.Head
			local pos, onScreen = cam:WorldToViewportPoint(head.Position)
			if onScreen then
				local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if mag < Settings.FOV and mag < dist then
					local rayParams = RaycastParams.new()
					rayParams.FilterType = Enum.RaycastFilterType.Blacklist
					rayParams.FilterDescendantsInstances = {player.Character}

					local result = workspace:Raycast(
						cam.CFrame.Position,
						(head.Position - cam.CFrame.Position).Unit * 1000,
						rayParams
					)

					if result and result.Instance and result.Instance:IsDescendantOf(plr.Character) then
						dist = mag
						closest = head
					end
				end
			end
		end
	end

	return closest
end

--// AIM & FOV LOOP
RunService.RenderStepped:Connect(function()
	FOV.Position = cam.ViewportSize / 2
	FOV.Radius = Settings.FOV
	FOV.Visible = Settings.ShowFOV
	FOV.Color = Settings.FOVColor

	if Settings.Enabled then
		local target = getClosest()
		if target then
			local cf = CFrame.new(cam.CFrame.Position, target.Position)
			cam.CFrame = cam.CFrame:Lerp(cf, Settings.Smoothness)
		end
	end
end)

--// TOGGLE KEYS
local cooldown = false
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end

	if input.KeyCode == Enum.KeyCode.LeftAlt and not cooldown then
		cooldown = true
		Settings.Enabled = not Settings.Enabled
		Settings.FOVColor = Settings.Enabled and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(255, 255, 255)
		task.delay(0.3, function() cooldown = false end)
	end

	if input.KeyCode == Enum.KeyCode.F then
		Settings.ShowFOV = not Settings.ShowFOV
	end
end)

--// NO RECOIL
local recoilActive = false
local recoilStrength = 0.65
local lastLook = cam.CFrame.LookVector

UIS.InputBegan:Connect(function(input, gp)
	if not gp and input.UserInputType == Enum.UserInputType.MouseButton1 then
		recoilActive = true
	end
end)

UIS.InputEnded:Connect(function(input, gp)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		recoilActive = false
	end
end)

RunService.RenderStepped:Connect(function()
	if not recoilActive then
		lastLook = cam.CFrame.LookVector
		return
	end

	local currentCF = cam.CFrame
	local currentLook = currentCF.LookVector
	local deltaY = currentLook.Y - lastLook.Y

	if deltaY > 0.002 then
		local correctedLook = Vector3.new(
			currentLook.X,
			currentLook.Y - (deltaY * recoilStrength),
			currentLook.Z
		).Unit

		cam.CFrame = CFrame.new(currentCF.Position, currentCF.Position + correctedLook)
	end

	lastLook = cam.CFrame.LookVector
end)

--// AIM GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AimMenu"
gui.ResetOnSpawn = false

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.3, 0.5)
main.Position = UDim2.fromScale(0.35, 0.25)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
main.Visible = true
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local function CreateButton(text, posY, callback)
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.fromScale(0.9, 0.08)
	btn.Position = UDim2.fromScale(0.05, posY)
	btn.Text = text
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseButton1Click:Connect(callback)
end

-- GUI Buttons
CreateButton("FOV +", 0.05, function() Settings.FOV += 10 end)
CreateButton("FOV -", 0.14, function() Settings.FOV = math.max(20, Settings.FOV - 10) end)
CreateButton("Smooth +", 0.23, function() Settings.Smoothness = math.clamp(Settings.Smoothness + 0.05, 0.05, 1) end)
CreateButton("Smooth -", 0.32, function() Settings.Smoothness = math.clamp(Settings.Smoothness - 0.05, 0.05, 1) end)
CreateButton("FOV Renk: Mor", 0.41, function() Settings.FOVColor = Color3.fromRGB(170,0,255) end)
CreateButton("FOV Renk: Kırmızı", 0.50, function() Settings.FOVColor = Color3.fromRGB(255,0,0) end)
CreateButton("FOV Renk: Yeşil", 0.59, function() Settings.FOVColor = Color3.fromRGB(0,255,0) end)

-- BLACKLIST TEXTBOX
local nameBox = Instance.new("TextBox", main)
nameBox.Size = UDim2.fromScale(0.9, 0.08)
nameBox.Position = UDim2.fromScale(0.05, 0.7)
nameBox.PlaceholderText = "Kullanıcı adı (Blacklist)"
nameBox.Text = ""
nameBox.TextScaled = true
nameBox.Font = Enum.Font.Gotham
nameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
nameBox.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 8)

CreateButton("Blackliste Ekle", 0.8, function()
	local name = string.match(nameBox.Text, "^%s*(.-)%s*$")
	if name ~= "" and not table.find(Settings.Blacklist, name) then
		table.insert(Settings.Blacklist, name)
		nameBox.Text = ""
	end
end)

CreateButton("Blacklist Temizle", 0.89, function()
	table.clear(Settings.Blacklist)
end)

-- INSERT key opens/closes aim menu
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		main.Visible = not main.Visible
		blur.Size = main.Visible and 16 or 0
	end
end)

--// =========================
--// SUNUCU BLACKLIST PANELİ
--// =========================

local gui2 = Instance.new("ScreenGui")
gui2.Name = "SunucuBlacklist"
gui2.IgnoreGuiInset = true
gui2.ResetOnSpawn = false
gui2.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Parent = gui2
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.fromScale(0.5, 0.5)
frame.Size = UDim2.fromScale(0.38, 0.65)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
frame.AutomaticSize = Enum.AutomaticSize.None
frame.ClipsDescendants = true

local LOCKED_SIZE = frame.AbsoluteSize
frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	if frame.AbsoluteSize ~= LOCKED_SIZE then
		frame.Size = UDim2.fromOffset(LOCKED_SIZE.X, LOCKED_SIZE.Y)
	end
end)

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1, 0.08)
title.BackgroundTransparency = 1
title.Text = "Sunucu Kara Liste Paneli"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(170, 0, 255)
title.TextSize = 28

local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.fromScale(0.95, 0.85)
scroll.Position = UDim2.fromScale(0.025, 0.12)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 6)

local function setBtn(btn, added)
	btn.Text = added and "Added" or "Add"
	btn.BackgroundColor3 = added and Color3.fromRGB(110,110,110) or Color3.fromRGB(0,200,100)
end

local function addRow(plr)
	if plr == player then return end
	if scroll:FindFirstChild(plr.Name) then return end

	local row = Instance.new("Frame", scroll)
	row.Name = plr.Name
	row.Size = UDim2.fromScale(1, 0.12)
	row.BackgroundColor3 = Color3.fromRGB(35,35,45)
	Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)

	local name = Instance.new("TextLabel", row)
	name.Size = UDim2.fromScale(0.65,1)
	name.Position = UDim2.fromScale(0.03,0)
	name.BackgroundTransparency = 1
	name.Text = plr.Name
	name.Font = Enum.Font.GothamBold
	name.TextSize = 20
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.TextColor3 = Color3.new(1,1,1)

	local btn = Instance.new("TextButton", row)
	btn.Size = UDim2.fromScale(0.25,0.6)
	btn.Position = UDim2.fromScale(0.72,0.2)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

	setBtn(btn, table.find(Settings.Blacklist, plr.Name))

	btn.MouseButton1Click:Connect(function()
		local i = table.find(Settings.Blacklist, plr.Name)
		if i then
			table.remove(Settings.Blacklist, i)
			setBtn(btn, false)
		else
			table.insert(Settings.Blacklist, plr.Name)
			setBtn(btn, true)
		end
	end)
end

local function refresh()
	for _,c in ipairs(scroll:GetChildren()) do
		if c:IsA("Frame") then c:Destroy() end
	end
	for _,plr in ipairs(Players:GetPlayers()) do
		addRow(plr)
	end
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(function(plr)
	if frame.Visible then
		task.wait(0.5)
		addRow(plr)
	end
end)

Players.PlayerRemoving:Connect(function(plr)
	local r = scroll:FindFirstChild(plr.Name)
	if r then r:Destroy() end
end)

-- DELETE key opens/closes sunucu paneli
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Delete then
		frame.Visible = not frame.Visible
		if frame.Visible then refresh() end
	end
end)
