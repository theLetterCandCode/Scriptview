-- Light Dex Explorer GUI Script for Roblox
-- Place this script in StarterGui or use a LocalScript

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LightDexExplorer"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Main Frame (draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 5, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Light Dex Explorer"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Parent = titleBar
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimize Button (Hide/Show)
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -60, 0, 0)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 18
minimizeButton.Parent = titleBar

local isMinimized = false
local originalSize = mainFrame.Size
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        originalSize = mainFrame.Size
        mainFrame.Size = UDim2.new(0, 600, 0, 30)
        searchFrame.Visible = false
        treeFrame.Visible = false
        detailsFrame.Visible = false
        minimizeButton.Text = "+"
    else
        mainFrame.Size = originalSize
        searchFrame.Visible = true
        treeFrame.Visible = true
        detailsFrame.Visible = true
        minimizeButton.Text = "-"
    end
end)

-- Make draggable
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Search Bar
local searchFrame = Instance.new("Frame")
searchFrame.Size = UDim2.new(1, 0, 0, 40)
searchFrame.Position = UDim2.new(0, 0, 0, 30)
searchFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchFrame.Parent = mainFrame

local searchIcon = Instance.new("ImageLabel")
searchIcon.Size = UDim2.new(0, 30, 0, 30)
searchIcon.Position = UDim2.new(0, 5, 0.5, -15)
searchIcon.BackgroundTransparency = 1
searchIcon.Image = "rbxassetid://14589737447"
searchIcon.Parent = searchFrame

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -40, 0, 30)
searchBox.Position = UDim2.new(0, 40, 0.5, -15)
searchBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderText = "Search for object..."
searchBox.TextSize = 16
searchBox.Parent = searchFrame

-- Layout: Left - Tree View, Right - Details (Viewport, Properties, Scripts)
local treeFrame = Instance.new("ScrollingFrame")
treeFrame.Size = UDim2.new(0.5, 0, 1, -70)
treeFrame.Position = UDim2.new(0, 0, 0, 70)
treeFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
treeFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
treeFrame.ScrollBarThickness = 8
treeFrame.Parent = mainFrame

local treeLayout = Instance.new("UIListLayout")
treeLayout.SortOrder = Enum.SortOrder.LayoutOrder
treeLayout.Padding = UDim.new(0, 2)
treeLayout.Parent = treeFrame

local detailsFrame = Instance.new("Frame")
detailsFrame.Size = UDim2.new(0.5, 0, 1, -70)
detailsFrame.Position = UDim2.new(0.5, 0, 0, 70)
detailsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
detailsFrame.Parent = mainFrame

-- Viewport in Details
local viewportFrame = Instance.new("ViewportFrame")
viewportFrame.Size = UDim2.new(1, 0, 0, 150)
viewportFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
viewportFrame.Parent = detailsFrame

local camera = Instance.new("Camera")
camera.Parent = viewportFrame
viewportFrame.CurrentCamera = camera

-- Properties ScrollingFrame
local propsFrame = Instance.new("ScrollingFrame")
propsFrame.Size = UDim2.new(1, 0, 1, -150)
propsFrame.Position = UDim2.new(0, 0, 0, 150)
propsFrame.BackgroundTransparency = 1
propsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
propsFrame.ScrollBarThickness = 8
propsFrame.Parent = detailsFrame

local propsLayout = Instance.new("UIListLayout")
propsLayout.SortOrder = Enum.SortOrder.LayoutOrder
propsLayout.Padding = UDim.new(0, 5)
propsLayout.Parent = propsFrame

-- Script Source TextBox (hidden by default)
local scriptFrame = Instance.new("Frame")
scriptFrame.Size = UDim2.new(1, 0, 1, -150)
scriptFrame.Position = UDim2.new(0, 0, 0, 150)
scriptFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
scriptFrame.Visible = false
scriptFrame.Parent = detailsFrame

local scriptBox = Instance.new("TextBox")
scriptBox.Size = UDim2.new(1, 0, 1, 0)
scriptBox.BackgroundTransparency = 1
scriptBox.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptBox.TextSize = 14
scriptBox.MultiLine = true
scriptBox.ClearTextOnFocus = false
scriptBox.TextWrapped = true
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
scriptBox.Parent = scriptFrame

-- Function to create tree item
local function createTreeItem(obj, parentFrame, depth)
    local itemFrame = Instance.new("Frame")
    itemFrame.Size = UDim2.new(1, 0, 0, 25)
    itemFrame.BackgroundTransparency = 1
    itemFrame.Parent = parentFrame

    local indent = Instance.new("UIPadding")
    indent.PaddingLeft = UDim.new(0, depth * 20)
    indent.Parent = itemFrame

    local expandButton = Instance.new("ImageButton")
    expandButton.Size = UDim2.new(0, 20, 0, 20)
    expandButton.Position = UDim2.new(0, 0, 0.5, -10)
    expandButton.BackgroundTransparency = 1
    expandButton.Image = "rbxassetid://1284564024"
    expandButton.Visible = #obj:GetChildren() > 0
    expandButton.Parent = itemFrame

    local nameButton = Instance.new("TextButton")
    nameButton.Size = UDim2.new(1, -20, 1, 0)
    nameButton.Position = UDim2.new(0, 20, 0, 0)
    nameButton.BackgroundTransparency = 1
    nameButton.Text = (obj.Name == "" and "game" or obj.Name) .. " (" .. obj.ClassName .. ")"
    nameButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameButton.TextSize = 14
    nameButton.TextXAlignment = Enum.TextXAlignment.Left
    nameButton.Parent = itemFrame

    local childrenFrame = Instance.new("Frame")
    childrenFrame.Size = UDim2.new(1, 0, 0, 0)
    childrenFrame.BackgroundTransparency = 1
    childrenFrame.Visible = false
    childrenFrame.Parent = itemFrame

    local childrenLayout = Instance.new("UIListLayout")
    childrenLayout.SortOrder = Enum.SortOrder.LayoutOrder
    childrenLayout.Padding = UDim.new(0, 2)
    childrenLayout.Parent = childrenFrame

    local expanded = false
    local populated = false

    expandButton.MouseButton1Click:Connect(function()
        expanded = not expanded
        childrenFrame.Visible = expanded
        expandButton.Rotation = expanded and 90 or 0
        if expanded then
            local height = childrenLayout.AbsoluteContentSize.Y
            childrenFrame.Size = UDim2.new(1, 0, 0, height)
        else
            childrenFrame.Size = UDim2.new(1, 0, 0, 0)
        end
        treeFrame.CanvasSize = UDim2.new(0, 0, 0, treeLayout.AbsoluteContentSize.Y)
    end)

    -- Populate children lazily
    expandButton.MouseButton1Click:Connect(function()
        if expanded and not populated then
            populated = true
            for _, child in ipairs(obj:GetChildren()) do
                createTreeItem(child, childrenFrame, depth + 1)
            end
            local height = childrenLayout.AbsoluteContentSize.Y
            childrenFrame.Size = UDim2.new(1, 0, 0, height)
            treeFrame.CanvasSize = UDim2.new(0, 0, 0, treeLayout.AbsoluteContentSize.Y)
        end
    end)

    -- On select
    nameButton.MouseButton1Click:Connect(function()
        -- Clear previous
        for _, child in ipairs(propsFrame:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        viewportFrame:ClearAllChildren()
        scriptFrame.Visible = false
        propsFrame.Visible = true

        -- Name
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 20)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = "Name: " .. obj.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = propsFrame

        -- Class
        local classLabel = Instance.new("TextLabel")
        classLabel.Size = UDim2.new(1, 0, 0, 20)
        classLabel.BackgroundTransparency = 1
        classLabel.Text = "Class: " .. obj.ClassName
        classLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        classLabel.TextSize = 14
        classLabel.TextXAlignment = Enum.TextXAlignment.Left
        classLabel.Parent = propsFrame

        -- More properties (limited for lightness)
        local props = {"Parent", "Archivable"}  -- Add more if needed
        for _, prop in ipairs(props) do
            local val = tostring(obj[prop])
            local propLabel = Instance.new("TextLabel")
            propLabel.Size = UDim2.new(1, 0, 0, 20)
            propLabel.BackgroundTransparency = 1
            propLabel.Text = prop .. ": " .. val
            propLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            propLabel.TextSize = 14
            propLabel.TextXAlignment = Enum.TextXAlignment.Left
            propLabel.Parent = propsFrame
        end

        propsFrame.CanvasSize = UDim2.new(0, 0, 0, propsLayout.AbsoluteContentSize.Y)

        -- Viewport preview
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local clone = obj:Clone()
            clone.Parent = viewportFrame
            camera.CFrame = CFrame.new(clone:GetPivot().Position + Vector3.new(0, 0, 10), clone:GetPivot().Position)
        end

        -- If script, show source
        if obj:IsA("LuaSourceContainer") then
            propsFrame.Visible = false
            scriptFrame.Visible = true
            scriptBox.Text = obj.Source
        end
    end)

    return itemFrame
end

-- Initial population (start from game)
createTreeItem(game, treeFrame, 0)

-- Search functionality
local function refreshTree(filter)
    treeFrame:ClearAllChildren()
    treeLayout.Parent = treeFrame  -- Re-add layout if needed, but shouldn't be necessary

    local function addFiltered(obj, parentFrame, depth)
        local added = false
        if obj.Name:lower():find(filter:lower()) or obj.ClassName:lower():find(filter:lower()) then
            createTreeItem(obj, parentFrame, depth)
            added = true
        end
        for _, child in ipairs(obj:GetChildren()) do
            addFiltered(child, added and itemFrame:FindFirstChild("childrenFrame") or parentFrame, added and depth + 1 or depth)
        end
    end

    if filter == "" then
        createTreeItem(game, treeFrame, 0)
    else
        addFiltered(game, treeFrame, 0)
    end
    treeFrame.CanvasSize = UDim2.new(0, 0, 0, treeLayout.AbsoluteContentSize.Y)
end

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        refreshTree(searchBox.Text)
    end
end)

-- Initial canvas size
treeFrame.CanvasSize = UDim2.new(0, 0, 0, treeLayout.AbsoluteContentSize.Y)
