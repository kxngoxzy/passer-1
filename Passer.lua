--// PASSER SCRIPT BY SIAH (RAYFIELD UI)
--// Select a player → press Pass key → tries ALL methods ONE BY ONE (sequential fallback)
--// Debug Mode toggle shows which method worked / failed (prints to console)
--// NOTE: all methods are ON by default and you CANNOT toggle individual ones off

--====================================================
-- Services
--====================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

--====================================================
-- Settings
--====================================================
local PASS_COMMAND = "/passto"
local selectedPlayer = nil

local passKey = Enum.KeyCode.T
local bindingMode = nil -- "pass" | nil

-- Debug mode
local DEBUG_MODE = false

-- Sequential fallback timing
local ECHO_TIMEOUT = 0.4
local BETWEEN_METHOD_DELAY = 0.05

--====================================================
-- Rayfield
--====================================================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Passer Script (Siah)",
	LoadingTitle = "Passer Script",
	LoadingSubtitle = "Sequential Sender + Debug Mode",
	ConfigurationSaving = { Enabled = false },
})

local MainTab = Window:CreateTab("Main", 4483362458)
local KeybindsTab = Window:CreateTab("Keybinds", 4483362458)
local DebugTab = Window:CreateTab("Debug", 4483362458)

--====================================================
-- Helpers
--====================================================
local function dprint(...)
	if DEBUG_MODE then
		print("[PASSER DEBUG]", ...)
	end
end

local function notify(t, c, d)
	pcall(function()
		Rayfield:Notify({ Title = t, Content = c, Duration = d or 2 })
	end)
end

local function setSelected(p)
	selectedPlayer = p
end

local function getSelectedName()
	return selectedPlayer and selectedPlayer.Name or "None"
end

local function findPlayerByText(txt)
	txt = (txt or ""):lower()
	if txt == "" then
		return nil
	end
	for _, p in ipairs(Players:GetPlayers()) do
		local n = (p.Name or ""):lower()
		local d = (p.DisplayName or ""):lower()
		if n:find(txt, 1, true) or d:find(txt, 1, true) then
			return p
		end
	end
	return nil
end

--====================================================
-- Echo detection (used to decide whether a method "took")
--====================================================
local function waitForOwnEcho(targetText, timeoutSec)
	local gotEcho = false
	local conns = {}

	local function cleanup()
		for _, c in ipairs(conns) do
			pcall(function()
				c:Disconnect()
			end)
		end
	end

	-- New chat (if available)
	if TextChatService and TextChatService.MessageReceived then
		table.insert(
			conns,
			TextChatService.MessageReceived:Connect(function(msg)
				pcall(function()
					if typeof(msg.Text) == "string" and msg.Text == targetText then
						gotEcho = true
					end
				end)
			end)
		)
	end

	-- Legacy echo
	if LocalPlayer and LocalPlayer.Chatted then
		table.insert(
			conns,
			LocalPlayer.Chatted:Connect(function(msg)
				if msg == targetText then
					gotEcho = true
				end
			end)
		)
	end

	local t0 = os.clock()
	while os.clock() - t0 < (timeoutSec or 0.4) do
		if gotEcho then
			cleanup()
			return true
		end
		task.wait(0.02)
	end

	cleanup()
	return false
end

--====================================================
-- Sender methods (each tries ONCE)
--====================================================
local function Try_TextChatService_TargetChannel(msg)
	dprint("Trying: TextChatService.TargetTextChannel")
	local cfg = TextChatService:FindFirstChild("ChatInputBarConfiguration")
	local chan = cfg and cfg.TargetTextChannel
	if not (chan and chan.SendAsync) then
		error("No TargetTextChannel/SendAsync")
	end
	chan:SendAsync(msg)
end

local function Try_TextChatService_RBXGeneral(msg)
	dprint("Trying: TextChatService.RBXGeneral")
	local chans = TextChatService:FindFirstChild("TextChannels")
	local chan = chans and chans:FindFirstChild("RBXGeneral")
	if not (chan and chan.SendAsync) then
		error("No RBXGeneral/SendAsync")
	end
	chan:SendAsync(msg)
end

local function Try_TextChatService_AnyChannel(msg)
	dprint("Trying: TextChatService.AnyChannel")
	local chans = TextChatService:FindFirstChild("TextChannels")
	if not chans then
		error("No TextChannels")
	end
	for _, ch in ipairs(chans:GetChildren()) do
		if ch.ClassName == "TextChannel" and ch.SendAsync then
			ch:SendAsync(msg)
			return
		end
	end
	error("No usable TextChannel")
end

local function Try_Legacy_DefaultChatSystem(msg)
	dprint("Trying: Legacy.DefaultChatSystem")
	local ev = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
	local say = ev and ev:FindFirstChild("SayMessageRequest")
	if not say then
		error("No SayMessageRequest")
	end
	say:FireServer(msg, "All")
end

local function Try_Legacy_Replicated_SayMessageRequest(msg)
	dprint("Trying: Legacy.Replicated.SayMessageRequest")
	local say = ReplicatedStorage:FindFirstChild("SayMessageRequest", true)
	if not (say and say:IsA("RemoteEvent")) then
		error("No RemoteEvent SayMessageRequest found")
	end
	say:FireServer(msg, "All")
end

local function Try_PlayersChat(msg)
	dprint("Trying: Players:Chat")
	Players:Chat(msg)
end

local function Try_ChatBar_TextBox_FocusLost(msg)
	dprint("Trying: ChatBar.TextBox.FocusLost")
	local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
	if not pg then
		error("No PlayerGui")
	end

	local candidate
	for _, d in ipairs(pg:GetDescendants()) do
		if d:IsA("TextBox") then
			local n = d.Name:lower()
			if (n:find("chat") or n:find("input") or n:find("bar")) and d.Visible and d.TextEditable then
				candidate = d
				break
			end
		end
	end
	if not candidate then
		error("No chat TextBox candidate")
	end

	candidate:CaptureFocus()
	task.wait(0.02)
	candidate.Text = msg
	task.wait(0.02)
	candidate:ReleaseFocus(true)
end

local function Try_VIM_Typed(msg)
	dprint("Trying: VirtualInputManager.Typed")
	pcall(function()
		StarterGui:SetCore("ChatActive", true)
	end)
	task.wait(0.05)

	-- Focus chat bar
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Slash, false, game)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Slash, false, game)
	task.wait(0.05)

	local toType = msg
	if toType:sub(1, 1) == "/" then
		toType = toType:sub(2)
	end

	VirtualInputManager:SendText(toType)
	task.wait(0.05)

	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
end

--====================================================
-- Sequential sender (ALL methods always enabled)
--====================================================
local function SendCommandSequential(msg)
	local methods = {
		{ name = "TextChat.TargetTextChannel", fn = Try_TextChatService_TargetChannel },
		{ name = "TextChat.RBXGeneral", fn = Try_TextChatService_RBXGeneral },
		{ name = "TextChat.AnyChannel", fn = Try_TextChatService_AnyChannel },
		{ name = "Legacy.DefaultChatSystem", fn = Try_Legacy_DefaultChatSystem },
		{ name = "Legacy.Replicated.SayMessageRequest", fn = Try_Legacy_Replicated_SayMessageRequest },
		{ name = "Players:Chat", fn = Try_PlayersChat },
		{ name = "ChatBar.TextBox.FocusLost", fn = Try_ChatBar_TextBox_FocusLost },
		{ name = "VIM.Typed", fn = Try_VIM_Typed },
	}

	local errors = {}

	for _, m in ipairs(methods) do
		dprint("Attempting:", m.name)

		local ok, err = pcall(function()
			m.fn(msg)
		end)

		if not ok then
			dprint("FAILED:", m.name, "|", err)
			table.insert(errors, m.name .. " | " .. tostring(err))
			task.wait(BETWEEN_METHOD_DELAY)
		else
			dprint("Sent, waiting for echo...")
			local echoed = waitForOwnEcho(msg, ECHO_TIMEOUT)
			if echoed then
				dprint("SUCCESS with:", m.name)
				return true, m.name
			else
				dprint("NO ECHO from:", m.name)
				table.insert(errors, m.name .. " | no echo (fallback)")
				task.wait(BETWEEN_METHOD_DELAY)
			end
		end
	end

	return false, table.concat(errors, "\n")
end

--====================================================
-- PASS ACTION
--====================================================
local function doPass()
	if not selectedPlayer then
		notify("No player selected", "Use Click Tool / dropdown / type a name first.", 3)
		return
	end

	local cmd = PASS_COMMAND .. " " .. selectedPlayer.Name
	local ok, methodOrErr = SendCommandSequential(cmd)

	if ok then
		notify("Pass attempted", ("Method: %s\n%s"):format(methodOrErr, cmd), 3)
	else
		notify("Pass failed", methodOrErr, 7)
	end
end

--====================================================
-- Click Tool
--====================================================
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
		if not mouse or not mouse.Target then
			return
		end
		local char = mouse.Target:FindFirstAncestorOfClass("Model")
		local p = char and Players:GetPlayerFromCharacter(char)
		if p then
			setSelected(p)
			notify("Selected", ("Selected: %s"):format(p.Name), 2)
		end
	end)

	tool.Parent = LocalPlayer.Backpack
end

LocalPlayer.CharacterAdded:Connect(function()
	task.wait(0.75)
	createClickTool()
end)
task.spawn(function()
	task.wait(0.2)
	createClickTool()
end)

--====================================================
-- UI: Main
--====================================================
local SelectedLabel = MainTab:CreateLabel("Selected Player: " .. getSelectedName())
local function refreshSelectedLabel()
	pcall(function()
		SelectedLabel:Set("Selected Player: " .. getSelectedName())
	end)
end

MainTab:CreateButton({
	Name = "Give Click Tool",
	Callback = function()
		createClickTool()
		notify("Done", "Click Tool added.", 2)
	end,
})

local function buildPlayerList()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(list, p.Name)
		end
	end
	table.sort(list)
	return list
end

MainTab:CreateDropdown({
	Name = "Select Player (Dropdown)",
	Options = buildPlayerList(),
	CurrentOption = {},
	MultipleOptions = false,
	Callback = function(option)
		local chosen = typeof(option) == "table" and option[1] or option
		if typeof(chosen) ~= "string" then
			return
		end
		local p = Players:FindFirstChild(chosen)
		if p then
			setSelected(p)
			refreshSelectedLabel()
		end
	end,
})

MainTab:CreateInput({
	Name = "Type username or display name",
	PlaceholderText = "e.g. coolkid123",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local p = findPlayerByText(text)
		if p then
			setSelected(p)
			refreshSelectedLabel()
			notify("Selected", p.Name, 2)
		else
			setSelected(nil)
			refreshSelectedLabel()
			notify("Not found", "No matching player.", 2)
		end
	end,
})

MainTab:CreateButton({ Name = "Pass Now", Callback = doPass })

MainTab:CreateButton({
	Name = "Clear Selection",
	Callback = function()
		setSelected(nil)
		refreshSelectedLabel()
	end,
})

--====================================================
-- UI: Keybinds (ONLY PASS KEY)
--====================================================
KeybindsTab:CreateParagraph({
	Title = "Pass Keybind",
	Content = "Click Set, then press the key you want.",
})

local PassKeyLabel = KeybindsTab:CreateLabel("Pass Key: " .. passKey.Name)

KeybindsTab:CreateButton({
	Name = "Set Pass Key",
	Callback = function()
		bindingMode = "pass"
		notify("Bind Pass Key", "Press any key now...", 3)
	end,
})

KeybindsTab:CreateButton({
	Name = "Reset Pass Key to T",
	Callback = function()
		passKey = Enum.KeyCode.T
		bindingMode = nil
		pcall(function()
			PassKeyLabel:Set("Pass Key: " .. passKey.Name)
		end)
		notify("Reset", "Pass key set to T", 2)
	end,
})

--====================================================
-- UI: Debug
--====================================================
DebugTab:CreateToggle({
	Name = "Debug Mode (prints to console)",
	CurrentValue = DEBUG_MODE,
	Callback = function(v)
		DEBUG_MODE = v
		notify("Debug", v and "ON" or "OFF", 2)
	end,
})

DebugTab:CreateParagraph({
	Title = "How it works",
	Content = "All methods are always enabled.\nWhen you pass, it tries them ONE BY ONE until one shows an echo.\nTurn Debug Mode ON to see which methods failed or succeeded in the console.",
})

--====================================================
-- Key handling (bind capture + pass hotkey)
--====================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then
		return
	end

	-- Binding mode
	if bindingMode == "pass" then
		if input.KeyCode == Enum.KeyCode.Unknown then
			return
		end
		passKey = input.KeyCode
		pcall(function()
			PassKeyLabel:Set("Pass Key: " .. passKey.Name)
		end)
		notify("Pass key set", passKey.Name, 2)
		bindingMode = nil
		return
	end

	-- Normal pass hotkey
	if input.KeyCode == passKey then
		doPass()
	end
end)

-- Initial UI sync
refreshSelectedLabel()
