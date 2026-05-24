--[[
    🔥 MEME SEA MOBILE HACK 🔥
    Chạy trên: Delta Mobile, Arceus X Mobile, Codex Mobile, Hydrogen Mobile
    Chức năng:
    - Auto Aimbot (tự xoay cam)
    - Auto Farm (bay quanh mục tiêu)
    - Auto Skill (bất chấp khoảng cách, spam tất cả skill)
    - Auto Dodge (né chiêu)
    - Menu cảm ứng
    GitHub: https://github.com/yourname/memesea-mobile
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInput = game:GetService("VirtualInput")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ========== CẤU HÌNH ==========
local Settings = {
    -- Aimbot
    AimEnabled = true,
    AimPart = "Head",
    FOV = 300,
    
    -- Auto Farm
    FarmEnabled = true,
    FarmRadius = 30,
    FarmSpeed = 2.5,
    
    -- Auto Skill (bất chấp khoảng cách)
    SkillEnabled = true,
    SkillDelay = 0.15,
    UseAllSkills = true,  -- Dùng Q, E, R, Z, X, C
    
    -- Auto Dodge
    DodgeEnabled = true,
    DodgeRange = 35,
}

-- ========== BIẾN ==========
local currentTarget = nil
local orbitAngle = 0
local lastSkill = 0
local lastDodge = 0
local screenGui = nil

-- ========== TÌM MỤC TIÊU ==========
local function getClosestEnemy()
    local closest = nil
    local shortest = Settings.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") 
           and player.Character.Humanoid.Health > 0 then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local screenPos, onScreen = Camera:WorldToScreenPoint(hrp.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- ========== AIMBOT ==========
local function doAimbot()
    if not Settings.AimEnabled then return end
    
    local target = getClosestEnemy()
    if not target then return end
    
    local char = target.Character
    if not char then return end
    
    local aimPart = char:FindFirstChild(Settings.AimPart) or char:FindFirstChild("HumanoidRootPart")
    if aimPart then
        local lookAt = CFrame.new(Camera.CFrame.Position, aimPart.Position)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.25)
    end
    
    currentTarget = target
    return target
end

-- ========== AUTO FARM (QUAY XUNG QUANH) ==========
local function doFarm()
    if not Settings.FarmEnabled then return end
    if not currentTarget or not currentTarget.Character then return end
    
    local hrp = currentTarget.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    orbitAngle = (orbitAngle + Settings.FarmSpeed * 0.03) % (math.pi * 2)
    local radius = Settings.FarmRadius
    local x = hrp.Position.X + math.cos(orbitAngle) * radius
    local z = hrp.Position.Z + math.sin(orbitAngle) * radius
    local y = hrp.Position.Y + 3
    
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:MoveTo(Vector3.new(x, y, z))
    end
end

-- ========== AUTO SKILL (BẤT CHẤP KHOẢNG CÁCH) ==========
local skills = {"q", "e", "r", "z", "x", "c", "v", "f", "g"}

local function useSkill()
    if not Settings.SkillEnabled then return end
    if tick() - lastSkill < Settings.SkillDelay then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    -- Spam tất cả skill bất kể có mục tiêu hay không
    for _, key in ipairs(skills) do
        local keyCode = Enum.KeyCode[key:upper()]
        if keyCode then
            -- Gửi sự kiện nhấn phím ảo
            VirtualInput:SendKeyEvent(true, keyCode, false, game)
            task.wait(0.02)
            VirtualInput:SendKeyEvent(false, keyCode, false, game)
        end
    end
    
    lastSkill = tick()
end

-- ========== AUTO DODGE (NÉ CHIÊU) ==========
local function doDodge()
    if not Settings.DodgeEnabled then return end
    if tick() - lastDodge < 0.3 then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsDescendantOf(LocalPlayer.Character) then
            local name = obj.Name:lower()
            if name:find("skill") or name:find("projectile") or name:find("blast") or name:find("beam") or name:find("fire") then
                local dist = (obj.Position - hrp.Position).Magnitude
                if dist < Settings.DodgeRange then
                    local direction = (hrp.Position - obj.Position).Unit
                    local jumpPos = hrp.Position + direction * 20 + Vector3.new(0, 15, 0)
                    
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid then
                        humanoid:MoveTo(jumpPos)
                        humanoid.Jump = true
                        lastDodge = tick()
                        
                        -- Tạo hiệu ứng né
                        local bv = Instance.new("BodyVelocity")
                        bv.Velocity = direction * 60
                        bv.MaxForce = Vector3.new(5000, 5000, 5000)
                        bv.Parent = hrp
                        task.wait(0.2)
                        bv:Destroy()
                    end
                    break
                end
            end
        end
    end
end

-- ========== MENU CẢM ỨNG (CHO MOBILE) ==========
local function createMobileMenu()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MemeSeaHack"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 200, 0, 280)
    mainFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "🔥 MEME SEA HACK 🔥"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = mainFrame
    
    -- Nút Aimbot
    local aimBtn = Instance.new("TextButton")
    aimBtn.Size = UDim2.new(0.9, 0, 0, 40)
    aimBtn.Position = UDim2.new(0.05, 0, 0, 50)
    aimBtn.Text = "🎯 AIMBOT: ON"
    aimBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    aimBtn.Parent = mainFrame
    aimBtn.MouseButton1Click:Connect(function()
        Settings.AimEnabled = not Settings.AimEnabled
        aimBtn.Text = Settings.AimEnabled and "🎯 AIMBOT: ON" or "🎯 AIMBOT: OFF"
        aimBtn.TextColor3 = Settings.AimEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    end)
    
    -- Nút Farm
    local farmBtn = Instance.new("TextButton")
    farmBtn.Size = UDim2.new(0.9, 0, 0, 40)
    farmBtn.Position = UDim2.new(0.05, 0, 0, 100)
    farmBtn.Text = "🌀 AUTO FARM: ON"
    farmBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    farmBtn.Parent = mainFrame
    farmBtn.MouseButton1Click:Connect(function()
        Settings.FarmEnabled = not Settings.FarmEnabled
        farmBtn.Text = Settings.FarmEnabled and "🌀 AUTO FARM: ON" or "🌀 AUTO FARM: OFF"
        farmBtn.TextColor3 = Settings.FarmEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    end)
    
    -- Nút Skill
    local skillBtn = Instance.new("TextButton")
    skillBtn.Size = UDim2.new(0.9, 0, 0, 40)
    skillBtn.Position = UDim2.new(0.05, 0, 0, 150)
    skillBtn.Text = "⚔️ AUTO SKILL: ON"
    skillBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    skillBtn.Parent = mainFrame
    skillBtn.MouseButton1Click:Connect(function()
        Settings.SkillEnabled = not Settings.SkillEnabled
        skillBtn.Text = Settings.SkillEnabled and "⚔️ AUTO SKILL: ON" or "⚔️ AUTO SKILL: OFF"
        skillBtn.TextColor3 = Settings.SkillEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    end)
    
    -- Nút Dodge
    local dodgeBtn = Instance.new("TextButton")
    dodgeBtn.Size = UDim2.new(0.9, 0, 0, 40)
    dodgeBtn.Position = UDim2.new(0.05, 0, 0, 200)
    dodgeBtn.Text = "💨 DODGE: ON"
    dodgeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    dodgeBtn.Parent = mainFrame
    dodgeBtn.MouseButton1Click:Connect(function()
        Settings.DodgeEnabled = not Settings.DodgeEnabled
        dodgeBtn.Text = Settings.DodgeEnabled and "💨 DODGE: ON" or "💨 DODGE: OFF"
        dodgeBtn.TextColor3 = Settings.DodgeEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    end)
    
    -- Nút đóng menu
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.4, 0, 0, 30)
    closeBtn.Position = UDim2.new(0.3, 0, 0, 245)
    closeBtn.Text = "HIDE"
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    return screenGui
end

-- ========== MAIN LOOP ==========
local function mainLoop()
    while true do
        task.wait()
        
        local target = doAimbot()
        
        if Settings.FarmEnabled and target then
            doFarm()
        end
        
        if Settings.SkillEnabled then
            useSkill()
        end
        
        if Settings.DodgeEnabled then
            doDodge()
        end
    end
end

-- ========== KHỞI ĐỘNG ==========
local function start()
    -- Đợi nhân vật load
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    
    -- Tạo menu
    createMobileMenu()
    
    -- Chạy loop
    spawn(mainLoop)
    
    print("✅ MEME SEA MOBILE HACK LOADED!")
    print("🎮 Bật/tắt chức năng bằng menu bên trái")
    print("🔥 Auto skill bất chấp khoảng cách")
end

start()
