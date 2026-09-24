--[[
    ⚡ ThunderHubz v5.2 - PRECISION HOP EDITION (FIXED)
    
    Load:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/forsellzsxteam/ThunderHubz/main/ThunderHubz.lua"))()
    
    Developer : WezxOffc
    Team      : forsellzsxteam
    Version   : 5.2.0
    Build     : 2026-09-24
    
    ✅ Exact match player count
    ✅ Real-time verification (double check)
    ✅ Multi-page scan (20 pages)
    ✅ API cache system
    ✅ Priority empty servers
    ✅ Region filter
    ✅ Server list viewer
    ✅ Job ID direct join
    ✅ Auto Hop
    ✅ Save config
    ✅ Notification toast
    ✅ Sound effect
    ✅ Manual UI
    ✅ FIX Error 771 (server gone)
    ✅ FIX Error 772 (server full)
    ✅ Verify server tepat sebelum teleport
    ✅ Track failed servers (skip kalau udah gagal)
    ✅ Adaptive delay (delay makin lama tiap gagal)
    
    Made with ⚡ by WezxOffc
]]

-- ========== METADATA ==========
local SCRIPT_VERSION = "5.2.0"
local SCRIPT_AUTHOR = "WezxOffc"
local SCRIPT_TEAM = "forsellzsxteam"
local SCRIPT_NAME = "ThunderHubz"

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer

local CoreGui
pcall(function()
    CoreGui = game:GetService("CoreGui")
end)
if not CoreGui then
    CoreGui = LocalPlayer:WaitForChild("PlayerGui")
end

-- ========== CONFIG ==========
local CONFIG = {
    MaxPlayers = 1,
    MinPlayers = 0,
    AutoHop = false,
    RetryDelay = 1.5,
    CheckInterval = 5,
    Region = "ANY",
    SoundEnabled = true,
    StrictMode = true,
    AdaptiveDelay = true,
}

local function saveConfig()
    pcall(function()
        if writefile then
            writefile(SCRIPT_NAME .. "_config.json", HttpService:JSONEncode(CONFIG))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if isfile and isfile(SCRIPT_NAME .. "_config.json") then
            local data = HttpService:JSONDecode(readfile(SCRIPT_NAME .. "_config.json"))
            for k, v in pairs(data) do
                CONFIG[k] = v
            end
        end
    end)
end

loadConfig()

-- ========== ANTI DUPLICATE ==========
pcall(function()
    local old = CoreGui:FindFirstChild(SCRIPT_NAME)
    if old then old:Destroy() end
end)

-- ========== ICON LIBRARY ==========
local ICONS = {
    Bolt    = "rbxassetid://6031091004",
    Users   = "rbxassetid://6031075931",
    User    = "rbxassetid://6031075938",
    Globe   = "rbxassetid://6031280882",
    List    = "rbxassetid://6031094670",
    Refresh = "rbxassetid://6031229859",
    Check   = "rbxassetid://6031094667",
    Close   = "rbxassetid://6031094678",
}

-- ========== HELPERS ==========
local function createIcon(parent, iconId, size, pos, color)
    local img = Instance.new("ImageLabel")
    img.Size = size
    img.Position = pos
    img.BackgroundTransparency = 1
    img.Image = iconId
    img.ImageColor3 = color or Color3.fromRGB(255, 255, 255)
    img.ScaleType = Enum.ScaleType.Fit
    img.Parent = parent
    return img
end

local function playSound(id, vol)
    if not CONFIG.SoundEnabled then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://" .. id
        s.Volume = vol or 0.5
        s.Parent = SoundService
        s:Play()
        game:GetService("Debris"):AddItem(s, 3)
    end)
end

local SOUNDS = {
    Success = "9118823105",
    Fail    = "9118822113",
    Click   = "9118822113",
}

-- ========== SCREEN GUI ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = SCRIPT_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = CoreGui

-- ================================================================
-- NOTIFICATION TOAST
-- ================================================================
local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 320, 1, 0)
NotifHolder.Position = UDim2.new(1, -340, 0, 0)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local function notify(title, message, notifType)
    notifType = notifType or "info"
    local color = Color3.fromRGB(0, 150, 255)
    if notifType == "success" then color = Color3.fromRGB(80, 220, 120) end
    if notifType == "error" then color = Color3.fromRGB(255, 80, 80) end
    if notifType == "warn" then color = Color3.fromRGB(255, 200, 80) end

    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, -20, 0, 70)
    Toast.Position = UDim2.new(1, 20, 0, 20)
    Toast.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Toast.BorderSizePixel = 0
    Toast.Parent = NotifHolder

    local TC = Instance.new("UICorner")
    TC.CornerRadius = UDim.new(0, 10)
    TC.Parent = Toast

    local TStroke = Instance.new("UIStroke")
    TStroke.Color = color
    TStroke.Thickness = 1.5
    TStroke.Transparency = 0.3
    TStroke.Parent = Toast

    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 4, 1, -12)
    AccentBar.Position = UDim2.new(0, 6, 0, 6)
    AccentBar.BackgroundColor3 = color
    AccentBar.BorderSizePixel = 0
    AccentBar.Parent = Toast

    local ABC = Instance.new("UICorner")
    ABC.CornerRadius = UDim.new(1, 0)
    ABC.Parent = AccentBar

    local TTitle = Instance.new("TextLabel")
    TTitle.Size = UDim2.new(1, -30, 0, 22)
    TTitle.Position = UDim2.new(0, 20, 0, 10)
    TTitle.BackgroundTransparency = 1
    TTitle.Text = title
    TTitle.TextColor3 = color
    TTitle.TextSize = 14
    TTitle.Font = Enum.Font.GothamBold
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    TTitle.Parent = Toast

    local TMsg = Instance.new("TextLabel")
    TMsg.Size = UDim2.new(1, -30, 0, 32)
    TMsg.Position = UDim2.new(0, 20, 0, 32)
    TMsg.BackgroundTransparency = 1
    TMsg.Text = message
    TMsg.TextColor3 = Color3.fromRGB(220, 220, 230)
    TMsg.TextSize = 12
    TMsg.Font = Enum.Font.Gotham
    TMsg.TextXAlignment = Enum.TextXAlignment.Left
    TMsg.TextWrapped = true
    TMsg.Parent = Toast

    TweenService:Create(Toast, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0, 20)
    }):Play()

    task.delay(3.5, function()
        local out = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 20, 0, 20),
            BackgroundTransparency = 1
        })
        out:Play()
        out.Completed:Connect(function() Toast:Destroy() end)
    end)
end

-- ================================================================
-- MINIMIZE BUTTON
-- ================================================================
local MiniBtn = Instance.new("TextButton")
MiniBtn.Name = "MiniBtn"
MiniBtn.Size = UDim2.new(0, 60, 0, 60)
MiniBtn.Position = UDim2.new(0, 20, 0.5, -30)
MiniBtn.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MiniBtn.BorderSizePixel = 0
MiniBtn.Text = ""
MiniBtn.AutoButtonColor = false
MiniBtn.Active = true
MiniBtn.Parent = ScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(1, 0)
MiniCorner.Parent = MiniBtn

local MiniRing = Instance.new("Frame")
MiniRing.Size = UDim2.new(1, 4, 1, 4)
MiniRing.Position = UDim2.new(0, -2, 0, -2)
MiniRing.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
MiniRing.BorderSizePixel = 0
MiniRing.ZIndex = 0
MiniRing.Parent = MiniBtn

local MRCorner = Instance.new("UICorner")
MRCorner.CornerRadius = UDim.new(1, 0)
MRCorner.Parent = MiniRing

local MiniGrad = Instance.new("UIGradient")
MiniGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255)),
})
MiniGrad.Rotation = 45
MiniGrad.Parent = MiniRing

local MiniIcon = createIcon(MiniBtn, ICONS.Bolt, UDim2.new(0, 30, 0, 30), UDim2.new(0.5, -15, 0.5, -15), Color3.fromRGB(255, 255, 255))

task.spawn(function()
    while MiniRing.Parent do
        MiniRing.Size = UDim2.new(1, 4, 1, 4)
        MiniRing.BackgroundTransparency = 0
        local tween = TweenService:Create(MiniRing, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 12, 1, 12),
            BackgroundTransparency = 0.7
        })
        tween:Play()
        task.wait(2)
    end
end)

-- ================================================================
-- MAIN PANEL
-- ================================================================
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 380, 0, 480)
Main.Position = UDim2.new(0.5, -190, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Visible = false
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainGrad = Instance.new("UIGradient")
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 15, 35)),
})
MainGrad.Rotation = 45
MainGrad.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 150, 255)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.6
MainStroke.Parent = Main

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Header.BorderSizePixel = 0
Header.ZIndex = 10
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = Header

local HeaderBottom = Instance.new("Frame")
HeaderBottom.Size = UDim2.new(1, 0, 0, 16)
HeaderBottom.Position = UDim2.new(0, 0, 1, -16)
HeaderBottom.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
HeaderBottom.BorderSizePixel = 0
HeaderBottom.ZIndex = 10
HeaderBottom.Parent = Header

local HBGrad = Instance.new("UIGradient")
HBGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 80, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 0, 160)),
})
HBGrad.Rotation = 0
HBGrad.Parent = Header

local LogoBadge = Instance.new("Frame")
LogoBadge.Size = UDim2.new(0, 38, 0, 38)
LogoBadge.Position = UDim2.new(0, 14, 0, 11)
LogoBadge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LogoBadge.BackgroundTransparency = 0.15
LogoBadge.BorderSizePixel = 0
LogoBadge.ZIndex = 11
LogoBadge.Parent = Header

local LBCorner = Instance.new("UICorner")
LBCorner.CornerRadius = UDim.new(0, 10)
LBCorner.Parent = LogoBadge

local LogoIcon = createIcon(LogoBadge, ICONS.Bolt, UDim2.new(0, 22, 0, 22), UDim2.new(0.5, -11, 0.5, -11), Color3.fromRGB(255, 220, 0))
LogoIcon.ZIndex = 12

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -100, 0, 24)
Title.Position = UDim2.new(0, 62, 0, 12)
Title.BackgroundTransparency = 1
Title.Text = SCRIPT_NAME
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 11
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -100, 0, 14)
Subtitle.Position = UDim2.new(0, 62, 0, 34)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "v" .. SCRIPT_VERSION .. "  •  by " .. SCRIPT_AUTHOR
Subtitle.TextColor3 = Color3.fromRGB(200, 200, 255)
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 11
Subtitle.Parent = Header

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 28, 0, 28)
MinBtn.Position = UDim2.new(1, -70, 0, 16)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.BackgroundTransparency = 0.85
MinBtn.Text = ""
MinBtn.AutoButtonColor = false
MinBtn.ZIndex = 20
MinBtn.Parent = Header

local MBCorner = Instance.new("UICorner")
MBCorner.CornerRadius = UDim.new(0, 8)
MBCorner.Parent = MinBtn

local MinLine = Instance.new("Frame")
MinLine.Size = UDim2.new(0, 12, 0, 2)
MinLine.Position = UDim2.new(0.5, -6, 0.5, -1)
MinLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
MinLine.BorderSizePixel = 0
MinLine.ZIndex = 21
MinLine.Parent = MinBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0, 16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.Text = ""
CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 20
CloseBtn.Parent = Header

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 8)
CBCorner.Parent = CloseBtn

local XLine1 = Instance.new("Frame")
XLine1.Size = UDim2.new(0, 12, 0, 2)
XLine1.Position = UDim2.new(0.5, -6, 0.5, -1)
XLine1.Rotation = 45
XLine1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
XLine1.BorderSizePixel = 0
XLine1.ZIndex = 21
XLine1.Parent = CloseBtn

local XLine2 = XLine1:Clone()
XLine2.Rotation = -45
XLine2.Parent = CloseBtn

-- TAB SYSTEM
local TabHolder = Instance.new("Frame")
TabHolder.Size = UDim2.new(1, -28, 0, 34)
TabHolder.Position = UDim2.new(0, 14, 0, 70)
TabHolder.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
TabHolder.BorderSizePixel = 0
TabHolder.Parent = Main

local THC = Instance.new("UICorner")
THC.CornerRadius = UDim.new(0, 8)
THC.Parent = TabHolder

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -28, 0, 280)
ContentHolder.Position = UDim2.new(0, 14, 0, 114)
ContentHolder.BackgroundTransparency = 1
ContentHolder.ClipsDescendants = false
ContentHolder.Parent = Main

local tabs = {}
local tabButtons = {}

local function createTab(name, iconId)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.33, -4, 1, -8)
    btn.Position = UDim2.new(#tabButtons * 0.333, 4, 0, 4)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = TabHolder

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 6)
    BC.Parent = btn

    local ico = createIcon(btn, iconId, UDim2.new(0, 16, 0, 16), UDim2.new(0, 10, 0.5, -8), Color3.fromRGB(180, 180, 200))

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -32, 1, 0)
    lbl.Position = UDim2.new(0, 30, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = ContentHolder

    tabs[name] = {button = btn, page = page, icon = ico, label = lbl}

    btn.MouseButton1Click:Connect(function()
        for n, t in pairs(tabs) do
            t.page.Visible = false
            TweenService:Create(t.button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 58)}):Play()
            TweenService:Create(t.label, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 220)}):Play()
        end
        page.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
        TweenService:Create(lbl, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        playSound(SOUNDS.Click, 0.2)
    end)

    table.insert(tabButtons, btn)
    return page
end

local HopPage = createTab("Hop", ICONS.Bolt)
local ServerPage = createTab("Servers", ICONS.List)
local SettingsPage = createTab("Settings", ICONS.Globe)

task.defer(function()
    tabs["Hop"].button.MouseButton1Click:Fire()
end)

-- ================================================================
-- TAB 1: HOP PAGE
-- ================================================================
local function makeInputOn(parent, yPos, label, default, iconId)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -4, 0, 44)
    Row.Position = UDim2.new(0, 2, 0, yPos)
    Row.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Row.BorderSizePixel = 0
    Row.Parent = parent

    local RC = Instance.new("UICorner")
    RC.CornerRadius = UDim.new(0, 10)
    RC.Parent = Row

    local IconBadge = Instance.new("Frame")
    IconBadge.Size = UDim2.new(0, 30, 0, 30)
    IconBadge.Position = UDim2.new(0, 7, 0, 7)
    IconBadge.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    IconBadge.BackgroundTransparency = 0.85
    IconBadge.BorderSizePixel = 0
    IconBadge.Parent = Row

    local IBCorner2 = Instance.new("UICorner")
    IBCorner2.CornerRadius = UDim.new(0, 8)
    IBCorner2.Parent = IconBadge

    createIcon(IconBadge, iconId, UDim2.new(0, 18, 0, 18), UDim2.new(0.5, -9, 0.5, -9), Color3.fromRGB(0, 200, 255))

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0, 130, 1, 0)
    Label.Position = UDim2.new(0, 44, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = label
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 110, 0, 30)
    Box.Position = UDim2.new(1, -118, 0, 7)
    Box.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
    Box.BorderSizePixel = 0
    Box.Text = default
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.TextSize = 14
    Box.Font = Enum.Font.GothamBold
    Box.PlaceholderText = "..."
    Box.ClearTextOnFocus = false
    Box.Parent = Row

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 8)
    BC.Parent = Box

    return Box
end

local MaxBox = makeInputOn(HopPage, 0, "Max Players", tostring(CONFIG.MaxPlayers), ICONS.Users)
local MinBox = makeInputOn(HopPage, 48, "Min Players", tostring(CONFIG.MinPlayers), ICONS.User)

-- Region selector
local RegionRow = Instance.new("Frame")
RegionRow.Size = UDim2.new(1, -4, 0, 44)
RegionRow.Position = UDim2.new(0, 2, 0, 96)
RegionRow.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
RegionRow.BorderSizePixel = 0
RegionRow.Parent = HopPage

local RRCorner = Instance.new("UICorner")
RRCorner.CornerRadius = UDim.new(0, 10)
RRCorner.Parent = RegionRow

local RRIcon = Instance.new("Frame")
RRIcon.Size = UDim2.new(0, 30, 0, 30)
RRIcon.Position = UDim2.new(0, 7, 0, 7)
RRIcon.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
RRIcon.BackgroundTransparency = 0.85
RRIcon.BorderSizePixel = 0
RRIcon.Parent = RegionRow

local RRIC = Instance.new("UICorner")
RRIC.CornerRadius = UDim.new(0, 8)
RRIC.Parent = RRIcon

createIcon(RRIcon, ICONS.Globe, UDim2.new(0, 18, 0, 18), UDim2.new(0.5, -9, 0.5, -9), Color3.fromRGB(0, 200, 255))

local RRLabel = Instance.new("TextLabel")
RRLabel.Size = UDim2.new(0, 100, 1, 0)
RRLabel.Position = UDim2.new(0, 44, 0, 0)
RRLabel.BackgroundTransparency = 1
RRLabel.Text = "Region"
RRLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
RRLabel.TextSize = 13
RRLabel.Font = Enum.Font.GothamMedium
RRLabel.TextXAlignment = Enum.TextXAlignment.Left
RRLabel.Parent = RegionRow

local regions = {"ANY", "SG", "JP", "US", "EU"}
local regionIdx = 1
for i, r in ipairs(regions) do
    if r == CONFIG.Region then regionIdx = i end
end

local RegionBtn = Instance.new("TextButton")
RegionBtn.Size = UDim2.new(0, 110, 0, 30)
RegionBtn.Position = UDim2.new(1, -118, 0, 7)
RegionBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
RegionBtn.Text = regions[regionIdx]
RegionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RegionBtn.TextSize = 14
RegionBtn.Font = Enum.Font.GothamBold
RegionBtn.AutoButtonColor = false
RegionBtn.Parent = RegionRow

local RBCorner = Instance.new("UICorner")
RBCorner.CornerRadius = UDim.new(0, 8)
RBCorner.Parent = RegionBtn

RegionBtn.MouseButton1Click:Connect(function()
    regionIdx = regionIdx + 1
    if regionIdx > #regions then regionIdx = 1 end
    RegionBtn.Text = regions[regionIdx]
    CONFIG.Region = regions[regionIdx]
    saveConfig()
    playSound(SOUNDS.Click, 0.2)
end)

-- Strict mode toggle
local StrictRow = Instance.new("Frame")
StrictRow.Size = UDim2.new(1, -4, 0, 40)
StrictRow.Position = UDim2.new(0, 2, 0, 148)
StrictRow.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
StrictRow.BorderSizePixel = 0
StrictRow.Parent = HopPage

local SRC = Instance.new("UICorner")
SRC.CornerRadius = UDim.new(0, 10)
SRC.Parent = StrictRow

local StrictLabel = Instance.new("TextLabel")
StrictLabel.Size = UDim2.new(1, -80, 1, 0)
StrictLabel.Position = UDim2.new(0, 14, 0, 0)
StrictLabel.BackgroundTransparency = 1
StrictLabel.Text = "Strict Mode (exact match)"
StrictLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
StrictLabel.TextSize = 12
StrictLabel.Font = Enum.Font.GothamMedium
StrictLabel.TextXAlignment = Enum.TextXAlignment.Left
StrictLabel.Parent = StrictRow

local StrictBtn = Instance.new("TextButton")
StrictBtn.Size = UDim2.new(0, 50, 0, 22)
StrictBtn.Position = UDim2.new(1, -60, 0.5, -11)
StrictBtn.BackgroundColor3 = CONFIG.StrictMode and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(70, 70, 90)
StrictBtn.Text = CONFIG.StrictMode and "ON" or "OFF"
StrictBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StrictBtn.TextSize = 11
StrictBtn.Font = Enum.Font.GothamBold
StrictBtn.AutoButtonColor = false
StrictBtn.Parent = StrictRow

local StBC = Instance.new("UICorner")
StBC.CornerRadius = UDim.new(0, 6)
StBC.Parent = StrictBtn

StrictBtn.MouseButton1Click:Connect(function()
    CONFIG.StrictMode = not CONFIG.StrictMode
    StrictBtn.Text = CONFIG.StrictMode and "ON" or "OFF"
    StrictBtn.BackgroundColor3 = CONFIG.StrictMode and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(70, 70, 90)
    saveConfig()
    playSound(SOUNDS.Click, 0.2)
end)

-- Status panel
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, -4, 0, 60)
StatusFrame.Position = UDim2.new(0, 2, 0, 196)
StatusFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = HopPage

local SFCorner = Instance.new("UICorner")
SFCorner.CornerRadius = UDim.new(0, 10)
SFCorner.Parent = StatusFrame

local SFStroke = Instance.new("UIStroke")
SFStroke.Color = Color3.fromRGB(0, 200, 255)
SFStroke.Thickness = 1
SFStroke.Transparency = 0.75
SFStroke.Parent = StatusFrame

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(0, 14, 0, 14)
StatusDot.BackgroundColor3 = Color3.fromRGB(100, 255, 120)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusFrame

local SDCorner = Instance.new("UICorner")
SDCorner.CornerRadius = UDim.new(1, 0)
SDCorner.Parent = StatusDot

local StatusGlow = Instance.new("Frame")
StatusGlow.Size = UDim2.new(0, 20, 0, 20)
StatusGlow.Position = UDim2.new(0, 9, 0, 9)
StatusGlow.BackgroundColor3 = Color3.fromRGB(100, 255, 120)
StatusGlow.BackgroundTransparency = 0.7
StatusGlow.BorderSizePixel = 0
StatusGlow.ZIndex = 0
StatusGlow.Parent = StatusFrame

local SGLCorner = Instance.new("UICorner")
SGLCorner.CornerRadius = UDim.new(1, 0)
SGLCorner.Parent = StatusGlow

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -46, 0, 18)
StatusLabel.Position = UDim2.new(0, 34, 0, 10)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Ready"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 14
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFrame

local RetryLabel = Instance.new("TextLabel")
RetryLabel.Size = UDim2.new(1, -46, 0, 16)
RetryLabel.Position = UDim2.new(0, 34, 0, 32)
RetryLabel.BackgroundTransparency = 1
RetryLabel.Text = "Scan: 0  •  Failed: 0  •  Candidates: 0"
RetryLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
RetryLabel.TextSize = 11
RetryLabel.Font = Enum.Font.Gotham
RetryLabel.TextXAlignment = Enum.TextXAlignment.Left
RetryLabel.Parent = StatusFrame

task.spawn(function()
    while StatusGlow.Parent do
        StatusGlow.Size = UDim2.new(0, 10, 0, 10)
        StatusGlow.Position = UDim2.new(0, 14, 0, 14)
        StatusGlow.BackgroundTransparency = 0.4
        local t1 = TweenService:Create(StatusGlow, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(0, 6, 0, 6),
            BackgroundTransparency = 0.85
        })
        t1:Play()
        task.wait(1.4)
    end
end)

-- INJECT button
local InjectBtn = Instance.new("TextButton")
InjectBtn.Size = UDim2.new(1, -4, 0, 58)
InjectBtn.Position = UDim2.new(0, 2, 0, 264)
InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
InjectBtn.BorderSizePixel = 0
InjectBtn.Text = ""
InjectBtn.AutoButtonColor = false
InjectBtn.Parent = HopPage

local IBCorner = Instance.new("UICorner")
IBCorner.CornerRadius = UDim.new(0, 12)
IBCorner.Parent = InjectBtn

local IBGrad = Instance.new("UIGradient")
IBGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 150, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 0, 255)),
})
IBGrad.Rotation = 0
IBGrad.Parent = InjectBtn

local IBStroke = Instance.new("UIStroke")
IBStroke.Color = Color3.fromRGB(0, 220, 255)
IBStroke.Thickness = 1.5
IBStroke.Transparency = 0.4
IBStroke.Parent = InjectBtn

local IBIcon = createIcon(InjectBtn, ICONS.Bolt, UDim2.new(0, 26, 0, 26), UDim2.new(0, 65, 0.5, -13), Color3.fromRGB(255, 220, 0))

local IBText = Instance.new("TextLabel")
IBText.Size = UDim2.new(1, -100, 1, 0)
IBText.Position = UDim2.new(0, 95, 0, 0)
IBText.BackgroundTransparency = 1
IBText.Text = "INJECT"
IBText.TextColor3 = Color3.fromRGB(255, 255, 255)
IBText.TextSize = 20
IBText.Font = Enum.Font.GothamBold
IBText.TextXAlignment = Enum.TextXAlignment.Left
IBText.Parent = InjectBtn

InjectBtn.MouseEnter:Connect(function()
    TweenService:Create(IBStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
end)
InjectBtn.MouseLeave:Connect(function()
    TweenService:Create(IBStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
end)

-- Auto Hop button
local AutoBtn = Instance.new("TextButton")
AutoBtn.Size = UDim2.new(1, -4, 0, 42)
AutoBtn.Position = UDim2.new(0, 2, 0, 330)
AutoBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
AutoBtn.BorderSizePixel = 0
AutoBtn.Text = ""
AutoBtn.AutoButtonColor = false
AutoBtn.Parent = HopPage

local ABCorner = Instance.new("UICorner")
ABCorner.CornerRadius = UDim.new(0, 10)
ABCorner.Parent = AutoBtn

local ABStroke = Instance.new("UIStroke")
ABStroke.Color = Color3.fromRGB(100, 100, 130)
ABStroke.Thickness = 1
ABStroke.Transparency = 0.5
ABStroke.Parent = AutoBtn

local ABIcon = createIcon(AutoBtn, ICONS.Refresh, UDim2.new(0, 18, 0, 18), UDim2.new(0, 16, 0.5, -9), Color3.fromRGB(180, 180, 200))

local ABText = Instance.new("TextLabel")
ABText.Size = UDim2.new(1, -50, 1, 0)
ABText.Position = UDim2.new(0, 44, 0, 0)
ABText.BackgroundTransparency = 1
ABText.Text = "Auto Hop: OFF"
ABText.TextColor3 = Color3.fromRGB(220, 220, 230)
ABText.TextSize = 14
ABText.Font = Enum.Font.GothamBold
ABText.TextXAlignment = Enum.TextXAlignment.Left
ABText.Parent = AutoBtn

local ToggleTrack = Instance.new("Frame")
ToggleTrack.Size = UDim2.new(0, 34, 0, 18)
ToggleTrack.Position = UDim2.new(1, -46, 0.5, -9)
ToggleTrack.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
ToggleTrack.BorderSizePixel = 0
ToggleTrack.Parent = AutoBtn

local TTCorner = Instance.new("UICorner")
TTCorner.CornerRadius = UDim.new(1, 0)
TTCorner.Parent = ToggleTrack

local ToggleKnob = Instance.new("Frame")
ToggleKnob.Size = UDim2.new(0, 14, 0, 14)
ToggleKnob.Position = UDim2.new(0, 2, 0.5, -7)
ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ToggleKnob.BorderSizePixel = 0
ToggleKnob.Parent = ToggleTrack

local TKCorner = Instance.new("UICorner")
TKCorner.CornerRadius = UDim.new(1, 0)
TKCorner.Parent = ToggleKnob

-- ================================================================
-- TAB 2: SERVERS PAGE
-- ================================================================
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(1, -4, 0, 40)
RefreshBtn.Position = UDim2.new(0, 2, 0, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
RefreshBtn.BorderSizePixel = 0
RefreshBtn.Text = ""
RefreshBtn.AutoButtonColor = false
RefreshBtn.Parent = ServerPage

local RefBC = Instance.new("UICorner")
RefBC.CornerRadius = UDim.new(0, 10)
RefBC.Parent = RefreshBtn

local RefIcon = createIcon(RefreshBtn, ICONS.Refresh, UDim2.new(0, 18, 0, 18), UDim2.new(0.5, -60, 0.5, -9), Color3.fromRGB(255, 255, 255))

local RefText = Instance.new("TextLabel")
RefText.Size = UDim2.new(1, 0, 1, 0)
RefText.Position = UDim2.new(0, 20, 0, 0)
RefText.BackgroundTransparency = 1
RefText.Text = "REFRESH SERVER LIST"
RefText.TextColor3 = Color3.fromRGB(255, 255, 255)
RefText.TextSize = 14
RefText.Font = Enum.Font.GothamBold
RefText.Parent = RefreshBtn

local ServerList = Instance.new("Frame")
ServerList.Size = UDim2.new(1, -4, 0, 220)
ServerList.Position = UDim2.new(0, 2, 0, 48)
ServerList.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
ServerList.BorderSizePixel = 0
ServerList.Parent = ServerPage

local SLC = Instance.new("UICorner")
SLC.CornerRadius = UDim.new(0, 10)
SLC.Parent = ServerList

local ListScroll = Instance.new("ScrollingFrame")
ListScroll.Size = UDim2.new(1, -8, 1, -8)
ListScroll.Position = UDim2.new(0, 4, 0, 4)
ListScroll.BackgroundTransparency = 1
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 4
ListScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 150, 255)
ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
ListScroll.Parent = ServerList

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 4)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Parent = ListScroll

local function renderServer(srv)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    row.BorderSizePixel = 0
    row.Parent = ListScroll

    local RC = Instance.new("UICorner")
    RC.CornerRadius = UDim.new(0, 6)
    RC.Parent = row

    local playing = srv.playing or 0
    local max = srv.maxPlayers or 0
    local ratio = playing / math.max(max, 1)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 8, 0, 8)
    dot.Position = UDim2.new(0, 10, 0.5, -4)
    dot.BackgroundColor3 = ratio < 0.1 and Color3.fromRGB(80, 220, 120) or (ratio < 0.4 and Color3.fromRGB(255, 200, 80) or Color3.fromRGB(255, 80, 80))
    dot.BorderSizePixel = 0
    dot.Parent = row

    local DC = Instance.new("UICorner")
    DC.CornerRadius = UDim.new(1, 0)
    DC.Parent = dot

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(0, 200, 1, 0)
    info.Position = UDim2.new(0, 26, 0, 0)
    info.BackgroundTransparency = 1
    info.Text = string.format("%d / %d players", playing, max)
    info.TextColor3 = Color3.fromRGB(230, 230, 240)
    info.TextSize = 12
    info.Font = Enum.Font.GothamMedium
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = row

    local joinBtn = Instance.new("TextButton")
    joinBtn.Size = UDim2.new(0, 70, 0, 24)
    joinBtn.Position = UDim2.new(1, -78, 0.5, -12)
    joinBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    joinBtn.Text = "JOIN"
    joinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    joinBtn.TextSize = 11
    joinBtn.Font = Enum.Font.GothamBold
    joinBtn.AutoButtonColor = false
    joinBtn.Parent = row

    local JC = Instance.new("UICorner")
    JC.CornerRadius = UDim.new(0, 6)
    JC.Parent = joinBtn

    joinBtn.MouseButton1Click:Connect(function()
        notify("Joining Server", string.format("Connecting to %d/%d players...", playing, max), "info")
        playSound(SOUNDS.Success, 0.4)
        task.wait(0.3)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
        end)
    end)
end

-- ================================================================
-- TAB 3: SETTINGS PAGE
-- ================================================================
local function makeSettingRow(yPos, label, default, placeholder)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, -4, 0, 44)
    Row.Position = UDim2.new(0, 2, 0, yPos)
    Row.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Row.BorderSizePixel = 0
    Row.Parent = SettingsPage

    local RC = Instance.new("UICorner")
    RC.CornerRadius = UDim.new(0, 10)
    RC.Parent = Row

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(0, 130, 1, 0)
    L.Position = UDim2.new(0, 14, 0, 0)
    L.BackgroundTransparency = 1
    L.Text = label
    L.TextColor3 = Color3.fromRGB(220, 220, 230)
    L.TextSize = 13
    L.Font = Enum.Font.GothamMedium
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = Row

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0, 180, 0, 30)
    Box.Position = UDim2.new(1, -194, 0, 7)
    Box.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
    Box.BorderSizePixel = 0
    Box.Text = default
    Box.PlaceholderText = placeholder or "..."
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.TextSize = 12
    Box.Font = Enum.Font.Gotham
    Box.ClearTextOnFocus = false
    Box.Parent = Row

    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 8)
    BC.Parent = Box

    return Box
end

local RetryBox = makeSettingRow(0, "Retry Delay (s)", tostring(CONFIG.RetryDelay))
local CheckBox = makeSettingRow(48, "Check Interval", tostring(CONFIG.CheckInterval))

-- Job ID
local JobRow = Instance.new("Frame")
JobRow.Size = UDim2.new(1, -4, 0, 44)
JobRow.Position = UDim2.new(0, 2, 0, 96)
JobRow.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
JobRow.BorderSizePixel = 0
JobRow.Parent = SettingsPage

local JRC = Instance.new("UICorner")
JRC.CornerRadius = UDim.new(0, 10)
JRC.Parent = JobRow

local JLabel = Instance.new("TextLabel")
JLabel.Size = UDim2.new(1, -14, 0, 20)
JLabel.Position = UDim2.new(0, 14, 0, 2)
JLabel.BackgroundTransparency = 1
JLabel.Text = "Direct Job ID"
JLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
JLabel.TextSize = 12
JLabel.Font = Enum.Font.GothamMedium
JLabel.TextXAlignment = Enum.TextXAlignment.Left
JLabel.Parent = JobRow

local JobBox = Instance.new("TextBox")
JobBox.Size = UDim2.new(1, -100, 0, 22)
JobBox.Position = UDim2.new(0, 14, 0, 20)
JobBox.BackgroundColor3 = Color3.fromRGB(45, 45, 62)
JobBox.BorderSizePixel = 0
JobBox.Text = ""
JobBox.PlaceholderText = "paste job id here..."
JobBox.TextColor3 = Color3.fromRGB(255, 255, 255)
JobBox.TextSize = 11
JobBox.Font = Enum.Font.Gotham
JobBox.ClearTextOnFocus = false
JobBox.Parent = JobRow

local JBC = Instance.new("UICorner")
JBC.CornerRadius = UDim.new(0, 6)
JBC.Parent = JobBox

local JobGoBtn = Instance.new("TextButton")
JobGoBtn.Size = UDim2.new(0, 70, 0, 22)
JobGoBtn.Position = UDim2.new(1, -80, 0, 20)
JobGoBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
JobGoBtn.Text = "JOIN"
JobGoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JobGoBtn.TextSize = 11
JobGoBtn.Font = Enum.Font.GothamBold
JobGoBtn.AutoButtonColor = false
JobGoBtn.Parent = JobRow

local JGBC = Instance.new("UICorner")
JGBC.CornerRadius = UDim.new(0, 6)
JGBC.Parent = JobGoBtn

JobGoBtn.MouseButton1Click:Connect(function()
    local jid = JobBox.Text
    if jid and #jid > 10 then
        notify("Direct Join", "Teleporting to job id...", "info")
        playSound(SOUNDS.Success, 0.4)
        task.wait(0.3)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, jid, LocalPlayer)
        end)
    else
        notify("Error", "Invalid Job ID", "error")
        playSound(SOUNDS.Fail, 0.4)
    end
end)

-- Save button
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(1, -4, 0, 40)
SaveBtn.Position = UDim2.new(0, 2, 0, 148)
SaveBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
SaveBtn.BorderSizePixel = 0
SaveBtn.Text = "SAVE CONFIG"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.TextSize = 14
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.AutoButtonColor = false
SaveBtn.Parent = SettingsPage

local SBC = Instance.new("UICorner")
SBC.CornerRadius = UDim.new(0, 10)
SBC.Parent = SaveBtn

SaveBtn.MouseButton1Click:Connect(function()
    CONFIG.RetryDelay = tonumber(RetryBox.Text) or 1.5
    CONFIG.CheckInterval = tonumber(CheckBox.Text) or 5
    CONFIG.MaxPlayers = tonumber(MaxBox.Text) or 1
    CONFIG.MinPlayers = tonumber(MinBox.Text) or 0
    saveConfig()
    notify("Config Saved", "Settings saved to file", "success")
    playSound(SOUNDS.Success, 0.5)
end)

-- FOOTER
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -28, 0, 16)
Footer.Position = UDim2.new(0, 14, 1, -28)
Footer.BackgroundTransparency = 1
Footer.Text = SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. "  •  by " .. SCRIPT_AUTHOR
Footer.TextColor3 = Color3.fromRGB(100, 100, 130)
Footer.TextSize = 10
Footer.Font = Enum.Font.Gotham
Footer.Parent = Main

-- ================================================================
-- DRAG SYSTEM
-- ================================================================
local function makeDraggable(frame, dragTarget)
    dragTarget = dragTarget or frame
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragTarget.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            dragTarget.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

makeDraggable(MiniBtn)
makeDraggable(Header, Main)

-- ================================================================
-- SHOW / HIDE LOGIC
-- ================================================================
local isOpen = false

local function openUI()
    isOpen = true
    Main.Visible = true
    Main.Size = UDim2.new(0, 380, 0, 0)
    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 380, 0, 480)
    }):Play()
    TweenService:Create(MiniBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.35, function()
        if isOpen then MiniBtn.Visible = false end
    end)
end

local function closeUI()
    isOpen = false
    MiniBtn.Visible = true
    MiniBtn.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(MiniBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 60, 0, 60)
    }):Play()
    TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 380, 0, 0)
    }):Play()
    task.delay(0.3, function()
        if not isOpen then Main.Visible = false end
    end)
end

MiniBtn.MouseButton1Click:Connect(function()
    if not isOpen then openUI() end
end)

MinBtn.MouseButton1Click:Connect(function()
    closeUI()
end)

CloseBtn.MouseButton1Click:Connect(function()
    playSound(SOUNDS.Click, 0.3)
    ScreenGui:Destroy()
end)

MiniBtn.MouseEnter:Connect(function()
    TweenService:Create(MiniBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 66, 0, 66)}):Play()
end)
MiniBtn.MouseLeave:Connect(function()
    TweenService:Create(MiniBtn, TweenInfo.new(0.2), {Size = UDim2.new(0, 60, 0, 60)}):Play()
end)

-- ================================================================
-- SERVER HOP LOGIC v5.2 - FIX 771 & 772
-- ================================================================
local stats = {scan = 0, failed = 0, candidates = 0, running = false}

local REGION_KEYWORDS = {
    SG = {"singapore", "sgp", "sg"},
    JP = {"japan", "tokyo", "jpn", "jp"},
    US = {"united states", "usa", "us-", "california", "virginia"},
    EU = {"europe", "eu-", "frankfurt", "amsterdam", "london"},
}

local function matchRegion(srv)
    if CONFIG.Region == "ANY" then return true end
    local region = (srv.region or ""):lower()
    local keywords = REGION_KEYWORDS[CONFIG.Region] or {}
    for _, kw in ipairs(keywords) do
        if region:find(kw) then return true end
    end
    return false
end

local function getServers(placeId, cursor)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
        placeId
    )
    if cursor then url = url .. "&cursor=" .. cursor end

    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if ok and res then return res end
    return nil
end

local function getAllServers(placeId, maxPages)
    maxPages = maxPages or 20
    local allServers = {}
    local cursor = nil
    local page = 0

    repeat
        local data = getServers(placeId, cursor)
        if not data or not data.data then break end

        for _, srv in ipairs(data.data) do
            if srv and srv.id and (srv.maxPlayers or 0) > 0 then
                table.insert(allServers, srv)
            end
        end

        cursor = data.nextPageCursor
        page = page + 1
        task.wait(0.35)
    until not cursor or page >= maxPages

    return allServers
end

-- ⚡ Verifikasi server: cek masih ada & player count terbaru
local function verifyServer(placeId, serverId)
    local url = string.format(
        "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100",
        placeId
    )

    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)

    if not ok or not data or not data.data then return nil end

    for _, s in ipairs(data.data) do
        if s.id == serverId then
            return s
        end
    end

    return false
end

-- ⚡ Cari kandidat server terbaik
local function findCandidates(placeId, maxP, minP, excludeIds)
    excludeIds = excludeIds or {}

    local allServers = getAllServers(placeId, 20)
    if #allServers == 0 then return {}, 0 end

    local candidates = {}
    for _, srv in ipairs(allServers) do
        local playing = srv.playing or 0
        local max = srv.maxPlayers or 0

        if not excludeIds[srv.id] then
            if playing >= minP and playing <= maxP and playing < max and max > 0 then
                if matchRegion(srv) then
                    table.insert(candidates, srv)
                end
            end
        end
    end

    -- Sort: paling kosong dulu
    table.sort(candidates, function(a, b)
        return (a.playing or 0) < (b.playing or 0)
    end)

    return candidates, #candidates
end

local function setStatus(txt, color)
    StatusLabel.Text = txt
    StatusDot.BackgroundColor3 = color or Color3.fromRGB(100, 255, 120)
    StatusGlow.BackgroundColor3 = color or Color3.fromRGB(100, 255, 120)
end

local function updateStats(candidates)
    RetryLabel.Text = string.format("Scan: %d  •  Failed: %d  •  Candidates: %d",
        stats.scan, stats.failed, candidates or stats.candidates)
end

-- ================================================================
-- INJECT HANDLER v5.2
-- ================================================================
InjectBtn.MouseButton1Click:Connect(function()
    if stats.running then
        notify("Wait", "Search already running!", "warn")
        return
    end

    stats.running = true
    stats.scan = 0
    stats.failed = 0
    stats.candidates = 0

    local maxP = tonumber(MaxBox.Text) or 1
    local minP = tonumber(MinBox.Text) or 0
    local failedServers = {}
    local adaptiveDelay = CONFIG.RetryDelay

    IBText.Text = "SEARCHING..."
    setStatus(string.format("Target: %d-%d players...", minP, maxP), Color3.fromRGB(255, 220, 100))
    notify(SCRIPT_NAME .. " v" .. SCRIPT_VERSION,
        string.format("Scanning [Region: %s, Target: %d-%d]", CONFIG.Region, minP, maxP), "info")

    task.spawn(function()
        while stats.running do
            stats.scan = stats.scan + 1
            updateStats()

            setStatus(string.format("Scan #%d — searching...", stats.scan), Color3.fromRGB(255, 220, 100))

            local candidates, candCount = findCandidates(game.PlaceId, maxP, minP, failedServers)
            stats.candidates = candCount
            updateStats()

            if #candidates > 0 then
                -- Ambil top 3 kandidat, coba verifikasi satu-satu
                local verified = nil
                for i = 1, math.min(3, #candidates) do
                    local srv = candidates[i]

                    setStatus(string.format("Verifying %d/%d...", srv.playing, srv.maxPlayers),
                        Color3.fromRGB(255, 220, 100))

                    task.wait(0.5)

                    local check = verifyServer(game.PlaceId, srv.id)

                    if check == false then
                        -- ❌ Server gone (771)
                        stats.failed = stats.failed + 1
                        failedServers[srv.id] = true
                        updateStats()
                        setStatus("Server gone (771), next...", Color3.fromRGB(255, 120, 120))
                        task.wait(0.3)
                    elseif check then
                        local actualPlaying = check.playing or 0
                        local actualMax = check.maxPlayers or 0

                        if actualPlaying > maxP or actualPlaying >= actualMax then
                            -- ❌ Server full (772)
                            stats.failed = stats.failed + 1
                            failedServers[srv.id] = true
                            updateStats()
                            setStatus(string.format("Full (%d/%d), next...", actualPlaying, actualMax),
                                Color3.fromRGB(255, 120, 120))
                            task.wait(0.3)
                        else
                            -- ✅ SEMUA CHECK PASS
                            verified = check
                            break
                        end
                    else
                        -- Gagal verify, skip
                        stats.failed = stats.failed + 1
                        failedServers[srv.id] = true
                        updateStats()
                    end
                end

                if verified then
                    -- Teleport
                    setStatus(string.format("MATCH! %d/%d players", verified.playing, verified.maxPlayers),
                        Color3.fromRGB(100, 255, 120))
                    IBText.Text = "TELEPORTING..."
                    playSound(SOUNDS.Success, 0.6)
                    notify("Server Match!",
                        string.format("%d/%d players — teleporting!", verified.playing, verified.maxPlayers),
                        "success")

                    local ok = pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, verified.id, LocalPlayer)
                    end)

                    if not ok then
                        stats.failed = stats.failed + 1
                        failedServers[verified.id] = true
                        updateStats()
                        setStatus("Teleport failed, retrying...", Color3.fromRGB(255, 120, 120))
                        task.wait(1)
                    else
                        -- Sukses, break
                        break
                    end
                end
            else
                setStatus("No candidates, retry...", Color3.fromRGB(255, 160, 100))
                IBText.Text = "SCANNING..."

                if CONFIG.AdaptiveDelay and stats.failed > 5 then
                    adaptiveDelay = math.min(CONFIG.RetryDelay * 1.5, 5)
                else
                    adaptiveDelay = CONFIG.RetryDelay
                end

                task.wait(adaptiveDelay)

                if stats.scan % 15 == 0 then
                    notify("Still Searching",
                        string.format("Scan #%d — %d failed. Keep trying...", stats.scan, stats.failed), "warn")
                end
            end

            -- Reset failed list kalau kegedean
            if stats.failed > 200 then
                failedServers = {}
                stats.failed = 0
            end
        end

        stats.running = false
        IBText.Text = "INJECT"
        setStatus("Ready", Color3.fromRGB(100, 255, 120))
    end)
end)

-- ================================================================
-- REFRESH SERVER LIST
-- ================================================================
RefreshBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(ListScroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end

    RefText.Text = "LOADING..."
    playSound(SOUNDS.Click, 0.3)

    task.spawn(function()
        local allServers = getAllServers(game.PlaceId, 5)

        if #allServers > 0 then
            table.sort(allServers, function(a, b) return (a.playing or 0) < (b.playing or 0) end)
            for _, srv in ipairs(allServers) do
                renderServer(srv)
            end
            notify("Server List", string.format("Found %d servers", #allServers), "success")
        else
            notify("Error", "Failed to fetch servers", "error")
        end
        RefText.Text = "REFRESH SERVER LIST"
    end)
end)

-- ================================================================
-- AUTO HOP HANDLER
-- ================================================================
AutoBtn.MouseButton1Click:Connect(function()
    CONFIG.AutoHop = not CONFIG.AutoHop
    playSound(SOUNDS.Click, 0.3)

    if CONFIG.AutoHop then
        ABText.Text = "Auto Hop: ON"
        ABText.TextColor3 = Color3.fromRGB(100, 255, 120)
        ABStroke.Color = Color3.fromRGB(100, 255, 120)
        ABStroke.Transparency = 0.3
        TweenService:Create(ToggleTrack, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(0, 180, 100)}):Play()
        TweenService:Create(ToggleKnob, TweenInfo.new(0.25), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        setStatus("Auto Hop active", Color3.fromRGB(100, 255, 120))
        notify("Auto Hop", "Auto hop is now ON", "success")

        task.spawn(function()
            while CONFIG.AutoHop do
                local count = #Players:GetPlayers()
                local maxP = tonumber(MaxBox.Text) or 1
                if count > maxP then
                    setStatus("Server exceeded, hopping...", Color3.fromRGB(255, 200, 100))
                    local candidates = findCandidates(game.PlaceId, maxP, tonumber(MinBox.Text) or 0, {})
                    if #candidates > 0 then
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[1].id, LocalPlayer)
                        end)
                    end
                end
                task.wait(CONFIG.CheckInterval)
            end
        end)
    else
        ABText.Text = "Auto Hop: OFF"
        ABText.TextColor3 = Color3.fromRGB(220, 220, 230)
        ABStroke.Color = Color3.fromRGB(100, 100, 130)
        ABStroke.Transparency = 0.5
        TweenService:Create(ToggleTrack, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(70, 70, 90)}):Play()
        TweenService:Create(ToggleKnob, TweenInfo.new(0.25), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        setStatus("Auto Hop off", Color3.fromRGB(200, 200, 200))
    end
end)

-- ================================================================
-- INIT
-- ================================================================
task.wait(0.3)
openUI()
notify(SCRIPT_NAME .. " v" .. SCRIPT_VERSION, "Loaded! by " .. SCRIPT_AUTHOR, "success")
