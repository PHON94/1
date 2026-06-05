--=============================================================================
--         BANANA HUB PREMIUM V16 - PHÂN CHIA MELEE THUẦN & ĐAN XEN VŨ KHÍ
--=============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

--// TRẠNG THÁI HỆ THỐNG
_G.AutoChest = false
_G.AutoHop = false
_G.AutoKillPlayers = false
_G.WeaveFastAttack = false 

local islandList = {}
local currentIslandIdx = 1
local collectedChests = setmetatable({}, {__mode = "k"})

-- Danh sách các võ học (Melee) thông dụng
local MELEE_LIST = {
    "Combat", "Dark Step", "Electro", "Water Kung Fu", "Dragon Breath", 
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", 
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

--// DỌN DẸP UI CŨ
if game:GetService("CoreGui"):FindFirstChild("BananaHubPremium") then
    game:GetService("CoreGui").BananaHubPremium:Destroy()
end

--// KHỞI TẠO SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BananaHubPremium"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local function ApplyTween(obj, info, goal)
    return TweenService:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal):Play()
end

--// 1. KHUNG CHÍNH (MAIN FRAME)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(45, 45, 45)

-- Kéo thả Menu
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

--// 2. THANH BÊN (SIDEBAR)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Sidebar.BorderSizePixel = 0

local SidebarLine = Instance.new("Frame", Sidebar)
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 60)
Logo.Text = "BANANA HUB"
Logo.TextColor3 = Color3.fromRGB(255, 215, 0)
Logo.TextSize = 20
Logo.Font = Enum.Font.GothamBold
Logo.BackgroundTransparency = 1

local TabContainer = Instance.new("Frame", Sidebar)
TabContainer.Position = UDim2.new(0, 10, 0, 70)
TabContainer.Size = UDim2.new(1, -20, 1, -80)
TabContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 8)

--// 3. KHU VỰC NỘI DUNG
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Position = UDim2.new(0, 170, 0, 50)
ContentArea.Size = UDim2.new(1, -180, 1, -60)
ContentArea.BackgroundTransparency = 1

--// 4. NÚT THU GỌN & ĐÓNG
local TopButtons = Instance.new("Frame", MainFrame)
TopButtons.Size = UDim2.new(1, -170, 0, 40)
TopButtons.Position = UDim2.new(0, 170, 0, 0)
TopButtons.BackgroundTransparency = 1

local MinimizeBtn = Instance.new("TextButton", TopButtons)
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0.5, -15)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = MinimizeBtn:Clone()
CloseBtn.Text = "×"
CloseBtn.Position = UDim2.new(1, -35, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBtn.Parent = TopButtons

local RestoreBtn = Instance.new("TextButton", ScreenGui)
RestoreBtn.Size = UDim2.new(0, 50, 0, 50)
RestoreBtn.Position = UDim2.new(0, 20, 0, 20)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
RestoreBtn.Text = "B"
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.TextSize = 25
RestoreBtn.TextColor3 = Color3.fromRGB(0,0,0)
RestoreBtn.Visible = false
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0,0,0,0), "Out", "Quart", 0.3, true)
    task.wait(0.3)
    MainFrame.Visible = false
    RestoreBtn.Visible = true
end)

RestoreBtn.MouseButton1Click:Connect(function()
    RestoreBtn.Visible = false
    MainFrame.Visible = true
    MainFrame:TweenSize(UDim2.new(0, 550, 0, 350), "Out", "Quart", 0.3, true)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--// 5. HÀM TẠO TAB & TOGGLE (ĐÃ FIX LỖI TỰ CO GIÃN THEO NÚT)
local function CreateTab(name, isDefault)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = isDefault and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(30, 30, 30)
    TabBtn.Text = name
    TabBtn.TextColor3 = isDefault and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn
