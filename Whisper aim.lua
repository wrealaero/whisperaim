-- Whisper Kit Enhancement Script for Roblox Bedwars
-- Features: Projectile Aimbot, GUI Control Panel, and Overlay System

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Player References
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Configuration
local Config = {
    Enabled = true,
    AimbotEnabled = true,
    OverlayEnabled = true,
    PredictionEnabled = true,
    SilentAim = false,
    AimbotStyle = "Legit",
    NearestVisibleOnly = false,
    
    AimKey = Enum.KeyCode.X,
    ToggleGuiKey = Enum.KeyCode.RightControl,
    
    FOV = 250,
    ShowFOV = true,
    FOVColor = Color3.fromRGB(255, 255, 255),
    
PredictionFactor = 0.165,
HitChance = function()
    return math.clamp(100 - (AimbotTarget and (AimbotTarget.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude / 2 or 50), 50, 100)
end,

TargetPart = "HumanoidRootPart",
    MaxDistance = 150,
    TeamCheck = true,
    
    ESPEnabled = true,
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPTransparency = 0.5,
    
    NotificationsEnabled = true
}

-- Variables
local AimbotTarget = nil
local AimbotActive = false
local GuiVisible = true
local ProjectileSpeed = 100 -- Will be updated based on weapon

-- Create GUI
local WhisperGUI = Instance.new("ScreenGui")
WhisperGUI.Name = "WhisperEnhancedGUI"
WhisperGUI.ResetOnSpawn = false
WhisperGUI.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Position = UDim2.new(0.8, 0, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = WhisperGUI

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = MainFrame.Position
        startMousePos = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.Draggable = false -- Disable default dragging
local dragging, dragInput, startPos, startMousePos

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - startMousePos
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Whisper Kit Enhanced"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 18
TitleText.Font = Enum.Font.SourceSansBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Dragging only through TitleBar
MainFrame.Draggable = false
local dragging, dragInput, startPos, startMousePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startPos = MainFrame.Position
        startMousePos = input.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - startMousePos
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -20, 1, -40)
ContentFrame.Position = UDim2.new(0, 10, 0, 35)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Create Toggle Function
local function CreateToggle(name, default, position, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
    ToggleFrame.Position = position
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = ContentFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 16
    ToggleLabel.Font = Enum.Font.SourceSans
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Name = "Button"
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(0.85, 0, 0.5, -10)
    ToggleButton.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(100, 100, 100)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = ToggleFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "Circle"
    ToggleCircle.Size = UDim2.new(0, 20, 0, 20)
    ToggleCircle.Position = UDim2.new(default and 0.5 or 0, 0, 0, 0)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleButton
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 10)
    UICorner2.Parent = ToggleCircle
    
    local Toggled = default
    
    local function UpdateToggle()
        Toggled = not Toggled
        
        local TargetPosition = Toggled and UDim2.new(0.5, 0, 0, 0) or UDim2.new(0, 0, 0, 0)
        local TargetColor = Toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(100, 100, 100)
        
        TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = TargetPosition}):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
        
        callback(Toggled)
    end
    
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UpdateToggle()
        end
    end)
    
    return {
        SetValue = function(value)
            if value ~= Toggled then
                UpdateToggle()
            end
        end,
        GetValue = function()
            return Toggled
        end
    }
end

-- Create Slider Function
local function CreateSlider(name, min, max, default, position, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name .. "Slider"
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.Position = position
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = ContentFrame
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Name = "Label"
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = name .. ": " .. default
    SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SliderLabel.TextSize = 16
    SliderLabel.Font = Enum.Font.SourceSans
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Name = "Background"
    SliderBackground.Size = UDim2.new(1, 0, 0, 10)
    SliderBackground.Position = UDim2.new(0, 0, 0.6, 0)
    SliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBackground.BorderSizePixel = 0
    SliderBackground.Parent = SliderFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = SliderBackground
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Name = "Fill"
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBackground
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 5)
    UICorner2.Parent = SliderFill
    
    local SliderKnob = Instance.new("Frame")
    SliderKnob.Name = "Knob"
    SliderKnob.Size = UDim2.new(0, 20, 0, 20)
    SliderKnob.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderKnob.BorderSizePixel = 0
    SliderKnob.Parent = SliderBackground
    
    local UICorner3 = Instance.new("UICorner")
    UICorner3.CornerRadius = UDim.new(0, 10)
    UICorner3.Parent = SliderKnob
    
    local Value = default
    
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
        local newValue = math.floor(min + (max - min) * pos)
        
        Value = newValue
        SliderLabel.Text = name .. ": " .. Value
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        SliderKnob.Position = UDim2.new(pos, -10, 0.5, -10)
        
        callback(Value)
    end
    
    local dragging = false
    
    SliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(input)
        end
    end)
    
    SliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
    
    return {
        SetValue = function(newValue)
            Value = math.clamp(newValue, min, max)
            local pos = (Value - min) / (max - min)
            SliderLabel.Text = name .. ": " .. Value
            SliderFill.Size = UDim2.new(pos, 0, 1, 0)
            SliderKnob.Position = UDim2.new(pos, -10, 0.5, -10)
            callback(Value)
        end,
        GetValue = function()
            return Value
        end
    }
end

-- Create GUI Elements
local AimbotToggle = CreateToggle("Aimbot", Config.AimbotEnabled, UDim2.new(0, 0, 0, 0), function(value)
    Config.AimbotEnabled = value
    ShowNotification("Aimbot " .. (value and "Enabled" or "Disabled"))
end)

local SilentAimToggle = CreateToggle("Silent Aim", Config.SilentAim, UDim2.new(0, 0, 0, 35), function(value)
    Config.SilentAim = value
    ShowNotification("Silent Aim " .. (value and "Enabled" or "Disabled"))
end)

local PredictionToggle = CreateToggle("Prediction", Config.PredictionEnabled, UDim2.new(0, 0, 0, 70), function(value)
    Config.PredictionEnabled = value
    ShowNotification("Prediction " .. (value and "Enabled" or "Disabled"))
end)

local TeamCheckToggle = CreateToggle("Team Check", Config.TeamCheck, UDim2.new(0, 0, 0, 105), function(value)
    Config.TeamCheck = value
end)

local ESPToggle = CreateToggle("ESP Overlay", Config.ESPEnabled, UDim2.new(0, 0, 0, 140), function(value)
    Config.ESPEnabled = value
    ShowNotification("ESP " .. (value and "Enabled" or "Disabled"))
end)

local FOVSlider = CreateSlider("FOV", 50, 500, Config.FOV, UDim2.new(0, 0, 0, 175), function(value)
    Config.FOV = value
end)

local HitChanceSlider = CreateSlider("Hit Chance", 0, 100, Config.HitChance, UDim2.new(0, 0, 0, 225), function(value)
    Config.HitChance = value
end)

local PredictionSlider = CreateSlider("Prediction", 0, 300, Config.PredictionFactor * 1000, UDim2.new(0, 0, 0, 275), function(value)
    Config.PredictionFactor = value / 1000
end)

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = Config.ShowFOV
FOVCircle.Radius = Config.FOV
FOVCircle.Thickness = 1
FOVCircle.Transparency = 1
FOVCircle.Color = Config.FOVColor
FOVCircle.Filled = false
FOVCircle.NumSides = 60

-- Notification System
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Name = "NotificationFrame"
NotificationFrame.Size = UDim2.new(0, 250, 0, 0)
NotificationFrame.Position = UDim2.new(0.5, -125, 0.8, 0)
NotificationFrame.BackgroundTransparency = 1
NotificationFrame.Parent = WhisperGUI

function ShowNotification(text, duration)
    if not Config.NotificationsEnabled then return end
    
    duration = duration or 2
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(1, 0, 0, 40)
    Notification.Position = UDim2.new(0, 0, 1, 10)
    Notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Notification.BorderSizePixel = 0
    Notification.Parent = NotificationFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = Notification
    
    local NotificationText = Instance.new("TextLabel")
    NotificationText.Name = "Text"
    NotificationText.Size = UDim2.new(1, -20, 1, 0)
    NotificationText.Position = UDim2.new(0, 10, 0, 0)
    NotificationText.BackgroundTransparency = 1
    NotificationText.Text = text
    NotificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotificationText.TextSize = 16
    NotificationText.Font = Enum.Font.SourceSans
    NotificationText.TextXAlignment = Enum.TextXAlignment.Left
    NotificationText.Parent = Notification
    
    -- Animate in
    TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    
    -- Animate out after duration
    task.delay(duration, function()
        local tween = TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Position = UDim2.new(1, 10, 0, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            Notification:Destroy()
        end)
    end)
end

-- ESP System
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "WhisperESP"
ESPFolder.Parent = game.CoreGui

function CreateESP(player)
    if player == LocalPlayer then return end
    
    local ESP = Instance.new("Folder")
    ESP.Name = player.Name
    ESP.Parent = ESPFolder
    
    local Box = Instance.new("BoxHandleAdornment")
    Box.Name = "Box"
    Box.Size = Vector3.new(4, 5, 4)
    Box.Color3 = Config.ESPColor
    Box.Transparency = Config.ESPTransparency
    Box.AlwaysOnTop = true
    Box.ZIndex = 10
    Box.Adornee = nil
    Box.Parent = ESP
    
    local Tracer = Instance.new("LineHandleAdornment")
    Tracer.Name = "Tracer"
    Tracer.Color3 = Config.ESPColor
    Tracer.Transparency = Config.ESPTransparency
    Tracer.AlwaysOnTop = true
    Tracer.ZIndex = 10
    Tracer.Adornee = workspace.Terrain
    Tracer.Parent = ESP
    
    return ESP
end

function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local esp = ESPFolder:FindFirstChild(player.Name)
            if not esp and Config.ESPEnabled then
                esp = CreateESP(player)
            end
            
            if esp and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local humanoidRootPart = player.Character.HumanoidRootPart
                local isTeammate = Config.TeamCheck and player.Team == LocalPlayer.Team
                
                -- Update ESP elements
                local box = esp:FindFirstChild("Box")
                if box then
                    box.Adornee = isTeammate and nil or humanoidRootPart
                    box.Visible = Config.ESPEnabled and not isTeammate
                end
                
                local tracer = esp:FindFirstChild("Tracer")
                if tracer then
                    tracer.Visible = Config.ESPEnabled and not isTeammate
                    if tracer.Visible then
                        tracer.Length = (humanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                        tracer.CFrame = CFrame.new(Camera.CFrame.Position, humanoidRootPart.Position)
                    end
                end
            end
        end
    end
end

-- Aimbot Functions
function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = Config.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
            
            local targetPart = player.Character:FindFirstChild(Config.TargetPart)
            if not targetPart then continue end
            
            local screenPoint = Camera:WorldToScreenPoint(targetPart.Position)
            local screenDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            
            if screenDistance < shortestDistance then
                local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * Config.MaxDistance)
                local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, player.Character})
                
                if (not Config.NearestVisibleOnly) or (hit and hit:IsDescendantOf(player.Character)) then
                    closestPlayer = player
                    shortestDistance = screenDistance
                end
            end
        end
    end
    
    return closestPlayer
end

function PredictProjectile(targetPosition, targetVelocity)
    if not Config.PredictionEnabled then return targetPosition end
    
    local distance = (targetPosition - Camera.CFrame.Position).Magnitude
    local timeToHit = distance / ProjectileSpeed
    
    
    local gravityEffect = Vector3.new(0, -workspace.Gravity * (timeToHit ^ 2) / 2, 0)
    
    return targetPosition + (targetVelocity * timeToHit * Config.PredictionFactor) + gravityEffect
end

function AimAt(position)
    if not Config.AimbotEnabled or not position then return end
    
    local aimCFrame = CFrame.new(Camera.CFrame.Position, position)
    
    if not Config.SilentAim then
        if Config.AimbotStyle == "Smooth" then
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, 0.12) -- Slower aim
        elseif Config.AimbotStyle == "Legit" then
            Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, 0.2) -- Normal aim
        elseif Config.AimbotStyle == "Rage" then
            Camera.CFrame = aimCFrame -- Instant aim
        end
    end
    
    return aimCFrame
end

-- Hook game's projectile system for silent aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if method == "FireServer" and Config.AimbotEnabled and Config.SilentAim and AimbotTarget and math.random(1, 100) <= Config.HitChance then
        local functionName = self.Name
        
        -- Check if this is a projectile firing remote
        if functionName:lower():find("fire") or functionName:lower():find("projectile") or functionName:lower():find("arrow") or functionName:lower():find("throw") then
            local targetPart = AimbotTarget.Character:FindFirstChild(Config.TargetPart)
            if targetPart then
                local targetVelocity = AimbotTarget.Character.HumanoidRootPart.Velocity
                local predictedPosition = PredictProjectile(targetPart.Position, targetVelocity)
                
                -- Modify firing direction in args
                if #args >= 2 and typeof(args[2]) == "Vector3" then
                    args[2] = (predictedPosition - Camera.CFrame.Position).Unit * (predictedPosition - Camera.CFrame.Position).Magnitude
                end
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    FOVCircle.Radius = Config.FOV
    FOVCircle.Visible = Config.ShowFOV and Config.AimbotEnabled
    
    -- Update ESP
    if Config.ESPEnabled then
        UpdateESP()
    end
    
    -- Update Aimbot
    if Config.AimbotEnabled then
        AimbotTarget = GetClosestPlayerToCursor()
        
        if AimbotTarget and AimbotActive then
            local targetPart = AimbotTarget.Character:FindFirstChild(Config.TargetPart)
            if targetPart then
                local targetVelocity = AimbotTarget.Character.HumanoidRootPart.Velocity
                local predictedPosition = PredictProjectile(targetPart.Position, targetVelocity)
                
                AimAt(predictedPosition)
            end
        end
    end
end)

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Config.AimKey then
        AimbotActive = true
    elseif input.KeyCode == Config.ToggleGuiKey then
        GuiVisible = not GuiVisible
        MainFrame.Visible = GuiVisible
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Config.AimKey then
        AimbotActive = false
    end
end)

-- Detect projectile weapons to update projectile speed
LocalPlayer.Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        -- Try to determine projectile speed based on weapon type
        if child.Name:lower():find("bow") then
            ProjectileSpeed = 100
        elseif child.Name:lower():find("crossbow") then
            ProjectileSpeed = 120
        elseif child.Name:lower():find("snowball") then
            ProjectileSpeed = 70
        elseif child.Name:lower():find("fireball") then
            ProjectileSpeed = 60
        else
            ProjectileSpeed = 100 -- Default
        end
    end
end)

-- Handle character respawning
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    
    newCharacter.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            -- Update projectile speed based on weapon
            if child.Name:lower():find("bow") then
                ProjectileSpeed = 100
            elseif child.Name:lower():find("crossbow") then
                ProjectileSpeed = 120
            elseif child.Name:lower():find("snowball") then
                ProjectileSpeed = 70
            elseif child.Name:lower():find("fireball") then
                ProjectileSpeed = 60
            else
                ProjectileSpeed = 100 -- Default
            end
        end
    end)
end)

-- Initial notifications
ShowNotification("Whisper Kit Enhanced Loaded", 3)
ShowNotification("Press X to activate aimbot", 3)
ShowNotification("Press Right Ctrl to toggle GUI", 3)
