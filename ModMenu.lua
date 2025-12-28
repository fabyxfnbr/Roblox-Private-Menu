-- ============================================
-- UNIVERSAL PRIVATE CLIENT MENU v4.0
-- Carica il menu in OGNI gioco/place
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- API ESPOSTE DAL VOSTRO ROBLOX.EXE MODIFICATO
local PrivateAPI = {
    -- Queste funzioni devono essere implementate nel vostro Roblox.exe
    IsPrivateClient = function() return true end,
    GetClientVersion = function() return "4.0.0" end,
    HasValidLicense = function() return true end,
    GetPremiumFeatures = function() return {"Aimbot", "ESP", "Fly", "Speed"} end,
    
    -- Funzioni di sicurezza implementate nel client
    SecureCall = function(func, ...)
        -- Chiamata sicura che bypassa detection
        return pcall(func, ...)
    end,
    
    -- Memory manipulation (implementata in C++ nel client)
    ReadMemory = function(address, type) 
        -- Implementato nel Roblox.exe
        return 0
    end,
    
    WriteMemory = function(address, value, type)
        -- Implementato nel Roblox.exe
        return true
    end
}

-- Verifica che sia il client corretto
if not PrivateAPI.IsPrivateClient() then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Errore",
        Text = "Questo menu funziona solo con Roblox Private Client",
        Duration = 5
    })
    return
end

-- Configurazione globale che persiste tra i giochi
_G.UniversalMenuConfig = {
    Active = true,
    Version = "4.0.1",
    Features = {
        Aimbot = {Enabled = false, Key = "E", Smoothing = 0.2},
        ESP = {Enabled = true, Box = true, Name = true},
        Fly = {Enabled = false, Speed = 50},
        Speed = {WalkSpeed = 16, JumpPower = 50}
    },
    WhitelistedGames = {
        -- Lista di tutti i PlaceId che supportate
        2753915549, -- Blox Fruits
        292439477,  -- Prison Life
        142823291,  -- Murder Mystery 2
        -- Aggiungete tutti gli ID dei giochi
    }
}

-- Sistema di hook universale
local UniversalHooks = {}

function UniversalHooks:SetupGameSpecific(gameId)
    -- Setup specifico per ogni gioco
    local gameConfigs = {
        [2753915549] = { -- Blox Fruits
            Aimbot = {TargetPart = "HumanoidRootPart"},
            ESP = {ShowFruits = true, ShowChests = true},
            AutoFarm = {Enabled = false, MobDistance = 50}
        },
        [292439477] = { -- Prison Life
            Aimbot = {TargetPart = "Head"},
            ESP = {ShowGuns = true, ShowKeys = true},
            AutoArrest = {Enabled = false}
        }
    }
    
    return gameConfigs[gameId] or {}
end

-- INIEZIONE UNIVERSALE DEL MENU
local function InjectUniversalMenu()
    print("[Universal Menu] Iniezione in corso...")
    
    -- Crea il CoreGUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UniversalPrivateMenu"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = game:GetService("CoreGui")
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- UI Library semplificata
    local function CreateButton(parent, text, position, callback)
        local button = Instance.new("TextButton")
        button.Name = text .. "Button"
        button.Size = UDim2.new(0.9, 0, 0, 35)
        button.Position = position
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Text = text
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.Parent = parent
        
        button.MouseButton1Click:Connect(callback)
        
        return button
    end
    
    -- Tabs
    local Tabs = {"Combat", "Visuals", "Player", "AutoFarm", "Settings"}
    local currentTab = "Combat"
    
    -- Combat Tab
    local combatFrame = Instance.new("Frame")
    combatFrame.Name = "CombatFrame"
    combatFrame.Size = UDim2.new(1, 0, 0.8, 0)
    combatFrame.Position = UDim2.new(0, 0, 0.15, 0)
    combatFrame.BackgroundTransparency = 1
    combatFrame.Visible = true
    combatFrame.Parent = MainFrame
    
    -- Aimbot Toggle
    local aimbotToggle = CreateButton(combatFrame, "Aimbot: OFF", UDim2.new(0.05, 0, 0.05, 0), function()
        _G.UniversalMenuConfig.Features.Aimbot.Enabled = not _G.UniversalMenuConfig.Features.Aimbot.Enabled
        aimbotToggle.Text = "Aimbot: " .. (_G.UniversalMenuConfig.Features.Aimbot.Enabled and "ON" or "OFF")
    end)
    
    -- ESP Toggle
    local espToggle = CreateButton(combatFrame, "ESP: ON", UDim2.new(0.05, 0, 0.15, 0), function()
        _G.UniversalMenuConfig.Features.ESP.Enabled = not _G.UniversalMenuConfig.Features.ESP.Enabled
        espToggle.Text = "ESP: " .. (_G.UniversalMenuConfig.Features.ESP.Enabled and "ON" or "OFF")
    end)
    
    -- Fly Toggle
    local flyToggle = CreateButton(combatFrame, "Fly: OFF", UDim2.new(0.05, 0, 0.25, 0), function()
        _G.UniversalMenuConfig.Features.Fly.Enabled = not _G.UniversalMenuConfig.Features.Fly.Enabled
        flyToggle.Text = "Fly: " .. (_G.UniversalMenuConfig.Features.Fly.Enabled and "ON" or "OFF")
    end)
    
    -- Speed Slider
    local speedText = Instance.new("TextLabel")
    speedText.Name = "SpeedText"
    speedText.Size = UDim2.new(0.9, 0, 0, 25)
    speedText.Position = UDim2.new(0.05, 0, 0.35, 0)
    speedText.BackgroundTransparency = 1
    speedText.Text = "WalkSpeed: 16"
    speedText.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedText.Font = Enum.Font.Gotham
    speedText.TextSize = 14
    speedText.Parent = combatFrame
    
    local speedSlider = Instance.new("TextButton")
    speedSlider.Name = "SpeedSlider"
    speedSlider.Size = UDim2.new(0.9, 0, 0, 20)
    speedSlider.Position = UDim2.new(0.05, 0, 0.4, 0)
    speedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    speedSlider.Text = ""
    speedSlider.Parent = combatFrame
    
    local speedFill = Instance.new("Frame")
    speedFill.Name = "SpeedFill"
    speedFill.Size = UDim2.new(0.5, 0, 1, 0)
    speedFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    speedFill.BorderSizePixel = 0
    speedFill.Parent = speedSlider
    
    -- Close Button
    local closeButton = CreateButton(MainFrame, "X", UDim2.new(0.9, -25, 0, 5), function()
        ScreenGui:Destroy()
        _G.UniversalMenuConfig.Active = false
    end)
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    title.Text = "PRIVATE CLIENT MENU v4.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = MainFrame
    
    print("[Universal Menu] UI creata con successo")
    return ScreenGui
end

-- FUNZIONALITÀ UNIVERSALI (lavorano in TUTTI i giochi)

-- Aimbot Universale
local function UniversalAimbot()
    if not _G.UniversalMenuConfig.Features.Aimbot.Enabled then return end
    
    local target = nil
    local closestDistance = math.huge
    local mouse = LocalPlayer:GetMouse()
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        target = player
                    end
                end
            end
        end
    end
    
    if target and UserInputService:IsKeyDown(Enum.KeyCode[_G.UniversalMenuConfig.Features.Aimbot.Key]) then
        local targetPart = target.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            workspace.CurrentCamera.CFrame = CFrame.lookAt(
                workspace.CurrentCamera.CFrame.Position,
                targetPart.Position
            )
        end
    end
end

-- ESP Universale
local function UniversalESP()
    if not _G.UniversalMenuConfig.Features.ESP.Enabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChildOfClass("Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = 0.5
                highlight.Parent = player.Character
            end
            highlight.Enabled = _G.UniversalMenuConfig.Features.ESP.Enabled
        end
    end
end

-- Fly Universale
local flyConnection
local function UniversalFly()
    if _G.UniversalMenuConfig.Features.Fly.Enabled then
        if flyConnection then flyConnection:Disconnect() end
        
        flyConnection = RunService.Heartbeat:Connect(function()
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
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - workspace.CurrentCamera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + workspace.CurrentCamera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
                
                if direction.Magnitude > 0 then
                    velocity.Velocity = direction.Unit * _G.UniversalMenuConfig.Features.Fly.Speed
                end
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
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

-- WalkSpeed Universale
local function UniversalWalkSpeed()
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = _G.UniversalMenuConfig.Features.Speed.WalkSpeed
            humanoid.JumpPower = _G.UniversalMenuConfig.Features.Speed.JumpPower
        end
    end
end

-- AutoFarm Universale (base)
local function UniversalAutoFarm()
    -- Implementazione base che funziona in molti giochi
    local nearestNPC = nil
    local nearestDistance = 50
    
    -- Cerca NPC/Enemy
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local distance = (obj.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < nearestDistance then
                nearestNPC = obj
                nearestDistance = distance
            end
        end
    end
    
    if nearestNPC then
        -- Muovi verso l'NPC
        LocalPlayer.Character.Humanoid:MoveTo(nearestNPC.HumanoidRootPart.Position)
        
        -- Attacca se vicino
        if nearestDistance < 10 then
            mouse1click()
        end
    end
end

-- SISTEMA DI INIEZIONE AUTOMATICA
local function AutoInjectOnGameLoad()
    -- Aspetta che il gioco carichi
    repeat wait() until game:IsLoaded()
    
    -- Aspetta che il player esista
    repeat wait() until LocalPlayer.Character
    
    print("[AutoInject] Gioco caricato: " .. game.PlaceId)
    
    -- Inietta il menu
    if not _G.UniversalMenuInjected then
        _G.UniversalMenuInjected = true
        InjectUniversalMenu()
        
        -- Avvia le funzionalità
        RunService.Heartbeat:Connect(function()
            UniversalAimbot()
            UniversalESP()
            UniversalWalkSpeed()
        end)
        
        -- Setup Fly
        UniversalFly()
        
        print("[AutoInject] Menu universale iniettato con successo!")
    end
end

-- MAIN EXECUTION
print("======================================")
print("PRIVATE CLIENT UNIVERSAL MENU v4.0")
print("Client: " .. PrivateAPI.GetClientVersion())
print("Game: " .. game.Name)
print("PlaceId: " .. game.PlaceId)
print("======================================")

-- Avvia l'iniezione automatica
AutoInjectOnGameLoad()

-- Ricarica automatica quando si cambia gioco
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
    if state == Enum.TeleportState.Started then
        -- Salva lo stato
        local savedConfig = _G.UniversalMenuConfig
        
        -- Usa Synapse o executor con teleport support
        if syn and syn.queue_on_teleport then
            syn.queue_on_teleport([[
                wait(5)
                loadstring(game:HttpGet("https://raw.githubusercontent.com/VostroUser/Roblox-Private-Menu/main/UniversalLoader.lua"))()
            ]])
        end
    end
end)

-- Messaggio di conferma
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Private Client Menu",
    Text = "Menu universale caricato! Premere INSERT per aprire",
    Icon = "rbxassetid://4483345998",
    Duration = 5
})

-- Toggle Menu con tasto
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        local menu = game:GetService("CoreGui"):FindFirstChild("UniversalPrivateMenu")
        if menu then
            menu.Enabled = not menu.Enabled
        else
            InjectUniversalMenu()
        end
    end
end)

print("✅ Menu universale pronto! Premere INSERT per aprire")