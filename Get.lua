-- Dark Gray Dex GUI Script for Roblox
-- This is a simple object explorer GUI with a dark gray theme
-- Includes a logo image using the provided asset ID

local gui = Instance.new("ScreenGui")
gui.Name = "DarkGrayDex"
gui.Parent = game:GetService("CoreGui")  -- Use CoreGui for persistence (requires exploit or local testing)

local mainFrame = Instance.new("Frame")
mainFrame.Parent = gui
mainFrame.Size = UDim2.new(0.4, 0, 0.6, 0)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0

-- Logo Image
local logo = Instance.new("ImageLabel")
logo.Parent = mainFrame
logo.Size = UDim2.new(0, 175, 0, 80)
logo.Position = UDim2.new(0, 10, 0, 10)
logo.BackgroundTransparency = 1
logo.Image = "rbxassetid://114450126752273"

-- Title Label
local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
title.TextColor3 = Color3.fromRGB(200, 200, 200)
title.Text = "Scriptview Dex"
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

-- Explorer Scrolling Frame
local explorerFrame = Instance.new("ScrollingFrame")
explorerFrame.Parent = mainFrame
explorerFrame.Size = UDim2.new(1, 0, 1, -100)
explorerFrame.Position = UDim2.new(0, 0, 0, 100)
explorerFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
explorerFrame.BorderSizePixel = 0
explorerFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
explorerFrame.ScrollBarThickness = 8
explorerFrame.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 70)

-- Function to add children recursively
local function addItem(parentFrame, instance, depth)
    local itemButton = Instance.new("TextButton")
    itemButton.Parent = parentFrame
    itemButton.Size = UDim2.new(1, -depth * 10, 0, 20)
    itemButton.Position = UDim2.new(0, depth * 10, 0, (#parentFrame:GetChildren() - 1) * 20)
    itemButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    itemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    itemButton.Text = instance.Name .. " [" .. instance.ClassName .. "]"
    itemButton.TextXAlignment = Enum.TextXAlignment.Left
    itemButton.Font = Enum.Font.SourceSans
    itemButton.TextSize = 14
    itemButton.BorderSizePixel = 0

    local childrenContainer
    itemButton.MouseButton1Click:Connect(function()
        if childrenContainer then
            childrenContainer:Destroy()
            childrenContainer = nil
            -- Update canvas size
            explorerFrame.CanvasSize = UDim2.new(0, 0, 0, (#explorerFrame:GetChildren() - 1) * 20)
        else
            childrenContainer = Instance.new("Frame")
            childrenContainer.Parent = itemButton
            childrenContainer.Name = "Children"
            childrenContainer.Size = UDim2.new(1, 0, 0, 0)
            childrenContainer.Position = UDim2.new(0, 0, 1, 0)
            childrenContainer.BackgroundTransparency = 1

            for _, child in ipairs(instance:GetChildren()) do
                addItem(childrenContainer, child, depth + 1)
            end

            -- Update canvas size
            explorerFrame.CanvasSize = UDim2.new(0, 0, 0, explorerFrame.CanvasSize.Y.Offset + #instance:GetChildren() * 20)
        end
    end)
end

-- Root Item (game)
local rootItem = Instance.new("TextButton")
rootItem.Parent = explorerFrame
rootItem.Size = UDim2.new(1, 0, 0, 20)
rootItem.Position = UDim2.new(0, 0, 0, 0)
rootItem.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
rootItem.TextColor3 = Color3.fromRGB(255, 255, 255)
rootItem.Text = "game [DataModel]"
rootItem.TextXAlignment = Enum.TextXAlignment.Left
rootItem.Font = Enum.Font.SourceSans
rootItem.TextSize = 14
rootItem.BorderSizePixel = 0

local rootChildren
rootItem.MouseButton1Click:Connect(function()
    if rootChildren then
        rootChildren:Destroy()
        rootChildren = nil
        explorerFrame.CanvasSize = UDim2.new(0, 0, 0, 20)
    else
        rootChildren = Instance.new("Frame")
        rootChildren.Parent = rootItem
        rootChildren.Name = "Children"
        rootChildren.Size = UDim2.new(1, 0, 0, 0)
        rootChildren.Position = UDim2.new(0, 0, 1, 0)
        rootChildren.BackgroundTransparency = 1

        for _, service in ipairs(game:GetChildren()) do
            addItem(rootChildren, service, 1)
        end

        explorerFrame.CanvasSize = UDim2.new(0, 0, 0, 20 + #game:GetChildren() * 20)
    end
end)

-- Make GUI draggable (simple drag implementation)
local dragging
local dragInput
local dragStart
local startPos

mainFrame.InputBegan:Connect(function(input)
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
