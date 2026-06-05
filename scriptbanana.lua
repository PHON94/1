--=============================================================================
--    BANANA HUB PREMIUM V16 - STYLE V10 KHỬ LỖI MẤT NÚT TRÊN DELTA MOBILE
--=============================================================================

local Players = game:GetService("Players")
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

local collectedChests = setmetatable({}, {__mode = "k"})
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
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "BananaHubPremium"
ScreenGui.ResetOnSpawn = false

--// 1. KHUNG CHÍNH (STYLE V10)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 420, 0, 250)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Màu đen mờ V10
MainFrame.BorderSizePixel = 0

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 5)

-- Hệ thống kéo thả Menu bằng cảm ứng Mobile
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

--// 2. THANH TIÊU ĐỀ BANANA V10
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 5)

local Title = Instance.new("TextLabel", TopBar)
Title.Size = UDim2.new(0, 150, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Text = "Banana Hub V10"
Title.TextColor3 = Color3.fromRGB(255, 255, 0) -- Màu vàng chuối huyền thoại
Title.TextSize = 15
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Nút ẩn / hiện và đóng menu
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local MinimizeBtn = CloseBtn:Clone()
MinimizeBtn.Text = "-"
MinimizeBtn.Position = UDim2.new(1, -55, 0.5, -11)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MinimizeBtn.Parent = TopBar

local RestoreBtn = Instance.new("TextButton", ScreenGui)
RestoreBtn.Size = UDim2.new(0, 40, 0, 40)
RestoreBtn.Position = UDim2.new(0, 15, 0, 15)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
RestoreBtn.Text = "Chuối"
RestoreBtn.Font = Enum.Font.SourceSansBold
RestoreBtn.TextSize = 13
RestoreBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
RestoreBtn.Visible = false
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false RestoreBtn.Visible = true end)
RestoreBtn.MouseButton1Click:Connect(function() RestoreBtn.Visible = false MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--// 3. THANH DANH MỤC TABS NẰM NGANG CHUẨN V10
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -16, 0, 30)
TabBar.Position = UDim2.new(0, 8, 0, 40)
TabBar.BackgroundTransparency = 1
local TabListLayout = Instance.new("UIListLayout", TabBar)
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.Padding = UDim.new(0, 6)

-- Vùng chứa nội dung (Dùng Frame thường, TUYỆT ĐỐI BỎ SCROLLINGFRAME GÂY MẤT NÚT)
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Position = UDim2.new(0, 8, 0, 78)
ContentArea.Size = UDim2.new(1, -16, 1, -86)
ContentArea.BackgroundTransparency = 1

--// 4. HÀM TẠO TAB VÀ TOGGLE GIAO DIỆN V10 ĐÃ FIX LỖI DELTA
local firstTab = true
local function CreateTab(name)
    local TabBtn = Instance.new("TextButton", TabBar)
    TabBtn.Size = UDim2.new(0, 95, 1, 0)
    TabBtn.BackgroundColor3 = firstTab and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(35, 35, 35)
    TabBtn.Text = name
    TabBtn.TextColor3 = firstTab and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(230, 230, 230)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

    -- Sử dụng Frame thường để ép Delta bắt buộc phải hiển thị nút ra màn hình
    local Page = Instance.new("Frame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = firstTab

    local ListLayout = Instance.new("UIListLayout", Page)
    ListLayout.Padding = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentArea:GetChildren()) do p.Visible = false end
        for _, b in pairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then 
                b.BackgroundColor3 = Color3.fromRGB(35, 35, 35) 
                b.TextColor3 = Color3.fromRGB(230, 230, 230)
            end
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    
    firstTab = false
    return Page
end

local function AddToggle(page, text, callback)
    local Frame = Instance.new("Frame", page)
    Frame.Size = UDim2.new(1, 0, 0, 36) -- Đặt kích thước chính xác tuyệt đối
    Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSans
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Tog = Instance.new("TextButton", Frame)
    Tog.Size = UDim2.new(0, 32, 0, 16)
    Tog.Position = UDim2.new(1, -42, 0.5, -8)
    Tog.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Tog.Text = ""
    Instance.new("UICorner", Tog).CornerRadius = UDim.new(1, 0)
    
    local TogCircle = Instance.new("Frame", Tog)
    TogCircle.Size = UDim2.new(0, 12, 0, 12)
    TogCircle.Position = UDim2.new(0, 2, 0.5, -6)
    TogCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", TogCircle).CornerRadius = UDim.new(1, 0)

    local state = false
    Tog.MouseButton1Click:Connect(function()
        state = not state
        Tog.BackgroundColor3 = state and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(60, 60, 60)
        TogCircle.Position = state and UDim2.new(0, 18, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        TogCircle.BackgroundColor3 = state and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        callback(state)
    end)
end

--=============================================================================
--         TÍCH HỢP NÚT CHỨC NĂNG (GIAO DIỆN KHÔNG SCROLL - HIỆN 100%)
--=============================================================================
local MainTab = CreateTab("Trang Chủ")
AddToggle(MainTab, "Càn Quét Rương Tốc Độ (V10)", function(v) _G.AutoChest = v end)
AddToggle(MainTab, "Tự Động Đổi Server Thông Minh", function(v) _G.AutoHop = v end)

local V4Tab = CreateTab("Tộc V4")
AddToggle(V4Tab, "OVERCLOCK: Đồ Sát Trial", function(v) _G.AutoKillPlayers = v end)
AddToggle(V4Tab, "Đan Xen Trái Ác Quỷ & Melee", function(v) _G.WeaveFastAttack = v end)

--=============================================================================
--                         HỆ THỐNG LOGIC VẬN HÀNH BÊN TRONG
--=============================================================================
local function HopServer()
    local fileName = "banana_hop_history.json"
    local history = {}
    if isfile and isfile(fileName) then pcall(function() history = HttpService:JSONDecode(readfile(fileName)) end) end
    if type(history) ~= "table" then history = {} end
    if #history > 30 then table.remove(history, 1) end
    pcall(function()
        local req = game:HttpGet("https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(req)
        if data and data.data then
            local validServers = {}
            for _, s in pairs(data.data) do
                if s.id ~= game.JobId and s.playing < s.maxPlayers and s.playing > 1 then
                    local visited = false
                    for _, oldId in pairs(history) do if oldId == s.id then visited = true break end end
                    if not visited then table.insert(validServers, s) end
                end
            end
            if #validServers > 0 then
                local chosen = validServers[math.random(1, #validServers)]
                table.insert(history, chosen.id)
                if writefile then writefile(fileName, HttpService:JSONEncode(history)) end
                TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, LocalPlayer)
            end
        end
    end)
end

local function MaintainHover()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = root:FindFirstChild("BananaHoverForce") or Instance.new("BodyVelocity")
    bv.Name = "BananaHoverForce" bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) bv.Parent = root
end

local function RemoveHover()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local bv = root and root:FindFirstChild("BananaHoverForce")
    if bv then bv:Destroy() end
end

local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if not root or not hum then return false end
    hum.PlatformStand = true root.Anchored = false 
    root.CFrame = targetCFrame
    task.wait(0.1)
    hum.PlatformStand = false
    return true
end

local function GetClosestPlayerInTrial()
    local closest, shortDist = nil, 250
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortDist then shortDist = dist closest = p end
            end
        end
    end
    return closest
end

local function GetTool(isMelee)
    local location = LocalPlayer.Character:FindFirstChildWhichIsA("Tool") and LocalPlayer.Character or LocalPlayer.Backpack
    for _, t in pairs(location:GetChildren()) do
        if t:IsA("Tool") then
            local matched = table.find(MELEE_LIST, t.Name)
            if (isMelee and matched) or (not isMelee and not matched and (t.Name:find("Fruit") or t.Name:find("-") or t.Name:find("Trái"))) then return t end
        end
    end
    return nil
end

local function GetChest()
    local function check(v)
        if v.Name:find("Chest") and not collectedChests[v] then
            return v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("RootPart") or (v:IsA("BasePart") and v)
        end
    end
    for _, v in pairs(workspace:GetChildren()) do local p = check(v) if p then return p, v end end
    for _, fName in pairs({"Chests", "ChestModels", "ChestSpawns"}) do
        local f = workspace:FindFirstChild(fName)
        if f then for _, v in pairs(f:GetChildren()) do local p = check(v) if p then return p, v end end end
    end
end

--=============================================================================
--    VÒNG LẶP FAST ATTACK OVERCLOCK SIÊU SÁT THƯƠNG QUA REMOTE
--=============================================================================
task.spawn(function()
    local attackCounter = 0
    while true do
        RunService.Heartbeat:Wait()
        if _G.AutoKillPlayers then
            local target = GetClosestPlayerInTrial()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if target and char and hum and root and hum.Health > 0 then
                local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                local tHum = target.Character:FindFirstChildWhichIsA("Humanoid")
                if tRoot and tHum and tHum.Health > 0 then
                    hum.PlatformStand = true MaintainHover()
                    root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.2)
                    root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    local remote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):FindFirstChild("RE/RegisterAttack")
                    if remote then
                        local melee = GetTool(true)
                        if _G.WeaveFastAttack then
                            local fruit = GetTool(false)
                            if fruit and melee then
                                attackCounter = attackCounter + 1
                                local currentTool = (attackCounter <= 2) and fruit or melee
                                if hum.Parent and currentTool.Parent ~= char then hum:EquipTool(currentTool) end
                                remote:FireServer(0.4000000059604645) remote:FireServer(0.4000000059604645)
                                remote:FireServer(0.4000000059604645) remote:FireServer(0.4000000059604645)
                                if attackCounter >= 4 then attackCounter = 0 end
                            elseif melee then
                                if hum.Parent and melee.Parent ~= char then hum:EquipTool(melee) end
                                remote:FireServer(0.4000000059604645) remote:FireServer(0.4000000059604645)
                            end
                        else
                            if melee then
                                if hum.Parent and melee.Parent ~= char then hum:EquipTool(melee) end
                                remote:FireServer(0.4000000059604645) remote:FireServer(0.4000000059604645)
                                remote:FireServer(0.4000000059604645) remote:FireServer(0.4000000059604645)
                                remote:FireServer(0.4000000059604645)
                            end
                        end
                    end
                end
            else if hum then hum.PlatformStand = false end RemoveHover() end
        else
            local char = LocalPlayer.Character local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.PlatformStand = false end RemoveHover()
        end
    end
end)

--=============================================================================
--                    VÒNG LẶP PHỤ: QUÉT VÀ NHẶT RƯƠNG V10
--=============================================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoChest and not _G.AutoKillPlayers then
            local cPart, cModel = GetChest()
            if cPart then
                MaintainHover()
                if TweenTo(cPart.CFrame * CFrame.new(0, 2, 0)) then collectedChests[cModel] = true task.wait(0.2) end
            else
                if _G.AutoHop then HopServer() end
            end
        end
    end
end)
