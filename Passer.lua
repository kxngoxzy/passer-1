-- // CONFIG
local PASS_COMMAND = "/passto"
local defaultPassKey = Enum.KeyCode.Q
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

	local tool = Instance.new("Tool")
	tool.Name = "Click Tool"
	tool.RequiresHandle = false
	tool.CanBeDropped = false

	local mouse
	tool.Equipped:Connect(function()
		mouse = LocalPlayer:GetMouse()
		mouse.Button1Down:Connect(function()
			if mouse.Target then
				local char = mouse.Target:FindFirstAncestorOfClass("Model")
				if char and Players:GetPlayerFromCharacter(char) then
					selectedPlayer = Players:GetPlayerFromCharacter(char)
					usernameLabel.Text = "Selected: " .. selectedPlayer.Name
				end
			end
		end)
	end)

	tool.Parent = LocalPlayer.Backpack
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	createClickTool()
end)

if LocalPlayer.Character then
	createClickTool()
end

-- // GUI CREATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 180)
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
Title.Size = UDim2.new(1, -20, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "PASSER SCRIPT BY SIAH"
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Username label
usernameLabel = Instance.new("TextLabel")
usernameLabel.Size = UDim2.new(1, -20, 0, 25)
usernameLabel.Position = UDim2.new(0, 10, 0, 30)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Text = "Selected: None"
usernameLabel.TextSize = 14
usernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
usernameLabel.Font = Enum.Font.Arial
usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
usernameLabel.Parent = MainFrame

-- Function to create keybind labels
local function createKeybindLabel(parent, name, currentKey)
	local label = Instance.new("TextButton")
	label.Size = UDim2.new(1, -20, 0, 25)
	label.Position = UDim2.new(0, 10, 0, (#parent:GetChildren() - 1) * 30)
	label.BackgroundColor3 = MainFrame.BackgroundColor3
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextSize = 14
	label.Font = Enum.Font.Arial
	label.Text = name .. ": " .. currentKey.Name
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent

	label.MouseButton1Click:Connect(function()
		label.Text = name .. ": Press a key..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				if name == "Pass Key" then
					passKey = input.KeyCode
				elseif name == "Toggle GUI Key" then
					toggleGUIKey = input.KeyCode
				end
				label.Text = name .. ": " .. input.KeyCode.Name
				conn:Disconnect()
			end
		end)
	end)

	return label
end

-- Keybind dropdown frame
local KeybindFrame = Instance.new("Frame")
KeybindFrame.Size = UDim2.new(1, -20, 0, 60)
KeybindFrame.Position = UDim2.new(0, 10, 0, 60)
KeybindFrame.BackgroundColor3 = MainFrame.BackgroundColor3
KeybindFrame.Parent = MainFrame

local KeybindCorner = Instance.new("UICorner")
KeybindCorner.CornerRadius = UDim.new(0, 10)
KeybindCorner.Parent = KeybindFrame

-- Create keybind labels
local passKeyLabel = createKeybindLabel(KeybindFrame, "Pass Key", passKey)
local toggleKeyLabel = createKeybindLabel(KeybindFrame, "Toggle GUI Key", toggleGUIKey)

-- Close button circular
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 0)
CloseButton.Text = "X"
CloseButton.TextSize = 16
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

-- Collapse/Hide button circular
local CollapseButton = Instance.new("TextButton")
CollapseButton.Size = UDim2.new(0, 30, 0, 30)
CollapseButton.Position = UDim2.new(1, -70, 0, 0)
CollapseButton.Text = "-"
CollapseButton.TextSize = 16
CollapseButton.BackgroundColor3 = MainFrame.BackgroundColor3
CollapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CollapseButton.Parent = MainFrame

local CollapseCorner = Instance.new("UICorner")
CollapseCorner.CornerRadius = UDim.new(0, 15)
CollapseCorner.Parent = CollapseButton

CollapseButton.MouseEnter:Connect(function()
	CollapseButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
end)
CollapseButton.MouseLeave:Connect(function()
	CollapseButton.BackgroundColor3 = MainFrame.BackgroundColor3
end)

CollapseButton.MouseButton1Click:Connect(function()
	guiOpen = not guiOpen
	MainFrame.Size = guiOpen and UDim2.new(0, 300, 0, 180) or UDim2.new(0, 300, 0, 40)
	usernameLabel.Visible = guiOpen
	KeybindFrame.Visible = guiOpen
end)

-- Detect key presses (fixed: only assigned keys trigger actions)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	-- Pass key
	if input.KeyCode == passKey and selectedPlayer then
		local chatEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
		if chatEvent and chatEvent:FindFirstChild("SayMessageRequest") then
			chatEvent.SayMessageRequest:FireServer(PASS_COMMAND .. " " .. selectedPlayer.Name, "All")
		else
			Players:Chat(PASS_COMMAND .. " " .. selectedPlayer.Name)
		end
	end

	-- Toggle GUI key
	if input.KeyCode == toggleGUIKey then
		guiOpen = not guiOpen
		MainFrame.Visible = guiOpen
	end
end)
