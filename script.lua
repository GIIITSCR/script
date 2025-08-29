local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

-- Default values
local teleportBackPosition = hrp.CFrame
local humanoid = character:WaitForChild("Humanoid")
local defaultWalkSpeed = humanoid.WalkSpeed
local defaultJumpPower = humanoid.JumpPower

-- GUI root
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 500)
frame.Position = UDim2.new(0.5, -200, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BackgroundTransparency = 0.1
frame.Active = true
frame.Parent = screenGui

-- Tabs container
local tabButtons = Instance.new("Frame")
tabButtons.Size = UDim2.new(1, 0, 0, 40)
tabButtons.Position = UDim2.new(0, 0, 0, 0)
tabButtons.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tabButtons.Parent = frame

-- Pages system
local pages = {}

local function createPage(name)
    local page = Instance.new("Frame")
    page.Size = UDim2.new(1, 0, 1, -40)
    page.Position = UDim2.new(0, 0, 0, 40)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = frame
    pages[name] = page
    return page
end

local function switchPage(name)
    for n, page in pairs(pages) do
        page.Visible = (n == name)
    end
end

local function createTab(name, order, pageName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 1, 0)
    btn.Position = UDim2.new(0, (order-1)*100, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = tabButtons
    btn.MouseButton1Click:Connect(function()
        switchPage(pageName)
    end)
end

---------------- TAB 1: Teleport ----------------
local tpPage = createPage("Teleport")
createTab("Teleport", 1, "Teleport")

local tpList = Instance.new("ScrollingFrame")
tpList.Size = UDim2.new(1, -10, 1, -100)
tpList.Position = UDim2.new(0, 5, 0, 5)
tpList.ScrollBarThickness = 6
tpList.BackgroundTransparency = 1
tpList.Parent = tpPage

local tpLayout = Instance.new("UIListLayout")
tpLayout.Parent = tpList
tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
tpLayout.Padding = UDim.new(0, 5)

local tpForward = Instance.new("TextButton")
tpForward.Size = UDim2.new(0, 350, 0, 40)
tpForward.Position = UDim2.new(0.5, -175, 1, -90)
tpForward.Text = "Teleport Forward (20 studs)"
tpForward.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
tpForward.TextColor3 = Color3.fromRGB(255,255,255)
tpForward.Parent = tpPage
tpForward.MouseButton1Click:Connect(function()
    hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -20)
end)

local tpBack = Instance.new("TextButton")
tpBack.Size = UDim2.new(0, 170, 0, 40)
tpBack.Position = UDim2.new(0, 10, 1, -45)
tpBack.Text = "Teleport Back"
tpBack.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
tpBack.TextColor3 = Color3.fromRGB(255,255,255)
tpBack.Parent = tpPage
tpBack.MouseButton1Click:Connect(function()
    hrp.CFrame = teleportBackPosition
end)

local setBack = Instance.new("TextButton")
setBack.Size = UDim2.new(0, 170, 0, 40)
setBack.Position = UDim2.new(1, -180, 1, -45)
setBack.Text = "Set Back Position"
setBack.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
setBack.TextColor3 = Color3.fromRGB(255,255,255)
setBack.Parent = tpPage
setBack.MouseButton1Click:Connect(function()
    teleportBackPosition = hrp.CFrame
end)

---------------- TAB 2: Movement ----------------
---------------- TAB 2: Movement ----------------
local wsPage = createPage("Movement")
createTab("Movement", 2, "Movement")

-- WalkSpeed Label
local wsLabel = Instance.new("TextLabel")
wsLabel.Size = UDim2.new(0, 380, 0, 30)
wsLabel.Position = UDim2.new(0, 10, 0, 10)
wsLabel.Text = "WalkSpeed: "..humanoid.WalkSpeed
wsLabel.BackgroundTransparency = 1
wsLabel.TextColor3 = Color3.fromRGB(255,255,255)
wsLabel.Parent = wsPage

-- WalkSpeed Slider
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 300, 0, 20)
sliderFrame.Position = UDim2.new(0, 10, 0, 40)
sliderFrame.BackgroundColor3 = Color3.fromRGB(60,60,60)
sliderFrame.Parent = wsPage

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0, 0, 1, 0)
sliderBar.BackgroundColor3 = Color3.fromRGB(0,200,200)
sliderBar.Parent = sliderFrame

local sliderBtn = Instance.new("TextButton")
sliderBtn.Size = UDim2.new(0, 20, 1.5, 0)
sliderBtn.Position = UDim2.new(0,0, -0.25, 0)
sliderBtn.BackgroundColor3 = Color3.fromRGB(200,200,200)
sliderBtn.Text = ""
sliderBtn.Parent = sliderFrame

local draggingSlider = false

sliderBtn.MouseButton1Down:Connect(function()
    draggingSlider = true
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSlider = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
        local relX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
        sliderBtn.Position = UDim2.new(0, relX-10, sliderBtn.Position.Y.Scale, sliderBtn.Position.Y.Offset)
        sliderBar.Size = UDim2.new(0, relX, 1, 0)

        local ws = math.floor((relX / sliderFrame.AbsoluteSize.X) * 200) -- максимум 200
        humanoid.WalkSpeed = ws
        wsLabel.Text = "WalkSpeed: "..ws
    end
end)

-- InfJump toggle
local infJumpEnabled = false
local infBtn = Instance.new("TextButton")
infBtn.Size = UDim2.new(0, 150, 0, 30)
infBtn.Position = UDim2.new(0, 10, 0, 70)
infBtn.Text = "InfJump: OFF"
infBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
infBtn.TextColor3 = Color3.fromRGB(255,255,255)
infBtn.Parent = wsPage

infBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    infBtn.Text = "InfJump: "..(infJumpEnabled and "ON" or "OFF")
end)

UIS.JumpRequest:Connect(function()
    if infJumpEnabled then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-Ragdoll toggle
local antiRagdollEnabled = false
local antiBtn = Instance.new("TextButton")
antiBtn.Size = UDim2.new(0, 150, 0, 30)
antiBtn.Position = UDim2.new(0, 10, 0, 110)
antiBtn.Text = "Anti-Ragdoll: OFF"
antiBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
antiBtn.TextColor3 = Color3.fromRGB(255,255,255)
antiBtn.Parent = wsPage

antiBtn.MouseButton1Click:Connect(function()
    antiRagdollEnabled = not antiRagdollEnabled
    antiBtn.Text = "Anti-Ragdoll: "..(antiRagdollEnabled and "ON" or "OFF")
end)

-- Убираем ragdoll Constraints
game:GetService("RunService").Stepped:Connect(function()
    if antiRagdollEnabled and character then
        for _, v in pairs(character:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                v:Destroy()
            end
        end
    end
end)


---------------- TAB 3: Phones ----------------
local phonePage = createPage("Phones")
createTab("Phones", 3, "Phones")

local phoneList = Instance.new("ScrollingFrame")
phoneList.Size = UDim2.new(1, -10, 1, -10)
phoneList.Position = UDim2.new(0, 5, 0, 5)
phoneList.ScrollBarThickness = 6
phoneList.BackgroundTransparency = 1
phoneList.Parent = phonePage

local phoneLayout = Instance.new("UIListLayout")
phoneLayout.Parent = phoneList
phoneLayout.SortOrder = Enum.SortOrder.LayoutOrder
phoneLayout.Padding = UDim.new(0, 5)

local function updatePhones()
    for _, child in pairs(phoneList:GetChildren()) do
        if child:IsA("TextLabel") then child:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local stats = p:FindFirstChild("Stats")
        local phones = {}
        if stats and stats:FindFirstChild("PlotNPC") then
            for _, obj in pairs(stats.PlotNPC:GetChildren()) do
                if obj:IsA("ValueBase") then
                    table.insert(phones, tostring(obj.Value).." ("..obj.Name..")")
                end
            end
        end
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0, phones[1] and 40 or 20)
        label.TextColor3 = Color3.fromRGB(255,255,0)
        label.BackgroundTransparency = 1
        label.TextScaled = true
        if #phones > 0 then
            label.Text = p.Name.." has: "..table.concat(phones,", ")
        else
            label.Text = p.Name.." has no phones"
        end
        label.Parent = phoneList
    end
    phoneList.CanvasSize = UDim2.new(0,0,0, phoneLayout.AbsoluteContentSize.Y)
end

---------------- TAB 4: Bind ----------------
local bindPage = createPage("Bind")
createTab("Bind", 4, "Bind")

local bindLabel = Instance.new("TextLabel")
bindLabel.Size = UDim2.new(1, -20, 0, 30)
bindLabel.Position = UDim2.new(0, 10, 0, 10)
bindLabel.Text = "Press key to bind TeleportBack"
bindLabel.TextColor3 = Color3.fromRGB(255,255,255)
bindLabel.BackgroundTransparency = 1
bindLabel.Parent = bindPage

local currentBind = Enum.KeyCode.B
local waitingForBind = false

local bindBtn = Instance.new("TextButton")
bindBtn.Size = UDim2.new(0,200,0,40)
bindBtn.Position = UDim2.new(0,10,0,50)
bindBtn.Text = "Current Bind: B"
bindBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
bindBtn.TextColor3 = Color3.fromRGB(255,255,255)
bindBtn.Parent = bindPage
bindBtn.MouseButton1Click:Connect(function()
    waitingForBind = true
    bindBtn.Text = "Press any key..."
end)

UIS.InputBegan:Connect(function(input,gp)
    if waitingForBind and input.UserInputType == Enum.UserInputType.Keyboard then
        currentBind = input.KeyCode
        bindBtn.Text = "Current Bind: "..tostring(currentBind.Name)
        waitingForBind = false
    elseif input.KeyCode == currentBind then
        hrp.CFrame = teleportBackPosition
    end
end)

-- Start with Teleport tab
switchPage("Teleport")

-- Update loops
task.spawn(function()
    while true do
        -- обновляем список игроков для телепорта
        for _, child in pairs(tpList:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, p in pairs(Players:GetPlayers()) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,30)
            btn.Text = p.Name
            btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            btn.Parent = tpList
            btn.MouseButton1Click:Connect(function()
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    hrp.CFrame = p.Character.HumanoidRootPart.CFrame
                end
            end)
        end
        tpList.CanvasSize = UDim2.new(0,0,0,tpLayout.AbsoluteContentSize.Y)
        updatePhones()
        task.wait(2)
    end
end)

---------------- DRAG WHOLE WINDOW ----------------
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
