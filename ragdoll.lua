-- Anti-Ragdoll Script (отдельный)
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

-- GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local btn = Instance.new("TextButton", screenGui)
btn.Size = UDim2.new(0, 200, 0, 40)
btn.Position = UDim2.new(0, 20, 0, 200)
btn.Text = "Anti-Ragdoll: OFF"
btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
btn.TextColor3 = Color3.fromRGB(255,255,255)

local enabled = false
btn.MouseButton1Click:Connect(function()
    enabled = not enabled
    btn.Text = "Anti-Ragdoll: "..(enabled and "ON" or "OFF")
end)

-- проверка ragdoll состояния
local function isRagdolled()
    if not character or not character.Parent then return false end
    for _, v in pairs(character:GetDescendants()) do
        if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
            return true
        end
    end
    return false
end

-- обработка ввода (толкания)
UIS.InputBegan:Connect(function(input, gp)
    if not enabled or gp or not isRagdolled() then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local dir
        if input.KeyCode == Enum.KeyCode.W then
            dir = hrp.CFrame.LookVector
        elseif input.KeyCode == Enum.KeyCode.S then
            dir = -hrp.CFrame.LookVector
        elseif input.KeyCode == Enum.KeyCode.A then
            dir = -hrp.CFrame.RightVector
        elseif input.KeyCode == Enum.KeyCode.D then
            dir = hrp.CFrame.RightVector
        end
        if dir then
            hrp.Velocity = dir * 50 + Vector3.new(0,20,0) -- толчок + подлет
        end
    end
end)

-- постоянное приподнятие
RS.Stepped:Connect(function()
    if enabled and isRagdolled() and hrp then
        -- Лёгкое поднятие вверх
        hrp.Velocity = Vector3.new(hrp.Velocity.X, 10, hrp.Velocity.Z)
    end
end)
