-- // CONFIG
local PASS_COMMAND = "/passto"
local defaultPassKey = Enum.KeyCode.T
local defaultToggleGUIKey = Enum.KeyCode.P

-- // SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- // VARS
local selectedPlayer = nil
local passKey = defaultPassKey
local toggleGUIKey = defaultToggleGUIKey
local guiOpen = true

-- // TOOL CREATION
local function createClickTool()
	if LocalPlayer.Backpack:FindFirstChild("Click Tool") then
		return
	end
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Click Tool") then
		return
	end

	local tool = Instance.new("Tool")
	tool.Name = "Click Tool"
	tool.RequiresHandle = false
	tool.CanBeDropped = false

	local mouse
	tool.Equipped:Connect(function(m)
		mouse = m
	end)

	tool.Activated:Connect(function()
		if mouse and mouse.Target then
			local char = mouse.Target:FindFirstAncestorOfClass("Model")
			local player = char and Players:GetPlayerFromCharacter(char)
			if player then
				selectedPlayer = player
				selectedPlayerBox.Text = selectedPlayer.Name
				manualInputBox.Text = ""
				manualInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end
	end)

	tool.Parent = LocalPlayer.Backpack
end

-- Give tool initially and on respawn
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	createClickTool()
end)
task.wait(0.5)
createClickTool()

-- // GUI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 250)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICornerMain = Instance.new("UICorner")
UICornerMain.CornerRadius = UDim.new(0, 15)
UICornerMain.Parent = MainFrame

-- Header
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "PASSER SCRIPT BY SIAH"
Title.TextSize = 18
Title.Font = Enum.Font.ArialBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Minimize button
local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.new(0, 30, 0, 30)
MinButton.Position = UDim2.new(1, -70, 0, 0)
MinButton.Text = "-"
MinButton.TextSize = 18
MinButton.BackgroundColor3 = MainFrame.BackgroundColor3
MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinButton.Parent = MainFrame
local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 15)
MinCorner.Parent = MinButton
MinButton.MouseEnter:Connect(function()
	MinButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
end)
MinButton.MouseLeave:Connect(function()
	MinButton.BackgroundColor3 = MainFrame.BackgroundColor3
end)
MinButton.MouseButton1Click:Connect(function()
	guiOpen = not guiOpen
	MainFrame.Size = guiOpen and UDim2.new(0, 340, 0, 250) or UDim2.new(0, 340, 0, 40)
end)

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.Text = "X"
CloseButton.TextSize = 18
CloseButton.BackgroundColor3 = MainFrame.BackgroundColor3
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Parent = MainFrame
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 15)
CloseCorner.Parent = CloseButton
CloseButton.MouseEnter:Connect(function()
	CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
end)
CloseButton.MouseLeave:Connect(function()
	CloseButton.BackgroundColor3 = MainFrame.BackgroundColor3
end)
CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

-- Selected Player display box
selectedPlayerBox = Instance.new("TextBox")
selectedPlayerBox.Size = UDim2.new(1, -20, 0, 25)
selectedPlayerBox.Position = UDim2.new(0, 10, 0, 40)
selectedPlayerBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
selectedPlayerBox.Text = "Selected Player"
selectedPlayerBox.TextEditable = false
selectedPlayerBox.TextSize = 14
selectedPlayerBox.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedPlayerBox.Font = Enum.Font.Arial
selectedPlayerBox.TextXAlignment = Enum.TextXAlignment.Left
selectedPlayerBox.BorderSizePixel = 0
selectedPlayerBox.Parent = MainFrame
local CornerSel = Instance.new("UICorner")
CornerSel.CornerRadius = UDim.new(0, 8)
CornerSel.Parent = selectedPlayerBox

-- Manual input box
manualInputBox = Instance.new("TextBox")
manualInputBox.Size = UDim2.new(1, -20, 0, 25)
manualInputBox.Position = UDim2.new(0, 10, 0, 75)
manualInputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
manualInputBox.BorderSizePixel = 0
manualInputBox.Text = "Type username or display name"
manualInputBox.TextSize = 14
manualInputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
manualInputBox.Font = Enum.Font.Arial
manualInputBox.TextXAlignment = Enum.TextXAlignment.Left
manualInputBox.ClearTextOnFocus = false
manualInputBox.Parent = MainFrame
local CornerManual = Instance.new("UICorner")
CornerManual.CornerRadius = UDim.new(0, 8)
CornerManual.Parent = manualInputBox

manualInputBox.Focused:Connect(function()
	if manualInputBox.Text == "Type username or display name" then
		manualInputBox.Text = ""
		manualInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

manualInputBox.FocusLost:Connect(function()
	local typedName = manualInputBox.Text:lower()
	if typedName == "" then
		manualInputBox.Text = "Type username or display name"
		manualInputBox.TextColor3 = Color3.fromRGB(200, 200, 200)
		return
	end
	local foundPlayer = nil
	for _, p in pairs(Players:GetPlayers()) do
		if p.Name:lower():find(typedName) or p.DisplayName:lower():find(typedName) then
			foundPlayer = p
			break
		end
	end
	if foundPlayer then
		selectedPlayer = foundPlayer
		selectedPlayerBox.Text = selectedPlayer.Name
	else
		selectedPlayer = nil
		selectedPlayerBox.Text = "Selected Player"
	end
end)

-- Keybind boxes
local function createKeybindBox(labelText, defaultKey, yPos)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, -15, 0, 25)
	lbl.Position = UDim2.new(0, 10, 0, yPos)
	lbl.BackgroundColor3 = MainFrame.BackgroundColor3
	lbl.BorderSizePixel = 0
	lbl.Text = labelText
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Font = Enum.Font.Arial
	lbl.TextSize = 14
	lbl.Parent = MainFrame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.5, -15, 0, 25)
	box.Position = UDim2.new(0.5, 0, 0, yPos)
	box.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
	box.BorderSizePixel = 0
	box.Text = defaultKey.Name:sub(1, 1)
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.TextSize = 14
	box.Font = Enum.Font.Arial
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.ClearTextOnFocus = false
	box.Parent = MainFrame
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = box

	box.Focused:Connect(function()
		box.Text = ""
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				box.Text = input.KeyCode.Name:sub(1, 1)
				if labelText == "Pass Key" then
					passKey = input.KeyCode
				else
					toggleGUIKey = input.KeyCode
				end
				conn:Disconnect()
			end
		end)
	end)
end

createKeybindBox("Pass Key", passKey, 120)
createKeybindBox("Toggle GUI Key", toggleGUIKey, 155)

-- Key press detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	if input.KeyCode == passKey and selectedPlayer then
		local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
		if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
			chatEvent.SayMessageRequest:FireServer(PASS_COMMAND .. " " .. selectedPlayer.Name, "All")
		else
			Players:Chat(PASS_COMMAND .. " " .. selectedPlayer.Name)
		end
	end

	if input.KeyCode == toggleGUIKey then
		guiOpen = not guiOpen
		MainFrame.Visible = guiOpen
	end
end)
