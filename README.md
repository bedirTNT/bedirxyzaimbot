--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local cam = Workspace.CurrentCamera

--// SETTINGS
local Settings = {
    Enabled = false,
    ShowFOV = true,
    FOV = 80,
    Smoothness = 0.18,
    FOVColor = Color3.fromRGB(170,0,255),
    NoRecoil = false,
    Keys = {
        Aim = Enum.KeyCode.LeftAlt,
        NoRecoil = Enum.KeyCode.B,
        FOVToggle = Enum.KeyCode.F
    }
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

--// TARGET SYSTEM (Sadece görünen hedefleri kilitle)
local function getClosest()
    local closest, dist = nil, math.huge
    local center = cam.ViewportSize / 2
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("HumanoidRootPart") then
            local headPos = plr.Character.Head.Position
            local onScreen = cam:WorldToViewportPoint(headPos)
            local ray = Ray.new(cam.CFrame.Position, (headPos - cam.CFrame.Position).Unit * 500)
            local part, pos = Workspace:FindPartOnRayWithIgnoreList(ray, {player.Character})

            local mag = (Vector2.new(onScreen.X,onScreen.Y)-center).Magnitude
            if onScreen.Z > 0 and mag < Settings.FOV and mag < dist and (part == nil or part:IsDescendantOf(plr.Character)) then
                dist = mag
                closest = plr.Character.Head
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
            cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, target.Position), Settings.Smoothness)
        end
    end

    -- No Recoil
    if Settings.NoRecoil then
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                tool.Handle.Velocity = Vector3.new(0,0,0)
                tool.Handle.RotVelocity = Vector3.new(0,0,0)
            end
        end
        if player.Character then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    tool.Handle.Velocity = Vector3.new(0,0,0)
                    tool.Handle.RotVelocity = Vector3.new(0,0,0)
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- GUI
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "LockUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Blur
local Lighting = game:GetService("Lighting")
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

----------------------------------------------------------------
-- MAIN PANEL
----------------------------------------------------------------
local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.fromScale(0.45,0.5)
main.Position = UDim2.fromScale(0.27,0.25)
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
    Position = UDim2.fromScale(0.27,0.23)
}):Play()

-- TOP BAR
local top = Instance.new("Frame", main)
top.Size = UDim2.fromScale(1,0.12)
top.BackgroundColor3 = Color3.fromRGB(22,22,32)
Instance.new("UICorner", top).CornerRadius = UDim.new(0,22)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.fromScale(1,1)
title.BackgroundTransparency = 1
title.Text = "bedirxyz SCRİPT"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(170,0,255)

-- CREDIT
local credit = Instance.new("TextLabel", top)
credit.Size = UDim2.fromScale(0.4, 0.35)
credit.Position = UDim2.fromScale(0.6,0.6)
credit.BackgroundTransparency = 1
credit.Text = player.Name
credit.TextScaled = true
credit.Font = Enum.Font.Gotham
credit.TextColor3 = Color3.fromRGB(255,255,255)
credit.TextTransparency = 0.3
credit.TextXAlignment = Enum.TextXAlignment.Right
credit.TextYAlignment = Enum.TextYAlignment.Bottom

-- USER AVATAR
local avatar = Instance.new("ImageLabel", top)
avatar.Size = UDim2.fromScale(0.1,0.9)
avatar.Position = UDim2.fromScale(0.02,0.05)
avatar.BackgroundTransparency = 1
avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)

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
local fovTab = TabButton("FOV")
local visualTab = TabButton("VISUAL")

-- CONTENT FRAMES
local content = Instance.new("Frame", main)
content.Position = UDim2.fromScale(0.3,0.14)
content.Size = UDim2.fromScale(0.68,0.82)
content.BackgroundTransparency = 1

local aimFrame = Instance.new("Frame", content)
aimFrame.Size = UDim2.fromScale(1,1)
aimFrame.BackgroundTransparency = 1

local fovFrame = Instance.new("Frame", content)
fovFrame.Size = UDim2.fromScale(1,1)
fovFrame.Visible = false
fovFrame.BackgroundTransparency = 1

local visualFrame = Instance.new("Frame", content)
visualFrame.Size = UDim2.fromScale(1,1)
visualFrame.Visible = false
visualFrame.BackgroundTransparency = 1

-- TAB SWITCH
aimTab.MouseButton1Click:Connect(function()
    aimFrame.Visible = true
    fovFrame.Visible = false
    visualFrame.Visible = false
end)

fovTab.MouseButton1Click:Connect(function()
    aimFrame.Visible = false
    fovFrame.Visible = true
    visualFrame.Visible = false
end)

visualTab.MouseButton1Click:Connect(function()
    aimFrame.Visible = false
    fovFrame.Visible = false
    visualFrame.Visible = true
end)

-- INSERT MENU TOGGLE + BLUR
UIS.InputBegan:Connect(function(i,gp)
    if not gp and i.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
        TweenService:Create(blur,TweenInfo.new(0.25),{Size = main.Visible and 16 or 0}):Play()
    end
end)

-- BUTTON FUNCTION
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

-- AIM FRAME BUTTONS
Button(aimFrame,"Lock-On : ON / OFF",function() Settings.Enabled = not Settings.Enabled end)
Button(aimFrame,"Smooth +",function() Settings.Smoothness = math.clamp(Settings.Smoothness + 0.05,0.05,1) end)
Button(aimFrame,"Smooth -",function() Settings.Smoothness = math.clamp(Settings.Smoothness - 0.05,0.05,1) end)
Button(aimFrame,"No Recoil : ON / OFF",function() Settings.NoRecoil = not Settings.NoRecoil end)

-- FOV FRAME BUTTONS
Button(fovFrame,"FOV +",function() Settings.FOV += 10 end)
Button(fovFrame,"FOV -",function() Settings.FOV = math.max(20,Settings.FOV - 10) end)
Button(fovFrame,"FOV Aç / Kapat",function() Settings.ShowFOV = not Settings.ShowFOV end)
Button(fovFrame,"FOV Rengi: Mor",function() Settings.FOVColor = Color3.fromRGB(170,0,255) end)
Button(fovFrame,"FOV Rengi: Kırmızı",function() Settings.FOVColor = Color3.fromRGB(255,0,0) end)
Button(fovFrame,"FOV Rengi: Yeşil",function() Settings.FOVColor = Color3.fromRGB(0,255,0) end)

-- VISUAL FRAME BUTTONS
Button(visualFrame,"Aim Lock Tuşunu Değiştir",function()
    local input = UIS.InputBegan:Wait()
    if input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.Keys.Aim = input.KeyCode
    end
end)

Button(visualFrame,"No Recoil Tuşunu Değiştir",function()
    local input = UIS.InputBegan:Wait()
    if input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.Keys.NoRecoil = input.KeyCode
    end
end)

Button(visualFrame,"FOV Toggle Tuşunu Değiştir",function()
    local input = UIS.InputBegan:Wait()
    if input.UserInputType == Enum.UserInputType.Keyboard then
        Settings.Keys.FOVToggle = input.KeyCode
    end
end)

-- CUSTOM KEY INPUTS
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Settings.Keys.Aim then Settings.Enabled = true end
    if input.KeyCode == Settings.Keys.NoRecoil then Settings.NoRecoil = not Settings.NoRecoil end
    if input.KeyCode == Settings.Keys.FOVToggle then Settings.ShowFOV = not Settings.ShowFOV end
end)

UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Settings.Keys.Aim then Settings.Enabled = false end
end)
