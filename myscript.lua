--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

--// SETTINGS
local Settings = {
	Enabled = false,
	ShowFOV = true,
	FOV = 80,
	Smoothness = 0.18,
	FOVColor = Color3.fromRGB(170,0,255)
}

--// FOV CIRCLE
local FOV = Drawing.new("Circle")
FOV.Thickness = 2
FOV.NumSides = 100
FOV.Radius = Settings.FOV
FOV.Color = Settings.FOVColor
FOV.Transparency = 1
FOV.Filled = false
FOV.Visible = true

--// TARGET SYSTEM
local function getClosest()
	local closest, dist = nil, math.huge
	local center = cam.ViewportSize / 2

	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
			local pos, onScreen = cam:WorldToViewportPoint(plr.Character.Head.Position)
			if onScreen then
				local mag = (Vector2.new(pos.X,pos.Y) - center).Magnitude
				if mag < Settings.FOV and mag < dist then
					dist = mag
					closest = plr.Character.Head
				end
			end
		end
	end
	return closest
end

--// CAMERA UPDATE
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

----------------------------------------------------------------
--// GUI (GELİŞTİRİLMİŞ MENÜ)
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "LockUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- blur
local Lighting = game:GetService("Lighting")
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

-- MAIN PANEL
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.fromScale(0.36,0.42)
main.Position = UDim2.fromScale(0.32,0.3)
main.BackgroundColor3 = Color3.fromRGB(14,14,20)
main.Active = true
main.Draggable = true
main.Visible = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,22)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(170,0,255)
stroke.Thickness = 1
stroke.Transparency = 0.3

TweenService:Create(main,TweenInfo.new(0.6,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
	Position = UDim2.fromScale(0.32,0.28)
}):Play()

-- TOP BAR
local top = Instance.new("Frame", main)
top.Size = UDim2.fromScale(1,0.12)
top.BackgroundColor3 = Color3.fromRGB(22,22,32)
Instance.new("UICorner", top).CornerRadius = UDim.new(0,22)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.fromScale(1,1)
title.BackgroundTransparency = 1
title.Text = "AIM"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(170,0,255)

local credit = Instance.new("TextLabel", top)
credit.Size = UDim2.fromScale(0.4, 0.35)
credit.Position = UDim2.fromScale(0.6, 0.6)
credit.BackgroundTransparency = 1
credit.Text = "bedirxyz"
credit.TextScaled = true
credit.Font = Enum.Font.Gotham
credit.TextColor3 = Color3.fromRGB(255,255,255)
credit.TextTransparency = 0.3
credit.TextXAlignment = Enum.TextXAlignment.Right
credit.TextYAlignment = Enum.TextYAlignment.Bottom

-- TAB PANEL
local tabs = Instance.new("Frame", main)
tabs.Position = UDim2.fromScale(0,0.12)
tabs.Size = UDim2.fromScale(0.28,0.88)
tabs.BackgroundColor3 = Color3.fromRGB(18,18,26)
Instance.new("UICorner", tabs).CornerRadius = UDim.new(0,18)

local layout = Instance.new("UIListLayout", tabs)
layout.Padding = UDim.new(0,12)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function TabButton(text)
	local b = Instance.new("TextButton", tabs)
	b.Size = UDim2.fromScale(0.88,0.12)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.BackgroundColor3 = Color3.fromRGB(32,32,48)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
	return b
end

local aimTab = TabButton("AIM")
local visTab = TabButton("VISUAL")
local colorTab = TabButton("COLOR")

-- CONTENT FRAMES
local content = Instance.new("Frame", main)
content.Position = UDim2.fromScale(0.3,0.14)
content.Size = UDim2.fromScale(0.68,0.82)
content.BackgroundTransparency = 1

local aimFrame = Instance.new("Frame", content)
aimFrame.Size = UDim2.fromScale(1,1)
aimFrame.BackgroundTransparency = 1

local visFrame = Instance.new("Frame", content)
visFrame.Size = UDim2.fromScale(1,1)
visFrame.Visible = false
visFrame.BackgroundTransparency = 1

local colorFrame = Instance.new("Frame", content)
colorFrame.Size = UDim2.fromScale(1,1)
colorFrame.Visible = false
colorFrame.BackgroundTransparency = 1

-- TAB SWITCH
aimTab.MouseButton1Click:Connect(function()
	aimFrame.Visible = true
	visFrame.Visible = false
	colorFrame.Visible = false
end)

visTab.MouseButton1Click:Connect(function()
	aimFrame.Visible = false
	visFrame.Visible = true
	colorFrame.Visible = false
end)

colorTab.MouseButton1Click:Connect(function()
	aimFrame.Visible = false
	visFrame.Visible = false
	colorFrame.Visible = true
end)

-- INSERT MENU TOGGLE + BLUR
UIS.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode == Enum.KeyCode.Insert then
		main.Visible = not main.Visible
		TweenService:Create(blur,TweenInfo.new(0.25),{Size = main.Visible and 16 or 0}):Play()
	end
end)

-- FOV toggle F
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.F then
		Settings.ShowFOV = not Settings.ShowFOV
	end
end)

----------------------------------------------------------------
-- BUTTONS (ORİJİNAL KODUN, EKLİ COLOR TAB)
----------------------------------------------------------------
local function Button(parent,text,callback)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.fromScale(0.9,0.15)
	b.Position = UDim2.fromScale(0.05,0.05 + (#parent:GetChildren()-1)*0.18)
	b.BackgroundColor3 = Color3.fromRGB(35,35,55)
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.TextScaled = true
	b.Font = Enum.Font.GothamBold
	b.Text = text
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,14)
	b.MouseButton1Click:Connect(callback)
	return b
end

-- AIM FRAME
Button(aimFrame,"Lock-On : ON / OFF",function()
	Settings.Enabled = not Settings.Enabled
end)

Button(aimFrame,"Smooth +",function()
	Settings.Smoothness = math.clamp(Settings.Smoothness + 0.05,0.05,1)
end)

Button(aimFrame,"Smooth -",function()
	Settings.Smoothness = math.clamp(Settings.Smoothness - 0.05,0.05,1)
end)

-- VISUAL FRAME
Button(visFrame,"FOV +",function()
	Settings.FOV += 10
end)

Button(visFrame,"FOV -",function()
	Settings.FOV = math.max(20,Settings.FOV - 10)
end)

Button(visFrame,"FOV Aç / Kapat",function()
	Settings.ShowFOV = not Settings.ShowFOV
end)

-- COLOR FRAME
Button(colorFrame,"FOV Rengi: Mor",function()
	Settings.FOVColor = Color3.fromRGB(170,0,255)
end)

Button(colorFrame,"FOV Rengi: Kırmızı",function()
	Settings.FOVColor = Color3.fromRGB(255,0,0)
end)

Button(colorFrame,"FOV Rengi: Yeşil",function()
	Settings.FOVColor = Color3.fromRGB(0,255,0)
end)

-- HOLD AIM (ALT)
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		Settings.Enabled = true
	end
end)

UIS.InputEnded:Connect(function(input, gp)
	if input.KeyCode == Enum.KeyCode.LeftAlt then
		Settings.Enabled = false
	end
end)
