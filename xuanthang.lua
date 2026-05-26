--[[
    🔥 MEME SEA KAITUN ALL SCRIPT 🔥
    Tác giả: Kaitun (Fix by Xuân Thắng)
    Chức năng:
    - Auto Farm (tự động farm quái)
    - Auto Skill (spam skill từ xa)
    - Auto Aimbot (bám mục tiêu)
    - Auto Heal (tự hồi máu)
    - Auto Block (tự động block)
    - Auto Dodge (né chiêu)
    - Auto Collect (nhặt đồ)
    - Teleport to Boss
    - Infinity Energy
    - No Cooldown
    - Damage Multiplier
    - Mob Aura (sát thương vòng quanh)
    - Click GUI
--]]

-- ========== LOAD SERVICES ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ========== SETTINGS ==========
local Settings = {
    -- Farm
    AutoFarm = true,
    FarmRange = 350,
    AttackDelay = 0.1,
    
    -- Skill
    AutoSkill = true,
    SkillDelay = 0.2,
    Skills = {"Q", "E", "R", "Z", "X", "C", "V", "F", "G"},
    LongRange = true,  -- skill bất chấp khoảng cách
    
    -- Aimbot
    AutoAim = true,
    AimPart = "Head",
    
    -- Heal
    AutoHeal = true,
    HealPercent = 50,
    
    -- Dodge
    AutoDodge = true,
    DodgeRange = 35,
    
    -- Other
    AutoBlock = true,
    AutoCollect = true,
    TeleportBoss = false,
    MobAura = true,
    MobAuraRange = 80,
    DamageMultiplier = 5,
    NoCooldown = true,
    InfinityEnergy = true
}

-- ========== VARIABLES ==========
local currentTarget = nil
local lastAttack = 0
local lastSkill = 0
local lastHeal = 0
local lastDodge = 0
local screenGui = nil
local player = LocalPlayer
local character = nil
local humanoid = nil
local rootPart = nil

-- ========== FUNCTIONS ==========
local function getCharacter()
    character = player.Character
    if not character then return nil end
    humanoid = character:FindFirstChild("Humanoid")
    rootPart = character:FindFirstChild("HumanoidRootPart")
    return character
end

local function getClosestEnemy()
    local closest = nil
    local shortest = 500
    
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= character then
            local hum = v:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local hrp = v:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - rootPart.Position).Magnitude
                    if dist < shortest and dist < Settings.FarmRange then
                        shortest = dist
                        closest = v
                    end
                end
            end
        end
    end
    return closest
end

local function doAttack(target)
    if not target or not character then return end
    local hrp = target:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if Settings.AutoAim then
        local lookAt = CFrame.new(Camera.CFrame.Position, hrp.Position)
        Camera.CFrame = Camera.CFrame:Lerp(lookAt, 0.3)
    end
    
    -- Tấn công
    local args = {
        [1] = hrp.Position,
        [2] = hrp
    }
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Attack"):FireServer(unpack(args))
end

local function useSkill(key)
    local keyCode = Enum.KeyCode[key:upper()]
    if keyCode then
        VirtualUser:SendKeyEvent(true, keyCode, false, game)
        task.wait(0.02)
        VirtualUser:SendKeyEvent(false, keyCode, false, game)
    end
end

local function doHeal()
    if character and humanoid then
        local healthPercent = (humanoid.Health / humanoid.MaxHealth) * 100
        if healthPercent <= Settings.HealPercent then
            -- Gửi lệnh heal (tùy game)
            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Heal"):FireServer()
            lastHeal = tick()
        end
    end
end

local function doDodge()
    if not character or not rootPart then return end
    if tick() - lastDodge < 0.5 then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent and not obj.Parent:IsDescendantOf(character) then
            local name = obj.Name:lower()
            if name:find("skill") or name:find("projectile") or name:find("blast") then
                local dist = (obj.Position - rootPart.Position).Magnitude
                if dist < Settings.DodgeRange then
                    local direction = (rootPart.Position - obj.Position).Unit
                    local jumpPos = rootPart.Position + direction * 25 + Vector3.new(0, 15, 0)
                    humanoid:MoveTo(jumpPos)
                    humanoid.Jump = true
                    lastDodge = tick()
                    
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = direction * 70
                    bv.MaxForce = Vector3.new(8000, 8000, 8000)
                    bv.Parent = rootPart
                    task.wait(0.2)
                    bv:Destroy()
                    break
                end
            end
        end
    end
end

local function doMobAura()
    if not Settings.MobAura then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v ~= character then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if hrp and (hrp.Position - rootPart.Position).Magnitude < Settings.MobAuraRange then
                local hum = v:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    hum.Health = hum.Health - Settings.DamageMultiplier
                end
            end
        end
    end
end

local function teleportToBoss()
    -- Tìm boss gần nhất
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v.Name:lower():find("boss") then
            local hrp = v:FindFirstChild("HumanoidRootPart")
            if hrp then
                rootPart.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
                break
            end
        end
    end
end

local function autoCollect()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("drop") or v.Name:lower():find("item") then
            if (v.Position - rootPart.Position).Magnitude < 50 then
                firetouchinterest(rootPart, v, 0)
                firetouchinterest(rootPart, v, 1)
            end
        end
    end
end

-- ========== INFINITY ENERGY & NO COOLDOWN ==========
local function modifyStats()
    if Settings.InfinityEnergy then
        if player.Character and player.Character:FindFirstChild("Energy") then
            player.Character.Energy.Value = player.Character.Energy.MaxValue
        end
    end
end

local function removeCooldowns()
    if not Settings.NoCooldown then return end
    local cooldowns = {"Q", "E", "R", "Z", "X", "C"}
    for _, skill in ipairs(cooldowns) do
        if player.Character and player.Character:FindFirstChild(skill) then
            local cd = player.Character[skill]:FindFirstChild("Cooldown")
            if cd then
                cd.Value = 0
            end
        end
    end
end

-- ========== MAIN LOOP ==========
local function mainLoop()
    while true do
        task.wait()
        
        if not getCharacter() then
            player.CharacterAdded:Wait()
            getCharacter()
        end
        
        modifyStats()
        removeCooldowns()
        
        if Settings.AutoDodge then
            doDodge()
        end
        
        if Settings.AutoHeal then
            doHeal()
        end
        
        if Settings.AutoCollect then
            autoCollect()
        end
        
        if Settings.MobAura then
            doMobAura()
        end
        
        if Settings.TeleportBoss then
            teleportToBoss()
            Settings.TeleportBoss = false
        end
        
        local target = getClosestEnemy()
        currentTarget = target
        
        if target then
            if Settings.AutoFarm and tick() - lastAttack > Settings.AttackDelay then
                doAttack(target)
                lastAttack = tick()
            end
            
            if Settings.AutoSkill and tick() - lastSkill > Settings.SkillDelay then
                for _, skill in ipairs(Settings.Skills) do
                    useSkill(skill)
                end
                lastSkill = tick()
            end
        end
    end
end

-- ========== CREATE GUI ==========
local function createGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KaitunGUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 450)
    mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "🔥 KAITUN ALL SKILL 🔥"
    title.TextColor3 = Color3.fromRGB(255, 80, 80)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = mainFrame
    
    -- Auto Farm
    local farmBtn = Instance.new("TextButton")
    farmBtn.Size = UDim2.new(0.9, 0, 0, 35)
    farmBtn.Position = UDim2.new(0.05, 0, 0, 50)
    farmBtn.Text = "⚔️ AUTO FARM: ON"
    farmBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    farmBtn.Parent = mainFrame
    farmBtn.MouseButton1Click:Connect(function()
        Settings.AutoFarm = not Settings.AutoFarm
        farmBtn.Text = Settings.AutoFarm and "⚔️ AUTO FARM: ON" or "⚔️ AUTO FARM: OFF"
        farmBtn.TextColor3 = Settings.AutoFarm and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    end)
    
    -- Auto Skill
    local skillBtn = Instance.new("TextButton")
    skillBtn.Size = UDim2.new(0.9, 0, 0, 35)
    skillBtn.Position = UDim2.new(0.05, 0, 0, 95)
    skillBtn.Text = "🌀 AUTO SKILL: ON"
    skillBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    skillBtn.Parent = mainFrame
    skillBtn.MouseButton1Click:Connect(function()
        Settings.AutoSkill = not Settings.AutoSkill
        skillBtn.Text = Settings.AutoSkill and "🌀 AUTO SKILL: ON" or "🌀 AUTO SKILL: OFF"
        skillBtn.TextColor3 = Settings.AutoSkill and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    end)
    
    -- Auto Heal
    local healBtn = Instance.new("TextButton")
    healBtn.Size = UDim2.new(0.9, 0, 0, 35)
    healBtn.Position = UDim2.new(0.05, 0, 0, 140)
    healBtn.Text = "💊 AUTO HEAL: ON"
    healBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    healBtn.Parent = mainFrame
    healBtn.MouseButton1Click:Connect(function()
        Settings.AutoHeal = not Settings.AutoHeal
        healBtn.Text = Settings.AutoHeal and "💊 AUTO HEAL: ON" or "💊 AUTO HEAL: OFF"
        healBtn.TextColor3 = Settings.AutoHeal and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    end)
    
    -- Auto Dodge
    local dodgeBtn = Instance.new("TextButton")
    dodgeBtn.Size = UDim2.new(0.9, 0, 0, 35)
    dodgeBtn.Position = UDim2.new(0.05, 0, 0, 185)
    dodgeBtn.Text = "💨 AUTO DODGE: ON"
    dodgeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    dodgeBtn.Parent = mainFrame
    dodgeBtn.MouseButton1Click:Connect(function()
        Settings.AutoDodge = not Settings.AutoDodge
        dodgeBtn.Text = Settings.AutoDodge and "💨 AUTO DODGE: ON" or "💨 AUTO DODGE: OFF"
        dodgeBtn.TextColor3 = Settings.AutoDodge and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    end)
    
    -- Mob Aura
    local auraBtn = Instance.new("TextButton")
    auraBtn.Size = UDim2.new(0.9, 0, 0, 35)
    auraBtn.Position = UDim2.new(0.05, 0, 0, 230)
    auraBtn.Text = "✨ MOB AURA: ON"
    auraBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    auraBtn.Parent = mainFrame
    auraBtn.MouseButton1Click:Connect(function()
        Settings.MobAura = not Settings.MobAura
        auraBtn.Text = Settings.MobAura and "✨ MOB AURA: ON" or "✨ MOB AURA: OFF"
        auraBtn.TextColor3 = Settings.MobAura and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,100,100)
    end)
    
    -- Teleport to Boss
    local bossBtn = Instance.new("TextButton")
    bossBtn.Size = UDim2.new(0.9, 0, 0, 35)
    bossBtn.Position = UDim2.new(0.05, 0, 0, 275)
    bossBtn.Text = "👑 TELEPORT BOSS"
    bossBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 80)
    bossBtn.Parent = mainFrame
    bossBtn.MouseButton1Click:Connect(function()
        Settings.TeleportBoss = true
        bossBtn.Text = "✅ ĐANG TP..."
        task.wait(2)
        bossBtn.Text = "👑 TELEPORT BOSS"
    end)
    
    -- Damage Multiplier
    local dmgBtn = Instance.new("TextButton")
    dmgBtn.Size = UDim2.new(0.9, 0, 0, 35)
    dmgBtn.Position = UDim2.new(0.05, 0, 0, 320)
    dmgBtn.Text = "⚡ DAMAGE x" .. Settings.DamageMultiplier
    dmgBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 30)
    dmgBtn.Parent = mainFrame
    dmgBtn.MouseButton1Click:Connect(function()
        Settings.DamageMultiplier = Settings.DamageMultiplier + 1
        if Settings.DamageMultiplier > 20 then Settings.DamageMultiplier = 1 end
        dmgBtn.Text = "⚡ DAMAGE x" .. Settings.DamageMultiplier
    end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.4, 0, 0, 30)
    closeBtn.Position = UDim2.new(0.3, 0, 0, 370)
    closeBtn.Text = "HIDE"
    closeBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
end

-- ========== START ==========
local function start()
    print("✅ KAITUN ALL SKILL LOADED!")
    print("🔥 Meme Sea Script by Xuân Thắng")
    print("🎮 Menu hiển thị bên trái màn hình")
    
    createGUI()
    spawn(mainLoop)
end

-- Chờ nhân vật load
repeat task.wait() until player.Character and player.Character:FindFirstChild("Humanoid")
start()
