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

--// 5. HÀM TẠO TAB & TOGGLE
local function CreateTab(name, isDefault)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.BackgroundColor3 = isDefault and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(30, 30, 30)
    TabBtn.Text = name
    TabBtn.TextColor3 = isDefault and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
    TabBtn.Font = Enum.Font.GothamSemibold
    TabBtn.TextSize = 14
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    local Page = Instance.new("ScrollingFrame", ContentArea)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.Visible = isDefault
    Page.ScrollBarThickness = 2
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

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
    Frame.Size = UDim2.new(1, -10, 0, 45)
    Frame.BackgroundColor3 = Color3.fromRGB(255, 25, 25)
    Frame.BackgroundTransparency = 0.95
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Frame).Color = Color3.fromRGB(40,40,40)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 14
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1

    local Tog = Instance.new("TextButton", Frame)
    Tog.Size = UDim2.new(0, 40, 0, 20)
    Tog.Position = UDim2.new(1, -50, 0.5, -10)
    Tog.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Tog.Text = ""
    Instance.new("UICorner", Tog).CornerRadius = UDim.new(1, 0)
    
    local TogCircle = Instance.new("Frame", Tog)
    TogCircle.Size = UDim2.new(0, 16, 0, 16)
    TogCircle.Position = UDim2.new(0, 2, 0.5, -8)
    TogCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", TogCircle).CornerRadius = UDim.new(1, 0)

    local state = false
    Tog.MouseButton1Click:Connect(function()
        state = not state
        ApplyTween(Tog, 0.2, {BackgroundColor3 = state and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 50, 50)})
        ApplyTween(TogCircle, 0.2, {Position = state and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
        callback(state)
    end)
end

--=============================================================================
--                         KHỞI TẠO CÁC TABS
--=============================================================================

local MainTab = CreateTab("Trang Chủ", true)
AddToggle(MainTab, "Càn Quét Rương Tốc Độ (V10)", function(v) _G.AutoChest = v end)
AddToggle(MainTab, "Tự Động Đổi Server Thông Minh", function(v) _G.AutoHop = v end)

local V4Tab = CreateTab("Tộc V4", false)
AddToggle(V4Tab, "Tự Động Đồ Sát Trial", function(v) _G.AutoKillPlayers = v end)
AddToggle(V4Tab, "Đan Xen Fruit & Melee (M1)", function(v) _G.WeaveFastAttack = v end)

--=============================================================================
--                         LOGIC HỆ THỐNG PHỤ TRỢ
--=============================================================================

local function HopServer()
    local fileName = "banana_hop_history.json"
    local history = {}
    if isfile and isfile(fileName) then pcall(function() history = HttpService:JSONDecode(readfile(fileName)) end) end
    if type(history) ~= "table" then history = {} end
    if #history > 30 then table.remove(history, 1) end
    local success, result = pcall(function()
        local req = game:HttpGet("https://games.roproxy.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
        local data = HttpService:JSONDecode(req)
        if data and data.data then
            local validServers = {}
            for _, server in pairs(data.data) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers and server.playing > 1 then
                    local visited = false
                    for _, oldId in pairs(history) do if oldId == server.id then visited = true break end end
                    if not visited then table.insert(validServers, server) end
                end
            end
            if #validServers > 0 then
                local chosenServer = validServers[math.random(1, #validServers)]
                table.insert(history, chosenServer.id)
                if writefile then writefile(fileName, HttpService:JSONEncode(history)) end
                TeleportService:TeleportToPlaceInstance(game.PlaceId, chosenServer.id, LocalPlayer)
                return true
            end
        end
    end)
    if not success then TeleportService:Teleport(game.PlaceId, LocalPlayer) end
end

local function MaintainHover()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = root:FindFirstChild("BananaHoverForce")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "BananaHoverForce"
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root
    end
end

local function RemoveHover()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local bv = root and root:FindFirstChild("BananaHoverForce")
    if bv then bv:Destroy() end
end

local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildWhichIsA("Humanoid")
    if not root or not hum then return false end
    hum.PlatformStand = true
    root.Anchored = false 
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local info = TweenInfo.new(dist/280, Enum.EasingStyle.Linear)
    local tw = TweenService:Create(root, info, {CFrame = targetCFrame})
    local isPlaying = true
    local connection
    connection = tw.Completed:Connect(function()
        isPlaying = false
        if hum and hum.Parent then hum.PlatformStand = false end
        if root and root.Parent then root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
        connection:Disconnect()
    end)
    tw:Play()
    while isPlaying and root.Parent do task.wait() end
    return true
end

local function GetClosestPlayerInTrial()
    local closestPlayer = nil
    local shortestDistance = 250
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildWhichIsA("Humanoid")
            if hum and hum.Health > 0 then
                local distance = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = p
                end
            end
        end
    end
    return closestPlayer
end

local function GetMeleeTool()
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and table.find(MELEE_LIST, tool.Name) then return tool end
    end
    for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") and table.find(MELEE_LIST, tool.Name) then return tool end
    end
    return nil
end

local function GetFruitTool()
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:find("Fruit") or tool.Name:find("-") or tool.Name:find("Trái")) and not table.find(MELEE_LIST, tool.Name) then 
            return tool 
        end
    end
    for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:find("Fruit") or tool.Name:find("-") or tool.Name:find("Trái")) and not table.find(MELEE_LIST, tool.Name) then 
            return tool 
        end
    end
    return nil
end

local function GetIslands()
    local targets = {}
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and not Players:GetPlayerFromCharacter(v) and v.Name ~= "Chests" and not v.Name:find("NPC") then
            local base = v:FindFirstChild("IslandPart") or v:FindFirstChildWhichIsA("BasePart")
            if base and base.Size.Magnitude > 150 then table.insert(targets, base.CFrame) end
        end
    end
    return targets
end

local function GetChest()
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name:find("Chest") and not collectedChests[v] then
            local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("RootPart") or (v:IsA("BasePart") and v)
            if part then return part, v end
        end
    end
    for _, folderName in pairs({"Chests", "ChestModels", "ChestSpawns"}) do
        local folder = workspace:FindFirstChild(folderName)
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if v.Name:find("Chest") and not collectedChests[v] then
                    local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("RootPart") or (v:IsA("BasePart") and v)
                    if part then return part, v end
                end
            end
        end
    end
end

--=============================================================================
--           XỬ LÝ CHẾ ĐỘ ĐÁNH THEO ĐÚNG YÊU CẦU PHÂN CHIA NÚT BẤT
--=============================================================================
task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if _G.AutoKillPlayers then
            local targetPlayer = GetClosestPlayerInTrial()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildWhichIsA("Humanoid")
            
            if targetPlayer and char and hum then
                local meleeTool = GetMeleeTool()
                
                -- CHẾ ĐỘ NÚT BÊN DƯỚI BẬT: Kết hợp đan xen (2 Fruit M1 -> 2 Melee M1)
                if _G.WeaveFastAttack then
                    local fruitTool = GetFruitTool()
                    if fruitTool and meleeTool then
                        hum:EquipTool(fruitTool)
                        fruitTool:Activate()
