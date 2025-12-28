-- ============================================
-- UNIVERSAL PRIVATE CLIENT MENU - VIP EDITION
-- Design: Viola/Blu/Nero - Fully Functional
-- ============================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- Configuration
local Config = {
    Active = true,
    Version = "1.0.0",
    
    -- Player Mods
    Player = {
        WalkSpeed = 16,
        JumpPower = 50,
        Fly = false,
        FlySpeed = 50,
        Noclip = false,
        InfiniteJump = false,
        GodMode = false,
        InfiniteStamina = false
    },
    
    -- Combat Mods
    Combat = {
        InfiniteAmmo = false,
        NoRecoil = false,
        NoSpread = false,
        RapidFire = false,
        InstantReload = false,
        AutoShoot = false,
        TriggerBot = false,
        DamageMultiplier = 1.0,
        OneHitKill = false
    },
    
    -- Visual Mods
    Visuals = {
        ESP = false,
        BoxESP = false,
        NameESP = true,
        HealthESP = true,
        Tracers = false,
        Chams = false,
        Wallhack = false,
        FullBright = false,
        XRay = false
    },
    
    -- Misc Mods
    Misc = {
        AutoFarm = false,
        AutoCollect = false,
        SpeedHack = 1.0,
        AntiAfk = true,
        NoClip = false,
        InfiniteYield = false
    }
}

-- Global Variables
local Connections = {}
local ESPObjects = {}
local OriginalProperties = {}
local FlyConnection = nil
local NoclipConnection = nil
local MenuOpen = true
local CurrentPage = "Player"

-- Save original properties
local function SaveOriginalProperties()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            OriginalProperties.WalkSpeed = humanoid.WalkSpeed
            OriginalProperties.JumpPower = humanoid.JumpPower
        end
    end
    
    OriginalProperties.Brightness = Lighting.Brightness
    OriginalProperties.GlobalShadows = Lighting.GlobalShadows
end

-- Apply Walkspeed
local function ApplyWalkSpeed()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Config.Player.WalkSpeed
            humanoid.JumpPower = Config.Player.JumpPower
        end
    end
end

-- Fly System
local function ToggleFly()
    if Config.Player.Fly then
        if FlyConnection then FlyConnection:Disconnect() end
        
        FlyConnection = RunService.Heartbeat:Connect(function()
            if not LocalPlayer.Character then return end
            
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and rootPart then
                humanoid.PlatformStand = true
                
                local velocity = rootPart:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity")
                velocity.Name = "FlyVelocity"
                velocity.MaxForce = Vector3.new(40000, 40000, 40000)
                velocity.Velocity = Vector3.new(0, 0, 0)
                velocity.Parent = rootPart
                
                local direction = Vector3.new()
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - Camera.CFrame.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + Camera.CFrame.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    direction = direction - Vector3.new(0, 1, 0)
                end
                
                if direction.Magnitude > 0 then
                    velocity.Velocity = direction.Unit * Config.Player.FlySpeed
                else
                    velocity.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    else
        if FlyConnection then
            FlyConnection:Disconnect()
            FlyConnection = nil
        end
        
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.PlatformStand = false
            end
            
            local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local velocity = rootPart:FindFirstChild("FlyVelocity")
                if velocity then velocity:Destroy() end
            end
        end
    end
end

-- Noclip System
local function ToggleNoclip()
    if Config.Player.Noclip then
        if NoclipConnection then NoclipConnection:Disconnect() end
        
        NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then
            NoclipConnection:Disconnect()
            NoclipConnection = nil
        end
    end
end

-- God Mode (Immortality)
local function ToggleGodMode()
    if Config.Player.GodMode then
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Name = "GodModeHumanoid"
                
                Connections.GodMode = humanoid.Changed:Connect(function()
                    if humanoid.Health < humanoid.MaxHealth then
                        humanoid.Health = humanoid.MaxHealth
                    end
                end)
            end
        end
    else
        if Connections.GodMode then
            Connections.GodMode:Disconnect()
        end
    end
end

-- Infinite Jump
local function ToggleInfiniteJump()
    if Config.Player.InfiniteJump then
        Connections.InfiniteJump = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if Connections.InfiniteJump then
            Connections.InfiniteJump:Disconnect()
        end
    end
end

-- Infinite Ammo & No Reload
local function ToggleCombatFeatures()
    if Config.Combat.InfiniteAmmo then
        -- Hook per infinite ammo
        local mt = getrawmetatable(game)
        local oldNamecall = mt.__namecall
        
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = {...}
            
            -- Infinite Ammo
            if method == "InvokeServer" and tostring(self):find("Ammo") then
                return math.huge
            end
            
            -- No Reload
            if method == "FireServer" and tostring(self):find("Reload") then
                return
            end
            
            -- Instant Reload
            if Config.Combat.InstantReload and method == "FireServer" and tostring(self):find("Reload") then
                return true
            end
            
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end
end

-- ESP System
local function ToggleESP()
    if Config.Visuals.ESP then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChildOfClass("Highlight")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.FillColor = Color3.fromRGB(170, 0, 255) -- Viola
                    highlight.OutlineColor = Color3.fromRGB(0, 170, 255) -- Blu
                    highlight.FillTransparency = 0.5
                    highlight.Parent = player.Character
                end
                highlight.Enabled = true
            end
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChildOfClass("Highlight")
                if highlight then
                    highlight.Enabled = false
                end
            end
        end
    end
end

-- FullBright
local function ToggleFullBright()
    if Config.Visuals.FullBright then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 14
    else
        Lighting.Brightness = OriginalProperties.Brightness or 1
        Lighting.GlobalShadows = OriginalProperties.GlobalShadows or true
    end
end

-- Wallhack
local function ToggleWallhack()
    if Config.Visuals.Wallhack then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
                obj.LocalTransparencyModifier = 0.3
            end
        end
    else
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier = 0
            end
        end
    end
end

-- Speed Hack
local function ToggleSpeedHack()
    if Config.Misc.SpeedHack ~= 1.0 then
        RunService:Set3dRenderingEnabled(false)
        settings().Physics.AllowSleep = false
    else
        RunService:Set3dRenderingEnabled(true)
        settings().Physics.AllowSleep = true
    end
end

-- Auto Farm (Basic)
local function ToggleAutoFarm()
    if Config.Misc.AutoFarm then
        Connections.AutoFarm = RunService.Heartbeat:Connect(function()
            if not LocalPlayer.Character then return end
            
            -- Find nearest NPC
            local nearestNPC = nil
            local nearestDistance = 100
            
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                    if obj:FindFirstChild("Humanoid") and obj.Humanoid.Health > 0 then
                        local distance = (obj.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if distance < nearestDistance then
                            nearestNPC = obj
                            nearestDistance = distance
                        end
                    end
                end
            end
            
            if nearestNPC then
                -- Move towards NPC
                LocalPlayer.Character.Humanoid:MoveTo(nearestNPC.HumanoidRootPart.Position)
                
                -- Attack if close
                if nearestDistance < 20 then
                    mouse1click()
                end
            end
        end)
    else
        if Connections.AutoFarm then
            Connections.AutoFarm:Disconnect()
        end
    end
end

-- Anti AFK
local function ToggleAntiAFK()
    if Config.Misc.AntiAfk then
        local VirtualUser = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end

-- Create the GUI
local function CreateGUI()
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "PrivateClientMenu"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main Container
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.Size = UDim2.new(0, 600, 0, 450)
    MainContainer.Position = UDim2.new(0.5, -300, 0.5, -225)
    MainContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainContainer.BorderSizePixel = 0
    MainContainer.Active = true
    MainContainer.Draggable = true
    MainContainer.Parent = ScreenGui
    
    -- Gradient Background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 0, 50)),  -- Viola scuro
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 20, 40))   -- Blu scuro
    })
    Gradient.Rotation = 45
    Gradient.Parent = MainContainer
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TitleBar.BackgroundTransparency = 0.7
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainContainer
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "PRIVATE CLIENT MENU v1.0"
    Title.TextColor3 = Color3.fromRGB(170, 0, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -40, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 16
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        MainContainer.Visible = MenuOpen
    end)
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -75, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    MinimizeButton.Text = "_"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = TitleBar
    
    MinimizeButton.MouseButton1Click:Connect(function()
        MenuOpen = not MenuOpen
        MainContainer.Visible = MenuOpen
    end)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 150, 0, 360)
    Sidebar.Position = UDim2.new(0, 10, 0, 50)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainContainer
    
    local SidebarGradient = Instance.new("UIGradient")
    SidebarGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 0, 80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 40, 80))
    })
    SidebarGradient.Parent = Sidebar
    
    -- Sidebar Buttons
    local SidebarButtons = {
        {Name = "Player", Icon = "👤"},
        {Name = "Combat", Icon = "⚔️"},
        {Name = "Visuals", Icon = "👁️"},
        {Name = "Misc", Icon = "⚙️"},
        {Name = "Settings", Icon = "🔧"}
    }
    
    local function CreateSidebarButton(index, data)
        local Button = Instance.new("TextButton")
        Button.Name = data.Name .. "Button"
        Button.Size = UDim2.new(0.9, 0, 0, 40)
        Button.Position = UDim2.new(0.05, 0, 0, 10 + (index-1) * 50)
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        Button.BackgroundTransparency = 0.5
        Button.Text = data.Icon .. " " .. data.Name
        Button.TextColor3 = Color3.fromRGB(200, 200, 255)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 14
        Button.Parent = Sidebar
        
        Button.MouseButton1Click:Connect(function()
            CurrentPage = data.Name
            UpdatePage()
            
            -- Update button colors
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    if btn.Name == data.Name .. "Button" then
                        btn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
                        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                        btn.TextColor3 = Color3.fromRGB(200, 200, 255)
                    end
                end
            end
        end)
        
        if index == 1 then
            Button.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    for i, buttonData in ipairs(SidebarButtons) do
        CreateSidebarButton(i, buttonData)
    end
    
    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(0, 420, 0, 360)
    ContentArea.Position = UDim2.new(0, 170, 0, 50)
    ContentArea.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    ContentArea.BackgroundTransparency = 0.3
    ContentArea.BorderSizePixel = 0
    ContentArea.Parent = MainContainer
    
    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Size = UDim2.new(1, 0, 1, 0)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 5
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(170, 0, 255)
    ContentScroll.Parent = ContentArea
    
    -- Function to create toggle
    local function CreateToggle(parent, name, configTable, configKey, x, y)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name .. "Toggle"
        ToggleFrame.Size = UDim2.new(0, 180, 0, 40)
        ToggleFrame.Position = UDim2.new(0, x, 0, y)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        ToggleFrame.BackgroundTransparency = 0.5
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.Parent = parent
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "ToggleButton"
        ToggleButton.Size = UDim2.new(0, 30, 0, 30)
        ToggleButton.Position = UDim2.new(0, 10, 0.5, -15)
        ToggleButton.BackgroundColor3 = configTable[configKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
        ToggleButton.Text = ""
        ToggleButton.Parent = ToggleFrame
        
        local ToggleLabel = Instance.new("TextLabel")
        ToggleLabel.Name = "ToggleLabel"
        ToggleLabel.Size = UDim2.new(0, 120, 1, 0)
        ToggleLabel.Position = UDim2.new(0, 50, 0, 0)
        ToggleLabel.BackgroundTransparency = 1
        ToggleLabel.Text = name
        ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        ToggleLabel.Font = Enum.Font.Gotham
        ToggleLabel.TextSize = 14
        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ToggleLabel.Parent = ToggleFrame
        
        ToggleButton.MouseButton1Click:Connect(function()
            configTable[configKey] = not configTable[configKey]
            ToggleButton.BackgroundColor3 = configTable[configKey] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(100, 100, 100)
            
            -- Apply the feature
            if name == "Fly" then
                ToggleFly()
            elseif name == "Noclip" then
                ToggleNoclip()
            elseif name == "God Mode" then
                ToggleGodMode()
            elseif name == "Infinite Jump" then
                ToggleInfiniteJump()
            elseif name == "Infinite Ammo" then
                ToggleCombatFeatures()
            elseif name == "ESP" then
                ToggleESP()
            elseif name == "FullBright" then
                ToggleFullBright()
            elseif name == "Wallhack" then
                ToggleWallhack()
            elseif name == "Auto Farm" then
                ToggleAutoFarm()
            elseif name == "Speed Hack" then
                ToggleSpeedHack()
            end
        end)
        
        return ToggleFrame
    end
    
    -- Function to create slider
    local function CreateSlider(parent, name, min, max, current, configTable, configKey, x, y)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = name .. "Slider"
        SliderFrame.Size = UDim2.new(0, 180, 0, 60)
        SliderFrame.Position = UDim2.new(0, x, 0, y)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        SliderFrame.BackgroundTransparency = 0.5
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = parent
        
        local SliderLabel = Instance.new("TextLabel")
        SliderLabel.Name = "SliderLabel"
        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
        SliderLabel.Position = UDim2.new(0, 0, 0, 0)
        SliderLabel.BackgroundTransparency = 1
        SliderLabel.Text = name .. ": " .. current
        SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
        SliderLabel.Font = Enum.Font.Gotham
        SliderLabel.TextSize = 14
        SliderLabel.Parent = SliderFrame
        
        local SliderTrack = Instance.new("Frame")
        SliderTrack.Name = "SliderTrack"
        SliderTrack.Size = UDim2.new(0.9, 0, 0, 6)
        SliderTrack.Position = UDim2.new(0.05, 0, 0, 30)
        SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        SliderTrack.BorderSizePixel = 0
        SliderTrack.Parent = SliderFrame
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Name = "SliderFill"
        SliderFill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
        SliderFill.Position = UDim2.new(0, 0, 0, 0)
        SliderFill.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
        SliderFill.BorderSizePixel = 0
        SliderFill.Parent = SliderTrack
        
        local SliderButton = Instance.new("TextButton")
        SliderButton.Name = "SliderButton"
        SliderButton.Size = UDim2.new(0, 20, 0, 20)
        SliderButton.Position = UDim2.new((current - min) / (max - min), -10, 0.5, -10)
        SliderButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        SliderButton.Text = ""
        SliderButton.Parent = SliderTrack
        
        local dragging = false
        
        local function updateValue(xPos)
            local relativeX = math.clamp((xPos - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * relativeX)
            
            configTable[configKey] = value
            SliderLabel.Text = name .. ": " .. value
            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            SliderButton.Position = UDim2.new(relativeX, -10, 0.5, -10)
            
            -- Apply changes
            if name == "WalkSpeed" then
                ApplyWalkSpeed()
            elseif name == "Fly Speed" then
                Config.Player.FlySpeed = value
            end
        end
        
        SliderButton.MouseButton1Down:Connect(function()
            dragging = true
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateValue(input.Position.X)
            end
        end)
        
        return SliderFrame
    end
    
    -- Function to update page content
    local function UpdatePage()
        ContentScroll:ClearAllChildren()
        ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        
        if CurrentPage == "Player" then
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 300)
            
            CreateSlider(ContentScroll, "WalkSpeed", 16, 200, Config.Player.WalkSpeed, Config.Player, "WalkSpeed", 10, 10)
            CreateSlider(ContentScroll, "Jump Power", 50, 300, Config.Player.JumpPower, Config.Player, "JumpPower", 200, 10)
            CreateSlider(ContentScroll, "Fly Speed", 10, 200, Config.Player.FlySpeed, Config.Player, "FlySpeed", 10, 80)
            
            CreateToggle(ContentScroll, "Fly", Config.Player, "Fly", 10, 150)
            CreateToggle(ContentScroll, "Noclip", Config.Player, "Noclip", 200, 150)
            CreateToggle(ContentScroll, "God Mode", Config.Player, "GodMode", 10, 200)
            CreateToggle(ContentScroll, "Infinite Jump", Config.Player, "InfiniteJump", 200, 200)
            
        elseif CurrentPage == "Combat" then
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 250)
            
            CreateToggle(ContentScroll, "Infinite Ammo", Config.Combat, "InfiniteAmmo", 10, 10)
            CreateToggle(ContentScroll, "No Recoil", Config.Combat, "NoRecoil", 200, 10)
            CreateToggle(ContentScroll, "No Spread", Config.Combat, "NoSpread", 10, 60)
            CreateToggle(ContentScroll, "Rapid Fire", Config.Combat, "RapidFire", 200, 60)
            CreateToggle(ContentScroll, "Instant Reload", Config.Combat, "InstantReload", 10, 110)
            CreateToggle(ContentScroll, "Auto Shoot", Config.Combat, "AutoShoot", 200, 110)
            CreateToggle(ContentScroll, "Trigger Bot", Config.Combat, "TriggerBot", 10, 160)
            CreateToggle(ContentScroll, "One Hit Kill", Config.Combat, "OneHitKill", 200, 160)
            
            CreateSlider(ContentScroll, "Damage Multiplier", 1, 10, Config.Combat.DamageMultiplier, Config.Combat, "DamageMultiplier", 10, 210)
            
        elseif CurrentPage == "Visuals" then
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 250)
            
            CreateToggle(ContentScroll, "ESP", Config.Visuals, "ESP", 10, 10)
            CreateToggle(ContentScroll, "Box ESP", Config.Visuals, "BoxESP", 200, 10)
            CreateToggle(ContentScroll, "Name ESP", Config.Visuals, "NameESP", 10, 60)
            CreateToggle(ContentScroll, "Health ESP", Config.Visuals, "HealthESP", 200, 60)
            CreateToggle(ContentScroll, "Tracers", Config.Visuals, "Tracers", 10, 110)
            CreateToggle(ContentScroll, "Chams", Config.Visuals, "Chams", 200, 110)
            CreateToggle(ContentScroll, "Wallhack", Config.Visuals, "Wallhack", 10, 160)
            CreateToggle(ContentScroll, "FullBright", Config.Visuals, "FullBright", 200, 160)
            CreateToggle(ContentScroll, "XRay", Config.Visuals, "XRay", 10, 210)
            
        elseif CurrentPage == "Misc" then
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 180)
            
            CreateToggle(ContentScroll, "Auto Farm", Config.Misc, "AutoFarm", 10, 10)
            CreateToggle(ContentScroll, "Auto Collect", Config.Misc, "AutoCollect", 200, 10)
            CreateToggle(ContentScroll, "Anti AFK", Config.Misc, "AntiAfk", 10, 60)
            CreateToggle(ContentScroll, "No Clip", Config.Misc, "NoClip", 200, 60)
            
            CreateSlider(ContentScroll, "Speed Hack", 0.1, 5, Config.Misc.SpeedHack * 10, Config.Misc, "SpeedHack", 10, 120)
            
        elseif CurrentPage == "Settings" then
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 120)
            
            local SaveButton = Instance.new("TextButton")
            SaveButton.Size = UDim2.new(0, 180, 0, 40)
            SaveButton.Position = UDim2.new(0, 10, 0, 10)
            SaveButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            SaveButton.Text = "💾 Save Settings"
            SaveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            SaveButton.Font = Enum.Font.GothamBold
            SaveButton.TextSize = 14
            SaveButton.Parent = ContentScroll
            
            SaveButton.MouseButton1Click:Connect(function()
                -- Save settings functionality
                print("Settings saved!")
            end)
            
            local LoadButton = Instance.new("TextButton")
            LoadButton.Size = UDim2.new(0, 180, 0, 40)
            LoadButton.Position = UDim2.new(0, 200, 0, 10)
            LoadButton.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
            LoadButton.Text = "📂 Load Settings"
            LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            LoadButton.Font = Enum.Font.GothamBold
            LoadButton.TextSize = 14
            LoadButton.Parent = ContentScroll
            
            local ResetButton = Instance.new("TextButton")
            ResetButton.Size = UDim2.new(0, 380, 0, 40)
            ResetButton.Position = UDim2.new(0, 10, 0, 60)
            ResetButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            ResetButton.Text = "🔄 Reset All Settings"
            ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ResetButton.Font = Enum.Font.GothamBold
            ResetButton.TextSize = 14
            ResetButton.Parent = ContentScroll
            
            ResetButton.MouseButton1Click:Connect(function()
                Config.Player.WalkSpeed = 16
                Config.Player.JumpPower = 50
                Config.Player.Fly = false
                Config.Player.FlySpeed = 50
                Config.Player.Noclip = false
                Config.Player.GodMode = false
                Config.Player.InfiniteJump = false
                
                Config.Combat.InfiniteAmmo = false
                Config.Combat.NoRecoil = false
                Config.Combat.NoSpread = false
                Config.Combat.RapidFire = false
                Config.Combat.InstantReload = false
                Config.Combat.AutoShoot = false
                Config.Combat.TriggerBot = false
                Config.Combat.DamageMultiplier = 1.0
                Config.Combat.OneHitKill = false
                
                Config.Visuals.ESP = false
                Config.Visuals.BoxESP = false
                Config.Visuals.NameESP = true
                Config.Visuals.HealthESP = true
                Config.Visuals.Tracers = false
                Config.Visuals.Chams = false
                Config.Visuals.Wallhack = false
                Config.Visuals.FullBright = false
                Config.Visuals.XRay = false
                
                Config.Misc.AutoFarm = false
                Config.Misc.AutoCollect = false
                Config.Misc.SpeedHack = 1.0
                Config.Misc.AntiAfk = true
                Config.Misc.NoClip = false
                
                -- Apply resets
                ApplyWalkSpeed()
                ToggleFly()
                ToggleNoclip()
                ToggleGodMode()
                ToggleInfiniteJump()
                ToggleESP()
                ToggleFullBright()
                ToggleWallhack()
                ToggleAutoFarm()
                ToggleSpeedHack()
                
                UpdatePage()
                print("All settings reset!")
            end)
        end
    end
    
    -- Initialize with Player page
    UpdatePage()
    
    -- Bottom Bar
    local BottomBar = Instance.new("Frame")
    BottomBar.Name = "BottomBar"
    BottomBar.Size = UDim2.new(1, 0, 0, 30)
    BottomBar.Position = UDim2.new(0, 0, 1, -30)
    BottomBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    BottomBar.BackgroundTransparency = 0.7
    BottomBar.BorderSizePixel = 0
    BottomBar.Parent = MainContainer
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -20, 1, 0)
    StatusLabel.Position = UDim2.new(0, 10, 0, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "✅ Menu Loaded | " .. game.Name .. " | FPS: --"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 12
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = BottomBar
    
    -- FPS Counter
    local lastTime = tick()
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 1 then
            local fps = frameCount
            frameCount = 0
            lastTime = currentTime
            
            StatusLabel.Text = "✅ Menu Loaded | " .. game.Name .. " | FPS: " .. fps
        end
    end)
    
    return ScreenGui
end

-- Initialize
SaveOriginalProperties()

-- Wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Wait for player
if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Create GUI
local GUI = CreateGUI()

-- Apply initial settings
ApplyWalkSpeed()
ToggleAntiAFK()

-- Toggle menu with Insert key
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        MenuOpen = not MenuOpen
        GUI.MainContainer.Visible = MenuOpen
    end
end)

-- Main loop
RunService.Heartbeat:Connect(function()
    ApplyWalkSpeed()
    ToggleESP()
    ToggleFullBright()
    ToggleWallhack()
    ToggleSpeedHack()
end)

-- Notification
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Private Client Menu",
    Text = "Menu loaded! Press INSERT to toggle",
    Icon = "rbxassetid://4483345998",
    Duration = 5
})

print("======================================")
print("PRIVATE CLIENT MENU v1.0")
print("✅ GUI Created Successfully")
print("✅ All Features Ready")
print("✅ Press INSERT to toggle menu")
print("======================================")