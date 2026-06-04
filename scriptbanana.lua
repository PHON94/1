--=============================================================================
--         BANANA HUB PREMIUM V7 - BAY THẤP SIÊU MƯỢT & CHỐNG GIẬT CAMERA
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
local islandList = {}
local currentIslandIdx = 1
local collectedChests = setmetatable({}, {__mode = "k"})

--// DỌN DẸP UI CŨ
if game:GetService("CoreGui"):FindFirstChild("BananaHubPremium") then
    game:GetService("CoreGui").BananaHubPremium:Destroy()
end

--// KHỞI TẠO SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PhongdzHubPremium"
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
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
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

--// TẠO NỘI DUNG TAB
local MainTab = CreateTab("Trang Chủ", true)

AddToggle(MainTab, "Càn Quét Rương Siêu Mượt (V7)", function(v)
    _G.AutoChest = v
end)

AddToggle(MainTab, "Tự Động Đổi Server Thông Minh", function(v)
    _G.AutoHop = v
end)

--// HỆ THỐNG HOP SERVER CHỐNG LẶP DỮ LIỆU
local function HopServer()
    local fileName = "banana_hop_history.json"
    local history = {}
    
    if isfile and isfile(fileName) then
        pcall(function() history = HttpService:JSONDecode(readfile(fileName)) end)
    end
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
                    for _, oldId in pairs(history) do
                        if oldId == server.id then visited = true break end
                    end
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

--// HÀM TWEEN SIÊU MƯỢT (CHỐNG RUNG GIẬT PHÝSICS)
local function TweenTo(targetCFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    -- KHÓA CỨNG VẬT LÝ NHÂN VẬT: Loại bỏ hoàn toàn hiện tượng rung lắc camera
    root.Anchored = true
    
    local dist = (root.Position - targetCFrame.Position).Magnitude
    local info = TweenInfo.new(dist/280, Enum.EasingStyle.Linear)
    local tw = TweenService:Create(root, info, {CFrame = targetCFrame})
    tw:Play()
    
    -- Khi bay tới đích, mở khóa vật lý ngay lập tức để nhặt rương
    local connection
    connection = tw.Completed:Connect(function()
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
        root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        connection:Disconnect()
    end)
    
    return tw
end

local function GetIslands()
    local targets = {}
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and not Players:GetPlayerFromCharacter(v) and v.Name ~= "Chests" and not v.Name:find("NPC") then
            local base = v:FindFirstChild("IslandPart") or v:FindFirstChildWhichIsA("BasePart")
            if base and base.Size.Magnitude > 150 then
                table.insert(targets, base.CFrame)
            end
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

--// VÒNG LẶP CHÍNH V7
task.spawn(function()
    while true do
        task.wait()
        
        if _G.AutoChest then
            local chestPart, chestModel = GetChest()
            
            if chestPart and chestModel then
                local tw = TweenTo(chestPart.CFrame)
                if tw then tw.Completed:Wait() end
                
                if firetouchinterest then
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, chestPart, 0)
                    task.wait()
                    firetouchinterest(LocalPlayer.Character.HumanoidRootPart, chestPart, 1)
                end
                
                collectedChests[chestModel] = true
            else
                if #islandList == 0 then
                    islandList = GetIslands()
                end
                
                if #islandList > 0 then
                    if currentIslandIdx > #islandList then
                        currentIslandIdx = 1
                        if _G.AutoHop then
                            HopServer()
                            task.wait(5)
                        end
                    end
                    
                    local targetIsland = islandList[currentIslandIdx]
                    if targetIsland then
                        -- ĐÃ HẠ THẤP ĐỘ CAO: Thay vì +120 studs, giờ chỉ cộng +30 studs để bay là là sát mặt đảo
                        local safetyCFrame = targetIsland + Vector3.new(0, 30, 0)
                        local tw = TweenTo(safetyCFrame)
                        if tw then tw.Completed:Wait() end
                        
                        task.wait(0.2)
                    end
                    currentIslandIdx = currentIslandIdx + 1
                else
                    if _G.AutoHop then HopServer() task.wait(5) end
                end
            end
        end
    end
end)

-- Hệ thống xuyên tường toàn diện
RunService.Stepped:Connect(function()
    if _G.AutoChest and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)
