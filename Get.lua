-- Dark Gray Dex GUI Script for Roblox
-- Improved version with tree view using UIListLayout, search, theme settings, properties viewer, class icons (basic), logo fit

local gui = Instance.new("ScreenGui")
gui.Name = "DarkGrayDex"
gui.Parent = game:GetService("CoreGui")

local themes = {
    dark = {
        mainBg = Color3.fromRGB(40, 40, 40),
        titleBg = Color3.fromRGB(30, 30, 30),
        textColor = Color3.fromRGB(200, 200, 200),
        buttonBg = Color3.fromRGB(60, 60, 60),
        scrollBg = Color3.fromRGB(50, 50, 50),
        scrollBar = Color3.fromRGB(70, 70, 70),
    },
    light = {
        mainBg = Color3.fromRGB(240, 240, 240),
        titleBg = Color3.fromRGB(220, 220, 220),
        textColor = Color3.fromRGB(50, 50, 50),
        buttonBg = Color3.fromRGB(200, 200, 200),
        scrollBg = Color3.fromRGB(230, 230, 230),
        scrollBar = Color3.fromRGB(180, 180, 180),
    }
}

local currentTheme = themes.dark

local mainFrame = Instance.new("Frame")
mainFrame.Parent = gui
mainFrame.Size = UDim2.new(0.6, 0, 0.7, 0)
mainFrame.Position = UDim2.new(0.2, 0, 0.15, 0)
mainFrame.BackgroundColor3 = currentTheme.mainBg
mainFrame.BorderSizePixel = 0

-- Logo Image
local logo = Instance.new("ImageLabel")
logo.Parent = mainFrame
logo.Size = UDim2.new(0, 50, 0, 50)
logo.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundTransparency = 1
logo.Image = "rbxassetid://114450126752273"
logo.ScaleType = Enum.ScaleType.Fit

-- Title Label
local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = currentTheme.titleBg
title.TextColor3 = currentTheme.textColor
title.Text = "Dark Gray Dex"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Parent = title
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Theme Button
local themeButton = Instance.new("TextButton")
themeButton.Parent = title
themeButton.Size = UDim2.new(0, 60, 0, 30)
themeButton.Position = UDim2.new(1, -90, 0, 0)
themeButton.BackgroundColor3 = currentTheme.buttonBg
themeButton.TextColor3 = currentTheme.textColor
themeButton.Text = "Theme"
themeButton.Font = Enum.Font.SourceSansBold
themeButton.TextSize = 14
themeButton.MouseButton1Click:Connect(function()
    if currentTheme == themes.dark then
        currentTheme = themes.light
    else
        currentTheme = themes.dark
    end
    applyTheme()
end)

-- Search Box
local searchBox = Instance.new("TextBox")
searchBox.Parent = mainFrame
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 40)
searchBox.BackgroundColor3 = currentTheme.buttonBg
searchBox.TextColor3 = currentTheme.textColor
searchBox.PlaceholderText = "Search..."
searchBox.Font = Enum.Font.SourceSans
searchBox.TextSize = 14

-- Explorer Frame (left)
local explorerFrame = Instance.new("ScrollingFrame")
explorerFrame.Parent = mainFrame
explorerFrame.Size = UDim2.new(0.5, 0, 1, -80)
explorerFrame.Position = UDim2.new(0, 0, 0, 80)
explorerFrame.BackgroundColor3 = currentTheme.scrollBg
explorerFrame.BorderSizePixel = 0
explorerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
explorerFrame.ScrollBarThickness = 8
explorerFrame.ScrollBarImageColor3 = currentTheme.scrollBar

local explorerLayout = Instance.new("UIListLayout")
explorerLayout.Parent = explorerFrame
explorerLayout.SortOrder = Enum.SortOrder.LayoutOrder
explorerLayout.FillDirection = Enum.FillDirection.Vertical
explorerLayout.Padding = UDim.new(0, 0)

-- Properties Frame (right)
local propertiesFrame = Instance.new("ScrollingFrame")
propertiesFrame.Parent = mainFrame
propertiesFrame.Size = UDim2.new(0.5, 0, 1, -80)
propertiesFrame.Position = UDim2.new(0.5, 0, 0, 80)
propertiesFrame.BackgroundColor3 = currentTheme.scrollBg
propertiesFrame.BorderSizePixel = 0
propertiesFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
propertiesFrame.ScrollBarThickness = 8
propertiesFrame.ScrollBarImageColor3 = currentTheme.scrollBar

local propertiesLayout = Instance.new("UIListLayout")
propertiesLayout.Parent = propertiesFrame
propertiesLayout.SortOrder = Enum.SortOrder.LayoutOrder
propertiesLayout.FillDirection = Enum.FillDirection.Vertical
propertiesLayout.Padding = UDim.new(0, 0)

local selectedInstance = nil

-- Function to apply theme
function applyTheme()
    mainFrame.BackgroundColor3 = currentTheme.mainBg
    title.BackgroundColor3 = currentTheme.titleBg
    title.TextColor3 = currentTheme.textColor
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255) -- keep white
    themeButton.BackgroundColor3 = currentTheme.buttonBg
    themeButton.TextColor3 = currentTheme.textColor
    searchBox.BackgroundColor3 = currentTheme.buttonBg
    searchBox.TextColor3 = currentTheme.textColor
    explorerFrame.BackgroundColor3 = currentTheme.scrollBg
    explorerFrame.ScrollBarImageColor3 = currentTheme.scrollBar
    propertiesFrame.BackgroundColor3 = currentTheme.scrollBg
    propertiesFrame.ScrollBarImageColor3 = currentTheme.scrollBar
    -- Apply to all items
    for _, item in ipairs(explorerFrame:GetChildren()) do
        if item:IsA("Frame") then
            item:FindFirstChild("ExpandButton").TextColor3 = currentTheme.textColor
            item:FindFirstChild("NameLabel").TextColor3 = currentTheme.textColor
            item.BackgroundColor3 = currentTheme.buttonBg
        end
    end
    updateProperties()
end

-- Property names to display
local propertyNames = {"Name", "ClassName", "Parent", "Archivable", "PrimaryPart"} -- Add more as needed

-- Function to update properties
function updateProperties()
    propertiesFrame:ClearAllChildren()
    if selectedInstance then
        for _, prop = in ipairs(propertyNames) do
            local propFrame = Instance.new("Frame")
            propFrame.Parent = propertiesFrame
            propFrame.Size = UDim2.new(1, 0, 0, 20)
            propFrame.BackgroundTransparency = 1

            local propLabel = Instance.new("TextLabel")
            propLabel.Parent = propFrame
            propLabel.Size = UDim2.new(1, 0, 1, 0)
            propLabel.BackgroundTransparency = 1
            propLabel.TextColor3 = currentTheme.textColor
            propLabel.Text = prop .. ": " .. tostring(selectedInstance[prop] or "N/A")
            propLabel.TextXAlignment = Enum.TextXAlignment.Left
            propLabel.Font = Enum.Font.SourceSans
            propLabel.TextSize = 14

            propertiesLayout:ApplyLayout()
            propertiesFrame.CanvasSize = UDim2.new(0, 0, 0, #propertiesFrame:GetChildren() * 20)
        end
    end
end

-- Function to create tree item
local function createTreeItem(instance, depth, parentItem)
    local itemFrame = Instance.new("Frame")
    itemFrame.Size = UDim2.new(1, 0, 0, 20)
    itemFrame.BackgroundColor3 = currentTheme.buttonBg
    itemFrame.BorderSizePixel = 0

    local padding = Instance.new("UIPadding")
    padding.Parent = itemFrame
    padding.PaddingLeft = UDim.new(0, depth * 10)

    local layout = Instance.new("UIListLayout")
    layout.Parent = itemFrame
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 5)

    local expandButton = Instance.new("TextButton")
    expandButton.Name = "ExpandButton"
    expandButton.Parent = itemFrame
    expandButton.Size = UDim2.new(0, 15, 0, 15)
    expandButton.BackgroundTransparency = 1
    expandButton.TextColor3 = currentTheme.textColor
    expandButton.Text = "+"
    expandButton.Font = Enum.Font.SourceSansBold
    expandButton.TextSize = 14

    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Parent = itemFrame
    icon.Size = UDim2.new(0, 16, 0, 16)
    icon.BackgroundTransparency = 1
    -- Basic condition for icon
    if not instance:IsA("ServiceProvider") and not instance:IsA("DataModel") then
        icon.Image = "rbxasset://textures/ClassImages.png"
        icon.ImageRectSize = Vector2.new(16,16)
        icon.ImageRectOffset = Vector2.new(0, 0) -- Replace with actual for class
        -- Note: Replace offset for different classes, e.g. for Part, find the Num
    end

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Parent = itemFrame
    nameLabel.Size = UDim2.new(1, -50, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = currentTheme.textColor
    nameLabel.Text = instance.Name .. " [" .. instance.ClassName .. "]"
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Font = Enum.Font.SourceSans
    nameLabel.TextSize = 14

    local expanded = false
    local childrenItems = {}

    expandButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        expandButton.Text = expanded and "-" or "+"
        if expanded then
            for _, child in ipairs(instance:GetChildren()) do
                local childItem = createTreeItem(child, depth + 1, itemFrame)
                table.insert(childrenItems, childItem)
                childItem.Parent = explorerFrame
            end
        else
            for _, childItem in ipairs(childrenItems) do
                childItem:Destroy()
            end
            childrenItems = {}
        end
        updateCanvasSize()
    end)

    nameLabel.MouseButton1Click:Connect(function()
        selectedInstance = instance
        updateProperties()
    end)

    return itemFrame
end

-- Function to update canvas size
function updateCanvasSize()
    local height = 0
    for _, child in ipairs(explorerFrame:GetChildren()) if child:IsA("Frame") then
        height = height + child.AbsoluteSize.Y
    end
    explorerFrame.CanvasSize = UDim2.new(0, 0, 0, height)
end

-- Initial root
local rootItem = createTreeItem(game, 0)
rootItem.Parent = explorerFrame
updateCanvasSize()

-- Search functionality (simple flat search, shows matching and hides others)
searchBox.FocusLost:Connect(function(enterPressed)
    if not enterPressed then return end
    local query = searchBox.Text:lower()
    if query == "" then
        -- Reset
        explorerFrame:ClearAllChildren()
        rootItem = createTreeItem(game, 0)
        rootItem.Parent = explorerFrame
        updateCanvasSize()
        return
    end
    explorerFrame:ClearAllChildren()
    local function searchRecursive(instance, depth)
        if instance.Name:lower():find(query) then
            local item = createTreeItem(instance, depth)
            item.Parent = explorerFrame
        end
        for _, child in ipairs(instance:GetChildren()) do
            searchRecursive(child, depth + 1)
        end
    end
    searchRecursive(game, 0)
    updateCanvasSize()
end)

-- Make GUI draggable
local dragging
local dragInput
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType = Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Initial theme apply
applyTheme()
