-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local hrp = lp.Character and lp.Character:WaitForChild("HumanoidRootPart")

-- UI
local ScreenGui = Instance.new("ScreenGui", lp.PlayerGui)
ScreenGui.ResetOnSpawn = false

-- Main Frame
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.Active = true
MainFrame.Draggable = true

-- UI Scaling
local UIScale = Instance.new("UIScale", MainFrame)
UIScale.Scale = 1

-- Tabs
local TabButtons = Instance.new("Frame", MainFrame)
TabButtons.Size = UDim2.new(1,0,0,30)
TabButtons.BackgroundTransparency = 1

local Tabs = Instance.new("Frame", MainFrame)
Tabs.Position = UDim2.new(0,0,0,30)
Tabs.Size = UDim2.new(1,0,1,-30)
Tabs.BackgroundTransparency = 1

-- Functions
local function createTab(name)
    local tab = Instance.new("ScrollingFrame", Tabs)
    tab.Name = name
    tab.Size = UDim2.new(1,0,1,0)
    tab.CanvasSize = UDim2.new(0,0,0,0)
    tab.ScrollBarThickness = 6
    tab.Visible = false
    return tab
end

local function createButton(tab, text, pos, callback)
    local b = Instance.new("TextButton", tab)
    b.Size = UDim2.new(0,200,0,40)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- Tab buttons
local function makeTabButton(name, index)
    local btn = Instance.new("TextButton", TabButtons)
    btn.Size = UDim2.new(0,100,1,0)
    btn.Position = UDim2.new(0,(index-1)*100,0,0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        for _,t in pairs(Tabs:GetChildren()) do
            if t:IsA("ScrollingFrame") then
                t.Visible = false
            end
        end
        Tabs:FindFirstChild(name.."Tab").Visible = true
    end)
end

-- Tabs
local TeleportTab = createTab("TeleportTab")
local WalkspeedTab = createTab("WalkspeedTab")
local PhonesTab = createTab("PhonesTab")
local SettingsTab = createTab("SettingsTab")

makeTabButton("Teleport",1)
makeTabButton("Walk/Anti",2)
makeTabButton("Phones",3)
makeTabButton("Settings",4)

TeleportTab.Visible = true

-- TELEPORT TAB
local savedPos = nil
createButton(TeleportTab,"Save Point",UDim2.new(0,10,0,10),function()
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        savedPos = lp.Character.HumanoidRootPart.CFrame
    end
end)

createButton(TeleportTab,"TP to Saved",UDim2.new(0,10,0,60),function()
    if savedPos and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.CFrame = savedPos
    end
end)

-- Teleport to players
local y = 120
for _,plr in pairs(Players:GetPlayers()) do
    if plr ~= lp then
        local btn = createButton(TeleportTab,"TP to "..plr.Name,UDim2.new(0,10,0,y),function()
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                lp.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(2,0,0)
            end
        end)
        y = y + 50
    end
end

-- WALK/ANTI TAB
local hum = lp.Character and lp.Character:WaitForChild("Humanoid")

local WalkButton = createButton(WalkspeedTab,"WalkSpeed: "..(hum and hum.WalkSpeed or 16),UDim2.new(0,10,0,10),function()
    if hum then
        hum.WalkSpeed = (hum.WalkSpeed==16 and 50 or 16)
        WalkButton.Text = "WalkSpeed: "..hum.WalkSpeed
    end
end)

local ragdollEnabled = false
local AntiRagdoll = createButton(WalkspeedTab,"Anti-Ragdoll: OFF",UDim2.new(0,10,0,60),function()
    ragdollEnabled = not ragdollEnabled
    AntiRagdoll.Text = ragdollEnabled and "Anti-Ragdoll: ON" or "Anti-Ragdoll: OFF"
end)

RunService.Stepped:Connect(function()
    if ragdollEnabled and lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then
        local h = lp.Character:FindFirstChildOfClass("Humanoid")
        if h:GetState() == Enum.HumanoidStateType.Ragdoll then
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)

-- PHONES TAB
local function refreshPhones()
    PhonesTab:ClearAllChildren()
    local listLayout = Instance.new("UIListLayout",PhonesTab)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for _,plr in pairs(Players:GetPlayers()) do
        local playerBtn = Instance.new("TextButton",PhonesTab)
        playerBtn.Size = UDim2.new(1,-10,0,30)
        playerBtn.Text = plr.Name.." [+]"
        playerBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
        playerBtn.TextColor3 = Color3.new(1,1,1)

        local expanded = false
        playerBtn.MouseButton1Click:Connect(function()
            expanded = not expanded
            playerBtn.Text = plr.Name..(expanded and " [-]" or " [+]")

            if expanded then
                for _,obj in pairs(plr:FindFirstChild("stats") and plr.stats:FindFirstChild("PlotNPC") and plr.stats.PlotNPC:GetChildren() or {}) do
                    if obj:IsA("ValueBase") then
                        local phone = Instance.new("TextLabel",PhonesTab)
                        phone.Size = UDim2.new(1,-30,0,25)
                        phone.Text = tostring(obj.Value)
                        phone.BackgroundColor3 = Color3.fromRGB(70,70,70)
                        phone.TextColor3 = Color3.new(1,1,1)
                    end
                end
            else
                for _,c in pairs(PhonesTab:GetChildren()) do
                    if c:IsA("TextLabel") and c.Text ~= nil and c.Text ~= "" and c.Text~=plr.Name then
                        c:Destroy()
                    end
                end
            end
        end)
    end
end
refreshPhones()
Players.PlayerAdded:Connect(refreshPhones)
Players.PlayerRemoving:Connect(refreshPhones)

-- SETTINGS TAB
local bKey, nKey = Enum.KeyCode.B, Enum.KeyCode.N

local function makeSettingButton(text,pos,callback)
    local b = Instance.new("TextButton",SettingsTab)
    b.Size = UDim2.new(0,200,0,40)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(60,60,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.MouseButton1Click:Connect(callback)
    return b
end

local scaleBtn = makeSettingButton("Scale: "..UIScale.Scale,UDim2.new(0,10,0,10),function()
    UIScale.Scale = UIScale.Scale==1 and 1.5 or 1
    scaleBtn.Text = "Scale: "..UIScale.Scale
end)

-- Themes
local themes = {
    Dark = {bg=Color3.fromRGB(30,30,30), btn=Color3.fromRGB(50,50,50)},
    Light = {bg=Color3.fromRGB(200,200,200), btn=Color3.fromRGB(240,240,240)},
    Red = {bg=Color3.fromRGB(60,0,0), btn=Color3.fromRGB(120,0,0)}
}
local currentTheme = "Dark"

local themeBtn = makeSettingButton("Theme: "..currentTheme,UDim2.new(0,10,0,60),function()
    if currentTheme=="Dark" then currentTheme="Light"
    elseif currentTheme=="Light" then currentTheme="Red"
    else currentTheme="Dark" end
    themeBtn.Text="Theme: "..currentTheme
    MainFrame.BackgroundColor3 = themes[currentTheme].bg
    for _,t in pairs(Tabs:GetChildren()) do
        for _,c in pairs(t:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = themes[currentTheme].btn
            end
        end
    end
end)

-- Binds
makeSettingButton("Change B Bind ("..bKey.Name..")",UDim2.new(0,10,0,110),function()
    bKey = nil
    themeBtn.Text = "Press new B key..."
    local conn; conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Keyboard then
            bKey=input.KeyCode
            themeBtn.Text = "Theme: "..currentTheme
            conn:Disconnect()
        end
    end)
end)

makeSettingButton("Change N Bind ("..nKey.Name..")",UDim2.new(0,10,0,160),function()
    nKey = nil
    themeBtn.Text = "Press new N key..."
    local conn; conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Keyboard then
            nKey=input.KeyCode
            themeBtn.Text = "Theme: "..currentTheme
            conn:Disconnect()
        end
    end)
end)

-- B/N actions
UserInputService.InputBegan:Connect(function(input,proc)
    if proc then return end
    if input.KeyCode==bKey then
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = lp.Character.HumanoidRootPart.CFrame + lp.Character.HumanoidRootPart.CFrame.LookVector*10
        end
    elseif input.KeyCode==nKey then
        if savedPos and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = savedPos
        end
    end
end)
