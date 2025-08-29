--// Roblox UI Script with Teleport, WalkSpeed, Phones, Settings
-- Авторская сборка

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- Vars
local wsValue = 16
local infJump = false
local antiRagdoll = false
local savedPos = nil

-- Themes
local Themes = {
    Dark = {bg=Color3.fromRGB(30,30,30), btn=Color3.fromRGB(60,60,60), txt=Color3.new(1,1,1), alpha=0.85},
    Light = {bg=Color3.fromRGB(240,240,240), btn=Color3.fromRGB(200,200,200), txt=Color3.new(0,0,0), alpha=0.9},
    Blue = {bg=Color3.fromRGB(25,25,60), btn=Color3.fromRGB(60,60,140), txt=Color3.new(1,1,1), alpha=0.85},
}
local Theme = Themes.Dark

-- UI Helpers
local function mkPanel(parent, size, pos)
    local f = Instance.new("Frame", parent)
    f.Size, f.Position = size, pos
    f.BackgroundColor3 = Theme.bg
    f.BackgroundTransparency = 1 - Theme.alpha
    f.BorderSizePixel = 0
    return f
end

local function mkLabel(parent, text)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1,0,0,20)
    l.BackgroundTransparency = 1
    l.TextColor3 = Theme.txt
    l.Text = text
    l.Font, l.TextSize = Enum.Font.SourceSans, 18
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local function mkButton(parent, text, style)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0,120,0,28)
    b.BackgroundColor3 = Theme.btn
    b.TextColor3 = Theme.txt
    b.Text = text
    b.Font, b.TextSize = Enum.Font.SourceSans, 18
    b.AutoButtonColor = true
    return b
end

local function mkSlider(parent, label, min, max, val, callback)
    local holder = Instance.new("Frame", parent)
    holder.Size, holder.BackgroundTransparency = UDim2.new(1,-8,0,48), 1

    local title = mkLabel(holder, label..": "..val)
    title.Size = UDim2.new(1,0,0,20)

    local bar = Instance.new("Frame", holder)
    bar.Size, bar.Position = UDim2.new(1,-20,0,8), UDim2.new(0,10,0,28)
    bar.BackgroundColor3, bar.BorderSizePixel = Theme.btn, 0

    local fill = Instance.new("Frame", bar)
    fill.Size, fill.BackgroundColor3, fill.BorderSizePixel = UDim2.new((val-min)/(max-min),0,1,0), Theme.txt, 0

    local dragging = false
    bar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            val = math.floor(min + rel*(max-min))
            fill.Size = UDim2.new(rel,0,1,0)
            title.Text = label..": "..val
            callback(val)
        end
    end)

    return {setValue=function(v)
        val=v
        local rel=(v-min)/(max-min)
        fill.Size=UDim2.new(rel,0,1,0)
        title.Text=label..": "..v
    end}
end

-- Main ScreenGui
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", sg)
mainFrame.Size, mainFrame.Position = UDim2.new(0,500,0,300), UDim2.new(0.5,-250,0.5,-150)
mainFrame.BackgroundColor3, mainFrame.BackgroundTransparency, mainFrame.BorderSizePixel = Theme.bg, 1-Theme.alpha, 0
mainFrame.Active, mainFrame.Draggable = true, true

-- Tabs
local tabs = Instance.new("Frame", mainFrame)
tabs.Size = UDim2.new(0,100,1,0)
tabs.BackgroundTransparency = 1

local pages = {}
local function createPage(name)
    local btn = mkButton(tabs,name,"tab")
    btn.Size=UDim2.new(1,0,0,28)
    btn.Position=UDim2.new(0,0,0,#tabs:GetChildren()*30)
    local page=Instance.new("Frame",mainFrame)
    page.Size, page.Position, page.Visible, page.BackgroundTransparency = UDim2.new(1,-100,1,0), UDim2.new(0,100,0,0), false,1
    pages[name]=page
    btn.MouseButton1Click:Connect(function()
        for n,p in pairs(pages)do p.Visible=(n==name)end
    end)
    return page
end

-- === Teleport Page ===
do
    local page=createPage("Teleport")
    local panel=mkPanel(page,UDim2.new(1,-8,1,-8),UDim2.new(0,4,0,4))

    local saveBtn=mkButton(panel,"Save Point")
    saveBtn.Position=UDim2.new(0,8,0,8)
    saveBtn.MouseButton1Click:Connect(function() savedPos=hrp.Position end)

    local tpBtn=mkButton(panel,"TP to Point")
    tpBtn.Position=UDim2.new(0,8,0,44)
    tpBtn.MouseButton1Click:Connect(function() if savedPos then hrp.CFrame=CFrame.new(savedPos) end end)

    -- клавиши по умолчанию
    local forwardKey, backKey = Enum.KeyCode.B, Enum.KeyCode.N
    UIS.InputBegan:Connect(function(i,g)
        if g then return end
        if i.KeyCode==forwardKey then hrp.CFrame=hrp.CFrame+hrp.CFrame.LookVector*10 end
        if i.KeyCode==backKey and savedPos then hrp.CFrame=CFrame.new(savedPos) end
    end)
end

-- === WalkSpeed Page ===
do
    local page=createPage("WalkSpeed")
    local panel=mkPanel(page,UDim2.new(1,-8,1,-8),UDim2.new(0,4,0,4))

    local wsLabel=mkLabel(panel,"WalkSpeed: "..wsValue)
    wsLabel.Position=UDim2.new(0,8,0,8)

    local slider=mkSlider(panel,"WalkSpeed",16,100,wsValue,function(v)
        wsValue=v
        if humanoid then humanoid.WalkSpeed=v end
        wsLabel.Text="WalkSpeed: "..v
    end)

    local reset=mkButton(panel,"Reset WalkSpeed")
    reset.Position=UDim2.new(0,8,0,84)
    reset.MouseButton1Click:Connect(function()
        wsValue=16
        if humanoid then humanoid.WalkSpeed=16 end
        wsLabel.Text="WalkSpeed: 16"
        slider.setValue(16)
    end)

    local infBtn=mkButton(panel,"Infinite Jump: OFF")
    infBtn.Position=UDim2.new(0,8,0,120)
    infBtn.MouseButton1Click:Connect(function()
        infJump=not infJump
        infBtn.Text="Infinite Jump: "..(infJump and "ON" or "OFF")
    end)
    UIS.JumpRequest:Connect(function() if infJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end end)

    local arBtn=mkButton(panel,"Anti-Ragdoll: OFF")
    arBtn.Position=UDim2.new(0,8,0,156)
    arBtn.MouseButton1Click:Connect(function()
        antiRagdoll=not antiRagdoll
        arBtn.Text="Anti-Ragdoll: "..(antiRagdoll and "ON" or "OFF")
    end)
    humanoid.StateChanged:Connect(function(_,s)
        if antiRagdoll and (s==Enum.HumanoidStateType.Ragdoll or s==Enum.HumanoidStateType.FallingDown) then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end)
end

-- === Phones Page ===
do
    local page=createPage("Phones")
    local panel=mkPanel(page,UDim2.new(1,-8,1,-8),UDim2.new(0,4,0,4))
    local list=Instance.new("ScrollingFrame",panel)
    list.Size, list.CanvasSize, list.ScrollBarThickness = UDim2.new(1,0,1,0), UDim2.new(), 6
    list.BackgroundTransparency=1

    local function refresh()
        list:ClearAllChildren()
        local y=0
        for _,plr in ipairs(Players:GetPlayers()) do
            local btn=mkButton(list,plr.Name)
            btn.Position=UDim2.new(0,0,0,y)
            y=y+32
            local open=false
            btn.MouseButton1Click:Connect(function()
                open=not open
                for _,c in pairs(list:GetChildren()) do
                    if c:IsA("TextLabel") and c.Name=="Phone"..plr.Name then c:Destroy() end
                end
                if open then
                    for i=1,3 do
                        local phone=mkLabel(list,"Phone"..i.."_"..plr.Name)
                        phone.Name="Phone"..plr.Name
                        phone.Position=UDim2.new(0,20,0,y)
                        y=y+20
                    end
                end
            end)
        end
        list.CanvasSize=UDim2.new(0,0,0,y)
    end
    refresh()
    game:GetService("RunService").Stepped:Connect(refresh)
end

-- === Settings Page ===
do
    local page=createPage("Settings")
    local panel=mkPanel(page,UDim2.new(1,-8,1,-8),UDim2.new(0,4,0,4))

    mkLabel(panel,"Theme:")
    local y=24
    for name,_ in pairs(Themes) do
        local btn=mkButton(panel,name)
        btn.Position=UDim2.new(0,8,0,y)
        y=y+32
        btn.MouseButton1Click:Connect(function() Theme=Themes[name] end)
    end
end

-- default open Teleport
pages.Teleport.Visible=true
