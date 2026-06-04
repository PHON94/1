--=============================================================================
--         SCRIPT TỰ ĐỘNG NHẶT RƯƠNG TRÊN NỀN GIAO DIỆN TỰ CODE TAY (NO LINK)
--=============================================================================

--// 1. SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Khởi tạo biến trạng thái toàn cục
_G.AutoChest = false         
local Ban_Kinh_Gom_Ruong = 1000 

-- Xóa Menu cũ nếu lỡ chạy lại script nhằm tránh trùng lặp
if game:GetService("CoreGui"):FindFirstChild("BananaHubCustom") then
    game:GetService("CoreGui").BananaHubCustom:Destroy()
end

--// 2. CUSTOM MENU UI (Tự tạo giao diện bằng Code thuần không qua link ngoài)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BananaHubCustom"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Khung chính của Menu
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép giữ chuột để kéo Menu di chuyển trên màn hình
MainFrame.Parent = ScreenGui

-- Bo góc khung chính
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Thanh Menu bên trái (Sidebar)
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

-- Tiêu đề Menu
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = " BANANA HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 16
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Parent = Sidebar

-- Khu vực chứa các nút Tab bên trái
local TabContainer = Instance.new("Frame")
TabContainer.Position = UDim2.new(0, 0, 0, 50)
TabContainer.Size = UDim2.new(1, 0, 1, -50)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = Sidebar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.Parent = TabContainer

-- Khung nội dung bên phải hiển thị tính năng
local ContentFrame = Instance.new("Frame")
ContentFrame.Position = UDim2.new(0, 150, 0, 10)
ContentFrame.Size = UDim2.new(1, -160, 1, -20)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- HÀM TẠO TAB BÊN TRÁI
local function CreateTab(name, isDefault)
    local TabButton = Instance.new("TextButton")
    TabButton.Size = UDim2.new(0, 120, 0, 32)
    TabButton.BackgroundColor3 = isDefault and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(22, 22, 22)
    TabButton.Text = name
    TabButton.TextColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    TabButton.TextSize = 14
    TabButton.Font = Enum.Font.SourceSansSemibold
    TabButton.BorderSizePixel = 0
    TabButton.Parent = TabContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = TabButton
    
    -- Khung nội dung riêng cho từng Tab
    local TabPage = Instance.new("Frame")
    TabPage.Size = UDim2.new(1, 0, 1, 0)
    TabPage.BackgroundTransparency = 1
    TabPage.Visible = isDefault
    TabPage.Parent = ContentFrame
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Padding = UDim.new(0, 8)
    PageLayout.Parent = TabPage

    TabButton.MouseButton1Click:Connect(function()
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("Frame") then child.Visible = false end
        end
        for _, btn in pairs(TabContainer:GetChildren()) do
            if btn:IsA("TextButton") then 
                btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        TabPage.Visible = true
        TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    return TabPage
end

-- TẠO CÁC DANH MỤC CỘT BÊN TRÁI
local MainTab = CreateTab("Main", true)
local CombatTab = CreateTab("Combat (Sắp có)", false)
local TeleportTab = CreateTab("Teleport (Sắp có)", false)
local SettingsTab = CreateTab("Cấu Hình", false)

-- HÀM TẠO NÚT BẬT / TẮT (TOGGLE) TRONG TAB MAIN
local function AddToggle(parentPage, text, callback)
    local ToggleBg = Instance.new("Frame")
    ToggleBg.Size = UDim2.new(1, 0, 0, 40)
    ToggleBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleBg.BorderSizePixel = 0
    ToggleBg.Parent = parentPage
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 6)
    ToggleCorner.Parent = ToggleBg
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(230, 230, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = ToggleBg
    
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 45, 0, 22)
    Button.Position = UDim2.new(1, -55, 0.5, -11)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.Text = "TẮT"
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.Font = Enum.Font.SourceSansBold
    Button.TextSize = 12
    Button.BorderSizePixel = 0
    Button.Parent = ToggleBg
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 4)
    BtnCorner.Parent = Button
    
    local enabled = false
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        if enabled then
            Button.BackgroundColor3 = Color3.fromRGB(46, 204, 113) -- Đổi sang xanh khi bật
            Button.Text = "BẬT"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)   -- Đổi sang xám khi tắt
            Button.Text = "TẮT"
            Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        callback(enabled)
    end)
end

-- THÊM TÍNH NĂNG AUTO CHEST VÀO TRONG TAB MAIN
AddToggle(MainTab, "Tự Động Nhặt Rương (Silver/Gold)", function(Value)
    _G.AutoChest = Value
end)

-- Nút đóng / ẩn nhanh Menu (Nút đỏ góc trên bên phải)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(192, 57, 43)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

--// 3. TWEEN SYSTEM (Hệ thống dịch chuyển mượt mà xuyên địa hình)
local function TweenTo(targetCFrame)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local distance = (character.HumanoidRootPart.Position - targetCFrame.Position).Magnitude
    local speed = 300 
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(character.HumanoidRootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

--// 4. AUTO CHEST SYSTEM (Hệ thống quét rương SilverChest và GoldChest)
local function LayRuongGanNhat()
    local WorkspaceRuong = workspace:FindFirstChild("Chests") or workspace:FindFirstChild("ChestModels") or workspace
    local ruongGanNhat = nil
    local khoangCachNhoNhat = math.huge
    
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local viTriCuaToi = character.HumanoidRootPart.Position

    for _, v in pairs(WorkspaceRuong:GetChildren()) do
        if (v.Name == "SilverChest" or v.Name == "GoldChest") and not v:GetAttribute("Collected") then
            local phanThuong = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("RootPart") or (v:IsA("BasePart") and v)
            if phanThuong then
                local khoangCach = (phanThuong.Position - viTriCuaToi).Magnitude
                if khoangCach < khoangCachNhoNhat and khoangCach <= Ban_Kinh_Gom_Ruong then
                    khoangCachNhoNhat = khoangCach
                    ruongGanNhat = phanThuong
                end
            end
        end
    end
    return ruongGanNhat
end

local function XuLyNhatRuong()
    local ruongMucTieu = LayRuongGanNhat()
    if ruongMucTieu then
        local tween = TweenTo(ruongMucTieu.CFrame)
        if tween then
            tween.Completed:Wait()
        end
        
        if firetouchinterest then
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, ruongMucTieu, 0)
            task.wait(0.05)
            firetouchinterest(LocalPlayer.Character.HumanoidRootPart, ruongMucTieu, 1)
        else
            task.wait(0.2) 
        end
        
        if ruongMucTieu.Parent then
            ruongMucTieu.Parent:SetAttribute("Collected", true)
        else
            ruongMucTieu:SetAttribute("Collected", true)
        end
        
        task.wait(0.2)
        return true
    end
    return false
end

--// 5. MAIN LOOP (Vòng lặp thực thi chạy ngầm tính năng)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoChest then
            XuLyNhatRuong()
        end
    end
end)

--// 6. NOCLIP SYSTEM (Bật liên tục khi AutoChest chạy để chống kẹt tường)
RunService.Stepped:Connect(function()
    if _G.AutoChest and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
