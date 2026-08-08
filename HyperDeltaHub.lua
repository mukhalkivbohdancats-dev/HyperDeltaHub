local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ==========================================
-- ЗБЕРЕЖЕННЯ ОРИГІНАЛЬНИХ НАЛАШТУВАНЬ
-- ==========================================
local originalSpeed = 16
local originalJumpPower = 50
local originalUseJumpPower = true

local function saveOriginals()
	local char = player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		originalSpeed = char:FindFirstChildOfClass("Humanoid").WalkSpeed
		originalJumpPower = char:FindFirstChildOfClass("Humanoid").JumpPower
		originalUseJumpPower = char:FindFirstChildOfClass("Humanoid").UseJumpPower
	end
end
saveOriginals()

-- Очищення попередніх версій
if CoreGui:FindFirstChild("QuantumDeltaHub") then
	CoreGui.QuantumDeltaHub:Destroy()
elseif player:WaitForChild("PlayerGui"):FindFirstChild("QuantumDeltaHub") then
	player.PlayerGui.QuantumDeltaHub:Destroy()
end

-- ==========================================
-- ОСНОВНЕ СТВОРЕННЯ GUI
-- ==========================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "QuantumDeltaHub"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 9999999 
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, _ = pcall(function() screenGui.Parent = CoreGui end)
if not success then
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 330, 0, 180) 
mainFrame.Position = UDim2.new(0.5, -165, 0.5, -90) 
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true 

local mainCorner = Instance.new("UICorner", mainFrame)
mainCorner.CornerRadius = UDim.new(0, 5) 

local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(255, 170, 0)
mainStroke.Thickness = 2 

-- ==========================================
-- ВЕРХНЯ ПАНЕЛЬ (TOPBAR)
-- ==========================================
local topBar = Instance.new("Frame", mainFrame)
topBar.Size = UDim2.new(1, 0, 0, 20) 
topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
topBar.BorderSizePixel = 0
local topCorner = Instance.new("UICorner", topBar)
topCorner.CornerRadius = UDim.new(0, 5)

local topFix = Instance.new("Frame", topBar)
topFix.Size = UDim2.new(1, 0, 0, 7)
topFix.Position = UDim2.new(0, 0, 1, -7)
topFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
topFix.BorderSizePixel = 0

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(0.6, 0, 1, 0)
title.Position = UDim2.new(0.04, 0, 0, 0)
title.Text = "HYPER DELTA HUB"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 170, 0)
title.TextScaled = true 
title.TextXAlignment = Enum.TextXAlignment.Left
title.BackgroundTransparency = 1

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -20, 0, 0)
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BackgroundTransparency = 1
closeBtn.ZIndex = 5

local minBtn = Instance.new("TextButton", topBar)
minBtn.Size = UDim2.new(0, 20, 0, 20)
minBtn.Position = UDim2.new(1, -40, 0, 0)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextScaled = true
minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
minBtn.BackgroundTransparency = 1
minBtn.ZIndex = 5

local minimized = false
local contentContainer = Instance.new("Frame", mainFrame)
contentContainer.Size = UDim2.new(1, 0, 1, -20)
contentContainer.Position = UDim2.new(0, 0, 0, 20)
contentContainer.BackgroundTransparency = 1

minBtn.Activated:Connect(function()
	minimized = not minimized
	contentContainer.Visible = not minimized
	mainFrame.Size = minimized and UDim2.new(0, 330, 0, 20) or UDim2.new(0, 330, 0, 180)
end)

-- ==========================================
-- БОКОВЕ МЕНЮ ТА ВКЛАДКИ
-- ==========================================
local sidebar = Instance.new("ScrollingFrame", contentContainer)
sidebar.Size = UDim2.new(0, 95, 1, 0) 
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 2
sidebar.ScrollBarImageColor3 = Color3.fromRGB(255, 170, 0)
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)

local sidebarList = Instance.new("UIGridLayout", sidebar)
sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
sidebarList.CellSize = UDim2.new(0.5, -3, 0, 20) 
sidebarList.CellPadding = UDim2.new(0, 3, 0, 3)

sidebarList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	sidebar.CanvasSize = UDim2.new(0, 0, 0, sidebarList.AbsoluteContentSize.Y + 10)
end)

local framesContainer = Instance.new("Frame", contentContainer)
framesContainer.Size = UDim2.new(1, -95, 1, 0)
framesContainer.Position = UDim2.new(0, 95, 0, 0)
framesContainer.BackgroundTransparency = 1

local tabs = {}

local function createTab(name, order)
	local btn = Instance.new("TextButton", sidebar)
	btn.Text = name
	btn.Font = Enum.Font.GothamSemibold
	btn.TextScaled = true 
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	btn.BorderSizePixel = 0
	btn.LayoutOrder = order

	local frame = Instance.new("Frame", framesContainer)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	
	tabs[name] = {Button = btn, Frame = frame}

	btn.Activated:Connect(function()
		for tName, tData in pairs(tabs) do
			tData.Frame.Visible = (tName == name)
			tData.Button.TextColor3 = (tName == name) and Color3.fromRGB(255, 170, 0) or Color3.fromRGB(200, 200, 200)
			tData.Button.BackgroundColor3 = (tName == name) and Color3.fromRGB(40, 40, 45) or Color3.fromRGB(30, 30, 35)
		end
	end)
	
	return frame
end

-- ==========================================
-- ДОПОМІЖНІ ФУНКЦІЇ ДЛЯ UI
-- ==========================================
local function createButton(parent, text, pos, size, color, callback)
	local btn = Instance.new("TextButton", parent)
	btn.Size = size
	btn.Position = pos
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextScaled = true 
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.BackgroundColor3 = color
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 3)
	btn.Activated:Connect(callback)
	return btn
end

local function createTextBox(parent, placeholder, text, pos, size)
	local box = Instance.new("TextBox", parent)
	box.Size = size
	box.Position = pos
	box.PlaceholderText = placeholder
	box.Text = text
	box.Font = Enum.Font.Gotham
	box.TextScaled = true
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	box.TextColor3 = Color3.new(1, 1, 1)
	local corner = Instance.new("UICorner", box)
	corner.CornerRadius = UDim.new(0, 3)
	return box
end

local function Message(Title, Text, Time)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = Title,
		Text = Text,
		Duration = Time or 5
	})
end

-- ==========================================
-- СТВОРЕННЯ ВКЛАДОК
-- ==========================================
local tab1 = createTab("Light", 1)
local tab2 = createTab("Jump", 2)
local tab3 = createTab("TP WP", 3)
local tab4 = createTab("Plrs", 4)
local tab5 = createTab("Spec", 5) 
local tab6 = createTab("TP For", 6)
local tab8 = createTab("Speed", 7)
local tab9 = createTab("J Power", 8)
local tab10 = createTab("Fly", 9)
local tab11 = createTab("Noclip", 10)
local tab12 = createTab("TP Time", 11)
local tab13 = createTab("Fling", 12)
local tab14 = createTab("WallHop", 13)
local tab15 = createTab("Spin", 14)
local tab16 = createTab("Loop TP", 15)
local tab17 = createTab("ProxPrompt", 16)

tabs["Light"].Button.TextColor3 = Color3.fromRGB(255, 170, 0)
tabs["Light"].Frame.Visible = true

-- ==========================================
-- TAB 1: LIGHTING 
-- ==========================================
local originalAmbient = Lighting.Ambient
local originalOutdoorAmbient = Lighting.OutdoorAmbient
local originalFogEnd = Lighting.FogEnd

local lightFolder = rootPart:FindFirstChild("UltraZoneLights") or Instance.new("Folder")
lightFolder.Name = "UltraZoneLights"
lightFolder.Parent = rootPart
lightFolder:ClearAllChildren()

for i = 1, 6 do
	local light = Instance.new("PointLight")
	light.Range = 60
	light.Brightness = 28 * i
	light.Shadows = false
	light.Enabled = false
	light.Parent = lightFolder
end

local function toggleLight(state)
	for _, light in ipairs(lightFolder:GetChildren()) do
		if light:IsA("PointLight") then light.Enabled = state end
	end
	if state then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		Lighting.FogEnd = 999999
	else
		Lighting.Ambient = originalAmbient
		Lighting.OutdoorAmbient = originalOutdoorAmbient
		Lighting.FogEnd = originalFogEnd
	end
end

createButton(tab1, "ON", UDim2.new(0.1, 0, 0.38, 0), UDim2.new(0.35, 0, 0.24, 0), Color3.fromRGB(200, 120, 0), function() toggleLight(true) end)
createButton(tab1, "OFF", UDim2.new(0.55, 0, 0.38, 0), UDim2.new(0.35, 0, 0.24, 0), Color3.fromRGB(150, 30, 40), function() toggleLight(false) end)

-- ==========================================
-- TAB 2: INF JUMP 
-- ==========================================
local infJumpLabel = Instance.new("TextLabel", tab2)
infJumpLabel.Size = UDim2.new(1, 0, 0.22, 0)
infJumpLabel.Position = UDim2.new(0, 0, 0.1, 0)
infJumpLabel.Text = "Inf jump"
infJumpLabel.Font = Enum.Font.GothamBold
infJumpLabel.TextScaled = true
infJumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
infJumpLabel.BackgroundTransparency = 1

local infJumpState = false
local infJumpConnection = nil
local infJumpBtn = createButton(tab2, "ON", UDim2.new(0.3, 0, 0.38, 0), UDim2.new(0.4, 0, 0.28, 0), Color3.fromRGB(200, 50, 50), function() end)

infJumpBtn.Activated:Connect(function()
	infJumpState = not infJumpState
	if infJumpState then
		infJumpBtn.Text = "OFF"
		infJumpBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		infJumpConnection = UserInputService.JumpRequest:Connect(function()
			if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
				player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		infJumpBtn.Text = "ON"
		infJumpBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		if infJumpConnection then infJumpConnection:Disconnect() infJumpConnection = nil end
	end
end)

-- ==========================================
-- TAB 3: WAYPOINTS (TELEPORT)
-- ==========================================
local wpNameInput = createTextBox(tab3, "Name", "", UDim2.new(0.05, 0, 0.05, 0), UDim2.new(0.6, 0, 0.16, 0))
local wpSaveBtn = createButton(tab3, "Save", UDim2.new(0.7, 0, 0.05, 0), UDim2.new(0.25, 0, 0.16, 0), Color3.fromRGB(50, 150, 200), function() end)

local wpScroll = Instance.new("ScrollingFrame", tab3)
wpScroll.Size = UDim2.new(0.9, 0, 0.5, 0)
wpScroll.Position = UDim2.new(0.05, 0, 0.26, 0)
wpScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
wpScroll.ScrollBarThickness = 3 
local wpListLayout = Instance.new("UIListLayout", wpScroll)
wpListLayout.Padding = UDim.new(0, 3)

local wpTeleportBtn = createButton(tab3, "Teleport", UDim2.new(0.05, 0, 0.8, 0), UDim2.new(0.9, 0, 0.16, 0), Color3.fromRGB(200, 120, 0), function() end)

local savedWaypoints = {}
local selectedWaypoint = nil
local wpUIElements = {}

local confirmFrame = Instance.new("Frame", tab3)
confirmFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
confirmFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
confirmFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
confirmFrame.Visible = false
confirmFrame.ZIndex = 10
local confirmLabel = Instance.new("TextLabel", confirmFrame)
confirmLabel.Size = UDim2.new(1, 0, 0.4, 0)
confirmLabel.Text = "Are you sure?"
confirmLabel.Font = Enum.Font.GothamBold
confirmLabel.TextColor3 = Color3.new(1,1,1)
confirmLabel.TextScaled = true
confirmLabel.BackgroundTransparency = 1
confirmLabel.ZIndex = 10

local confirmTarget = nil
local btnYes = createButton(confirmFrame, "Yes", UDim2.new(0.1, 0, 0.55, 0), UDim2.new(0.35, 0, 0.3, 0), Color3.fromRGB(50, 200, 50), function()
	if confirmTarget and wpUIElements[confirmTarget] then
		wpUIElements[confirmTarget]:Destroy()
		savedWaypoints[confirmTarget] = nil
		if selectedWaypoint == confirmTarget then selectedWaypoint = nil end
	end
	confirmFrame.Visible = false
end)
btnYes.ZIndex = 10

local btnNo = createButton(confirmFrame, "No", UDim2.new(0.55, 0, 0.55, 0), UDim2.new(0.35, 0, 0.3, 0), Color3.fromRGB(200, 50, 50), function() confirmFrame.Visible = false end)
btnNo.ZIndex = 10

local function refreshWaypointSelection()
	for name, item in pairs(wpUIElements) do
		item.BackgroundColor3 = (name == selectedWaypoint) and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(35, 35, 40)
	end
end

wpSaveBtn.Activated:Connect(function()
	local name = wpNameInput.Text
	if name ~= "" and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		if savedWaypoints[name] then return end
		savedWaypoints[name] = player.Character.HumanoidRootPart.CFrame
		
		local item = Instance.new("TextButton", wpScroll)
		item.Size = UDim2.new(1, -8, 0, 24) 
		item.Text = " " .. name
		item.TextXAlignment = Enum.TextXAlignment.Left
		item.Font = Enum.Font.Gotham
		item.TextScaled = true
		item.TextColor3 = Color3.new(1, 1, 1)
		item.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		
		local delBtn = Instance.new("TextButton", item)
		delBtn.Size = UDim2.new(0, 24, 1, 0)
		delBtn.Position = UDim2.new(1, -24, 0, 0)
		delBtn.Text = "×"
		delBtn.Font = Enum.Font.GothamBold
		delBtn.TextScaled = true
		delBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
		delBtn.BackgroundTransparency = 1
		
		wpUIElements[name] = item
		wpScroll.CanvasSize = UDim2.new(0, 0, 0, wpListLayout.AbsoluteContentSize.Y)
		
		item.Activated:Connect(function() selectedWaypoint = name refreshWaypointSelection() end)
		delBtn.Activated:Connect(function() confirmTarget = name confirmFrame.Visible = true end)
		wpNameInput.Text = ""
	end
end)

wpTeleportBtn.Activated:Connect(function()
	if selectedWaypoint and savedWaypoints[selectedWaypoint] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = savedWaypoints[selectedWaypoint]
	end
end)

-- ==========================================
-- TAB 4 (PLAYERS) & TAB 5 (SPECTATE) & TAB 13 (FLING)
-- ==========================================
local plrScroll = Instance.new("ScrollingFrame", tab4)
plrScroll.Size = UDim2.new(0.9, 0, 0.48, 0)
plrScroll.Position = UDim2.new(0.05, 0, 0.05, 0)
plrScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
plrScroll.ScrollBarThickness = 3
local plrListLayout = Instance.new("UIListLayout", plrScroll)
plrListLayout.Padding = UDim.new(0, 3)

local specScroll = Instance.new("ScrollingFrame", tab5)
specScroll.Size = UDim2.new(0.9, 0, 0.65, 0)
specScroll.Position = UDim2.new(0.05, 0, 0.05, 0)
specScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
specScroll.ScrollBarThickness = 3
local specListLayout = Instance.new("UIListLayout", specScroll)
specListLayout.Padding = UDim.new(0, 3)

local flingScroll = Instance.new("ScrollingFrame", tab13)
flingScroll.Size = UDim2.new(0.9, 0, 0.45, 0)
flingScroll.Position = UDim2.new(0.05, 0, 0.16, 0)
flingScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
flingScroll.ScrollBarThickness = 3
local flingListLayout = Instance.new("UIListLayout", flingScroll)
flingListLayout.Padding = UDim.new(0, 3)

local flingStatusLabel = Instance.new("TextLabel", tab13)
flingStatusLabel.Size = UDim2.new(0.9, 0, 0.12, 0)
flingStatusLabel.Position = UDim2.new(0.05, 0, 0.02, 0)
flingStatusLabel.Text = "0 target(s) selected"
flingStatusLabel.Font = Enum.Font.GothamBold
flingStatusLabel.TextScaled = true
flingStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
flingStatusLabel.BackgroundTransparency = 1

local selectedTpPlayer = nil
local selectedSpecPlayer = nil
local tpUIElements = {}
local specUIElements = {}
local flingUIElements = {}
local SelectedTargets = {}
local FlingActive = false

getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

local function refreshTpSelection()
	for name, item in pairs(tpUIElements) do
		item.BackgroundColor3 = (name == selectedTpPlayer) and Color3.fromRGB(60, 70, 70) or Color3.fromRGB(35, 35, 40)
	end
end

local function refreshSpecSelection()
	for name, item in pairs(specUIElements) do
		item.BackgroundColor3 = (name == selectedSpecPlayer) and Color3.fromRGB(60, 60, 70) or Color3.fromRGB(35, 35, 40)
	end
end

local function CountSelectedTargets()
	local count = 0
	for _ in pairs(SelectedTargets) do count = count + 1 end
	return count
end

local function UpdateFlingStatus()
	local count = CountSelectedTargets()
	if FlingActive then
		flingStatusLabel.Text = "Flinging " .. count .. " target(s)"
		flingStatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
	else
		flingStatusLabel.Text = count .. " target(s) selected"
		flingStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end

local function updatePlayerLists()
	for _, child in ipairs(plrScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
	for _, child in ipairs(specScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
	for _, child in ipairs(flingScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
	
	tpUIElements = {}
	specUIElements = {}
	flingUIElements = {}
	
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			-- Вкладка TP
			local tpItem = Instance.new("TextButton", plrScroll)
			tpItem.Size = UDim2.new(1, -8, 0, 24)
			tpItem.Text = " " .. p.Name
			tpItem.TextXAlignment = Enum.TextXAlignment.Left
			tpItem.Font = Enum.Font.Gotham
			tpItem.TextScaled = true
			tpItem.TextColor3 = Color3.new(1, 1, 1)
			tpItem.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			tpUIElements[p.Name] = tpItem
			tpItem.Activated:Connect(function() selectedTpPlayer = p.Name refreshTpSelection() end)
			
			-- Вкладка Spectate
			local specItem = Instance.new("TextButton", specScroll)
			specItem.Size = UDim2.new(1, -8, 0, 24)
			specItem.Text = " " .. p.Name
			specItem.TextXAlignment = Enum.TextXAlignment.Left
			specItem.Font = Enum.Font.Gotham
			specItem.TextScaled = true
			specItem.TextColor3 = Color3.new(1, 1, 1)
			specItem.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			specUIElements[p.Name] = specItem
			specItem.Activated:Connect(function() selectedSpecPlayer = p.Name refreshSpecSelection() end)

			-- Вкладка Fling
			local flingItem = Instance.new("TextButton", flingScroll)
			flingItem.Size = UDim2.new(1, -8, 0, 24)
			flingItem.Font = Enum.Font.Gotham
			flingItem.TextScaled = true
			flingItem.TextXAlignment = Enum.TextXAlignment.Left
			
			local function updateFlingItemVisuals()
				if SelectedTargets[p.Name] then
					flingItem.Text = "  [✓] " .. p.Name
					flingItem.TextColor3 = Color3.fromRGB(50, 255, 50)
					flingItem.BackgroundColor3 = Color3.fromRGB(45, 55, 45)
				else
					flingItem.Text = "  [ ] " .. p.Name
					flingItem.TextColor3 = Color3.fromRGB(255, 255, 255)
					flingItem.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
				end
			end
			updateFlingItemVisuals()
			flingUIElements[p.Name] = flingItem

			flingItem.Activated:Connect(function()
				if SelectedTargets[p.Name] then
					SelectedTargets[p.Name] = nil
				else
					SelectedTargets[p.Name] = p
				end
				updateFlingItemVisuals()
				UpdateFlingStatus()
			end)
		end
	end
	plrScroll.CanvasSize = UDim2.new(0, 0, 0, plrListLayout.AbsoluteContentSize.Y)
	specScroll.CanvasSize = UDim2.new(0, 0, 0, specListLayout.AbsoluteContentSize.Y)
	flingScroll.CanvasSize = UDim2.new(0, 0, 0, flingListLayout.AbsoluteContentSize.Y)
end

Players.PlayerAdded:Connect(updatePlayerLists)
Players.PlayerRemoving:Connect(function(p)
	if SelectedTargets[p.Name] then SelectedTargets[p.Name] = nil end
	updatePlayerLists()
	UpdateFlingStatus()
end)
updatePlayerLists()

local tpBehindBtn, tpFarBehindBtn, tpAboveBtn, tpUnderBtn, focusHeadBtn
local activeTeleport = nil
local teleportConnection = nil
local tpPlatform = nil 
local isFocusingHead = false
local focusHeadConnection = nil

local function stopFocusingHead()
	isFocusingHead = false
	if focusHeadBtn then focusHeadBtn.Text = "Focus Head" focusHeadBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80) end
	if focusHeadConnection then focusHeadConnection:Disconnect() focusHeadConnection = nil end
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
		workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid")
	end
end

local function stopTeleporting()
	if teleportConnection then teleportConnection:Disconnect() teleportConnection = nil end
	activeTeleport = nil
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.Anchored = false
	end
	if tpPlatform then tpPlatform:Destroy() tpPlatform = nil end 
	if tpBehindBtn then tpBehindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80) end
	if tpFarBehindBtn then tpFarBehindBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80) end
	if tpAboveBtn then tpAboveBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80) end
	if tpUnderBtn then tpUnderBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80) end
end

local function startTeleporting(mode, btn)
	stopTeleporting() 
	activeTeleport = mode
	btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	
	tpPlatform = Instance.new("Part")
	tpPlatform.Name = "QDH_HoverPlatform"
	tpPlatform.Size = Vector3.new(15, 1, 15)
	tpPlatform.Transparency = 1
	tpPlatform.Anchored = true
	tpPlatform.CanCollide = true
	tpPlatform.Parent = workspace

	teleportConnection = RunService.Heartbeat:Connect(function()
		local target = Players:FindFirstChild(selectedTpPlayer or "")
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			
			hrp.Anchored = true
			hrp.Velocity = Vector3.new(0, 0, 0)
			hrp.RotVelocity = Vector3.new(0, 0, 0)
			
			local targetCFrame = target.Character.HumanoidRootPart.CFrame
			local desiredCFrame
			if mode == "Behind" then desiredCFrame = targetCFrame * CFrame.new(0, 0, 2.5)
			elseif mode == "FarBehind" then desiredCFrame = targetCFrame * CFrame.new(0, 0, 15)
			elseif mode == "Above" then desiredCFrame = targetCFrame * CFrame.new(0, 10, 0)
			elseif mode == "Under" then
				desiredCFrame = targetCFrame * CFrame.new(0, -3.5, 0)
				for _, part in ipairs(player.Character:GetChildren()) do
					if part:IsA("BasePart") then part.CanCollide = true end
				end
			end
			
			-- МИТТЄВИЙ ТЕЛЕПОРТ БЕЗ ПОКРОКОВИХ ОБМЕЖЕНЬ
			hrp.CFrame = desiredCFrame
			
			if tpPlatform then
				tpPlatform.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0)
			end
		end
	end)
end

tpBehindBtn = createButton(tab4, "Behind", UDim2.new(0.05, 0, 0.56, 0), UDim2.new(0.42, 0, 0.13, 0), Color3.fromRGB(70, 70, 80), function() if activeTeleport == "Behind" then stopTeleporting() else startTeleporting("Behind", tpBehindBtn) end end)
tpFarBehindBtn = createButton(tab4, "Far Away", UDim2.new(0.53, 0, 0.56, 0), UDim2.new(0.42, 0, 0.13, 0), Color3.fromRGB(70, 70, 80), function() if activeTeleport == "FarBehind" then stopTeleporting() else startTeleporting("FarBehind", tpFarBehindBtn) end end)
tpAboveBtn = createButton(tab4, "Above", UDim2.new(0.05, 0, 0.71, 0), UDim2.new(0.42, 0, 0.13, 0), Color3.fromRGB(70, 70, 80), function() if activeTeleport == "Above" then stopTeleporting() else startTeleporting("Above", tpAboveBtn) end end)
tpUnderBtn = createButton(tab4, "Under", UDim2.new(0.53, 0, 0.71, 0), UDim2.new(0.42, 0, 0.13, 0), Color3.fromRGB(70, 70, 80), function() if activeTeleport == "Under" then stopTeleporting() else startTeleporting("Under", tpUnderBtn) end end)

focusHeadBtn = createButton(tab4, "Focus", UDim2.new(0.05, 0, 0.86, 0), UDim2.new(0.9, 0, 0.13, 0), Color3.fromRGB(70, 70, 80), function()
	if isFocusingHead then stopFocusingHead() else
		local target = Players:FindFirstChild(selectedTpPlayer or "")
		if target then
			isFocusingHead = true focusHeadBtn.Text = "Stop" focusHeadBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
			focusHeadConnection = RunService.RenderStepped:Connect(function()
				local t = Players:FindFirstChild(selectedTpPlayer or "")
				local localHead = player.Character and player.Character:FindFirstChild("Head")
				if t and t.Character and t.Character:FindFirstChild("Head") and localHead then
					workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
					workspace.CurrentCamera.CFrame = CFrame.lookAt(localHead.Position, t.Character.Head.Position)
				else
					workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
					if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid") end
				end
			end)
		end
	end
end)

-- ==========================================
-- TAB 5: SPECTATE
-- ==========================================
local spectateBtn = createButton(tab5, "Spectate", UDim2.new(0.05, 0, 0.74, 0), UDim2.new(0.9, 0, 0.22, 0), Color3.fromRGB(150, 100, 200), function() end)
local isSpectating = false
local spectateConnection = nil

local function stopSpectating()
	isSpectating = false spectateBtn.Text = "Spectate" spectateBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 200)
	if spectateConnection then spectateConnection:Disconnect() spectateConnection = nil end
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then workspace.CurrentCamera.CameraSubject = player.Character:FindFirstChildOfClass("Humanoid") end
end

spectateBtn.Activated:Connect(function()
	if isSpectating then stopSpectating() else
		local target = Players:FindFirstChild(selectedSpecPlayer or "")
		if target then
			isSpectating = true spectateBtn.Text = "Stop Spectating" spectateBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) 
			spectateConnection = RunService.Heartbeat:Connect(function()
				local t = Players:FindFirstChild(selectedSpecPlayer or "")
				if t and t.Character then
					local humanoid = t.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
						if workspace.CurrentCamera.CameraSubject ~= humanoid then workspace.CurrentCamera.CameraSubject = humanoid end
					end
				else stopSpectating() end
			end)
		end
	end
end)

-- ==========================================
-- TAB 6: TP FORWARD
-- ==========================================
local tpForLabel = Instance.new("TextLabel", tab6)
tpForLabel.Size = UDim2.new(0.9, 0, 0.22, 0)
tpForLabel.Position = UDim2.new(0.05, 0, 0.08, 0)
tpForLabel.Text = "Teleport Forward"
tpForLabel.Font = Enum.Font.GothamBold
tpForLabel.TextScaled = true
tpForLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
tpForLabel.BackgroundTransparency = 1

local studsInput = createTextBox(tab6, "Enter studs...", "", UDim2.new(0.05, 0, 0.35, 0), UDim2.new(0.9, 0, 0.22, 0))

createButton(tab6, "Teleport", UDim2.new(0.05, 0, 0.68, 0), UDim2.new(0.9, 0, 0.24, 0), Color3.fromRGB(200, 120, 0), function()
	local studs = tonumber(studsInput.Text)
	if studs and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = player.Character.HumanoidRootPart
		hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -studs)
	end
end)

-- ==========================================
-- TAB 8 & 9: SPEED & JUMP PWR
-- ==========================================
local Config = { WalkSpeed = originalSpeed, JumpPower = originalJumpPower, ForceSpeed = false, ForceJump = false }

RunService.RenderStepped:Connect(function()
	local char = player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if Config.ForceSpeed then hum.WalkSpeed = Config.WalkSpeed end
		if Config.ForceJump then hum.UseJumpPower = true hum.JumpPower = Config.JumpPower end
	end
end)

local speedInput = createTextBox(tab8, "Enter WalkSpeed", "100", UDim2.new(0.1, 0, 0.15, 0), UDim2.new(0.8, 0, 0.25, 0))
local speedSetBtn = createButton(tab8, "Set Speed", UDim2.new(0.1, 0, 0.5, 0), UDim2.new(0.8, 0, 0.3, 0), Color3.fromRGB(50, 150, 200), function()
	local val = tonumber(speedInput.Text)
	if val then
		Config.WalkSpeed = val
		Config.ForceSpeed = true
	end
end)

local jumpInput = createTextBox(tab9, "Enter JumpPower", "150", UDim2.new(0.1, 0, 0.15, 0), UDim2.new(0.8, 0, 0.25, 0))
local jumpSetBtn = createButton(tab9, "Set Jump Power", UDim2.new(0.1, 0, 0.5, 0), UDim2.new(0.8, 0, 0.3, 0), Color3.fromRGB(50, 150, 200), function()
	local val = tonumber(jumpInput.Text)
	if val then
		Config.JumpPower = val
		Config.ForceJump = true
	end
end)

-- ==========================================
-- TAB 10: FLY 
-- ==========================================
local flySpeed = 1
local isFlying, upPressed, downPressed, forwardPressed, backwardPressed = false, false, false, false, false
local bv, bg, flyConnection

local function stopFlying()
	isFlying = false 
	upPressed, downPressed, forwardPressed, backwardPressed = false, false, false, false, false
	if bv then bv:Destroy() bv = nil end 
	if bg then bg:Destroy() bg = nil end
	if flyConnection then flyConnection:Disconnect() flyConnection = nil end
	local char = player.Character
	if char and char:FindFirstChildOfClass("Humanoid") then 
		char:FindFirstChildOfClass("Humanoid").PlatformStand = false 
	end
end

local flyToggleBtn = createButton(tab10, "Fly: OFF", UDim2.new(0.1, 0, 0.05, 0), UDim2.new(0.8, 0, 0.16, 0), Color3.fromRGB(200, 50, 50), function() end)

local function startFlying()
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	isFlying = true 
	flyToggleBtn.Text = "Fly: ON" 
	flyToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	
	local hrp = char.HumanoidRootPart 
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	
	local flyRoot = hrp.AssemblyRootPart or hrp
	humanoid.PlatformStand = true

	bv = Instance.new("BodyVelocity", flyRoot) 
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge) 
	bv.Velocity = Vector3.new(0, 0, 0)
	
	bg = Instance.new("BodyGyro", flyRoot) 
	bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) 
	bg.P = 1000000 
	bg.D = 500
	bg.CFrame = workspace.CurrentCamera.CFrame

	flyConnection = RunService.RenderStepped:Connect(function()
		if not isFlying or not char or not char:FindFirstChild("HumanoidRootPart") then stopFlying() return end
		
		local cam = workspace.CurrentCamera 
		bg.CFrame = cam.CFrame
		local moveDir = humanoid.MoveDirection 
		local baseVel = Vector3.new(0, 0, 0)
		
		if moveDir.Magnitude > 0.01 then
			local _, camY, _ = cam.CFrame:ToOrientation()
			local flatCamCFrame = CFrame.Angles(0, camY, 0)
			local localMove = flatCamCFrame:VectorToObjectSpace(moveDir)
			local flyDir = (cam.CFrame.LookVector * -localMove.Z) + (cam.CFrame.RightVector * localMove.X)
			baseVel = flyDir.Unit * (flySpeed * 150)
		end
		
		local upDownVel = Vector3.new(0, 0, 0)
		if upPressed then upDownVel = cam.CFrame.UpVector * (flySpeed * 150)
		elseif downPressed then upDownVel = -cam.CFrame.UpVector * (flySpeed * 150) end
		
		local fbVel = Vector3.new(0, 0, 0)
		if forwardPressed then fbVel = cam.CFrame.LookVector * (flySpeed * 150)
		elseif backwardPressed then fbVel = -cam.CFrame.LookVector * (flySpeed * 150) end
		
		bv.Velocity = baseVel + upDownVel + fbVel
	end)
end

flyToggleBtn.Activated:Connect(function()
	if isFlying then stopFlying() flyToggleBtn.Text = "Fly: OFF" flyToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	else startFlying() end
end)

local upBtn = createButton(tab10, "UP", UDim2.new(0.1, 0, 0.25, 0), UDim2.new(0.35, 0, 0.16, 0), Color3.fromRGB(50, 150, 200), function() end)
local downBtn = createButton(tab10, "DOWN", UDim2.new(0.55, 0, 0.25, 0), UDim2.new(0.35, 0, 0.16, 0), Color3.fromRGB(200, 120, 0), function() end)
local forwardBtn = createButton(tab10, "FORWARD", UDim2.new(0.1, 0, 0.45, 0), UDim2.new(0.35, 0, 0.16, 0), Color3.fromRGB(50, 180, 100), function() end)
local backwardBtn = createButton(tab10, "BACKWARD", UDim2.new(0.55, 0, 0.45, 0), UDim2.new(0.35, 0, 0.16, 0), Color3.fromRGB(180, 50, 150), function() end)
local minusBtn = createButton(tab10, "-", UDim2.new(0.1, 0, 0.65, 0), UDim2.new(0.2, 0, 0.16, 0), Color3.fromRGB(150, 50, 200), function() end)
local plusBtn = createButton(tab10, "+", UDim2.new(0.7, 0, 0.65, 0), UDim2.new(0.2, 0, 0.16, 0), Color3.fromRGB(150, 50, 200), function() end)

local speedDisplay = Instance.new("TextLabel", tab10)
speedDisplay.Size = UDim2.new(0.3, 0, 0.16, 0)
speedDisplay.Position = UDim2.new(0.35, 0, 0.65, 0)
speedDisplay.Text = "Spd: " .. tostring(flySpeed)
speedDisplay.Font = Enum.Font.GothamBold
speedDisplay.TextScaled = true
speedDisplay.TextColor3 = Color3.new(1, 1, 1)
speedDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
local sdCorner = Instance.new("UICorner", speedDisplay)
sdCorner.CornerRadius = UDim.new(0, 3)

minusBtn.Activated:Connect(function() 
	if flySpeed > 1 then 
		flySpeed = flySpeed - 1 
	elseif flySpeed <= 1 and flySpeed > 0.1 then 
		flySpeed = flySpeed - 0.1 
	end 
	flySpeed = math.floor(flySpeed * 10 + 0.5) / 10 
	speedDisplay.Text = "Spd: " .. tostring(flySpeed) 
end)

plusBtn.Activated:Connect(function() 
	if flySpeed >= 1 then 
		flySpeed = flySpeed + 1 
	else 
		flySpeed = flySpeed + 0.1 
	end 
	flySpeed = math.floor(flySpeed * 10 + 0.5) / 10
	speedDisplay.Text = "Spd: " .. tostring(flySpeed) 
end)

upBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then upPressed = true end end)
upBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then upPressed = false end end)
downBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then downPressed = true end end)
downBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then downPressed = false end end)
forwardBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then forwardPressed = true end end)
forwardBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then forwardPressed = false end end)
backwardBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then backwardPressed = true end end)
backwardBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then backwardPressed = false end end)

-- ==========================================
-- TAB 11: NOCLIP 
-- ==========================================
local globalNoclipConnection, forwardNoclipConnection
local isGlobalNoclip, isForwardNoclip = false, false

local globalNoclipBtn = createButton(tab11, "Global Noclip: OFF", UDim2.new(0.1, 0, 0.2, 0), UDim2.new(0.8, 0, 0.25, 0), Color3.fromRGB(70, 70, 80), function() end)
local forwardNoclipBtn = createButton(tab11, "Forward Noclip: OFF", UDim2.new(0.1, 0, 0.55, 0), UDim2.new(0.8, 0, 0.25, 0), Color3.fromRGB(70, 70, 80), function() end)

local function stopGlobalNoclip()
	isGlobalNoclip = false globalNoclipBtn.Text = "Global Noclip: OFF" globalNoclipBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	if globalNoclipConnection then globalNoclipConnection:Disconnect() globalNoclipConnection = nil end
end

local function stopForwardNoclip()
	isForwardNoclip = false forwardNoclipBtn.Text = "Forward Noclip: OFF" forwardNoclipBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
	if forwardNoclipConnection then forwardNoclipConnection:Disconnect() forwardNoclipConnection = nil end
end

globalNoclipBtn.Activated:Connect(function()
	if isGlobalNoclip then stopGlobalNoclip() else
		if isForwardNoclip then stopForwardNoclip() end
		isGlobalNoclip = true globalNoclipBtn.Text = "Global Noclip: ON" globalNoclipBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		globalNoclipConnection = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
		end)
	end
end)

forwardNoclipBtn.Activated:Connect(function()
	if isForwardNoclip then stopForwardNoclip() else
		if isGlobalNoclip then stopGlobalNoclip() end
		isForwardNoclip = true forwardNoclipBtn.Text = "Forward Noclip: ON" forwardNoclipBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		forwardNoclipConnection = RunService.Stepped:Connect(function()
			local char = player.Character if not char then return end
			local hrp = char:FindFirstChild("HumanoidRootPart") local hum = char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum then return end
			local moveDir = hum.MoveDirection local insideWall = false
			if moveDir.Magnitude > 0.1 then
				local rayParams = RaycastParams.new() rayParams.FilterDescendantsInstances = {char} rayParams.FilterType = Enum.RaycastFilterType.Exclude
				local origins = { hrp.Position, hrp.Position + Vector3.new(0, 1.5, 0) }
				for _, origin in ipairs(origins) do
					local result = workspace:Raycast(origin, moveDir * 2.5, rayParams)
					if result and result.Instance and result.Instance:IsA("BasePart") and result.Instance.CanCollide then insideWall = true break end
				end
			end
			if insideWall then for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
		end)
	end
end)

-- ==========================================
-- TAB 12: TIME TELEPORT 
-- ==========================================
local savedCFrameNormal = nil
local savedCFrameTemp = nil
local isTimeTeleporting = false 

local tpSaveNormalBtn = createButton(tab12, "Save Normal", UDim2.new(0.05, 0, 0.1, 0), UDim2.new(0.42, 0, 0.2, 0), Color3.fromRGB(50, 50, 60), function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then savedCFrameNormal = char.HumanoidRootPart.CFrame end
end)

local tpGoNormalBtn = createButton(tab12, "TP Normal", UDim2.new(0.53, 0, 0.1, 0), UDim2.new(0.42, 0, 0.2, 0), Color3.fromRGB(50, 150, 200), function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") and savedCFrameNormal then char.HumanoidRootPart.CFrame = savedCFrameNormal end
end)

local tpSaveTempBtn = createButton(tab12, "Save Temp", UDim2.new(0.05, 0, 0.38, 0), UDim2.new(0.42, 0, 0.2, 0), Color3.fromRGB(50, 50, 60), function()
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then savedCFrameTemp = char.HumanoidRootPart.CFrame end
end)

local tpTimeInput = createTextBox(tab12, "Secs", "5", UDim2.new(0.53, 0, 0.38, 0), UDim2.new(0.42, 0, 0.2, 0))

local tpGoTimeBtn = createButton(tab12, "Time Teleport", UDim2.new(0.05, 0, 0.66, 0), UDim2.new(0.9, 0, 0.25, 0), Color3.fromRGB(200, 100, 50), function() end)

tpGoTimeBtn.Activated:Connect(function()
	if isTimeTeleporting then return end 
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") and savedCFrameTemp then
		local timeToWait = tonumber(tpTimeInput.Text)
		if timeToWait and timeToWait > 0 then
			isTimeTeleporting = true
			local originalPos = char.HumanoidRootPart.CFrame 
			char.HumanoidRootPart.CFrame = savedCFrameTemp 
			
			tpGoTimeBtn.Text = "Wait " .. timeToWait .. "s..."
			tpGoTimeBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
			
			task.delay(timeToWait, function()
				local currentChar = player.Character
				if currentChar and currentChar:FindFirstChild("HumanoidRootPart") then
					currentChar.HumanoidRootPart.CFrame = originalPos
				end
				tpGoTimeBtn.Text = "Time Teleport"
				tpGoTimeBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
				isTimeTeleporting = false
			end)
		end
	end
end)

-- ==========================================
-- TAB 13: МОМЕНТАЛЬНИЙ FLING (БЕЗ ПОКРОКОВОГО ТП)
-- ==========================================
local function SkidFling(TargetPlayer)
	local Character = player.Character
	local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
	local RootPart = Humanoid and Humanoid.RootPart
	local TCharacter = TargetPlayer.Character
	if not TCharacter then return end
	
	local THumanoid, TRootPart, THead, Accessory, Handle
	if TCharacter:FindFirstChildOfClass("Humanoid") then THumanoid = TCharacter:FindFirstChildOfClass("Humanoid") end
	if THumanoid and THumanoid.RootPart then TRootPart = THumanoid.RootPart end
	if TCharacter:FindFirstChild("Head") then THead = TCharacter.Head end
	if TCharacter:FindFirstChildOfClass("Accessory") then Accessory = TCharacter:FindFirstChildOfClass("Accessory") end
	if Accessory and Accessory:FindFirstChild("Handle") then Handle = Accessory.Handle end
	
	if Character and Humanoid and RootPart then
		if RootPart.Velocity.Magnitude < 50 then getgenv().OldPos = RootPart.CFrame end
		
		if THead then workspace.CurrentCamera.CameraSubject = THead
		elseif Handle then workspace.CurrentCamera.CameraSubject = Handle
		elseif THumanoid and TRootPart then workspace.CurrentCamera.CameraSubject = THumanoid end
		
		if not TCharacter:FindFirstChildWhichIsA("BasePart") then return end
		
		local FPos = function(BasePart, Pos, Ang)
			RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
			Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
			RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
			RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
		end
		
		local SFBasePart = function(BasePart)
			local TimeToWait = 2
			local Time = tick()
			local Angle = 0
			repeat
				if RootPart and THumanoid then
					if BasePart.Velocity.Magnitude < 50 then
						Angle = Angle + 100
						FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
						task.wait()
						FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
						task.wait()
						FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
						task.wait()
						FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
						task.wait()
						FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
						task.wait()
						FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
						task.wait()
					else
						FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
						task.wait()
						FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
						task.wait()
						FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
						task.wait()
						
						FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
						task.wait()
						FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
						task.wait()
						FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
						task.wait()
						FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
						task.wait()
					end
				end
			until Time + TimeToWait < tick() or not FlingActive
		end
		
		workspace.FallenPartsDestroyHeight = 0/0
		local BV = Instance.new("BodyVelocity")
		BV.Parent = RootPart
		BV.Velocity = Vector3.new(0, 0, 0)
		BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		
		if TRootPart then SFBasePart(TRootPart)
		elseif THead then SFBasePart(THead)
		elseif Handle then SFBasePart(Handle)
		else return Message("Error", TargetPlayer.Name .. " has no valid parts", 2) end
		
		BV:Destroy()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		workspace.CurrentCamera.CameraSubject = Humanoid
		
		if getgenv().OldPos then
			repeat
				RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
				Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
				Humanoid:ChangeState("GettingUp")
				for _, part in pairs(Character:GetChildren()) do
					if part:IsA("BasePart") then part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new() end
				end
				task.wait()
			until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
			workspace.FallenPartsDestroyHeight = getgenv().FPDH
		end
	else
		return Message("Error", "Your character is not ready", 2)
	end
end

local function stopFlingLoop()
	FlingActive = false
	UpdateFlingStatus()
end

local function startFlingLoop()
	if FlingActive then return end
	local count = CountSelectedTargets()
	if count == 0 then
		flingStatusLabel.Text = "No targets selected!"
		task.wait(1)
		UpdateFlingStatus()
		return
	end
	
	FlingActive = true
	UpdateFlingStatus()
	Message("Started", "Flinging " .. count .. " targets", 2)
	
	task.spawn(function()
		while FlingActive do
			local validTargets = {}
			for name, p in pairs(SelectedTargets) do
				if p and p.Parent then
					validTargets[name] = p
				else
					SelectedTargets[name] = nil
				end
			end
			
			for _, p in pairs(validTargets) do
				if FlingActive then
					SkidFling(p)
					task.wait(0.1)
				else break end
			end
			UpdateFlingStatus()
			task.wait(0.5)
		end
	end)
end

local function ToggleAllFlingPlayers(select)
	for name, item in pairs(flingUIElements) do
		local p = Players:FindFirstChild(name)
		if p then
			if select then SelectedTargets[name] = p else SelectedTargets[name] = nil end
			if select then
				item.Text = "  [✓] " .. name
				item.TextColor3 = Color3.fromRGB(50, 255, 50)
				item.BackgroundColor3 = Color3.fromRGB(45, 55, 45)
			else
				item.Text = "  [ ] " .. name
				item.TextColor3 = Color3.fromRGB(255, 255, 255)
				item.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
			end
		end
	end
	UpdateFlingStatus()
end

createButton(tab13, "START FLING", UDim2.new(0.05, 0, 0.64, 0), UDim2.new(0.42, 0, 0.14, 0), Color3.fromRGB(50, 200, 50), startFlingLoop)
createButton(tab13, "STOP FLING", UDim2.new(0.53, 0, 0.64, 0), UDim2.new(0.42, 0, 0.14, 0), Color3.fromRGB(200, 50, 50), stopFlingLoop)
createButton(tab13, "SELECT ALL", UDim2.new(0.05, 0, 0.81, 0), UDim2.new(0.42, 0, 0.14, 0), Color3.fromRGB(60, 60, 70), function() ToggleAllFlingPlayers(true) end)
createButton(tab13, "DESELECT ALL", UDim2.new(0.53, 0, 0.81, 0), UDim2.new(0.42, 0, 0.14, 0), Color3.fromRGB(60, 60, 70), function() ToggleAllFlingPlayers(false) end)

-- ==========================================
-- TAB 14: WALLHOP FUNCTIONALITY & LOGIC
-- ==========================================
local wallhopToggle = false
local autoToggle = false
local selectModeActive = false
local InfiniteJumpEnabled = true
local selectedBrickColor = nil

local whRaycastParams = RaycastParams.new()
whRaycastParams.FilterType = Enum.RaycastFilterType.Exclude

local whJumpConnection = nil
local whAutoJumpConnection = nil
local whMouseClickConnection = nil

local function getWallRaycastResult()
	local char = player.Character
	if not char then return nil end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	whRaycastParams.FilterDescendantsInstances = {char}
	local detectionDistance = 2
	local closestHit = nil
	local minDistance = detectionDistance + 1
	local hrpCF = hrp.CFrame

	for i = 0, 7 do
		local angle = math.rad(i * 45)
		local direction = (hrpCF * CFrame.Angles(0, angle, 0)).LookVector
		local ray = Workspace:Raycast(hrp.Position, direction * detectionDistance, whRaycastParams)
		if ray and ray.Instance and ray.Distance < minDistance then
			minDistance = ray.Distance
			closestHit = ray
		end
	end

	local blockCastSize = Vector3.new(1.5, 1, 0.5)
	local blockCastOffset = CFrame.new(0, -1, -0.5)
	local blockCastOriginCF = hrpCF * blockCastOffset
	local blockCastDirection = hrpCF.LookVector
	local blockCastDistance = 1.5
	local blockResult = Workspace:Blockcast(blockCastOriginCF, blockCastSize, blockCastDirection * blockCastDistance, whRaycastParams)

	if blockResult and blockResult.Instance and blockResult.Distance < minDistance then
		minDistance = blockResult.Distance
		closestHit = blockResult
	end

	return closestHit
end

local function executeWallJump(wallRayResult, jumpType)
	if jumpType ~= "Button" and not InfiniteJumpEnabled then return end

	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local camera = Workspace.CurrentCamera

	if not (humanoid and hrp and camera and humanoid:GetState() ~= Enum.HumanoidStateType.Dead and wallRayResult) then return end

	if jumpType ~= "Button" then InfiniteJumpEnabled = false end

	local maxInfluenceAngleRight = math.rad(20)
	local maxInfluenceAngleLeft  = math.rad(-100)
	local wallNormal = wallRayResult.Normal
	local baseDirectionAwayFromWall = Vector3.new(wallNormal.X, 0, wallNormal.Z).Unit
	
	if baseDirectionAwayFromWall.Magnitude < 0.1 then
		local dirToHit = (wallRayResult.Position - hrp.Position) * Vector3.new(1,0,1)
		baseDirectionAwayFromWall = -dirToHit.Unit
		if baseDirectionAwayFromWall.Magnitude < 0.1 then
			baseDirectionAwayFromWall = -hrp.CFrame.LookVector * Vector3.new(1, 0, 1)
			if baseDirectionAwayFromWall.Magnitude > 0.1 then baseDirectionAwayFromWall = baseDirectionAwayFromWall.Unit end
			if baseDirectionAwayFromWall.Magnitude < 0.1 then baseDirectionAwayFromWall = Vector3.new(0,0,1) end
		end
	end
	baseDirectionAwayFromWall = Vector3.new(baseDirectionAwayFromWall.X, 0, baseDirectionAwayFromWall.Z).Unit
	if baseDirectionAwayFromWall.Magnitude < 0.1 then baseDirectionAwayFromWall = Vector3.new(0,0,1) end

	local cameraLook = camera.CFrame.LookVector
	local horizontalCameraLook = Vector3.new(cameraLook.X, 0, cameraLook.Z).Unit
	if horizontalCameraLook.Magnitude < 0.1 then horizontalCameraLook = baseDirectionAwayFromWall end

	local dot = math.clamp(baseDirectionAwayFromWall:Dot(horizontalCameraLook), -1, 1)
	local angleBetween = math.acos(dot)
	local cross = baseDirectionAwayFromWall:Cross(horizontalCameraLook)
	local rotationSign = -math.sign(cross.Y)
	if rotationSign == 0 then angleBetween = 0 end

	local actualInfluenceAngle = 0
	if rotationSign == 1 then actualInfluenceAngle = math.min(angleBetween, maxInfluenceAngleRight)
	elseif rotationSign == -1 then actualInfluenceAngle = math.min(angleBetween, maxInfluenceAngleLeft) end

	local adjustmentRotation = CFrame.Angles(0, actualInfluenceAngle * rotationSign, 0)
	local initialTargetLookDirection = adjustmentRotation * baseDirectionAwayFromWall

	hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + initialTargetLookDirection)
	RunService.Heartbeat:Wait()

	local didJump = false
	if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		didJump = true
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, -1, 0)
		task.wait(0.15)
		hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 1, 0)
	end

	if didJump then
		local directionTowardsWall = -baseDirectionAwayFromWall
		task.wait(0.05)
		hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + directionTowardsWall)
	end

	if jumpType ~= "Button" then
		task.wait(0.1)
		InfiniteJumpEnabled = true
	end
end

local toggleWHBtn = createButton(tab14, "WallHop: OFF", UDim2.new(0.05, 0, 0.05, 0), UDim2.new(0.43, 0, 0.24, 0), Color3.fromRGB(200, 50, 50), function() end)
local toggleAutoBtn = createButton(tab14, "Auto: OFF", UDim2.new(0.52, 0, 0.05, 0), UDim2.new(0.43, 0, 0.24, 0), Color3.fromRGB(200, 50, 50), function() end)
local selectColorBtn = createButton(tab14, "Select Color", UDim2.new(0.05, 0, 0.34, 0), UDim2.new(0.43, 0, 0.24, 0), Color3.fromRGB(70, 70, 80), function() end)
local forceJumpBtn = createButton(tab14, "Force Jump", UDim2.new(0.52, 0, 0.34, 0), UDim2.new(0.43, 0, 0.24, 0), Color3.fromRGB(0, 120, 200), function()
	local wallRayResult = getWallRaycastResult()
	if wallRayResult then executeWallJump(wallRayResult, "Button") end
end)

local colorStatusLabel = Instance.new("TextLabel", tab14)
colorStatusLabel.Size = UDim2.new(0.9, 0, 0.26, 0)
colorStatusLabel.Position = UDim2.new(0.05, 0, 0.64, 0)
colorStatusLabel.Text = "No color selected"
colorStatusLabel.Font = Enum.Font.GothamBold
colorStatusLabel.TextScaled = true
colorStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
colorStatusLabel.BackgroundTransparency = 1

toggleWHBtn.Activated:Connect(function()
	wallhopToggle = not wallhopToggle
	toggleWHBtn.Text = wallhopToggle and "WallHop: ON" or "WallHop: OFF"
	toggleWHBtn.BackgroundColor3 = wallhopToggle and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

toggleAutoBtn.Activated:Connect(function()
	if not selectedBrickColor then
		colorStatusLabel.Text = "Select color first!"
		colorStatusLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
		task.wait(1.5)
		colorStatusLabel.Text = selectedBrickColor and "Color: " .. selectedBrickColor.Name or "No color selected"
		colorStatusLabel.TextColor3 = selectedBrickColor and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
		return
	end
	autoToggle = not autoToggle
	toggleAutoBtn.Text = autoToggle and "Auto: ON" or "Auto: OFF"
	toggleAutoBtn.BackgroundColor3 = autoToggle and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
end)

selectColorBtn.Activated:Connect(function()
	selectModeActive = not selectModeActive
	selectColorBtn.BackgroundColor3 = selectModeActive and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(70, 70, 80)
	if selectModeActive then
		colorStatusLabel.Text = "Click any part..."
		if whMouseClickConnection then whMouseClickConnection:Disconnect() end
		whMouseClickConnection = mouse.Button1Down:Connect(function()
			local target = mouse.Target
			if target and target:IsA("BasePart") then
				selectedBrickColor = target.BrickColor
				colorStatusLabel.Text = "Color: " .. selectedBrickColor.Name
				colorStatusLabel.TextColor3 = target.Color
				selectModeActive = false
				selectColorBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
				if whMouseClickConnection then whMouseClickConnection:Disconnect() whMouseClickConnection = nil end
			end
		end)
	else
		if whMouseClickConnection then whMouseClickConnection:Disconnect() whMouseClickConnection = nil end
		colorStatusLabel.Text = selectedBrickColor and "Color: " .. selectedBrickColor.Name or "No color selected"
	end
end)

whJumpConnection = UserInputService.JumpRequest:Connect(function()
	if not wallhopToggle then return end
	local wallRayResult = getWallRaycastResult()
	if wallRayResult then executeWallJump(wallRayResult, "Manual") end
end)

whAutoJumpConnection = RunService.Heartbeat:Connect(function()
	if not (autoToggle and wallhopToggle and selectedBrickColor) then return end
	local char = player.Character
	local humanoid = char and char:FindFirstChildOfClass("Humanoid")
	if not (humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead) then return end

	local wallRayResult = getWallRaycastResult()
	if wallRayResult and wallRayResult.Instance and wallRayResult.Instance:IsA("BasePart") then
		if wallRayResult.Instance.BrickColor == selectedBrickColor then
			executeWallJump(wallRayResult, "Auto")
		end
	end
end)

-- ==========================================
-- TAB 15: SPIN (BLOCK FLING)
-- ==========================================
local spinToggle = false
local spinFixation = false
local spinLoopConnection = nil
local fixedCFrame = nil 

local spinLabel = Instance.new("TextLabel", tab15)
spinLabel.Size = UDim2.new(1, 0, 0.22, 0)
spinLabel.Position = UDim2.new(0, 0, 0.05, 0)
spinLabel.Text = "Spin (Block Fling)"
spinLabel.Font = Enum.Font.GothamBold
spinLabel.TextScaled = true
spinLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
spinLabel.BackgroundTransparency = 1

local function updateSpinFixationLoop()
	if not spinToggle and not spinFixation then
		if spinLoopConnection then
			spinLoopConnection:Disconnect()
			spinLoopConnection = nil
		end
		fixedCFrame = nil
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hrp then
			hrp.RotVelocity = Vector3.new(0, 0, 0)
			hrp.Velocity = Vector3.new(0, 0, 0)
			hrp.Anchored = false
		end
		if hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		end
		return
	end

	if not spinLoopConnection then
		spinLoopConnection = RunService.Heartbeat:Connect(function()
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			
			if hrp then
				if spinFixation then
					if not fixedCFrame then
						fixedCFrame = hrp.CFrame
					end
					
					if spinToggle then
						hrp.Anchored = false
						hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
						hrp.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
						hrp.CFrame = CFrame.new(fixedCFrame.Position) * (hrp.CFrame - hrp.CFrame.Position)
						if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
					else
						hrp.CFrame = fixedCFrame
						hrp.Anchored = true
						hrp.RotVelocity = Vector3.new(0, 0, 0)
						hrp.Velocity = Vector3.new(0, 0, 0)
					end
				else
					fixedCFrame = nil
					hrp.Anchored = false
					if spinToggle then
						hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
						hrp.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
						if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false) end
					else
						hrp.RotVelocity = Vector3.new(0, 0, 0)
						hrp.Velocity = Vector3.new(0, 0, 0)
					end
				end
			end
		end)
	end
end

local function stopSpinning()
	spinToggle = false
	updateSpinFixationLoop()
end

local function startSpinning()
	spinToggle = true
	updateSpinFixationLoop()
end

createButton(tab15, "ON", UDim2.new(0.05, 0, 0.35, 0), UDim2.new(0.42, 0, 0.25, 0), Color3.fromRGB(50, 200, 50), startSpinning)
createButton(tab15, "OFF", UDim2.new(0.53, 0, 0.35, 0), UDim2.new(0.42, 0, 0.25, 0), Color3.fromRGB(200, 50, 50), stopSpinning)

local fixationBtn = createButton(tab15, "Fixation: OFF", UDim2.new(0.05, 0, 0.68, 0), UDim2.new(0.9, 0, 0.25, 0), Color3.fromRGB(200, 50, 50), function() end)

fixationBtn.Activated:Connect(function()
	spinFixation = not spinFixation
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	
	if spinFixation then
		fixationBtn.Text = "Fixation: ON"
		fixationBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
		if hrp then fixedCFrame = hrp.CFrame end
	else
		fixationBtn.Text = "Fixation: OFF"
		fixationBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	updateSpinFixationLoop()
end)

-- ==========================================
-- TAB 16: LOOP TP
-- ==========================================
local loopWaypoints = {}
local isLoopTeleporting = false

local loopNameInput = createTextBox(tab16, "Name", "", UDim2.new(0.05, 0, 0.04, 0), UDim2.new(0.6, 0, 0.14, 0))
local loopSaveBtn = createButton(tab16, "Save", UDim2.new(0.7, 0, 0.04, 0), UDim2.new(0.25, 0, 0.14, 0), Color3.fromRGB(50, 150, 200), function() end)
local loopTimeInput = createTextBox(tab16, "Time (s)", "2", UDim2.new(0.05, 0, 0.21, 0), UDim2.new(0.9, 0, 0.14, 0))

local loopScroll = Instance.new("ScrollingFrame", tab16)
loopScroll.Size = UDim2.new(0.9, 0, 0.42, 0)
loopScroll.Position = UDim2.new(0.05, 0, 0.38, 0)
loopScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
loopScroll.ScrollBarThickness = 3
local loopListLayout = Instance.new("UIListLayout", loopScroll)
loopListLayout.Padding = UDim.new(0, 3)

local loopStartBtn = createButton(tab16, "Teleport", UDim2.new(0.05, 0, 0.82, 0), UDim2.new(0.9, 0, 0.15, 0), Color3.fromRGB(200, 120, 0), function() end)

local function refreshLoopList()
	for _, child in ipairs(loopScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	for i, wp in ipairs(loopWaypoints) do
		local itemFrame = Instance.new("Frame", loopScroll)
		itemFrame.Size = UDim2.new(1, -8, 0, 24)
		itemFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		itemFrame.BorderSizePixel = 0
		local itemCorner = Instance.new("UICorner", itemFrame)
		itemCorner.CornerRadius = UDim.new(0, 3)
		
		local lbl = Instance.new("TextLabel", itemFrame)
		lbl.Size = UDim2.new(0.5, 0, 1, 0)
		lbl.Position = UDim2.new(0.02, 0, 0, 0)
		lbl.Text = tostring(i) .. ". " .. wp.Name
		lbl.Font = Enum.Font.Gotham
		lbl.TextScaled = true
		lbl.TextColor3 = Color3.new(1, 1, 1)
		lbl.BackgroundTransparency = 1
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		
		local del = Instance.new("TextButton", itemFrame)
		del.Size = UDim2.new(0, 24, 1, 0)
		del.Position = UDim2.new(1, -24, 0, 0)
		del.Text = "×"
		del.Font = Enum.Font.GothamBold
		del.TextScaled = true
		del.TextColor3 = Color3.fromRGB(255, 80, 80)
		del.BackgroundTransparency = 1
		del.Activated:Connect(function()
			table.remove(loopWaypoints, i)
			refreshLoopList()
		end)
		
		local downBtn = Instance.new("TextButton", itemFrame)
		downBtn.Size = UDim2.new(0, 24, 1, 0)
		downBtn.Position = UDim2.new(1, -48, 0, 0)
		downBtn.Text = "▼"
		downBtn.Font = Enum.Font.GothamBold
		downBtn.TextScaled = true
		downBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		downBtn.BackgroundTransparency = 1
		downBtn.Activated:Connect(function()
			if i < #loopWaypoints then
				loopWaypoints[i], loopWaypoints[i+1] = loopWaypoints[i+1], loopWaypoints[i]
				refreshLoopList()
			end
		end)
		
		local upBtn = Instance.new("TextButton", itemFrame)
		upBtn.Size = UDim2.new(0, 24, 1, 0)
		upBtn.Position = UDim2.new(1, -72, 0, 0)
		upBtn.Text = "▲"
		upBtn.Font = Enum.Font.GothamBold
		upBtn.TextScaled = true
		upBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
		upBtn.BackgroundTransparency = 1
		upBtn.Activated:Connect(function()
			if i > 1 then
				loopWaypoints[i], loopWaypoints[i-1] = loopWaypoints[i-1], loopWaypoints[i]
				refreshLoopList()
			end
		end)
	end
	loopScroll.CanvasSize = UDim2.new(0, 0, 0, loopListLayout.AbsoluteContentSize.Y)
end

loopSaveBtn.Activated:Connect(function()
	local name = loopNameInput.Text
	if name == "" then name = "Point " .. tostring(#loopWaypoints + 1) end
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		table.insert(loopWaypoints, {Name = name, CFrame = player.Character.HumanoidRootPart.CFrame})
		loopNameInput.Text = ""
		refreshLoopList()
	end
end)

loopStartBtn.Activated:Connect(function()
	if isLoopTeleporting then
		isLoopTeleporting = false
		loopStartBtn.Text = "Teleport"
		loopStartBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Anchored = false end
		return
	end
	if #loopWaypoints == 0 then return end
	
	local delayTime = tonumber(loopTimeInput.Text) or 2
	isLoopTeleporting = true
	loopStartBtn.Text = "Stop"
	loopStartBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	
	task.spawn(function()
		for i = 1, #loopWaypoints do
			if not isLoopTeleporting then break end
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = loopWaypoints[i].CFrame
				hrp.Anchored = true 
				hrp.Velocity = Vector3.new(0, 0, 0)
				hrp.RotVelocity = Vector3.new(0, 0, 0)
			end
			if i < #loopWaypoints then
				task.wait(delayTime)
			end
		end
		
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.Anchored = false 
		end
		
		isLoopTeleporting = false
		loopStartBtn.Text = "Teleport"
		loopStartBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
	end)
end)

-- ==========================================
-- TAB 17: PROXIMITY PROMPT
-- ==========================================
local proxPromptActive = false
local proxPromptConnection = nil
local originalDurations = {}

local function disableProxPrompt()
	proxPromptActive = false
	if proxPromptConnection then
		proxPromptConnection:Disconnect()
		proxPromptConnection = nil
	end
	for prompt, duration in pairs(originalDurations) do
		if prompt and prompt.Parent then
			prompt.HoldDuration = duration
		end
	end
	table.clear(originalDurations)
end

local function enableProxPrompt()
	if proxPromptActive then return end
	proxPromptActive = true
	
	for _, v in ipairs(Workspace:GetDescendants()) do
		if v:IsA("ProximityPrompt") then
			if not originalDurations[v] then
				originalDurations[v] = v.HoldDuration
			end
			v.HoldDuration = 0
		end
	end
	
	proxPromptConnection = Workspace.DescendantAdded:Connect(function(v)
		if v:IsA("ProximityPrompt") then
			if not originalDurations[v] then
				originalDurations[v] = v.HoldDuration
			end
			v.HoldDuration = 0
		end
	end)
end

createButton(tab17, "ON", UDim2.new(0.05, 0, 0.38, 0), UDim2.new(0.42, 0, 0.24, 0), Color3.fromRGB(50, 200, 50), enableProxPrompt)
createButton(tab17, "OFF", UDim2.new(0.53, 0, 0.38, 0), UDim2.new(0.42, 0, 0.24, 0), Color3.fromRGB(200, 50, 50), disableProxPrompt)

-- ==========================================
-- СИСТЕМА ПОВНОГО І БЕЗПЕЧНОГО ОЧИЩЕННЯ
-- ==========================================
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	stopFlying()
	stopGlobalNoclip()
	stopForwardNoclip()
	stopFlingLoop()
	spinFixation = false
	isLoopTeleporting = false
	pcall(stopSpinning)
	pcall(disableProxPrompt)
	task.wait(1)
	saveOriginals()
end)

closeBtn.Activated:Connect(function()
	pcall(stopTeleporting)
	pcall(stopSpectating)
	pcall(stopFocusingHead)
	pcall(stopFlingLoop)
	pcall(disableProxPrompt)
	spinFixation = false
	isLoopTeleporting = false
	pcall(stopSpinning)
	pcall(function() toggleLight(false) end)
	
	if infJumpConnection then pcall(function() infJumpConnection:Disconnect() end) end
	if whJumpConnection then pcall(function() whJumpConnection:Disconnect() end) end
	if whAutoJumpConnection then pcall(function() whAutoJumpConnection:Disconnect() end) end
	if whMouseClickConnection then pcall(function() whMouseClickConnection:Disconnect() end) end
	
	Config.ForceSpeed = false
	Config.ForceJump = false
	pcall(stopFlying)
	pcall(stopGlobalNoclip)
	pcall(stopForwardNoclip)
	
	local c = player.Character
	if c and c:FindFirstChildOfClass("Humanoid") then
		c:FindFirstChildOfClass("Humanoid").WalkSpeed = originalSpeed
		c:FindFirstChildOfClass("Humanoid").JumpPower = originalJumpPower
		c:FindFirstChildOfClass("Humanoid").UseJumpPower = originalUseJumpPower
		c:FindFirstChildOfClass("Humanoid").PlatformStand = false
	end
	if c and c:FindFirstChild("HumanoidRootPart") then
		c.HumanoidRootPart.Anchored = false 
	end
	
	workspace.FallenPartsDestroyHeight = getgenv().FPDH or workspace.FallenPartsDestroyHeight
	if screenGui then screenGui:Destroy() end
end)
