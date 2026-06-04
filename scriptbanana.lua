--=============================================================================
--         SCRIPT TỰ ĐỘNG NHẶT RƯƠNG VỚI PHIÊN BẢN RAYFIELD UI MỚI
--=============================================================================

--// 1. SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Khởi tạo biến trạng thái toàn cục
_G.AutoChest = false         
local Ban_Kinh_Gom_Ruong = 1000 

--// 2. RAYFIELD MENU UI SYSTEM (Đổi sang thư viện Rayfield siêu ổn định)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "Banana Hub | Auto Chest",
   LoadingTitle = "Đang Tải Giao Diện...",
   LoadingSubtitle = "by AI Assistant",
   ConfigurationSaving = {
      Enabled = false -- Tắt lưu file cấu hình để tránh lỗi bộ nhớ executor
   },
   KeySystem = false -- Tắt hệ thống nhập key để vào thẳng menu nhanh chóng
})

-- KHỞI TẠO CÁC MỤC Ở THANH DANH MỤC BÊN TRÁI (Tabs)
local MainTab = Window:CreateTab("Main", 4483362458)       -- Icon Home
local CombatTab = Window:CreateTab("Combat", 4483362458)   -- Mục bổ sung sau
local TeleportTab = Window:CreateTab("Teleport", 4483362458) -- Mục bổ sung sau
local SettingsTab = Window:CreateTab("Cấu Hình", 4483362458) -- Mục bổ sung sau

-- THÊM TÍNH NĂNG BẬT/TẮT VÀO TRONG TAB "MAIN"
local ToggleChest = MainTab:CreateToggle({
   Name = "Tự Động Nhặt Rương (Silver/Gold)",
   CurrentValue = false,
   Flag = "ToggleAutoChest", 
   Callback = function(Value)
      _G.AutoChest = Value
   end,
})

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
