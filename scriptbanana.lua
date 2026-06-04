--=============================================================================
--              SCRIPT TỰ ĐỘNG NHẶT RƯƠNG (SILVER & GOLD CHEST) + MENU UI
--=============================================================================

--// 1. SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Khởi tạo biến trạng thái toàn cục
_G.AutoChest = false         
local Ban_Kinh_Gom_Ruong = 1000 

--// 2. MENU UI SYSTEM (Cập nhật Link chính thức và ép hiển thị ngay lập tức)
local Fluent = loadstring(game:HttpGet("https://githubusercontent.com"))()

local Window = Fluent:CreateWindow({
    Title = "Banana Hub | Auto Chest",
    SubTitle = "by AI Assistant",
    TabWidth = 160,                     -- Độ rộng của cột danh mục bên trái
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,                    -- Tắt hiệu ứng nhòe để tránh lỗi hiển thị trên máy yếu
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Nhấn nút Ctrl Trái để Ẩn/Hiện Menu
})

-- KHỞI TẠO CÁC MỤC Ở CỘT BÊN TRÁI
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Combat = Window:AddTab({ Title = "Combat (Sắp có)", Icon = "swords" }),
    Teleport = Window:AddTab({ Title = "Teleport (Sắp có)", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Cấu Hình", Icon = "settings" })
}

-- THÊM TÍNH NĂNG VÀO TRONG TAB "MAIN"
local ToggleChest = Tabs.Main:AddToggle("ToggleChest", {Title = "Tự Động Nhặt Rương (Silver/Gold)", Default = false})

-- Đồng bộ trạng thái từ Menu UI vào Logic Code
ToggleChest:OnChanged(function(Value)
    _G.AutoChest = Value
end)

-- ÉP MENU TỰ ĐỘNG BẬT LÊN MÀN HÌNH NGAY KHI CHẠY SCRIPT
Window:SelectTab(1)

--// 3. TWEEN SYSTEM (Hệ thống dịch chuyển mượt mà)
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

--// 4. AUTO CHEST SYSTEM (Hệ thống tự động quét rương)
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
        -- Di chuyển xuyên thẳng vào tâm rương
        local tween = TweenTo(ruongMucTieu.CFrame)
        if tween then
            tween.Completed:Wait()
        end
        
        -- Kích hoạt TouchInterest để nhận quà từ rương
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

--// 5. MAIN LOOP (Vòng lặp thực thi cốt lõi)
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoChest then
            XuLyNhatRuong()
        end
    end
end)

--// 6. NOCLIP SYSTEM (Chống kẹt địa hình và xuyên tường)
RunService.Stepped:Connect(function()
    if _G.AutoChest and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Thông báo Giao diện đã sẵn sàng
Fluent:Notify({
    Title = "Banana Hub",
    Content = "Menu đã được kích hoạt thành công trên màn hình!",
    Duration = 5
})
