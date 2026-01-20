--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

--// SETTINGS (TEK ORTAK LISTE)  >>> HİÇBİR ŞEYİ KALDIRMADIM, SADECE BAĞLADIM
_G.Settings = _G.Settings or {}
_G.Settings.Blacklist = _G.Settings.Blacklist or {}

local Settings = _G.Settings
Settings.Enabled = (Settings.Enabled ~= nil) and Settings.Enabled or false
Settings.ShowFOV = (Settings.ShowFOV ~= nil) and Settings.ShowFOV or true
Settings.FOV = Settings.FOV or 80
Settings.Smoothness = Settings.Smoothness or 0.18
Settings.FOVColor = Settings.FOVColor or Color3.fromRGB(255,255,255)

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

			-- Blacklist kontrol (ilk scriptteki gibi)
			local isBlacklisted = false
			for _, name in ipairs(Settings.Blacklist) do
				if tostring(name):lower() == plr.Name:lower() then
					isBlacklisted = true
					break
				end
			end
			if isBlacklisted then
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

--// RENDER STEP (AIM)
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

--// TOGGLE KEYBINDS (AIM)
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

--// NO RECOIL (SADECE SIKARKEN)  (ilk scriptteki gibi)
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

		cam.CFrame = CFrame.new(
			currentCF.Position,
			currentCF.Position + correctedLook
		)
	end

	lastLook = cam.CFrame.LookVector
end)

--// =========================
--// GUI 1: AIM MENU (ilk script aynen)
--// =========================
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
	btn.TextColor3 = Color3.new(1,1,1)
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	btn.MouseButton1Click:Connect(callback)
end

-- AYAR BUTONLARI (ilk script aynen)
CreateButton("FOV +", 0.05, function() Settings.FOV += 10 end)
CreateButton("FOV -", 0.14, function() Settings.FOV = math.max(20, Settings.FOV - 10) end)
CreateButton("Smooth +", 0.23, function() Settings.Smoothness = math.clamp(Settings.Smoothness + 0.05, 0.05, 1) end)
CreateButton("Smooth -", 0.32, function() Settings.Smoothness = math.clamp(Settings.Smoothness - 0.05, 0.05, 1) end)
CreateButton("FOV Renk: Mor", 0.41, function() Settings.FOVColor = Color3.fromRGB(170,0,255) end)
CreateButton("FOV Renk: Kırmızı", 0.50, function() Settings.FOVColor = Color3.fromRGB(255,0,0) end)
CreateButton("FOV Renk: Yeşil", 0.59, function() Settings.FOVColor = Color3.fromRGB(0,255,0) end)

-- BLACKLIST EKLEME (ilk script aynen)
local nameBox = Instance.new("TextBox", main)
nameBox.Size = UDim2.fromScale(0.9, 0.08)
nameBox.Position = UDim2.fromScale(0.05, 0.7)
nameBox.PlaceholderText = "Kullanıcı adı (Blacklist)"
nameBox.Text = ""
nameBox.TextScaled = true
nameBox.Font = Enum.Font.Gotham
nameBox.BackgroundColor3 = Color3.fromRGB(50,50,70)
nameBox.TextColor3 = Color3.new(1,1,1)
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

-- INSERT ile menüyü aç/kapat (ilk script aynen)
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		main.Visible = not main.Visible
		blur.Size = main.Visible and 16 or 0
	end
end)

--// =========================
--// GUI 2: SUNUCU BLACKLIST PANELİ (ikinci script aynen, sadece Settings'e bağlandı)
--// =========================
local UserInputService = UIS

local gui2 = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui2.Name = "SunucuBlacklist"
gui2.ResetOnSpawn = false
gui2.Enabled = false -- Başlangıçta kapalı

-- PANEL
local frame = Instance.new("Frame", gui2)
frame.Size = UDim2.fromScale(0.38, 0.65)
frame.Position = UDim2.fromScale(0.31, 0.2)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- BAŞLIK
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromScale(1, 0.08)
title.Text = "Sunucu Kara Liste Paneli"
title.TextScaled = true
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(170, 0, 255)
title.Font = Enum.Font.GothamBold

-- YENİLE ve TEMİZLE BUTONLARI
local refreshBtn = Instance.new("TextButton", frame)
refreshBtn.Size = UDim2.fromScale(0.45, 0.06)
refreshBtn.Position = UDim2.fromScale(0.03, 0.085)
refreshBtn.Text = "↻ Yenile (F5)"
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextScaled = true
refreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)

local clearBtn = Instance.new("TextButton", frame)
clearBtn.Size = UDim2.fromScale(0.45, 0.06)
clearBtn.Position = UDim2.fromScale(0.52, 0.085)
clearBtn.Text = "🗑️ Temizle"
clearBtn.Font = Enum.Font.GothamBold
clearBtn.TextScaled = true
clearBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 30)
clearBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 6)

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.fromScale(0.95, 0.78)
scroll.Position = UDim2.fromScale(0.025, 0.16)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- OYUNCU SATIRI
local function addPlayerEntry(plr)
	if plr == player then return end
	if scroll:FindFirstChild(plr.Name) then return end

	local entry = Instance.new("Frame", scroll)
	entry.Name = plr.Name
	entry.Size = UDim2.fromScale(1, 0.12)
	entry.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	Instance.new("UICorner", entry).CornerRadius = UDim.new(0, 6)

	local nameLabel = Instance.new("TextLabel", entry)
	nameLabel.Size = UDim2.fromScale(0.7, 1)
	nameLabel.Position = UDim2.fromScale(0.03, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = plr.Name
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextColor3 = Color3.new(1, 1, 1)
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left

	local btn = Instance.new("TextButton", entry)
	btn.Size = UDim2.fromScale(0.2, 0.6)
	btn.Position = UDim2.fromScale(0.75, 0.2)
	btn.Text = table.find(Settings.Blacklist, plr.Name) and "Eklendi" or "Ekle"
	btn.BackgroundColor3 = table.find(Settings.Blacklist, plr.Name) and Color3.fromRGB(100,100,100) or Color3.fromRGB(0, 200, 100)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	btn.MouseButton1Click:Connect(function()
		if not table.find(Settings.Blacklist, plr.Name) then
			table.insert(Settings.Blacklist, plr.Name)
			btn.Text = "Eklendi"
			btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			print("[BLACKLIST] Eklendi:", plr.Name)
		end
	end)

	task.defer(function()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)
end

-- OYUNCULARI LİSTELE
local function refreshList()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		addPlayerEntry(plr)
	end
end

refreshBtn.MouseButton1Click:Connect(refreshList)

clearBtn.MouseButton1Click:Connect(function()
	table.clear(Settings.Blacklist)
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	print("[BLACKLIST] Temizlendi.")
end)

-- TUŞLA PANEL AÇ/KAPA (DELETE) + F5 YENİLE (ikinci script aynen)
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Delete then
		gui2.Enabled = not gui2.Enabled
		if gui2.Enabled then
			refreshList()
		end
	end
	if input.KeyCode == Enum.KeyCode.F5 then
		refreshList()
	end
end)

-- YENİ OYUNCU GELİRSE OTOMATİK EKLE (ikinci script aynen)
Players.PlayerAdded:Connect(function(plr)
	task.wait(1)
	addPlayerEntry(plr)
end)

-- ÇIKAN OYUNCU VARSA PANELDEN SİLİNSİN (senin isteğin: menüde kalmasın)
Players.PlayerRemoving:Connect(function(plr)
	local row = scroll:FindFirstChild(plr.Name)
	if row and row:IsA("Frame") then
		row:Destroy()
		scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end
end)
