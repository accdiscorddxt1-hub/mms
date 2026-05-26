-- Script Redirect Removed - Onion13 Modified
-- Chạy script cũ trực tiếp, không redirect

local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ========== SCRIPT CŨ CỦA BOSS ==========
-- Nhét script cũ vào đây (thay thế nội dung bên dưới)
local OLD_SCRIPT = [[
    -- Nội dung script cũ của boss ở đây
    print("Script cũ đang chạy!")
    -- Ví dụ: auto farm, auto click, etc.
]]

-- ========== INTERFACE ==========
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Subtitle = Instance.new("TextLabel")
local ExecButton = Instance.new("TextButton")
local CloseButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local ButtonCorner = Instance.new("UICorner")
local ButtonCorner2 = Instance.new("UICorner")

ScreenGui.Parent = CoreGui
ScreenGui.Name = "Onion13_Script"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -140)
MainFrame.Size = UDim2.new(0, 500, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0.1, 0)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "SCRIPT LOADER"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 45
Title.TextWrapped = true

Subtitle.Name = "Subtitle"
Subtitle.Parent = MainFrame
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 0, 0.4, 0)
Subtitle.Size = UDim2.new(1, 0, 0, 40)
Subtitle.Font = Enum.Font.GothamSemibold
Subtitle.Text = "Click Execute to run script"
Subtitle.TextColor3 = Color3.fromRGB(255, 255, 255)
Subtitle.TextSize = 20
Subtitle.TextWrapped = true

-- Nút Execute
ExecButton.Name = "ExecButton"
ExecButton.Parent = MainFrame
ExecButton.BackgroundColor3 = Color3.fromRGB(0, 200, 80)
ExecButton.Position = UDim2.new(0.5, -125, 0.6, 0)
ExecButton.Size = UDim2.new(0, 250, 0, 45)
ExecButton.Font = Enum.Font.GothamBold
ExecButton.Text = "⚡ EXECUTE SCRIPT"
ExecButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ExecButton.TextSize = 18
ButtonCorner.CornerRadius = UDim.new(0, 8)
ButtonCorner.Parent = ExecButton

-- Nút Close
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Position = UDim2.new(0.5, -60, 0.8, 0)
CloseButton.Size = UDim2.new(0, 120, 0, 35)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Text = "❌ CLOSE"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
ButtonCorner2.CornerRadius = UDim.new(0, 8)
ButtonCorner2.Parent = CloseButton

-- Xử lý execute
ExecButton.MouseButton1Click:Connect(function()
    -- Đổi màu nút báo hiệu đang chạy
    local oldText = ExecButton.Text
    local oldColor = ExecButton.BackgroundColor3
    ExecButton.Text = "🚀 LOADING..."
    ExecButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
    
    -- Hiển thị thông báo
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Script Loader",
            Text = "Đang tải script...",
            Duration = 2
        })
    end)
    
    -- Chạy script cũ
    local success, err = loadstring(OLD_SCRIPT)()
    
    if success then
        ExecButton.Text = "✅ EXECUTED!"
        ExecButton.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Success!",
                Text = "Script đã chạy thành công!",
                Duration = 3
            })
        end)
    else
        ExecButton.Text = "❌ ERROR!"
        ExecButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Error!",
                Text = "Lỗi: " .. tostring(err),
                Duration = 5
            })
        end)
    end
    
    -- Reset nút sau 2 giây
    task.wait(2)
    ExecButton.Text = oldText
    ExecButton.BackgroundColor3 = oldColor
end)

-- Đóng GUI
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Closed",
            Text = "Script GUI đã đóng!",
            Duration = 2
        })
    end)
end)

-- Hiệu ứng chạy chữ
task.spawn(function()
    local texts = {"SCRIPT LOADER", "READY TO USE", "CLICK EXECUTE"}
    local i = 1
    while ScreenGui and ScreenGui.Parent do
        task.wait(2)
        i = i % #texts + 1
        Title.Text = texts[i]
    end
end)

print("✅ Script Loader đã sẵn sàng! Nhấn Execute để chạy script cũ.")
