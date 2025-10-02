-- Plugins/Scriptview/Main.lua
-- Scriptview: a Studio-only plugin for inspecting Scripts/LocalScripts/ModuleScripts and logs
-- Minimal comments; documentation-first. Uses Plugin API: CreateDockWidgetPluginGui, OpenScript, LogService:GetLogHistory.

local Plugin = plugin
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")

-- CONFIG
local WIDGET_ID = "ScriptviewDock_v1"
local WINDOW_TITLE = "Scriptview"
local ICON = "rbxassetid://135866511037510" -- provided decal

-- Helpers
local function isScriptLike(inst)
	return inst:IsA("Script") or inst:IsA("LocalScript") or inst:IsA("ModuleScript")
end

local function make(class, props)
	local obj = Instance.new(class)
	for k,v in pairs(props or {}) do obj[k] = v end
	return obj
end

-- Create toolbar/button
local toolbar = Plugin:CreateToolbar("Scriptview")
local button = toolbar:CreateButton("ToggleScriptview", "Open Scriptview", ICON)
button.ClickableWhenViewportHidden = true

-- Dock widget
local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right, -- initial dock state
	false, -- initially enabled
	false, -- override enabled
	300, -- default width
	420, -- default height
	200, -- min width
	200  -- min height
)
local dock = Plugin:CreateDockWidgetPluginGui(WIDGET_ID, widgetInfo)
dock.Title = WINDOW_TITLE

-- Root UI
local root = make("Frame", {Name="Root", Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Parent=dock})
local ui = Instance.new("ScreenGui") -- container frame (widgets are 2D)
ui.ResetOnSpawn = false
ui.Parent = dock

-- Layout: left tree, middle inspector, right tabs
local main = make("Frame", {Name="Main", Parent=ui, Size=UDim2.fromScale(1,1), BackgroundColor3 = Color3.fromRGB(250,250,250)})
local layout = make("UIListLayout", {Parent=main, FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder})

-- LEFT: Tree
local left = make("Frame", {Parent=main, Size=UDim2.new(0.33,0,1,0), BackgroundColor3=Color3.fromRGB(245,245,245)})
local leftHeader = make("TextBox", {Parent=left, Size=UDim2.new(1,0,0,28), Text="Search...", TextColor3=Color3.fromRGB(100,100,100), TextXAlignment=Enum.TextXAlignment.Left, BackgroundColor3=Color3.fromRGB(230,230,230)})
local leftScroll = make("ScrollingFrame", {Parent=left, Size=UDim2.new(1,0,1,-28), CanvasSize=UDim2.new(0,0,0,0), ScrollBarImageColor3=Color3.fromRGB(170,170,170)})
leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local leftListLayout = make("UIListLayout", {Parent=leftScroll, SortOrder=Enum.SortOrder.Name, Padding=UDim.new(0,2)})

-- MIDDLE: Inspector / Actions
local mid = make("Frame", {Parent=main, Size=UDim2.new(0.34,0,1,0), BackgroundColor3=Color3.fromRGB(255,255,255)})
local midHeader = make("TextLabel", {Parent=mid, Size=UDim2.new(1,0,0,28), Text="Inspector", TextXAlignment=Enum.TextXAlignment.Left, BackgroundColor3=Color3.fromRGB(240,240,240)})
local propArea = make("ScrollingFrame", {Parent=mid, Size=UDim2.new(1,0,1,-100), CanvasSize=UDim2.new(0,0,0,0)})
propArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
local actions = make("Frame", {Parent=mid, Size=UDim2.new(1,0,0,100), Position=UDim2.new(0,0,1,-100), BackgroundColor3=Color3.fromRGB(250,250,250)})
local btnSelect = make("TextButton", {Parent=actions, Size=UDim2.new(1,-10,0,30), Position=UDim2.new(0,0,6,6), Text="Select In Explorer"})
local btnFocus = make("TextButton", {Parent=actions, Size=UDim2.new(1,-10,0,30), Position=UDim2.new(0,0,6,42), Text="Focus View (Camera)"})
local btnOpenScript = make("TextButton", {Parent=actions, Size=UDim2.new(1,-10,0,30), Position=UDim2.new(0,0,6,78), Text="Open In Script Editor"})

-- RIGHT: Tabs (Source, Console)
local right = make("Frame", {Parent=main, Size=UDim2.new(0.33,0,1,0), BackgroundColor3=Color3.fromRGB(245,245,245)})
local tabBar = make("Frame", {Parent=right, Size=UDim2.new(1,0,0,28), BackgroundColor3=Color3.fromRGB(240,240,240)})
local tSourceBtn = make("TextButton", {Parent=tabBar, Size=UDim2.new(0.5,0,1,0), Text="Source"})
local tConsoleBtn = make("TextButton", {Parent=tabBar, Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0.5,0,0,0), Text="Console"})
local contentArea = make("Frame", {Parent=right, Size=UDim2.new(1,0,1,-28), Position=UDim2.new(0,0,0,28)})
local sourceBox = make("TextBox", {Parent=contentArea, Size=UDim2.new(1,0,1,0), Text="", TextWrapped=false, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top, Font=Enum.Font.Code, TextSize=14, MultiLine=true, ClearTextOnFocus=false, BackgroundColor3=Color3.fromRGB(255,255,255)})
local consoleBox = make("ScrollingFrame", {Parent=contentArea, Size=UDim2.new(1,0,1,0), Visible=false, CanvasSize=UDim2.new(0,0,0,0)})
consoleBox.AutomaticCanvasSize = Enum.AutomaticSize.Y
local consoleLayout = make("UIListLayout", {Parent=consoleBox})

-- State
local selectedInstance = nil

-- Utilities: populate tree (workspace + Services commonly containing scripts)
local function traverseAndAdd(parentFrame, instance, prefix)
	prefix = prefix or ""
	-- only show containers and script-likes
	local button = make("TextButton", {Parent=parentFrame, Text = prefix .. instance.Name .. (isScriptLike(instance) and (" ["..instance.ClassName.."]") or ""), Size=UDim2.new(1,0,0,24), TextXAlignment=Enum.TextXAlignment.Left})
	button.MouseButton1Click:Connect(function()
		selectedInstance = instance
		Selection:Set({instance})
		-- update Inspector
		updateInspector()
	end)
	-- recursively add children if container
	local children = instance:GetChildren()
	for _,child in ipairs(children) do
		-- show only useful items or scripts
		if #child:GetChildren() > 0 or isScriptLike(child) then
			traverseAndAdd(parentFrame, child, prefix .. "  ")
		elseif isScriptLike(child) then
			traverseAndAdd(parentFrame, child, prefix .. "  ")
		end
	end
end

function refreshTree(filterText)
	for _,c in ipairs(leftScroll:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
	-- Common roots: Workspace and Scripts containers
	local roots = {workspace, game:GetService("ServerScriptService"), game:GetService("StarterPlayer"), game:GetService("StarterPlayerScripts"), game:GetService("ReplicatedStorage")}
	for _,rootInst in ipairs(roots) do
		if rootInst then
			local rootBtn = make("TextLabel", {Parent=leftScroll, Text = rootInst.Name, Size=UDim2.new(1,0,0,20), BackgroundColor3=Color3.fromRGB(240,240,240), TextXAlignment=Enum.TextXAlignment.Left})
			for _,desc in ipairs(rootInst:GetDescendants()) do
				if isScriptLike(desc) then
					if (not filterText) or filterText == "" or string.find(string.lower(desc.Name), string.lower(filterText)) then
						local line = make("TextButton", {Parent=leftScroll, Text = "  "..desc.Name.." ["..desc.ClassName.."]", Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left})
						line.MouseButton1Click:Connect(function()
							selectedInstance = desc
							Selection:Set({desc})
							updateInspector()
						end)
					end
				end
			end
		end
	end
end

-- Inspector update
function updateInspector()
	for _,c in ipairs(propArea:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
	if not selectedInstance then return end
	local props = {"ClassName","Name","Parent","Archivable"}
	for _,k in ipairs(props) do
		local val = tostring(selectedInstance[k])
		local label = make("TextLabel", {Parent=propArea, Size=UDim2.new(1,0,0,20), Text = k..": "..val, TextXAlignment=Enum.TextXAlignment.Left})
	end
	-- show some special properties for parts
	if selectedInstance:IsA("BasePart") then
		local pos = tostring(selectedInstance.Position)
		local label = make("TextLabel", {Parent=propArea, Size=UDim2.new(1,0,0,20), Text = "Position: "..pos, TextXAlignment=Enum.TextXAlignment.Left})
	end
	-- populate source viewer if script-like
	if isScriptLike(selectedInstance) then
		local ok, src = pcall(function() return selectedInstance.Source end)
		if ok and src then
			sourceBox.Text = src
			sourceBox.Visible = true
			consoleBox.Visible = false
		else
			sourceBox.Text = "-- (Unable to read Source) --"
		end
	else
		sourceBox.Text = "-- Not a Script/LocalScript/ModuleScript --"
	end
end

-- Button behaviors
btnSelect.MouseButton1Click:Connect(function()
	if selectedInstance then Selection:Set({selectedInstance}) end
end)

btnFocus.MouseButton1Click:Connect(function()
	if not selectedInstance then return end
	if selectedInstance:IsA("BasePart") then
		-- scriptable camera move (Studio)
		local cam = workspace.CurrentCamera
		if cam then
			local prevType = cam.CameraType
			cam.CameraType = Enum.CameraType.Scriptable
			cam.CFrame = selectedInstance.CFrame * CFrame.new(0, 2, -8)
			delay(0.35, function() pcall(function() cam.CameraType = prevType end) end)
		end
	end
end)

btnOpenScript.MouseButton1Click:Connect(function()
	if selectedInstance and isScriptLike(selectedInstance) then
		-- Open the script in the Studio script editor
		local ok, err = pcall(function() Plugin:OpenScript(selectedInstance) end)
		if not ok then
			warn("Scriptview: failed to open script:", err)
			-- Try ScriptEditorService alternative if plugin:OpenScript is not available
			local success, sErr = pcall(function()
				local ScriptEditorService = game:GetService("ScriptEditorService")
				if ScriptEditorService and ScriptEditorService.OpenScriptDocumentAsync then
					ScriptEditorService:OpenScriptDocumentAsync(selectedInstance)
				end
			end)
			if not success then warn("Scriptview: alternative open attempt failed:", sErr) end
		end
	end
end)

-- Console: pull logs
local function refreshConsole()
	for _,c in ipairs(consoleBox:GetChildren()) do if not (c:IsA("UIListLayout")) then c:Destroy() end end
	local entries = {}
	local ok, hist = pcall(function() return LogService:GetLogHistory() end)
	if ok and hist then
		for i = 1, #hist do
			local e = hist[i]
			local text = string.format("[%s] %s", os.date("%H:%M:%S", math.floor(e[3]/1000)), tostring(e[1]))
			local label = make("TextLabel", {Parent=consoleBox, Size=UDim2.new(1,0,0,18), Text = text, TextXAlignment=Enum.TextXAlignment.Left, BackgroundTransparency=1})
		end
	end
end

-- Tab switching
tSourceBtn.MouseButton1Click:Connect(function()
	sourceBox.Visible = true
	consoleBox.Visible = false
end)
tConsoleBtn.MouseButton1Click:Connect(function()
	sourceBox.Visible = false
	consoleBox.Visible = true
	refreshConsole()
end)

-- Search
leftHeader.FocusLost:Connect(function(enter)
	refreshTree(leftHeader.Text)
end)

-- Selection sync
Selection.SelectionChanged:Connect(function()
	local sel = Selection:Get()
	if sel and #sel > 0 then
		selectedInstance = sel[1]
		updateInspector()
	end
end)

-- Button toggles widget
button.Click:Connect(function()
	dock.Enabled = not dock.Enabled
end)

-- Start-up populate
refreshTree("")

-- Periodic refresh (non-intrusive)
local lastRefresh = tick()
RunService.Heartbeat:Connect(function(dt)
	if tick() - lastRefresh > 5 then
		lastRefresh = tick()
		-- harmless refresh of tree to catch new scripts
		refreshTree(leftHeader.Text)
	end
end)

-- Clean shutdown handler
dock.AncestryChanged:Connect(function()
	if not dock:IsDescendantOf(game:GetService("CoreGui")) and not dock.Parent then
		-- attempt cleanup
	end
end)

-- Finalize: show widget when first installed
dock.Enabled = true
