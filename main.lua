-- nucaxem



-- how to use:
-- 1. get killed by a zombie or join mid round
-- 2. activate the teleport and spam the red button
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "TeleportGUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 390) -- extra height for new button + GitHub label
frame.Position = UDim2.new(0, 20, 0.5, -195)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -30, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "Zombie Attack Troll"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.Parent = frame

-- Scroll for player list
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0, 0, 0, 30)
scroll.Size = UDim2.new(1, -100, 1, -150) -- leave space for side buttons + GitHub label
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 6
scroll.Parent = frame

-- Side button container
local sideFrame = Instance.new("Frame")
sideFrame.Size = UDim2.new(0, 90, 1, -150)
sideFrame.Position = UDim2.new(1, -95, 0, 30)
sideFrame.BackgroundTransparency = 1
sideFrame.Parent = frame

-- Loop Teleport button
local loopButton = Instance.new("TextButton")
loopButton.Size = UDim2.new(1, 0, 0, 40)
loopButton.Position = UDim2.new(0, 0, 0, 0)
loopButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
loopButton.Text = "Loop TP: OFF"
loopButton.TextColor3 = Color3.new(1, 1, 1)
loopButton.Font = Enum.Font.SourceSansBold
loopButton.TextSize = 14
loopButton.Parent = sideFrame

-- Teleport to Spawn button
local mapButton = Instance.new("TextButton")
mapButton.Size = UDim2.new(1, 0, 0, 40)
mapButton.Position = UDim2.new(0, 0, 0, 45)
mapButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
mapButton.Text = "TP to Spawn"
mapButton.TextColor3 = Color3.new(1, 1, 1)
mapButton.Font = Enum.Font.SourceSansBold
mapButton.TextSize = 14
mapButton.Parent = sideFrame

-- Teleport to Map button
local spawnButton = Instance.new("TextButton")
spawnButton.Size = UDim2.new(1, 0, 0, 40)
spawnButton.Position = UDim2.new(0, 0, 0, 90)
spawnButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
spawnButton.Text = "TP to Map"
spawnButton.TextColor3 = Color3.new(1, 1, 1)
spawnButton.Font = Enum.Font.SourceSansBold
spawnButton.TextSize = 14
spawnButton.Parent = sideFrame

-- Autofarm toggle button (NEW)
local farmButton = Instance.new("TextButton")
farmButton.Size = UDim2.new(1, 0, 0, 40)
farmButton.Position = UDim2.new(0, 0, 0, 135) -- below the other side buttons
farmButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
farmButton.Text = "Autofarm: OFF"
farmButton.TextColor3 = Color3.new(1, 1, 1)
farmButton.Font = Enum.Font.SourceSansBold
farmButton.TextSize = 14
farmButton.Parent = sideFrame

-- GitHub rainbow label
local githubLabel = Instance.new("TextLabel")
githubLabel.Size = UDim2.new(1, 0, 0, 20)
githubLabel.Position = UDim2.new(0, 0, 1, -25)
githubLabel.BackgroundTransparency = 1
githubLabel.Text = "github.com/nucax"
githubLabel.TextColor3 = Color3.new(1,1,1)
githubLabel.Font = Enum.Font.SourceSansBold
githubLabel.TextSize = 16
githubLabel.Parent = frame

-- State
local selectedPlayer = nil
local looping = false
local loopTask = nil
local rainbowSpeed = 2.5
local playerButtons = {}
local currentHighlight = nil
local highlightTick = 0
local closed = false

-- Teleport function
local function teleportTo(target)
	if not target then return end
	if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and player.Character then
		player.Character:MoveTo(target.Character.HumanoidRootPart.Position)
	end
end

-- Teleport to coordinates
local function teleportToCoords(x, y, z)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
	end
end

-- Clear highlight
local function clearHighlight()
	if currentHighlight then
		pcall(function() currentHighlight:Destroy() end)
		currentHighlight = nil
	end
end

-- Create highlight for selected character
local function createHighlightForCharacter(char)
	if not char then return end
	local success, _ = pcall(function() return Instance.new("Highlight") end)
	if success then
		local h = Instance.new("Highlight")
		h.Adornee = char
		h.FillTransparency = 0.85
		h.OutlineTransparency = 0
		h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		h.Parent = workspace
		return h
	end
end

-- Select player
local function selectPlayer(plr)
	if selectedPlayer == plr then return end
	selectedPlayer = plr

	for name, btn in pairs(playerButtons) do
		if name == plr.Name then
			btn.Selected = true
		else
			btn.Selected = false
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			btn.TextColor3 = Color3.new(1, 1, 1)
		end
	end

	clearHighlight()
	if plr and plr.Character then
		currentHighlight = createHighlightForCharacter(plr.Character)
	end
end

-- Populate player list
local function refreshPlayers()
	for _, c in ipairs(scroll:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	playerButtons = {}
	local y = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 30)
			btn.Position = UDim2.new(0, 5, 0, y)
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			btn.Text = plr.Name
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.Font = Enum.Font.SourceSansBold
			btn.TextSize = 14
			btn.Parent = scroll
			btn.AutoButtonColor = true
			btn.Selected = false
			btn.MouseButton1Click:Connect(function()
				selectPlayer(plr)
				teleportTo(plr)
			end)
			playerButtons[plr.Name] = btn
			y += 35
		end
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Loop teleport
local function startLoop()
	if loopTask then task.cancel(loopTask) end
	loopTask = task.spawn(function()
		while looping do
			if selectedPlayer and Players:FindFirstChild(selectedPlayer.Name) then
				teleportTo(selectedPlayer)
			else
				looping = false
				loopButton.Text = "Loop TP: OFF"
			end
			task.wait(0.1) -- teleport every 0.1s
		end
	end)
end

loopButton.MouseButton1Click:Connect(function()
	looping = not looping
	loopButton.Text = looping and "Loop TP: ON" or "Loop TP: OFF"
	if looping then startLoop() end
end)

-- Map / Spawn buttons
mapButton.MouseButton1Click:Connect(function() teleportToCoords(106, -39.79, 2491) end)
spawnButton.MouseButton1Click:Connect(function() teleportToCoords(-57.92, 75.45, 70.51) end)

-- Autofarm toggle
farmButton.MouseButton1Click:Connect(function()
	_G.farm2 = not _G.farm2
	farmButton.Text = "Autofarm: " .. (_G.farm2 and "ON" or "OFF")
end)

-- Close GUI
closeButton.MouseButton1Click:Connect(function()
	if closed then return end
	closed = true
	looping = false
	clearHighlight()
	if loopTask then task.cancel(loopTask) loopTask=nil end
	gui:Destroy()
end)

-- Player events
Players.PlayerRemoving:Connect(function(plr)
	if selectedPlayer == plr then clearHighlight() selectedPlayer=nil end
	refreshPlayers()
end)
Players.PlayerAdded:Connect(refreshPlayers)

-- Rainbow effects
task.spawn(function()
	while RunService.Heartbeat:Wait() and not closed do
		highlightTick = (tick()*rainbowSpeed)%1
		local color = Color3.fromHSV(highlightTick,1,1)
		title.TextColor3 = Color3.fromHSV((highlightTick+0.3)%1,0.9,1)
		githubLabel.TextColor3 = Color3.fromHSV((highlightTick+0.5)%1,1,1)
		for _, btn in pairs(playerButtons) do
			if btn.Selected then
				local bg = Color3.fromHSV((highlightTick)%1,0.9,0.35)
				btn.BackgroundColor3 = bg
				btn.TextColor3 = color
			else
				btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
				btn.TextColor3 = Color3.new(1,1,1)
			end
		end
		if currentHighlight then
			if currentHighlight:IsA("Highlight") then
				currentHighlight.OutlineColor=color
				currentHighlight.FillColor=Color3.fromHSV((highlightTick+0.5)%1,0.9,1)
			elseif currentHighlight:IsA("SelectionBox") then
				currentHighlight.Color3=color
			end
		end
	end
end)

-- Initial load
refreshPlayers()

-- AUTOFARM LOGIC
local groundDistance = 8
spawn(function()
	while wait() do
		if player.Character then
			local hrp = player.Character:FindFirstChild("HumanoidRootPart")
			local torso = player.Character:FindFirstChild("Torso")
			if hrp then hrp.Velocity = Vector3.new(0,0,0) end
			if torso then torso.Velocity = Vector3.new(0,0,0) end
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if _G.farm2 then
		local target = nil
		local nearestDist = 99999
		for _,v in pairs(game.Workspace:WaitForChild("BossFolder"):GetChildren()) do
			if v:FindFirstChild("Head") then
				local dist = (player.Character.Head.Position - v.Head.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					target = v
				end
			end
		end
		for _,v in pairs(game.Workspace:WaitForChild("enemies"):GetChildren()) do
			if v:FindFirstChild("Head") then
				local dist = (player.Character.Head.Position - v.Head.Position).Magnitude
				if dist < nearestDist then
					nearestDist = dist
					target = v
				end
			end
		end
		if target then
			workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Head.Position)
			player.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, groundDistance, 9)
			_G.globalTarget = target
		end
	end
end)

spawn(function()
	while wait() do
		if _G.farm2 and _G.globalTarget and _G.globalTarget:FindFirstChild("Head") and player.Character:FindFirstChildOfClass("Tool") then
			local target = _G.globalTarget
			game.ReplicatedStorage.Gun:FireServer({
				["Normal"] = Vector3.new(0,0,0),
				["Direction"] = target.Head.Position,
				["Name"] = player.Character:FindFirstChildOfClass("Tool").Name,
				["Hit"] = target.Head,
				["Origin"] = target.Head.Position,
				["Pos"] = target.Head.Position
			})
			wait()
		end
	end
end)
