--=============================================================================
--    PHONGDZ HUB V16 - PHIÊN BẢN ĐỒ SÁT TRIAL SIÊU TỐC & EXPAND HITBOX (FIXED)
--=============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

--// TRẠNG THÁI
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

--// CACHE REMOTE
local remoteCache = { registerAttack = nil, registerHit = nil }
local lastAttackTime = 0
local ATTACK_COOLDOWN = 0.1 -- 100ms giữa các attack
local PLAYER_DETECTION_RANGE = 300 -- 300 stud

--// XÓA GIAO DIỆN CŨ
if game:GetService("CoreGui"):FindFirstChild("PhongdzHub") then
    game:GetService("CoreGui").PhongdzHub:Destroy()
end

--// SCREEN GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "PhongdzHub"
ScreenGui.ResetOnSpawn = false

--// 1. KHUNG CHÍNH (MAIN)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 450, 0, 250)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- Kéo thả Menu
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
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

--// 2. CỘT TRÁI (SIDEBAR)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.Position = UDim2.new(0, 0, 0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)

local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 40)
Logo.Text = "PHONGDZ HUB"
Logo.TextColor3 = Color3.fromRGB(255, 255, 0)
Logo.TextSize = 16
Logo.Font = Enum.Font.SourceSansBold
Logo.BackgroundTransparency = 1

--// 3. CỘT PHẢI (CONTENT AREA)
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size = UDim2.new(1, -135, 1, -40)
ContentArea.Position = UDim2.new(0, 135, 0, 40)
ContentArea.BackgroundTransparency = 1

local TopButtons = Instance.new("Frame", MainFrame)
TopButtons.Size = UDim2.new(1, -130, 0, 40)
TopButtons.Position = UDim2.new(0, 130, 0, 0)
TopButtons.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", TopButtons)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

local MinimizeBtn = CloseBtn:Clone()
MinimizeBtn.Text = "-"
MinimizeBtn.Position = UDim2.new(1, -60, 0.5, -12)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinimizeBtn.Parent = TopButtons

local RestoreBtn = Instance.new("TextButton", ScreenGui)
RestoreBtn.Size = UDim2.new(0, 45, 0, 45)
RestoreBtn.Position = UDim2.new(0, 15, 0, 15)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
RestoreBtn.Text = "Mở"
RestoreBtn.Font = Enum.Font.SourceSansBold
RestoreBtn.TextSize = 16
RestoreBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
RestoreBtn.Visible = false
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)

MinimizeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false RestoreBtn.Visible = true end)
RestoreBtn.MouseButton1Click:Connect(function() RestoreBtn.Visible = false MainFrame.Visible = true end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--// 4. HÀM TẠO GIAO DIỆN ÉP TOẠ ĐỘ
local tabCount = 0
local pages = {}
local tabButtons = {}

local function CreateTab(name, isDefault)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -10, 0, 32)
    TabBtn.Position = UDim2.new(0, 5, 0, 45 + (tabCount * 36))
    TabBtn.BackgroundColor3 = isDefault and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(30, 30, 30)
    TabBtn.Text = name
    TabBtn.TextColor3 = isDefault and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(220, 220, 220)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)

    local Page = Instance.new("Frame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Position = UDim2.new(0, 0, 0, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = isDefault

    table.insert(pages, Page)
    table.insert(tabButtons, TabBtn)
    tabCount = tabCount + 1

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(pages) do p.Visible = false end
        for _, b in pairs(tabButtons) do 
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 30) 
            b.TextColor3 = Color3.fromRGB(220, 220, 220)
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)

    return { frame = Page, itemCount = 0 }
end

local function AddToggle(pageData, text, callback)
    local Frame = Instance.new("Frame", pageData.frame)
    Frame.Size = UDim2.new(1, -10, 0, 36)
    Frame.Position = UDim2.new(0, 0, 0, pageData.itemCount * 42)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSansBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Tog = Instance.new("TextButton", Frame)
    Tog.Size = UDim2.new(0, 36, 0, 18)
    Tog.Position = UDim2.new(1, -45, 0.5, -9)
    Tog.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Tog.Text = ""
    Instance.new("UICorner", Tog).CornerRadius = UDim.new(1, 0)
    
    local TogCircle = Instance.new("Frame", Tog)
    TogCircle.Size = UDim2.new(0, 14, 0, 14)
    TogCircle.Position = UDim2.new(0, 2, 0.5, -7)
    TogCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    Instance.new("UICorner", TogCircle).CornerRadius = UDim.new(1, 0)

    local state = false
    Tog.MouseButton1Click:Connect(function()
        state = not state
        Tog.BackgroundColor3 = state and Color3.fromRGB(255, 255, 0) or Color3.fromRGB(60, 60, 60)
        TogCircle.Position = state and UDim2.new(0, 20, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        TogCircle.BackgroundColor3 = state and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        callback(state)
    end)

    pageData.itemCount = pageData.itemCount + 1
end

--=============================================================================
--         TÍCH HỢP NÚT CHỨC NĂNG VÀO TỪNG CỘT
--=============================================================================
local MainTab = CreateTab("Trang Chủ", true)
AddToggle(MainTab, "Càn Quét Rương Nhanh", function(v) _G.AutoChest = v end)
AddToggle(MainTab, "Tự Động Đổi Server", function(v) _G.AutoHop = v end)

local V4Tab = CreateTab("Tộc V4", false)
AddToggle(V4Tab, "OVERCLOCK: Đồ Sát Trial", function(v) _G.AutoKillPlayers = v end)
AddToggle(V4Tab, "Đan Xen Trái Ác Quỷ & Melee", function(v) _G.WeaveFastAttack = v end)

--=============================================================================
--                         HỆ THỐNG LOGIC VẬN HÀNH
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
    bv.Name = "BananaHoverForce"; bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Parent = root
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
    if not root or not hum or hum.Health <= 0 then return false end
    
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local speed = 350 
    local duration = distance / speed
    
    hum.PlatformStand = true
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    local completed = false
    local connection
    connection = tween.Completed:Connect(function()
        completed = true
        if connection then connection:Disconnect() end
    end)
    
    --// FIX: THÊM TIMEOUT ĐỂ TRÁNH BỊ TREO
    local timeoutCounter = 0
    while not completed and _G.AutoChest and hum.Health > 0 do
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        timeoutCounter = timeoutCounter + 1
        if timeoutCounter > 500 then -- 5 giây timeout (0.01 * 500 = 5s)
            tween:Cancel()
            if connection then connection:Disconnect() end
            hum.PlatformStand = false
            return false
        end
        task.wait(0.01)
    end
    
    --// FIX: CHỈ KIỂM TRA TWEEN ĐÃ HOÀN THÀNH HAY CHƯA
    hum.PlatformStand = false
    return completed
end

--// ✅ CHỈNH SỬA: Quét người trong phạm vi 300 stud
local function GetClosestPlayerInTrial()
    local closest, shortDist = nil, PLAYER_DETECTION_RANGE
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health > 0 then
                local dist = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                -- Chỉ tính người trong phạm vi 300 stud
                if dist < shortDist then 
                    shortDist = dist 
                    closest = p 
                end
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

--// CACHE REMOTE HÀM
local function CacheRemotes()
    if not remoteCache.registerAttack or not remoteCache.registerHit then
        pcall(function()
            local net = game:GetService("ReplicatedStorage").Modules.Net
            remoteCache.registerAttack = net:FindFirstChild("RE/RegisterAttack")
            remoteCache.registerHit = net:FindFirstChild("RE/RegisterHit")
        end)
    end
    return remoteCache.registerAttack, remoteCache.registerHit
end

--// ✅ TỐI ƯU: Quét TẤT CẢ rương trong toàn map (FIX CẤUTRÚC CHEST)
local function GetAllChests()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return {} end
    
    local chests = {}
    local checkedModels = setmetatable({}, {__mode = "k"})
    
    local function checkChest(v)
        if checkedModels[v] then return end
        checkedModels[v] = true
        
        -- Tìm Chest1, Chest2, Chest3 (không phải folder "Chest")
        if (v.Name == "Chest1" or v.Name == "Chest2" or v.Name == "Chest3") and not collectedChests[v] then
            local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("RootPart") or (v:IsA("BasePart") and v)
            if part then
                local dist = (myRoot.Position - part.Position).Magnitude
                table.insert(chests, { part = part, model = v, distance = dist })
            end
        end
    end
    
    -- Quét ChestModels/Map (chỉ quét Map, bỏ Elements vì đó là quái)
    local chestModels = workspace:FindFirstChild("ChestModels")
    if chestModels then
        local mapFolder = chestModels:FindFirstChild("Map")
        if mapFolder then
            -- Quét tất cả descendants để tìm Chest1, Chest2, Chest3
            for _, v in pairs(mapFolder:GetDescendants()) do
                checkChest(v)
            end
        end
    end
    
    -- Fallback: Quét trực tiếp Chests folder nếu có
    local chestFolder = workspace:FindFirstChild("Chests")
    if chestFolder then
        for _, v in pairs(chestFolder:GetDescendants()) do
            checkChest(v)
        end
    end
    
    -- Sắp xếp theo khoảng cách
    table.sort(chests, function(a, b) return a.distance < b.distance end)
    
    return chests
end

--// VÒNG LẶP LIÊN TỤC KHÓA NOCLIP XUYÊN TƯỜNG (ANTI-KẸT ĐẢO)
RunService.Stepped:Connect(function()
    if _G.AutoChest or _G.AutoKillPlayers then
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root and root.CanCollide then
                root.CanCollide = false
            end
        end
    end
end)

--// CHỈNH SỬA: VÒNG LẶP TỰ ĐỘNG TĂNG PHẠM VI HITBOX (EXPAND HITBOX) CỦA PLAYER KHÁC
task.spawn(function()
    local playerStates = {}
    while true do
        task.wait(0.3)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local shouldExpand = _G.AutoKillPlayers
                    local cached = playerStates[p]
                    
                    -- Chỉ update nếu trạng thái thay đổi
                    if cached ~= shouldExpand then
                        playerStates[p] = shouldExpand
                        if shouldExpand then
                            root.Size = Vector3.new(25, 25, 25)
                            root.CanCollide = false
                            root.Transparency = 0.5
                        else
                            root.Size = Vector3.new(2, 2, 1)
                            root.CanCollide = true
                            root.Transparency = 0
                        end
                    end
                end
            end
        end
    end
end)

--=============================================================================
--    VÒNG LẶP SÁT THƯƠNG (DÙNG CẢ 2 REMOTE: RegisterAttack + RegisterHit)
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
                    hum.PlatformStand = true 
                    MaintainHover()
                    
                    -- Dịch chuyển áp sát liên tục vào vị trí mục tiêu
                    root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.2)
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    
                    --// ✅ TỐI ƯU: Cache remote + Giảm spam với cooldown
                    local registerAttack, registerHit = CacheRemotes()
                    
                    if registerAttack and registerHit then
                        local currentTime = tick()
                        -- Chỉ gửi nếu đủ cooldown (0.1 giây)
                        if currentTime - lastAttackTime > ATTACK_COOLDOWN then
                            local melee = GetTool(true)
                            if _G.WeaveFastAttack then
                                local fruit = GetTool(false)
                                if fruit and melee then
                                    attackCounter = attackCounter + 1
                                    local currentTool = (attackCounter <= 2) and fruit or melee
                                    if hum.Parent and currentTool.Parent ~= char then hum:EquipTool(currentTool) end
                                    
                                    --// GỬI CẢ 2 REMOTE: Với cooldown an toàn
                                    pcall(function() registerAttack:FireServer(0.4000000059604645) end)
                                    pcall(function() registerHit:FireServer(0.4000000059604645) end)
                                    lastAttackTime = currentTime
                                    
                                    if attackCounter >= 4 then attackCounter = 0 end
                                elseif melee then
                                    if hum.Parent and melee.Parent ~= char then hum:EquipTool(melee) end
                                    pcall(function() registerAttack:FireServer(0.4000000059604645) end)
                                    pcall(function() registerHit:FireServer(0.4000000059604645) end)
                                    lastAttackTime = currentTime
                                end
                            else
                                if melee then
                                    if hum.Parent and melee.Parent ~= char then hum:EquipTool(melee) end
                                    pcall(function() registerAttack:FireServer(0.4000000059604645) end)
                                    pcall(function() registerHit:FireServer(0.4000000059604645) end)
                                    lastAttackTime = currentTime
                                end
                            end
                        end
                    end
                end
            else 
                if hum then hum.PlatformStand = false end 
                RemoveHover() 
            end
        else
            local char = LocalPlayer.Character 
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum.PlatformStand = false end 
            RemoveHover()
        end
    end
end)

--=============================================================================
--         VÒNG LẶP RƯƠNG (CẢI THIỆN - Quét TẤT CẢ RƯƠNG TOÀN MAP)
--=============================================================================
task.spawn(function()
    while true do
        task.wait(0.1)
        if _G.AutoChest then
            local allChests = GetAllChests()
            
            if #allChests > 0 then
                MaintainHover()
                -- Quét lần lượt từ gần đến xa
                for _, chestData in pairs(allChests) do
                    if _G.AutoChest then
                        if TweenTo(chestData.part.CFrame * CFrame.new(0, 2, 0)) then 
                            collectedChests[chestData.model] = true 
                            task.wait(0.2) -- Delay trước khi quét cái tiếp theo
                        end
                    end
                end
            else
                -- Không còn rương nữa, đổi server
                if _G.AutoHop then 
                    HopServer() 
                end
            end
        else
            RemoveHover()
        end
    end
end())
