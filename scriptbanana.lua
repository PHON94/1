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

local collectedChests = setmetatable({}, {__mode = "k"})
local MELEE_LIST = {
    "Combat", "Dark Step", "Electro", "Water Kung Fu", "Dragon Breath", 
    "Superhuman", "Death Step", "Sharkman Karate", "Electric Claw", 
    "Dragon Talon", "Godhuman", "Sanguine Art"
}

--// DỌN DẸP UI CŨ KHỎI CORE_GUI
if game:GetService("CoreGui"):FindFirstChild("BananaHubPremium") then
    game:GetService("CoreGui").BananaHubPremium:Destroy()
end

--// KHỞI TẠO SCREEN GUI
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "BananaHubPremium"
ScreenGui.ResetOnSpawn = false

local function ApplyTween(obj, info, goal)
    return TweenService:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal):Play()
end

--// 1. KHUNG CHÍNH (MAIN FRAME)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 550, 0, 350)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(45, 45, 45)

-- Hệ thống kéo thả Menu
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
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

--// 2. THANH BÊN (SIDEBAR) & NỘI DUNG
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

local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Position = UDim2.new(0, 170, 0, 50)
ContentArea.Size = UDim2.new(1, -180, 1, -60)
ContentArea.BackgroundTransparency = 1

--// 3. NÚT THU GỌN / ĐÓNG MENU
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
RestoreBtn.Size = UDim2.new(0, 45, 0, 45)
RestoreBtn.Position = UDim2.new(0, 15, 0, 15)
RestoreBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
RestoreBtn.Text = "B"
RestoreBtn.Font = Enum.Font.GothamBold
RestoreBtn.TextSize = 22
RestoreBtn.TextColor3 = Color3.fromRGB(0,0,0)
RestoreBtn.Visible = false
Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(1, 0)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame:TweenSize(UDim2.new(0,0,0,0), "Out", "Quart", 0.2, true)
    task.wait(0.2) MainFrame.Visible = false RestoreBtn.Visible = true
end)

RestoreBtn.MouseButton1Click:Connect(function()
    RestoreBtn.Visible = false MainFrame.Visible = true
    MainFrame:TweenSize(UDim2.new(0, 550, 0, 350), "Out", "Quart", 0.2, true)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

--// 4. HÀM TẠO TAB & TOGGLE (ĐÃ SỬA LỖI TỌA ĐỘ POSITION)
local function CreateTab(name, isDefault)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = isDefault and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(30, 30, 30)
    TabBtn.Text = name
    TabBtn.TextColor3 = isDefault and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 13
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = isDefault
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticCanvasSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)

    local ListLayout = Instance.new("UIListLayout", Page)
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(ContentArea:GetChildren()) do p.Visible = false end
        for _, b in pairs(TabContainer:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                b.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    return Page
end

local function AddToggle(page, text, callback)
    local Frame = Instance.new("Frame", page)
    Frame.Size = UDim2.new(1, -10, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 25, 25)
    Frame.BackgroundTransparency = 0.96
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0) -- Đã sửa lỗi thiếu tham số ở đây
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Tog = Instance.new("TextButton", Frame)
    Tog.Size = UDim2.new(0, 36, 0, 18)
    Tog.Position = UDim2.new(1, -48, 0.5, -9)
    Tog.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Tog.Text = ""
    Instance.new("UICorner", Tog).CornerRadius = UDim.new(1, 0)
    
    local TogCircle = Instance.new("Frame", Tog)
    TogCircle.Size = UDim2.new(0, 14, 0, 14)
    TogCircle.Position = UDim2.new(0, 2, 0.5, -7)
    TogCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", TogCircle).CornerRadius = UDim.new(1, 0)

    local state = false
    Tog.MouseButton1Click:Connect(function()
        state = not state
        ApplyTween(Tog, 0.15, {BackgroundColor3 = state and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 50, 50)})
        ApplyTween(TogCircle, 0.15, {Position = state and UDim2.new(0, 20, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
        callback(state)
    end)
end

--=============================================================================
--         TÍCH HỢP TOÀN BỘ CÁC NÚT CHỨC NĂNG CŨ VÀ MỚI
--=============================================================================
local MainTab = CreateTab("Trang Chủ", true)
AddToggle(MainTab, "Càn Quét Rương Tốc Độ (V10)", function(v) _G.AutoChest = v end)
AddToggle(MainTab, "Tự Động Đổi Server Thông Minh", function(v) _G.AutoHop = v end)

local V4Tab = CreateTab("Tộc V4", false)
AddToggle(V4Tab, "Tự Động Đồ Sát Trial", function(v) _G.AutoKillPlayers = v end)
AddToggle(V4Tab, "Đan Xen Fruit & Melee (M1)", function(v) _G.WeaveFastAttack = v end)

--=============================================================================
--                         HỆ THỐNG LOGIC PHỤ TRỢ
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
    local tw = TweenService:Create(root, TweenInfo.new((root.Position - targetCFrame.Position).Magnitude/280, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    local isPlaying = true
    local conn; conn = tw.Completed:Connect(function() isPlaying = false hum.PlatformStand = false root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) conn:Disconnect() end)
    tw:Play()
    while isPlaying and root.Parent do task.wait() end
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
--         VÒNG LẶP FAST ATTACK QUA REMOTE REGISTERATTACK BẠN GỬI
--=============================================================================
task.spawn(function()
    local attackCounter, lastAttackTime, attackCooldown = 0, 0, 0.05
    while true do
        RunService.Heartbeat:Wait()
        if _G.AutoKillPlayers then
            local target = GetClosestPlayerInTrial()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if target and char and hum and root then
                local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    MaintainHover() root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.5)
                    local melee = GetTool(true)
                    if (root.Position - tRoot.Position).Magnitude <= 15 and (tick() - lastAttackTime) >= attackCooldown then
                        local remote = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):FindFirstChild("RE/RegisterAttack")
                        if remote then
                            if _G.WeaveFastAttack then
                                local fruit = GetTool(false)
                                if fruit and melee then
                                    attackCounter = attackCounter + 1
                                    local tool = attackCounter <= 2 and fruit or melee
                                    if hum.Parent and tool.Parent ~= char then hum:EquipTool(tool) end
                                    remote:FireServer(0.4000000059604645) lastAttackTime = tick()
                                    if attackCounter >= 4 then attackCounter = 0 end
                                elseif melee then
                                    if hum.Parent and melee.Parent ~= char then hum:EquipTool(melee) end
                                    remote:FireServer(0.4000000059604645) lastAttackTime = tick()
                                end
                            else
                                if melee then
                                    if hum.Parent and melee.Parent ~= char then hum:EquipTool(melee) end
                                    remote:FireServer(0.4000000059604645) lastAttackTime = tick()
                                end
                            end
                        end
                    end
                end
            else RemoveHover() end
        else RemoveHover() end
    end
end)

--=============================================================================
--       VÒNG LẶP CHÍNH CHẠY CHỨC NĂNG NHẶT RƯƠNG CŨ & TỰ HOP SERVER
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
