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
