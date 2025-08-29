--// Services & Player
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

--// State
local savedPos = hrp.CFrame
local wsValue = humanoid.WalkSpeed
local infJump = false
local menuVisible = true

-- Keybinds (changeable)
local bindToPoint = Enum.KeyCode.B
local bindForward = Enum.KeyCode.N
local waitingForBind = nil -- "point" | "forward" | nil

-- Phones view style: "under" or "side"
local phonesViewStyle = "under"

-- Floating buttons state
local floatingEnabled = false
local floatingButtons = {}

-- Theme system
local Theme = {
    name = "Dark",
    bg = Color3.fromRGB(25,25,25),
    header = Color3.fromRGB(40,40,40),
    tabBg = Color3.fromRGB(35,35,35),
    panel = Color3.fromRGB(40,40,40),
    button = Color3.fromRGB(60,60,60),
    text = Color3.fromRGB(255,255,255),
    accent = Color3.fromRGB(0,170,255),
    transparency = 0 -- 0..1
}

local Presets = {
    Dark = {
        name="Dark", bg=Color3.fromRGB(25,25,25), header=Color3.fromRGB(40,40,40),
        tabBg=Color3.fromRGB(35,35,35), panel=Color3.fromRGB(40,40,40),
        button=Color3.fromRGB(60,60,60), text=Color3.fromRGB(255,255,255),
        accent=Color3.fromRGB(0,170,255), transparency=0
    },
    Light = {
        name="Light", bg=Color3.fromRGB(235,235,235), header=Color3.fromRGB(215,215,215),
        tabBg=Color3.fromRGB(220,220,220), panel=Color3.fromRGB(230,230,230),
        button=Color3.fromRGB(200,200,200), text=Color3.fromRGB(20,20,20),
        accent=Color3.fromRGB(0,120,215), transparency=0
    },
    Neon = {
        name="Neon", bg=Color3.fromRGB(15,15,25), header=Color3.fromRGB(20,20,35),
        tabBg=Color3.fromRGB(25,25,45), panel=Color3.fromRGB(25,25,45),
        button=Color3.fromRGB(55,0,90), text=Color3.fromRGB(230,255,255),
        accent=Color3.fromRGB(120,0,255), transparency=0.05
    },
    Red = {
        name="Red", bg=Color3.fromRGB(30,10,10), header=Color3.fromRGB(60,20,20),
        tabBg=Color3.fromRGB(50,15,15), panel=Color3.fromRGB(55,18,18),
        button=Color3.fromRGB(120,30,30), text=Color3.fromRGB(255,230,230),
        accent=Color3.fromRGB(255,60,60), transparency=0
    },
    Glass = {
        name="Glass", bg=Color3.fromRGB(25,25,25), header=Color3.fromRGB(40,40,40),
        tabBg=Color3.fromRGB(35,35,35), panel=Color3.fromRGB(40,40,40),
        button=Color3.fromRGB(60,60,60), text=Color3.fromRGB(255,255,255),
        accent=Color3.fromRGB(0,170,255), transparency=0.35
    },
}

--// UI Root
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TP_Utility_UI"
screenGui.ResetOnSpawn = false
screenGui.Parent = lp:WaitForChild("PlayerGui")

-- UIScale + scale slider in settings
local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = screenGui

-- Main window
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 520, 0, 360)
mainFrame.Position = UDim2.new(0.25, 0, 0.25, 0)
mainFrame.BackgroundColor3 = Theme.bg
mainFrame.BackgroundTransparency = Theme.transparency
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Titlebar
local titleBar = Instance.new("TextButton")
titleBar.Size = UDim2.new(1, 0, 0, 28)
titleBar.BackgroundColor3 = Theme.header
titleBar.BackgroundTransparency = Theme.transparency
titleBar.BorderSizePixel = 0
titleBar.Text = "Меню"
titleBar.TextColor3 = Theme.text
titleBar.AutoButtonColor = false
titleBar.Parent = mainFrame

-- Minimize (collapse to bar)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 28, 1, 0)
minimizeBtn.Position = UDim2.new(1, -28, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Theme.button
minimizeBtn.BackgroundTransparency = Theme.transparency
minimizeBtn.TextColor3 = Theme.text
minimizeBtn.BorderSizePixel = 0
minimizeBtn.Parent = titleBar

-- Tabs column
local tabButtons = Instance.new("Frame")
tabButtons.Size = UDim2.new(0, 120, 1, -28)
tabButtons.Position = UDim2.new(0, 0, 0, 28)
tabButtons.BackgroundColor3 = Theme.tabBg
tabButtons.BackgroundTransparency = Theme.transparency
tabButtons.BorderSizePixel = 0
tabButtons.Parent = mainFrame

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.Padding = UDim.new(0, 4)
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Parent = tabButtons

-- Pages container
local pagesFrame = Instance.new("Frame")
pagesFrame.Size = UDim2.new(1, -120, 1, -28)
pagesFrame.Position = UDim2.new(0, 120, 0, 28)
pagesFrame.BackgroundTransparency = 1
pagesFrame.Parent = mainFrame

-- Helpers
local function applyTheme()
    mainFrame.BackgroundColor3 = Theme.bg
    mainFrame.BackgroundTransparency = Theme.transparency
    titleBar.BackgroundColor3 = Theme.header
    titleBar.BackgroundTransparency = Theme.transparency
    titleBar.TextColor3 = Theme.text
    minimizeBtn.BackgroundColor3 = Theme.button
    minimizeBtn.BackgroundTransparency = Theme.transparency
    minimizeBtn.TextColor3 = Theme.text
    tabButtons.BackgroundColor3 = Theme.tabBg
    tabButtons.BackgroundTransparency = Theme.transparency

    -- Recolor all descendants by role attributes if set
    for _,inst in ipairs(screenGui:GetDescendants()) do
        if inst:IsA("TextButton") or inst:IsA("TextLabel") then
            if inst:GetAttribute("role") == "btn" then
                inst.BackgroundColor3 = Theme.button
                inst.BackgroundTransparency = Theme.transparency
                inst.TextColor3 = Theme.text
            elseif inst:GetAttribute("role") == "title" then
                inst.BackgroundColor3 = Theme.header
                inst.BackgroundTransparency = Theme.transparency
                inst.TextColor3 = Theme.text
            elseif inst:GetAttribute("role") == "panel" then
                inst.BackgroundColor3 = Theme.panel
                inst.BackgroundTransparency = Theme.transparency
                if inst:IsA("TextLabel") then inst.TextColor3 = Theme.text end
            elseif inst:GetAttribute("role") == "accent" then
                inst.BackgroundColor3 = Theme.accent
                inst.BackgroundTransparency = Theme.transparency
                if inst:IsA("TextLabel") then inst.TextColor3 = Theme.text end
            end
        elseif inst:IsA("Frame") then
            if inst:GetAttribute("role") == "panel" then
                inst.BackgroundColor3 = Theme.panel
                inst.BackgroundTransparency = Theme.transparency
            elseif inst:GetAttribute("role") == "btn" then
                inst.BackgroundColor3 = Theme.button
                inst.BackgroundTransparency = Theme.transparency
            end
        end
    end

    -- Floating buttons
    for _,b in pairs(floatingButtons) do
        b.BackgroundColor3 = Theme.button
        b.TextColor3 = Theme.text
        b.BackgroundTransparency = Theme.transparency
    end
end

local function cloneTheme(t) -- shallow copy
    local r = {}
    for k,v in pairs(t) do r[k]=v end
    return r
end

local function setPreset(name)
    local preset = Presets[name]
    if not preset then return end
    Theme = cloneTheme(preset)
    applyTheme()
end

local function mkButton(parent, text, role)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 28)
    b.BackgroundColor3 = Theme.button
    b.BackgroundTransparency = Theme.transparency
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Theme.text
    b.Parent = parent
    if role then b:SetAttribute("role", role) end
    return b
end

local function mkPanel(parent, size, pos)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1, -8, 1, -8)
    f.Position = pos or UDim2.new(0, 4, 0, 4)
    f.BackgroundColor3 = Theme.panel
    f.BackgroundTransparency = Theme.transparency
    f.BorderSizePixel = 0
    f.Parent = parent
    f:SetAttribute("role", "panel")
    return f
end

local function mkLabel(parent, text)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.TextColor3 = Theme.text
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local function mkSlider(parent, title, minVal, maxVal, startVal, onChange)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 48)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = mkLabel(container, string.format("%s: %d", title, startVal))
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -8, 0, 8)
    bar.Position = UDim2.new(0, 4, 0, 28)
    bar.BackgroundColor3 = Theme.button
    bar.BackgroundTransparency = Theme.transparency
    bar.BorderSizePixel = 0
    bar.Parent = container

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 20)
    knob.Position = UDim2.new((startVal-minVal)/(maxVal-minVal), -6, -0.75, 0)
    knob.BackgroundColor3 = Theme.accent
    knob.BorderSizePixel = 0
    knob.Parent = bar
    knob:SetAttribute("role","accent")
    knob.Active = true
    knob.Draggable = true

    local function setValByRatio(r)
        r = math.clamp(r,0,1)
        local val = math.floor(minVal + r*(maxVal-minVal) + 0.5)
        knob.Position = UDim2.new(r, -6, -0.75, 0)
        label.Text = string.format("%s: %d", title, val)
        if onChange then onChange(val) end
    end

    knob:GetPropertyChangedSignal("Position"):Connect(function()
        local r = math.clamp(knob.Position.X.Scale, 0, 1)
        setValByRatio(r)
    end)

    return {
        setValue = function(v)
            local r = (v-minVal)/(maxVal-minVal)
            setValByRatio(r)
        end
    }
end

local function mkToggle(parent, labelText, startOn, onChange)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.new(1, -8, 0, 28)
    holder.Parent = parent

    local btn = mkButton(holder, labelText .. ": " .. (startOn and "ON" or "OFF"), "btn")
    btn.Size = UDim2.new(0, 200, 1, 0)
    btn.MouseButton1Click:Connect(function()
        startOn = not startOn
        btn.Text = labelText .. ": " .. (startOn and "ON" or "OFF")
        if onChange then onChange(startOn) end
    end)

    return {
        set = function(v)
            startOn = v
            btn.Text = labelText .. ": " .. (startOn and "ON" or "OFF")
        end
    }
end

-- Tabs + Pages
local pages = {}
local tabOrder = {"Teleport","WalkSpeed","Phones","Settings"}

local function createPage(name)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = pagesFrame
    pages[name] = page

    local tab = mkButton(tabButtons, name, "btn")
    tab.MouseButton1Click:Connect(function()
        for n, p in pairs(pages) do p.Visible = (n == name) end
    end)

    return page
end

-- Initialize pages
createPage("Teleport")
createPage("WalkSpeed")
createPage("Phones")
createPage("Settings")
pages["Teleport"].Visible = true

-- === Teleport Page ===
do
    local page = pages.Teleport
    local panel = mkPanel(page, UDim2.new(1, -8, 1, -8), UDim2.new(0,4,0,4))

    -- Left controls
    local left = Instance.new("Frame")
    left.Size = UDim2.new(0, 180, 1, -8)
    left.Position = UDim2.new(0, 8, 0, 4)
    left.BackgroundTransparency = 1
    left.Parent = panel

    local saveBtn = mkButton(left, "Сохранить точку", "btn")
    saveBtn.Position = UDim2.new(0,0,0,0)
    saveBtn.MouseButton1Click:Connect(function()
        savedPos = hrp.CFrame
    end)

    local toPointBtn = mkButton(left, "ТП к точке", "btn")
    toPointBtn.Position = UDim2.new(0,0,0,32)
    toPointBtn.MouseButton1Click:Connect(function()
        hrp.CFrame = savedPos
    end)

    local forwardBtn = mkButton(left, "ТП вперед (20)", "btn")
    forwardBtn.Position = UDim2.new(0,0,0,64)
    forwardBtn.MouseButton1Click:Connect(function()
        hrp.CFrame = hrp.CFrame * CFrame.new(0,0,-20)
    end)

    -- Players list
    local right = Instance.new("Frame")
    right.Size = UDim2.new(1, -200, 1, -8)
    right.Position = UDim2.new(0, 192, 0, 4)
    right.BackgroundTransparency = 1
    right.Parent = panel

    local playersList = Instance.new("ScrollingFrame")
    playersList.Size = UDim2.new(1, 0, 1, 0)
    playersList.CanvasSize = UDim2.new(0,0,0,0)
    playersList.ScrollBarThickness = 6
    playersList.BackgroundColor3 = Theme.panel
    playersList.BackgroundTransparency = Theme.transparency
    playersList.BorderSizePixel = 0
    playersList.Parent = right
    playersList:SetAttribute("role","panel")

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0,4)
    listLayout.Parent = playersList

    local function refreshPlayers()
        for _,c in ipairs(playersList:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local btn = mkButton(playersList, "ТП к "..p.Name, "btn")
                btn.Size = UDim2.new(1, -8, 0, 28)
                btn.MouseButton1Click:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        hrp.CFrame = p.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
                    end
                end)
            end
        end
        playersList.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 8)
    end

    refreshPlayers()
    Players.PlayerAdded:Connect(refreshPlayers)
    Players.PlayerRemoving:Connect(refreshPlayers)
end

-- === WalkSpeed Page ===
-- WalkSpeed Tab
local WalkspeedTab = Instance.new("ScrollingFrame")
WalkspeedTab.Name = "WalkspeedTab"
WalkspeedTab.Parent = Tabs
WalkspeedTab.Size = UDim2.new(1,0,1,0)
WalkspeedTab.CanvasSize = UDim2.new(0,0,0,0)
WalkspeedTab.ScrollBarThickness = 6
WalkspeedTab.Visible = false

-- WalkSpeed slider
local WalkSlider = Instance.new("TextButton")
WalkSlider.Size = UDim2.new(0, 200, 0, 40)
WalkSlider.Position = UDim2.new(0, 10, 0, 10)
WalkSlider.Text = "WalkSpeed: "..game.Players.LocalPlayer.Character.Humanoid.WalkSpeed
WalkSlider.Parent = WalkspeedTab

WalkSlider.MouseButton1Click:Connect(function()
    local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = hum.WalkSpeed == 16 and 50 or 16
        WalkSlider.Text = "WalkSpeed: "..hum.WalkSpeed
    end
end)

-- Anti-Ragdoll toggle
local AntiRagdoll = Instance.new("TextButton")
AntiRagdoll.Size = UDim2.new(0, 200, 0, 40)
AntiRagdoll.Position = UDim2.new(0, 10, 0, 60)
AntiRagdoll.Text = "Anti-Ragdoll: OFF"
AntiRagdoll.Parent = WalkspeedTab

local ragdollEnabled = false

AntiRagdoll.MouseButton1Click:Connect(function()
    ragdollEnabled = not ragdollEnabled
    AntiRagdoll.Text = ragdollEnabled and "Anti-Ragdoll: ON" or "Anti-Ragdoll: OFF"

    if ragdollEnabled then
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.StateChanged:Connect(function(_, newState)
                if ragdollEnabled and newState == Enum.HumanoidStateType.Ragdoll then
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        end
    end
end)


-- === Phones Page ===
-- Two modes: "under" expand/collapse OR "side" details panel
local phonesExpanded = {} -- remember expanded state by UserId for "under" mode

local function getPlayerPhones(plr)
    local list = {}
    local stats = plr:FindFirstChild("Stats")
    if stats and stats:FindFirstChild("PlotNPC") then
        for _,obj in ipairs(stats.PlotNPC:GetChildren()) do
            if obj:IsA("ValueBase") then
                table.insert(list, tostring(obj.Value))
            end
        end
    end
    table.sort(list, function(a,b) return tostring(a) < tostring(b) end)
    return list
end

local function buildPhonesUnder(panel)
    panel:ClearAllChildren()

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -8, 1, -8)
    holder.Position = UDim2.new(0,4,0,4)
    holder.BackgroundTransparency = 1
    holder.Parent = panel

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.ScrollBarThickness = 6
    scroll.BackgroundColor3 = Theme.panel
    scroll.BackgroundTransparency = Theme.transparency
    scroll.BorderSizePixel = 0
    scroll.Parent = holder
    scroll:SetAttribute("role","panel")

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0,4)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    for _,pl in ipairs(Players:GetPlayers()) do
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, -8, 0, 28)
        container.BackgroundColor3 = Theme.button
        container.BackgroundTransparency = Theme.transparency
        container.BorderSizePixel = 0
        container.Parent = scroll
        container:SetAttribute("role","btn")

        local foldBtn = Instance.new("TextButton")
        foldBtn.Size = UDim2.new(1, 0, 1, 0)
        foldBtn.BackgroundTransparency = 1
        local opened = phonesExpanded[pl.UserId] or false
        foldBtn.Text = (opened and "▼ " or "▶ ") .. pl.Name
        foldBtn.TextColor3 = Theme.text
        foldBtn.TextXAlignment = Enum.TextXAlignment.Left
        foldBtn.Parent = container

        local phonesFrame = Instance.new("Frame")
        phonesFrame.BackgroundColor3 = Theme.panel
        phonesFrame.BackgroundTransparency = Theme.transparency
        phonesFrame.BorderSizePixel = 0
        phonesFrame.Parent = scroll
        phonesFrame.Visible = opened
        phonesFrame.Size = UDim2.new(1, -16, 0, 0)
        phonesFrame.Position = UDim2.new(0,8,0,0)
        phonesFrame:SetAttribute("role","panel")

        local phonesLayout = Instance.new("UIListLayout")
        phonesLayout.Padding = UDim.new(0,2)
        phonesLayout.SortOrder = Enum.SortOrder.LayoutOrder
        phonesLayout.Parent = phonesFrame

        local function fillPhones()
            for _,c in ipairs(phonesFrame:GetChildren()) do
                if c:IsA("TextLabel") then c:Destroy() end
            end
            local list = getPlayerPhones(pl)
            if #list == 0 then
                local lbl = mkLabel(phonesFrame, "Телефонов нет")
                lbl.Size = UDim2.new(1, -8, 0, 20)
            else
                for _,ph in ipairs(list) do
                    local lbl = mkLabel(phonesFrame, ph)
                    lbl.Size = UDim2.new(1, -8, 0, 20)
                end
            end
            -- auto height:
            task.wait()
            phonesFrame.Size = UDim2.new(1, -16, 0, phonesLayout.AbsoluteContentSize.Y + 6)
            scroll.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 8)
        end

        fillPhones()

        foldBtn.MouseButton1Click:Connect(function()
            opened = not opened
            phonesExpanded[pl.UserId] = opened
            foldBtn.Text = (opened and "▼ " or "▶ ") .. pl.Name
            phonesFrame.Visible = opened
            if opened then
                fillPhones()
            else
                phonesFrame.Size = UDim2.new(1, -16, 0, 0)
                scroll.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 8)
            end
        end)
    end

    scroll.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 8)
end

local function buildPhonesSide(panel)
    panel:ClearAllChildren()

    local left = mkPanel(panel, UDim2.new(0, 220, 1, -8), UDim2.new(0,4,0,4))
    local right = mkPanel(panel, UDim2.new(1, -232, 1, -8), UDim2.new(0,228,0,4))

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -8, 1, -8)
    list.Position = UDim2.new(0,4,0,4)
    list.CanvasSize = UDim2.new(0,0,0,0)
    list.ScrollBarThickness = 6
    list.BackgroundTransparency = 1
    list.Parent = left

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0,4)
    listLayout.Parent = list

    local phonesPanel = Instance.new("ScrollingFrame")
    phonesPanel.Size = UDim2.new(1, -8, 1, -8)
    phonesPanel.Position = UDim2.new(0,4,0,4)
    phonesPanel.CanvasSize = UDim2.new(0,0,0,0)
    phonesPanel.ScrollBarThickness = 6
    phonesPanel.BackgroundTransparency = 1
    phonesPanel.Parent = right

    local phonesLayout = Instance.new("UIListLayout")
    phonesLayout.Padding = UDim.new(0,2)
    phonesLayout.Parent = phonesPanel

    local function showPhones(pl)
        for _,c in ipairs(phonesPanel:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        local listPh = getPlayerPhones(pl)
        local title = mkLabel(phonesPanel, "Телефоны: "..pl.Name)
        title.Size = UDim2.new(1, -8, 0, 20)

        if #listPh == 0 then
            local l = mkLabel(phonesPanel, "Нет телефонов")
            l.Size = UDim2.new(1, -8, 0, 20)
        else
            for _,ph in ipairs(listPh) do
                local l = mkLabel(phonesPanel, ph)
                l.Size = UDim2.new(1, -8, 0, 20)
            end
        end
        task.wait()
        phonesPanel.CanvasSize = UDim2.new(0,0,0,phonesLayout.AbsoluteContentSize.Y + 8)
    end

    for _,pl in ipairs(Players:GetPlayers()) do
        local btn = mkButton(list, pl.Name, "btn")
        btn.MouseButton1Click:Connect(function()
            showPhones(pl)
        end)
    end

    list.CanvasSize = UDim2.new(0,0,0,listLayout.AbsoluteContentSize.Y + 8)
end

do
    local page = pages.Phones
    local panel = mkPanel(page, UDim2.new(1, -8, 1, -8), UDim2.new(0,4,0,4))
    page:SetAttribute("phones_panel", panel) -- store ref for refresh

    local function rebuild()
        local p = page:GetAttribute("phones_panel")
        if not p then return end
        if phonesViewStyle == "under" then
            buildPhonesUnder(p)
        else
            buildPhonesSide(p)
        end
    end

    page:SetAttribute("rebuild_fn_set", true)
    page:SetAttribute("rebuild", rebuild)

    rebuild()

    -- Auto refresh phones every 3 seconds
    task.spawn(function()
        while page and page.Parent do
            task.wait(3)
            if phonesViewStyle == "under" then
                -- preserve expanded state and refresh values
                local panelRef = page:GetAttribute("phones_panel")
                if panelRef then buildPhonesUnder(panelRef) end
            else
                local panelRef = page:GetAttribute("phones_panel")
                if panelRef then buildPhonesSide(panelRef) end
            end
        end
    end)
end

-- === Settings Page ===
do
    local page = pages.Settings
    local panel = mkPanel(page, UDim2.new(1, -8, 1, -8), UDim2.new(0,4,0,4))

    -- Preset themes
    local themeLabel = mkLabel(panel, "Тема:")
    themeLabel.Size = UDim2.new(0, 80, 0, 20)
    themeLabel.Position = UDim2.new(0,8,0,8)

    local themeBtn = mkButton(panel, "Dark", "btn")
    themeBtn.Size = UDim2.new(0, 120, 0, 28)
    themeBtn.Position = UDim2.new(0,92,0,4)

    local presetList = {"Dark","Light","Neon","Red","Glass"}
    local presetIndex = 1
    themeBtn.Text = presetList[presetIndex]
    themeBtn.MouseButton1Click:Connect(function()
        presetIndex = presetIndex % #presetList + 1
        themeBtn.Text = presetList[presetIndex]
        setPreset(presetList[presetIndex])
    end)

    -- Transparency slider (0..80%)
    local transpSlider = mkSlider(panel, "Прозрачность %", 0, 80, math.floor(Theme.transparency*100), function(val)
        Theme.transparency = math.clamp(val/100, 0, 0.97)
        applyTheme()
    end)

    -- Scale slider (50..150%)
    local scaleSlider = mkSlider(panel, "Масштаб %", 50, 150, math.floor(uiScale.Scale*100), function(val)
        uiScale.Scale = val/100
    end)

    -- Custom colors (bg & button) — простые 3x RGB ползунки для каждого
    local function colorToRGB(c) return math.floor(c.R*255+0.5), math.floor(c.G*255+0.5), math.floor(c.B*255+0.5) end
    local function applyBG(r,g,b) Theme.bg = Color3.fromRGB(r,g,b); applyTheme() end
    local function applyBTN(r,g,b) Theme.button = Color3.fromRGB(r,g,b); applyTheme() end

    local br, bgc, bb = colorToRGB(Theme.bg)
    local sr = mkSlider(panel, "BG R", 0, 255, br, function(v) br=v; applyBG(br,bgc,bb) end)
    local sg = mkSlider(panel, "BG G", 0, 255, bgc, function(v) bgc=v; applyBG(br,bgc,bb) end)
    local sb = mkSlider(panel, "BG B", 0, 255, bb, function(v) bb=v; applyBG(br,bgc,bb) end)

    local cr, cg, cb = colorToRGB(Theme.button)
    local sbr = mkSlider(panel, "BTN R", 0, 255, cr, function(v) cr=v; applyBTN(cr,cg,cb) end)
    local sbg = mkSlider(panel, "BTN G", 0, 255, cg, function(v) cg=v; applyBTN(cr,cg,cb) end)
    local sbb = mkSlider(panel, "BTN B", 0, 255, cb, function(v) cb=v; applyBTN(cr,cg,cb) end)

    -- Phones view style toggle
    local styleLabel = mkLabel(panel, "Стиль телефонов:")
    styleLabel.Size = UDim2.new(0, 140, 0, 20)
    styleLabel.Position = UDim2.new(0,8,0,260)

    local styleBtn = mkButton(panel, (phonesViewStyle=="under") and "Под игроком" or "Справа", "btn")
    styleBtn.Size = UDim2.new(0, 140, 0, 28)
    styleBtn.Position = UDim2.new(0,152,0,256)
    styleBtn.MouseButton1Click:Connect(function()
        phonesViewStyle = (phonesViewStyle=="under") and "side" or "under"
        styleBtn.Text = (phonesViewStyle=="under") and "Под игроком" or "Справа"
        -- rebuild phones page
        local phPage = pages.Phones
        local p = phPage:GetAttribute("phones_panel")
        if p then
            if phonesViewStyle == "under" then buildPhonesUnder(p) else buildPhonesSide(p) end
        end
    end)

    -- Floating buttons toggle
    local floatToggle = mkButton(panel, "Floating TP: OFF", "btn")
    floatToggle.Size = UDim2.new(0, 160, 0, 28)
    floatToggle.Position = UDim2.new(0,8,0,296)
    floatToggle.MouseButton1Click:Connect(function()
        floatingEnabled = not floatingEnabled
        floatToggle.Text = "Floating TP: " .. (floatingEnabled and "ON" or "OFF")
        for _,btn in pairs(floatingButtons) do btn.Visible = floatingEnabled end
    end)

    -- Key rebinds
    local kLabel = mkLabel(panel, "Бинды:")
    kLabel.Size = UDim2.new(0, 80, 0, 20)
    kLabel.Position = UDim2.new(0,190,0,296)

    local rebindPoint = mkButton(panel, "ТП к точке: " .. bindToPoint.Name, "btn")
    rebindPoint.Size = UDim2.new(0, 160, 0, 28)
    rebindPoint.Position = UDim2.new(0,260,0,296)
    rebindPoint.MouseButton1Click:Connect(function()
        waitingForBind = "point"
        rebindPoint.Text = "Нажми клавишу..."
    end)

    local rebindForward = mkButton(panel, "ТП вперед: " .. bindForward.Name, "btn")
    rebindForward.Size = UDim2.new(0, 160, 0, 28)
    rebindForward.Position = UDim2.new(0,260,0,328)
    rebindForward.MouseButton1Click:Connect(function()
        waitingForBind = "forward"
        rebindForward.Text = "Нажми клавишу..."
    end)
end

-- Floating Buttons (created once; visibility controlled in Settings)
local function createFloatingButtons()
    local function makeFloat(name, text, onClick, pos)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 120, 0, 40)
        b.Position = pos
        b.Text = text
        b.BackgroundColor3 = Theme.button
        b.BackgroundTransparency = Theme.transparency
        b.TextColor3 = Theme.text
        b.BorderSizePixel = 0
        b.Active = true
        b.Draggable = true
        b.Visible = false
        b.Parent = screenGui
        b.MouseButton1Click:Connect(onClick)
        floatingButtons[name] = b
        return b
    end

    makeFloat("Point", "ТП к точке", function()
        hrp.CFrame = savedPos
    end, UDim2.new(0.8, 0, 0.5, 0))

    makeFloat("Forward", "ТП вперед", function()
        hrp.CFrame = hrp.CFrame * CFrame.new(0,0,-20)
    end, UDim2.new(0.8, 0, 0.58, 0))
end
createFloatingButtons()

-- Key input handling (rebind + actions)
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if waitingForBind and input.UserInputType == Enum.UserInputType.Keyboard then
        if waitingForBind == "point" then
            bindToPoint = input.KeyCode
            -- update button text in settings
            for _,d in ipairs(pages.Settings:GetDescendants()) do
                if d:IsA("TextButton") and d.Text:find("Нажми клавишу") then
                    if d.Text:find("ТП к точке") or true then
                        -- do nothing
                    end
                end
            end
            for _,d in ipairs(pages.Settings:GetDescendants()) do
                if d:IsA("TextButton") and d.Text:find("Нажми клавишу") then
                    d.Text = "ТП к точке: " .. bindToPoint.Name
                end
            end
        elseif waitingForBind == "forward" then
            bindForward = input.KeyCode
            for _,d in ipairs(pages.Settings:GetDescendants()) do
                if d:IsA("TextButton") and d.Text:find("Нажми клавишу") then
                    -- find which was forward
                end
            end
            -- More robust: search by position text
            for _,d in ipairs(pages.Settings:GetDescendants()) do
                if d:IsA("TextButton") and (d.Text:find("Нажми клавишу") or d.Text:find("ТП вперед")) then
                    if d.AbsolutePosition.Y > (pages.Settings.AbsolutePosition.Y + pages.Settings.AbsoluteSize.Y/2 - 10) then
                        -- not reliable; simpler approach: reset all labels containing "ТП вперед:".
                    end
                end
            end
            -- Reset any button with prefix
            for _,d in ipairs(pages.Settings:GetDescendants()) do
                if d:IsA("TextButton") and d.Text:find("ТП вперед") or (d:IsA("TextButton") and d.Text:find("Нажми клавишу")) then
                    if d.Text:find("ТП вперед") or d.Text:find("Нажми клавишу") then
                        if d.Text:find("ТП к точке") then
                            -- skip
                        else
                            d.Text = "ТП вперед: " .. bindForward.Name
                        end
                    end
                end
            end
        end
        waitingForBind = nil
        return
    end

    if input.KeyCode == bindToPoint then
        hrp.CFrame = savedPos
    elseif input.KeyCode == bindForward then
        hrp.CFrame = hrp.CFrame * CFrame.new(0,0,-20)
    end
end)

-- Minimize toggle
minimizeBtn.MouseButton1Click:Connect(function()
    menuVisible = not menuVisible
    pagesFrame.Visible = menuVisible
    tabButtons.Visible = menuVisible
    if menuVisible then
        minimizeBtn.Text = "-"
        mainFrame.Size = UDim2.new(0, 520, 0, 360)
    else
        minimizeBtn.Text = "+"
        mainFrame.Size = UDim2.new(0, 160, 0, 28)
    end
end)

-- Theme initial apply
applyTheme()