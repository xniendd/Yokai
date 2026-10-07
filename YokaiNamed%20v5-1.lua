-- ============================================================
-- Yokai Named GUI  ─  完全再現 + Aimbot + Ragebot
-- 写真参考: ESP / Combat(Aimbot+Rage) / Weapon Mods タブ
-- ============================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")

local LocalPlayer    = Players.LocalPlayer
local PlayerGui      = LocalPlayer:WaitForChild("PlayerGui")
local Camera         = workspace.CurrentCamera

pcall(function() PlayerGui:FindFirstChild("YokaiNamedUI"):Destroy() end)

local ScreenGui           = Instance.new("ScreenGui")
ScreenGui.Name            = "YokaiNamedUI"
ScreenGui.ResetOnSpawn    = false
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = PlayerGui

-- ============================================================
-- 色定数
-- ============================================================
local C = {
    bg       = Color3.fromRGB(18, 18, 24),
    sidebar  = Color3.fromRGB(13, 13, 18),
    content  = Color3.fromRGB(18, 18, 24),
    accent   = Color3.fromRGB(110, 90, 220),
    accent2  = Color3.fromRGB(80, 70, 180),
    text     = Color3.fromRGB(210, 210, 230),
    subtext  = Color3.fromRGB(130, 130, 155),
    border   = Color3.fromRGB(40, 40, 58),
    toggle_on  = Color3.fromRGB(110, 90, 220),
    toggle_off = Color3.fromRGB(38, 38, 50),
    section  = Color3.fromRGB(140, 120, 255),
    green    = Color3.fromRGB(80, 220, 100),
    red      = Color3.fromRGB(220, 80, 80),
    orange   = Color3.fromRGB(255, 160, 60),
}

-- ============================================================
-- Toggle / Lock ボタン  (Robloxアイコン下に配置 + ドラッグ可)
-- ============================================================
local BtnHolder = Instance.new("Frame")
BtnHolder.Parent = ScreenGui
BtnHolder.Size = UDim2.new(0, 152, 0, 28)
-- Robloxトップバー高さ ≈ 36px。アイコン下 Y=62 に配置
BtnHolder.Position = UDim2.new(0, 12, 0, 62)
BtnHolder.BackgroundTransparency = 1
BtnHolder.Active = true   -- InputBegan を受け取るために必要

local function mkSmallBtn(txt, x)
    local b = Instance.new("TextButton")
    b.Parent = BtnHolder
    b.Size = UDim2.new(0, 68, 0, 26)
    b.Position = UDim2.new(0, x, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = C.text
    b.TextSize = 12
    b.Font = Enum.Font.GothamSemibold
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    local s = Instance.new("UIStroke", b)
    s.Color = C.border; s.Thickness = 1; s.Transparency = 0.3
    b.MouseEnter:Connect(function() b.BackgroundColor3 = Color3.fromRGB(24, 24, 34) end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(14, 14, 20) end)
    return b
end

local ToggleBtn = mkSmallBtn("Toggle", 0)
local LockBtn   = mkSmallBtn("Lock",   80)

-- ============================================================
-- メインウィンドウ  480 × 340
-- ============================================================
local WIN_W, WIN_H = 480, 340

local Main = Instance.new("Frame")
Main.Name   = "Main"
Main.Parent = ScreenGui
Main.Size   = UDim2.new(0, WIN_W, 0, WIN_H)
Main.Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
Main.BackgroundColor3 = C.bg
Main.BorderSizePixel  = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local ms = Instance.new("UIStroke", Main)
ms.Color = C.border; ms.Thickness = 1; ms.Transparency = 0.1

-- タイトルバー
local TitleBar = Instance.new("Frame")
TitleBar.Parent = Main
TitleBar.Size   = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
TitleBar.BorderSizePixel  = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 8)

local TitleFix = Instance.new("Frame")   -- 下半分角丸を隠す
TitleFix.Parent = TitleBar
TitleFix.Size   = UDim2.new(1, 0, 0, 8)
TitleFix.Position = UDim2.new(0, 0, 1, -8)
TitleFix.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
TitleFix.BorderSizePixel  = 0

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Parent = TitleBar
TitleLbl.Size   = UDim2.new(1, 0, 1, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text  = "Yokai Named"
TitleLbl.TextColor3 = C.text
TitleLbl.TextSize   = 13
TitleLbl.Font       = Enum.Font.GothamBold

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = TitleBar
CloseBtn.Size   = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -24, 0, 4)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text       = "×"
CloseBtn.TextColor3 = C.subtext
CloseBtn.TextSize   = 16
CloseBtn.Font       = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

-- サイドバー  120px
local Sidebar = Instance.new("Frame")
Sidebar.Parent = Main
Sidebar.Size   = UDim2.new(0, 120, 1, -28)
Sidebar.Position = UDim2.new(0, 0, 0, 28)
Sidebar.BackgroundColor3 = C.sidebar
Sidebar.BorderSizePixel  = 0

local SbBL = Instance.new("Frame")    -- 下角丸マスク
SbBL.Parent = Sidebar; SbBL.Size = UDim2.new(0, 8, 0, 8)
SbBL.Position = UDim2.new(0, 0, 1, -8)
SbBL.BackgroundColor3 = C.sidebar; SbBL.BorderSizePixel = 0

-- コンテンツ
local Content = Instance.new("Frame")
Content.Parent = Main
Content.Size   = UDim2.new(1, -120, 1, -28)
Content.Position = UDim2.new(0, 120, 0, 28)
Content.BackgroundColor3 = C.content
Content.BorderSizePixel  = 0

-- 仕切り線
local Divider = Instance.new("Frame")
Divider.Parent = Main
Divider.Size   = UDim2.new(0, 1, 1, -28)
Divider.Position = UDim2.new(0, 120, 0, 28)
Divider.BackgroundColor3 = C.border
Divider.BorderSizePixel  = 0

-- フッター
local Footer = Instance.new("TextLabel")
Footer.Parent = Main
Footer.Size   = UDim2.new(1, 0, 0, 14)
Footer.Position = UDim2.new(0, 0, 1, -14)
Footer.BackgroundTransparency = 1
Footer.Text  = "open source"
Footer.TextColor3 = Color3.fromRGB(65, 65, 85)
Footer.TextSize   = 9
Footer.Font       = Enum.Font.Gotham
Footer.ZIndex     = 2

-- ============================================================
-- ページ管理
-- ============================================================
local Pages      = {}
local SideBtns   = {}

local function mkPage(name)
    local f = Instance.new("Frame")
    f.Name   = name
    f.Parent = Content
    f.Size   = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ZIndex  = 3
    Pages[name] = f
    return f
end

local ESPPage    = mkPage("ESP")
local CombatPage = mkPage("Combat")
local WeaponPage = mkPage("Weapon")
local AutoPage   = mkPage("Automation")
local ClientPage = mkPage("Client Effects")
local CrossPage  = mkPage("Crosshair")
local WorldPage  = mkPage("World")
local MovePage   = mkPage("Movement")
local MiscPage   = mkPage("Misc")
local DebugPage  = mkPage("Debug")
local UIPage     = mkPage("UI Settings")

-- 最初はESP
ESPPage.Visible = true

local function setTab(name)
    for n, p in pairs(Pages) do p.Visible = n == name end
    for n, b in pairs(SideBtns) do
        if n == name then
            b.BackgroundColor3 = Color3.fromRGB(26, 24, 40)
            b.TextColor3 = Color3.fromRGB(180, 160, 255)
            -- アクセントライン
            if b:FindFirstChild("_line") then
                b:FindFirstChild("_line").BackgroundColor3 = C.accent
            end
        else
            b.BackgroundColor3 = C.sidebar
            b.TextColor3 = C.subtext
            if b:FindFirstChild("_line") then
                b:FindFirstChild("_line").BackgroundColor3 = C.sidebar
            end
        end
    end
end

-- サイドバーボタン生成
local SIDE_TABS = {
    "ESP","Combat","Weapon","Automation","Client Effects",
    "Crosshair","World","Movement","Misc","Debug","UI Settings"
}

for i, name in ipairs(SIDE_TABS) do
    local btn = Instance.new("TextButton")
    btn.Parent = Sidebar
    btn.Size   = UDim2.new(1, -10, 0, 24)
    btn.Position = UDim2.new(0, 5, 0, 4 + (i-1)*26)
    btn.BackgroundColor3 = C.sidebar
    btn.BorderSizePixel  = 0
    btn.Text     = name
    btn.TextColor3 = C.subtext
    btn.TextSize   = 10
    btn.Font       = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.ZIndex  = 4
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local pad = Instance.new("UIPadding", btn)
    pad.PaddingLeft = UDim.new(0, 10)

    -- アクセントライン
    local line = Instance.new("Frame")
    line.Name   = "_line"
    line.Parent = btn
    line.Size   = UDim2.new(0, 3, 0.7, 0)
    line.Position = UDim2.new(0, 0, 0.15, 0)
    line.BackgroundColor3 = C.sidebar
    line.BorderSizePixel  = 0
    Instance.new("UICorner", line).CornerRadius = UDim.new(0, 2)

    SideBtns[name] = btn
    local n = name
    btn.MouseButton1Click:Connect(function() setTab(n) end)
    btn.MouseEnter:Connect(function()
        if SideBtns[n].BackgroundColor3 ~= Color3.fromRGB(26,24,40) then
            btn.BackgroundColor3 = Color3.fromRGB(18, 17, 28)
        end
    end)
    btn.MouseLeave:Connect(function()
        if SideBtns[n].BackgroundColor3 ~= Color3.fromRGB(26,24,40) then
            btn.BackgroundColor3 = C.sidebar
        end
    end)
end

-- 初期アクティブ
setTab("ESP")

-- ============================================================
-- UI部品ファクトリ
-- ============================================================
local function mkLabel(parent, text, x, y, w, size)
    local L = Instance.new("TextLabel")
    L.Parent = parent
    L.Size   = UDim2.new(0, w or 160, 0, 18)
    L.Position = UDim2.new(0, x, 0, y)
    L.BackgroundTransparency = 1
    L.Text  = text
    L.TextColor3 = C.text
    L.TextSize   = size or 10
    L.Font       = Enum.Font.Gotham
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.ZIndex = 4
    return L
end

local function mkSection(parent, text, x, y, w)
    local s = mkLabel(parent, text, x, y, w or 160, 11)
    s.TextColor3 = C.section
    s.Font = Enum.Font.GothamSemibold
    return s
end

-- Toggle: ラベル + スイッチ  (stateRef はテーブルとキー)
local function mkToggle(parent, text, x, y, initVal, stateRef, stateKey)
    mkLabel(parent, text, x, y, 128)

    local sw = Instance.new("TextButton")
    sw.Parent = parent
    sw.Size   = UDim2.new(0, 32, 0, 16)
    sw.Position = UDim2.new(0, x+128, 0, y+1)
    sw.BackgroundColor3 = initVal and C.toggle_on or C.toggle_off
    sw.BorderSizePixel  = 0
    sw.Text  = ""; sw.AutoButtonColor = false; sw.ZIndex = 4
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Parent = sw
    dot.Size   = UDim2.new(0, 12, 0, 12)
    dot.Position = initVal and UDim2.new(1,-14,0,2) or UDim2.new(0,2,0,2)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.BorderSizePixel  = 0; dot.ZIndex = 5
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local state = initVal
    sw.MouseButton1Click:Connect(function()
        state = not state
        if stateRef and stateKey then stateRef[stateKey] = state end
        TweenService:Create(sw, TweenInfo.new(0.12), {
            BackgroundColor3 = state and C.toggle_on or C.toggle_off}):Play()
        TweenService:Create(dot, TweenInfo.new(0.12), {
            Position = state and UDim2.new(1,-14,0,2) or UDim2.new(0,2,0,2)}):Play()
    end)
    return sw, function() return state end
end

-- Value row:  "Label         Value  >"
local function mkValueRow(parent, label, value, x, y, w)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.Size   = UDim2.new(0, w or 320, 0, 20)
    row.Position = UDim2.new(0, x, 0, y)
    row.BackgroundTransparency = 1; row.ZIndex = 4
    mkLabel(row, label, 0, 0, (w or 320)*0.55)
    local vl = mkLabel(row, value, (w or 320)*0.55, 0, (w or 320)*0.38)
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.TextColor3 = C.subtext
    return row, vl
end

-- Slider (表示のみ)
local function mkSlider(parent, text, x, y, pct, color)
    mkLabel(parent, text, x, y, 155)
    local bar = Instance.new("Frame")
    bar.Parent = parent
    bar.Size   = UDim2.new(0, 155, 0, 4)
    bar.Position = UDim2.new(0, x, 0, y+16)
    bar.BackgroundColor3 = Color3.fromRGB(28,28,38)
    bar.BorderSizePixel  = 0; bar.ZIndex = 4
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame")
    fill.Parent = bar
    fill.Size   = UDim2.new(pct or 0.5, 0, 1, 0)
    fill.BackgroundColor3 = color or C.accent
    fill.BorderSizePixel  = 0; fill.ZIndex = 5
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    return fill
end

-- ============================================================
-- STATE
-- ============================================================
local ST = {
    -- ESP
    espEnabled    = false,
    espBoxes      = false,
    espNames      = false,
    espHealthInfo = false,
    espVHealth    = false,
    espWeaponInfo = false,
    espAmmoText   = false,
    espDistance   = false,
    espLookDir    = false,
    espArrows     = false,
    espTeammates  = false,
    espThrowable  = false,

    -- Aimbot
    aimbotEnabled = false,
    aimbotSilent  = false,
    aimbotIgnoreFOV = false,
    aimbotShowFOV = false,
    aimbotFlickbot = false,
    aimbotTrigger  = false,
    aimbotFOV     = 200,
    aimbotSmooth  = 0.08,
    aimbotPred    = 0.10,

    -- Rage
    rageEnabled   = false,
    rageAutoFire  = false,
    rageWallCheck = false,
    rageTeamCheck = false,
    rageResolver  = false,
    rageDrawTarget = false,
    rageFOV       = 0.65,
    rageSmooth    = 0.35,

    -- Crosshair
    crossEnabled  = false,

    -- Weapon Mods
    wepAttackSpd  = false,
    wepNoSpread   = false,
    wepNoRecoil   = false,
    wepInfAmmo    = false,
    wepAutoReload = false,
    wepScytheDash = false,
    wepAutoWep    = false,
    wepGrenFuse   = false,
    wepExplodeOn  = false,
    wepImpact     = false,
    wepRemoveFuse = false,
}

-- ============================================================
-- ESP PAGE  (写真左: ESP Options + Live Preview風)
-- ============================================================
mkSection(ESPPage, "ESP Options", 8, 6, 160)

local espToggles = {
    {"ESP Enabled",   "espEnabled"},
    {"Highlight",     nil},
    {"Box",           "espBoxes"},
    {"Names",         "espNames"},
    {"Health Info",   "espHealthInfo"},
    {"Vertical Health","espVHealth"},
    {"Weapon Info",   "espWeaponInfo"},
    {"Ammo Text",     "espAmmoText"},
    {"Distance",      "espDistance"},
    {"Look Direction","espLookDir"},
    {"Arrows",        "espArrows"},
    {"Show Teammates","espTeammates"},
    {"Throwable ESP", "espThrowable"},
}
for i, t in ipairs(espToggles) do
    mkToggle(ESPPage, t[1], 8, 24+(i-1)*20, false, t[2] and ST or nil, t[2])
end

-- 色ボタン (Visible Color / Hidden Color)
mkLabel(ESPPage, "Visible Color",  8, 294, 110)
local vcBtn = Instance.new("Frame")
vcBtn.Parent = ESPPage; vcBtn.Size = UDim2.new(0,16,0,12)
vcBtn.Position = UDim2.new(0,120,0,297); vcBtn.BackgroundColor3 = C.green
vcBtn.BorderSizePixel = 0; Instance.new("UICorner",vcBtn).CornerRadius = UDim.new(0,2)

mkLabel(ESPPage, "Hidden Color",   8, 312, 110)
local hcBtn = Instance.new("Frame")
hcBtn.Parent = ESPPage; hcBtn.Size = UDim2.new(0,16,0,12)
hcBtn.Position = UDim2.new(0,120,0,315); hcBtn.BackgroundColor3 = C.red
hcBtn.BorderSizePixel = 0; Instance.new("UICorner",hcBtn).CornerRadius = UDim.new(0,2)

-- Live Preview セクション
mkSection(ESPPage, "Live Preview", 175, 6, 140)
local previewBox = Instance.new("Frame")
previewBox.Parent = ESPPage
previewBox.Size   = UDim2.new(0, 135, 0, 155)
previewBox.Position = UDim2.new(0, 175, 0, 24)
previewBox.BackgroundColor3 = Color3.fromRGB(10,10,14)
previewBox.BorderSizePixel  = 0
Instance.new("UICorner", previewBox).CornerRadius = UDim.new(0,4)
local ps = Instance.new("UIStroke", previewBox)
ps.Color = C.green; ps.Thickness = 1; ps.Transparency = 0.3

local previewName = mkLabel(previewBox, "Yokai_Named3", 0, 2, 135, 9)
previewName.TextXAlignment = Enum.TextXAlignment.Center

local previewHp = mkLabel(previewBox, "20/30", 0, 138, 135, 9)
previewHp.TextXAlignment = Enum.TextXAlignment.Center
previewHp.TextColor3 = C.green

local previewWep = mkLabel(previewBox, "Assault Rifle", 0, 148, 135, 9)
previewWep.TextXAlignment = Enum.TextXAlignment.Center
previewWep.TextColor3 = C.subtext

-- ============================================================
-- COMBAT PAGE  (写真右上: Aimbot + Rage)
-- ============================================================
-- 左カラム: Aimbot
mkSection(CombatPage, "Aimbot", 8, 6, 155)

local _, getAimEnabled  = mkToggle(CombatPage,"Enabled",    8, 24, false, ST,"aimbotEnabled")
mkValueRow(CombatPage, "Mode", "Hold", 8, 44, 155)
local _, getAimSilent   = mkToggle(CombatPage,"Silent",     8, 62, false, ST,"aimbotSilent")
local _, getAimIgnFOV   = mkToggle(CombatPage,"Ignore FOV", 8, 82, false, ST,"aimbotIgnoreFOV")
local _, getAimShowFOV  = mkToggle(CombatPage,"Show FOV",   8,102, false, ST,"aimbotShowFOV")
mkValueRow(CombatPage, "Aim Part", "Head", 8, 122, 155)
mkValueRow(CombatPage, "Prediction", "0.10s", 8, 140, 155)
local _, getFlickbot    = mkToggle(CombatPage,"Flickbot",   8,158, false, ST,"aimbotFlickbot")
mkValueRow(CombatPage, "Shot Delay", "0 ms", 8, 178, 155)
mkValueRow(CombatPage, "Cooldown",  "250 ms", 8, 196, 155)
mkValueRow(CombatPage, "Click Duration","110 ms",8,214,155)
mkSlider(CombatPage, "Humanness", 8, 232, 0.3, C.accent)
local _, getTrigger     = mkToggle(CombatPage,"Triggerbot", 8,258, false, ST,"aimbotTrigger")
mkValueRow(CombatPage, "Trigger Reaction","0 s",8,276,155)

-- 右カラム: Rage + Weapon Mods (写真右)
mkSection(CombatPage, "Weapon Mods", 170, 6, 155)

local wepRows = {
    {"Weapon Attack Speed","wepAttackSpd"},
    {"No Spread",          "wepNoSpread"},
    {"No Recoil",          "wepNoRecoil"},
    {"Scythe Dash Cooldown","wepScytheDash"},
    {"Automatic Weapon",   "wepAutoWep"},
    {"Grenade Fuse",       "wepGrenFuse"},
    {"Explode On",         "wepExplodeOn"},
    {"Impact",             "wepImpact"},
    {"Remove Fuse",        "wepRemoveFuse"},
}
for i, r in ipairs(wepRows) do
    mkToggle(CombatPage, r[1], 170, 24+(i-1)*22, false, ST, r[2])
end

mkSlider(CombatPage, "Faster Reload",  170, 244, 0.45, C.accent)
mkSlider(CombatPage, "Faster ADS",     170, 268, 0.55, C.accent)
mkSlider(CombatPage, "Faster Equip",   170, 290, 0.65, C.accent)
mkSlider(CombatPage, "Scythe Cooldown",170, 314, 0.73, C.accent)

-- ============================================================
-- WEAPON PAGE  (Skin Changer UI)
-- ============================================================
mkSection(WeaponPage, "Skin Changer", 8, 6, 160)

local skinStatusLbl = mkLabel(WeaponPage, "Status: Ready", 8, 26, 280)
skinStatusLbl.TextColor3 = C.green

local skinSelectedLbl = mkLabel(WeaponPage, "Equipped: None", 8, 44, 280)
skinSelectedLbl.TextColor3 = C.subtext

-- Apply / Reset ボタン
local function mkActionBtn(parent, txt, x, y, w, col)
    local b = Instance.new("TextButton")
    b.Parent = parent; b.Size = UDim2.new(0, w, 0, 24)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = col or C.accent
    b.BorderSizePixel = 0; b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.TextSize = 10; b.Font = Enum.Font.GothamSemibold
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = Color3.fromRGB(
            math.min(col.R*255+15,255),
            math.min(col.G*255+15,255),
            math.min(col.B*255+15,255))
    end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = col end)
    return b
end

local applySkinBtn = mkActionBtn(WeaponPage, "✓ Apply Skin",  8, 68, 130, C.accent)
local resetSkinBtn = mkActionBtn(WeaponPage, "✕ Reset Skin", 145, 68, 130, Color3.fromRGB(140,50,50))

mkSection(WeaponPage, "Auto Settings", 8, 102, 160)
local _, getSkinAutoApply   = mkToggle(WeaponPage, "Auto Apply",   8, 120, false, nil, nil)
local _, getSkinAutoPreview = mkToggle(WeaponPage, "Preview Skin", 8, 142, false, nil, nil)

mkSection(WeaponPage, "Weapon Mods", 8, 172, 160)
local wepModRows = {
    {"Attack Speed",  "wepAttackSpd"},
    {"No Spread",     "wepNoSpread"},
    {"No Recoil",     "wepNoRecoil"},
    {"Infinite Ammo", "wepInfAmmo"},
    {"Auto Reload",   "wepAutoReload"},
}
for i, r in ipairs(wepModRows) do
    mkToggle(WeaponPage, r[1], 8, 190+(i-1)*22, false, ST, r[2])
end

mkSlider(WeaponPage, "Faster Reload", 8, 310, 0.5, C.accent)

-- ============================================================
-- CROSSHAIR PAGE
-- ============================================================
mkSection(CrossPage, "Crosshair", 8, 6, 160)
mkToggle(CrossPage, "Enabled", 8, 24, false, ST, "crossEnabled")
mkLabel(CrossPage, "Style: Yokai Spin", 8, 48, 200)
mkLabel(CrossPage, "Color: Rainbow", 8, 64, 200)

-- ============================================================
-- MISC: その他タブ (空プレースホルダー)
-- ============================================================
for _, pg in ipairs({AutoPage,ClientPage,WorldPage,MovePage,MiscPage,DebugPage,UIPage}) do
    mkLabel(pg, "Coming soon...", 8, 8, 200)
end

-- ============================================================
-- ドラッグ / Lock / Toggle
-- ============================================================
local locked   = false
local dragging = false
local dragStart, startPos

local function updateLock()
    LockBtn.Text = locked and "Unlock" or "Lock"
    LockBtn.TextColor3 = locked and C.accent or C.text
end

LockBtn.MouseButton1Click:Connect(function()
    locked = not locked; updateLock()
end)

local function beginDrag(inp)
    if locked then return end
    dragging = true; dragStart = inp.Position; startPos = Main.Position
end

TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then beginDrag(i) end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                  startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local opened = true
local function setOpened(v)
    opened = v
    if v then
        Main.Visible = true
        Main.Size = UDim2.new(0, WIN_W, 0, 0)
        Main.BackgroundTransparency = 1
        TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0,WIN_W,0,WIN_H), BackgroundTransparency=0}):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(0,WIN_W,0,0), BackgroundTransparency=1}):Play()
        task.delay(0.16, function() if not opened then Main.Visible = false end end)
    end
end
ToggleBtn.MouseButton1Click:Connect(function() setOpened(not opened) end)

-- ── BtnHolder ドラッグ ──
local btnDragging  = false
local btnDragStart = nil
local btnStartPos  = nil

BtnHolder.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        btnDragging  = true
        btnDragStart = i.Position
        btnStartPos  = BtnHolder.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if btnDragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - btnDragStart
        BtnHolder.Position = UDim2.new(
            btnStartPos.X.Scale, btnStartPos.X.Offset + d.X,
            btnStartPos.Y.Scale, btnStartPos.Y.Offset + d.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        btnDragging = false
    end
end)

-- ============================================================
-- ヘルパー関数
-- ============================================================
local function w2s(pos)
    local sp, vis = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), vis
end

local function screenCenter()
    return Vector2.new(Camera.ViewportSize.X*0.5, Camera.ViewportSize.Y*0.5)
end

local function isAlive(char)
    local h = char and char:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function hasLOS(from, to)
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {LocalPlayer.Character}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(from, to - from, rp)
    if not res then return true end
    local m = res.Instance:FindFirstAncestorOfClass("Model")
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == m then return true end
    end
    return false
end

-- 距離でソートしたターゲットリスト取得
local function getSortedTargets()
    local lChar = LocalPlayer.Character
    local lHRP  = lChar and lChar:FindFirstChild("HumanoidRootPart")
    if not lHRP then return {} end
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if ST.rageTeamCheck and plr.Team == LocalPlayer.Team then continue end
        local char = plr.Character
        if not char or not isAlive(char) then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local d = (hrp.Position - lHRP.Position).Magnitude
        table.insert(list, {plr=plr, hrp=hrp, dist=d})
    end
    table.sort(list, function(a,b) return a.dist < b.dist end)
    return list
end

-- 一番近い画面上のターゲット取得 (Aimbot用)
local function getNearestScreenTarget()
    local lChar = LocalPlayer.Character
    local lHRP  = lChar and lChar:FindFirstChild("HumanoidRootPart")
    if not lHRP then return nil, nil end
    local center = screenCenter()
    local bestDist = ST.aimbotIgnoreFOV and math.huge or ST.aimbotFOV
    local bestPlr, bestPart = nil, nil
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        if not char or not isAlive(char) then continue end
        local head = char:FindFirstChild("Head")
        local hrp  = char:FindFirstChild("HumanoidRootPart")
        local part = head or hrp
        if not part then continue end
        local vel = hrp and hrp.Velocity or Vector3.zero
        local pred = part.Position + vel * ST.aimbotPred
        local sp, onScreen = w2s(pred)
        if not onScreen then continue end
        local d = (sp - center).Magnitude
        if d < bestDist then
            bestDist = d; bestPlr = plr; bestPart = part
        end
    end
    return bestPlr, bestPart
end

-- ============================================================
-- Drawing オブジェクト
-- ============================================================

-- FOVサークル
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false; fovCircle.Radius = ST.aimbotFOV
fovCircle.Color = Color3.fromRGB(255,255,255); fovCircle.Thickness = 1
fovCircle.Transparency = 0.6; fovCircle.Filled = false; fovCircle.NumSides = 64

-- ESP オブジェクトプール
local espPool = {}
local function getESP(plr)
    if not espPool[plr] then
        espPool[plr] = {
            box    = Drawing.new("Square"),
            name   = Drawing.new("Text"),
            hpBg   = Drawing.new("Square"),
            hpFill = Drawing.new("Square"),
            dist   = Drawing.new("Text"),
        }
        local e = espPool[plr]
        e.box.Visible = false; e.box.Filled = false
        e.box.Thickness = 1; e.box.Color = C.green

        e.name.Visible = false; e.name.Size = 11
        e.name.Font = Drawing.Fonts.UI
        e.name.Center = true; e.name.Outline = true
        e.name.Color = Color3.fromRGB(255,255,255)

        e.hpBg.Visible = false; e.hpBg.Filled = true
        e.hpBg.Color = Color3.fromRGB(20,20,20)

        e.hpFill.Visible = false; e.hpFill.Filled = true
        e.hpFill.Color = C.green

        e.dist.Visible = false; e.dist.Size = 10
        e.dist.Font = Drawing.Fonts.UI
        e.dist.Center = true; e.dist.Outline = true
        e.dist.Color = C.subtext
    end
    return espPool[plr]
end

local function hideESP(e)
    e.box.Visible=false; e.name.Visible=false
    e.hpBg.Visible=false; e.hpFill.Visible=false
    e.dist.Visible=false
end

-- クロスヘア (4本の線)
local chLines = {}
for i = 1, 4 do
    local l = Drawing.new("Line")
    l.Visible = false; l.Thickness = 2
    l.Color = Color3.fromRGB(255,0,0)
    l.From = Vector2.new(0,0); l.To = Vector2.new(1,0)
    chLines[i] = l
end
local chAngle = 0
local chPhase = 0
local chTick  = 0

-- Rage: ターゲット ESP枠
local rageLine = Drawing.new("Square")
rageLine.Visible = false; rageLine.Filled = false
rageLine.Color = C.red; rageLine.Thickness = 2

-- ============================================================
-- Ragebot  (最強設計)
-- RAGEBOT_MODE:
--   0 = Off
--   1 = Spinbot (自分が高速回転)
--   2 = TeleAbove (頭上瞬間移動)
--   3 = Orbit    (周回 + クロスヘア固定)
--   4 = Overlap  (重なり固定)
--   5 = MapTP    (マップランダム70%重なり)
-- ============================================================
local RB = {
    enabled = false,
    mode    = 0,
    orbitAngle = 0,
    mapTimer   = 0,
    MAP_INTERVAL = 0.15,
    spinAngle    = 0,
}

-- RageセクションUI (CombatPageの下部に追加)
-- CombatPageはスクロール無しなので別セクション枠内
local rageYBase = 6
mkSection(CombatPage, "Ragebot", 170, rageYBase, 155)  -- 上書き防止のためrightカラム下部

-- 実際のRage UIはCombatPageの一番下に別レイヤーで置く
-- ContentのZIndexを使って重ねる
local RagePanel = Instance.new("Frame")
RagePanel.Parent = CombatPage
RagePanel.Size   = UDim2.new(1, 0, 0, 80)
RagePanel.Position = UDim2.new(0, 0, 1, -80)
RagePanel.BackgroundColor3 = Color3.fromRGB(14,13,20)
RagePanel.BorderSizePixel  = 0
RagePanel.ZIndex = 5

local rsBorder = Instance.new("UIStroke", RagePanel)
rsBorder.Color = C.accent; rsBorder.Thickness = 1; rsBorder.Transparency = 0.6

mkSection(RagePanel, "⚡ Ragebot", 8, 4, 150)

local _, getRageEnabled = mkToggle(RagePanel,"Enabled",8,22,false,RB,"enabled")

-- モードボタン
local RMODES = {"Spinbot","AboveHead","Orbit","Overlap","MapTP"}
local RCOLORS = {
    Color3.fromRGB(220,60,60),
    Color3.fromRGB(80,180,255),
    Color3.fromRGB(255,160,60),
    Color3.fromRGB(180,60,220),
    Color3.fromRGB(80,220,130),
}
local rModeBtns = {}
local rModeLbl = mkLabel(RagePanel, "Mode: OFF", 8, 46, 120)
rModeLbl.TextColor3 = C.subtext
rModeLbl.ZIndex = 6

for i, nm in ipairs(RMODES) do
    local bx = 130 + (i-1)*58
    local btn = Instance.new("TextButton")
    btn.Parent = RagePanel
    btn.Size   = UDim2.new(0, 55, 0, 18)
    btn.Position = UDim2.new(0, bx, 0, 44)
    btn.BackgroundColor3 = Color3.fromRGB(18,16,26)
    btn.BorderSizePixel  = 0
    btn.Text     = nm
    btn.TextColor3 = C.subtext
    btn.TextSize   = 8
    btn.Font       = Enum.Font.Gotham
    btn.AutoButtonColor = false
    btn.ZIndex = 6
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,3)
    local idx = i
    btn.MouseButton1Click:Connect(function()
        RB.mode = (RB.mode == idx) and 0 or idx
        for j, b in ipairs(rModeBtns) do
            if RB.mode == j then
                b.BackgroundColor3 = RCOLORS[j]
                b.TextColor3 = Color3.fromRGB(255,255,255)
            else
                b.BackgroundColor3 = Color3.fromRGB(18,16,26)
                b.TextColor3 = C.subtext
            end
        end
        local labels = {"OFF","Spinbot","AboveHead","Orbit","Overlap","MapTP"}
        rModeLbl.Text = "Mode: "..labels[RB.mode+1]
        rModeLbl.TextColor3 = RB.mode > 0 and RCOLORS[RB.mode] or C.subtext
    end)
    rModeBtns[i] = btn
end

-- ============================================================
-- Silent Aim Hook
-- ============================================================
local origIndex
if hookmetamethod then
    origIndex = hookmetamethod(game, "__index", function(self, key)
        if ST.aimbotEnabled and ST.aimbotSilent
           and typeof(self) == "Instance" and self:IsA("Camera") and key == "CFrame" then
            local _, part = getNearestScreenTarget()
            if part then
                local hrp = part.Parent:FindFirstChild("HumanoidRootPart")
                local vel = hrp and hrp.Velocity or Vector3.zero
                local pred = part.Position + vel * ST.aimbotPred
                local camCF = origIndex(self, "CFrame")
                return CFrame.new(camCF.Position, pred)
            end
        end
        return origIndex(self, key)
    end)
end

-- ============================================================
-- メインループ: RenderStepped (クロスヘア) + Heartbeat (全機能)
-- ============================================================

-- クロスヘア: RenderStepped で毎フレーム
RunService.RenderStepped:Connect(function(dt)
    chTick  += dt
    chAngle += dt * 0.7
    chPhase += dt * 2.0
    local vis = ST.crossEnabled
    if not vis then
        for _, l in ipairs(chLines) do l.Visible = false end
        return
    end
    local vp  = Camera.ViewportSize
    local cx, cy = vp.X*0.5, vp.Y*0.5
    local len = 7 + 20*((math.sin(chPhase)+1)*0.5)
    local gap = 5
    for i, line in ipairs(chLines) do
        line.Visible = true
        local ang = chAngle + (i-1)*(math.pi*0.5)
        local dx, dy = math.cos(ang), math.sin(ang)
        line.Color = Color3.fromHSV((chTick*0.28 + (i-1)*0.25) % 1, 1, 1)
        line.From  = Vector2.new(cx+dx*gap,       cy+dy*gap)
        line.To    = Vector2.new(cx+dx*(gap+len), cy+dy*(gap+len))
    end
end)

-- Heartbeat: Aimbot + ESP + Ragebot
local VU = game:GetService("VirtualUser")

RunService.Heartbeat:Connect(function(dt)
    local lChar = LocalPlayer.Character
    local lHRP  = lChar and lChar:FindFirstChild("HumanoidRootPart")

    -- ── FOV Circle ──
    local sc = screenCenter()
    fovCircle.Position = sc
    fovCircle.Radius   = ST.aimbotFOV
    fovCircle.Visible  = ST.aimbotEnabled and ST.aimbotShowFOV and not ST.aimbotIgnoreFOV

    -- ── Aimbot (非Silent: Softaim) ──
    if ST.aimbotEnabled and not ST.aimbotSilent and lHRP then
        local plr, part = getNearestScreenTarget()
        if plr and part then
            local hrp2 = part.Parent:FindFirstChild("HumanoidRootPart")
            local vel2 = hrp2 and hrp2.Velocity or Vector3.zero
            local pred = part.Position + vel2 * ST.aimbotPred
            local sp, vis = w2s(pred)
            if vis then
                local mouse = LocalPlayer:GetMouse()
                local cur   = Vector2.new(mouse.X, mouse.Y)
                local moved = cur:Lerp(sp, math.clamp(ST.aimbotSmooth, 0.01, 1))
                mousemoverel(moved.X - cur.X, moved.Y - cur.Y)
            end
            -- Triggerbot
            if ST.aimbotTrigger then
                VU:Button1Down(Vector2.new(0,0), Camera.CFrame)
                task.wait(0.05)
                VU:Button1Up(Vector2.new(0,0), Camera.CFrame)
            end
        end
    end

    -- ── ESP ──
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local e    = getESP(plr)
        local char = plr.Character
        if not ST.espEnabled or not char or not isAlive(char) then
            hideESP(e); continue
        end
        local hrp3 = char:FindFirstChild("HumanoidRootPart")
        local hum3 = char:FindFirstChildOfClass("Humanoid")
        if not hrp3 then hideESP(e); continue end

        local topSP, topVis = w2s(hrp3.Position + Vector3.new(0, 3.2, 0))
        local botSP, botVis = w2s(hrp3.Position + Vector3.new(0,-3.2, 0))
        if not topVis and not botVis then hideESP(e); continue end

        local h = math.max(math.abs(topSP.Y - botSP.Y), 1)
        local w = h * 0.55
        local lx = topSP.X - w/2

        e.box.Visible   = ST.espBoxes
        e.box.Size      = Vector2.new(w, h)
        e.box.Position  = Vector2.new(lx, topSP.Y)
        -- チームで色変え
        e.box.Color = (plr.Team == LocalPlayer.Team) and C.green or C.red

        e.name.Visible   = ST.espNames
        e.name.Text      = plr.DisplayName
        e.name.Position  = Vector2.new(topSP.X, topSP.Y - 14)

        local hp = hum3 and math.clamp(hum3.Health/hum3.MaxHealth, 0, 1) or 1
        e.hpBg.Visible   = ST.espHealthInfo
        e.hpBg.Size      = Vector2.new(3, h)
        e.hpBg.Position  = Vector2.new(lx - 5, topSP.Y)
        e.hpFill.Visible = ST.espHealthInfo
        e.hpFill.Size    = Vector2.new(3, h*hp)
        e.hpFill.Position = Vector2.new(lx - 5, topSP.Y + h*(1-hp))
        e.hpFill.Color   = Color3.fromRGB(math.floor((1-hp)*255), math.floor(hp*200), 50)

        local distM = lHRP and math.floor((hrp3.Position - lHRP.Position).Magnitude) or 0
        e.dist.Visible   = ST.espDistance
        e.dist.Text      = distM.."m"
        e.dist.Position  = Vector2.new(topSP.X, botSP.Y + 2)
    end

    -- ESP pool cleanup
    for plr, e in pairs(espPool) do
        if not plr.Parent then hideESP(e); espPool[plr] = nil end
    end

    -- ── Ragebot ──
    if not RB.enabled or RB.mode == 0 or not lHRP then
        rageLine.Visible = false
        return
    end

    local targets = getSortedTargets()
    local best = targets[1]   -- 一番近い敵

    if not best then
        rageLine.Visible = false
        return
    end

    local tHRP  = best.hrp
    local tChar = best.plr.Character
    local tHead = tChar and tChar:FindFirstChild("Head")

    -- 共通: ターゲットESP枠
    if tHead then
        local tTopSP, tTopVis = w2s(tHRP.Position + Vector3.new(0,3.2,0))
        local tBotSP, _ = w2s(tHRP.Position + Vector3.new(0,-3.2,0))
        if tTopVis then
            local rh = math.max(math.abs(tTopSP.Y-tBotSP.Y),1)
            local rw = rh*0.55
            rageLine.Size     = Vector2.new(rw,rh)
            rageLine.Position = Vector2.new(tTopSP.X-rw/2, tTopSP.Y)
            rageLine.Visible  = true
            -- 色をモードに合わせる
            rageLine.Color = RCOLORS[RB.mode] or C.red
        else
            rageLine.Visible = false
        end
    end

    -- Mode 1: Spinbot (自分がY軸高速スピン)
    if RB.mode == 1 then
        RB.spinAngle = RB.spinAngle + dt * 30   -- 30 rad/s ≈ 5回転/秒
        local newCF = CFrame.new(lHRP.Position) * CFrame.Angles(0, RB.spinAngle, 0)
        lHRP.CFrame = newCF

    -- Mode 2: AboveHead (頭の真上に瞬間移動)
    elseif RB.mode == 2 then
        if tHead then
            lHRP.CFrame = CFrame.new(tHead.Position + Vector3.new(0, 4.5, 0))
        end

    -- Mode 3: Orbit (周回 + カメラ頭固定)
    elseif RB.mode == 3 then
        RB.orbitAngle = RB.orbitAngle + dt * 8   -- 速い周回
        local r = 3.5
        local ox = math.cos(RB.orbitAngle)*r
        local oz = math.sin(RB.orbitAngle)*r
        local orbitPos = tHRP.Position + Vector3.new(ox, 0.5, oz)
        if tHead then
            lHRP.CFrame = CFrame.new(orbitPos, tHead.Position)
            -- カメラも頭に向ける
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, tHead.Position)
        else
            lHRP.CFrame = CFrame.new(orbitPos)
        end

    -- Mode 4: Overlap (完全重なり + 固定)
    elseif RB.mode == 4 then
        lHRP.CFrame = tHRP.CFrame
        -- 自動発火
        VU:Button1Down(Vector2.new(0,0), Camera.CFrame)
        task.wait(0.03)
        VU:Button1Up(Vector2.new(0,0), Camera.CFrame)

    -- Mode 5: MapTP (70%重なり / 30%ランダム)
    elseif RB.mode == 5 then
        RB.mapTimer += dt
        if RB.mapTimer >= RB.MAP_INTERVAL then
            RB.mapTimer = 0
            if math.random() < 0.70 then
                -- 70%: ターゲットと重なる
                lHRP.CFrame = tHRP.CFrame
            else
                -- 30%: マップ内ランダム
                local camP = Camera.CFrame.Position
                local rx = camP.X + math.random(-120, 120)
                local rz = camP.Z + math.random(-120, 120)
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {lChar}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local res = workspace:Raycast(
                    Vector3.new(rx, camP.Y+200, rz),
                    Vector3.new(0,-400,0), rp)
                if res then
                    lHRP.CFrame = CFrame.new(res.Position + Vector3.new(0,3,0))
                end
            end
        end
    end
end)

-- ============================================================
-- スキンチェンジャー (rivals_unlocker.lua 完全統合版)
-- ============================================================
local _rs      = game:GetService("ReplicatedStorage")
local _http    = game:GetService("HttpService")
local _lp      = LocalPlayer
local _pscripts = _lp.PlayerScripts
local _ctrl2   = _pscripts:FindFirstChild("Controllers")
local _mods    = _rs:FindFirstChild("Modules")

-- モジュール取得
local _enumLib, _cosLib, _datCtrl, _itmLib
pcall(function()
    if not _mods then _mods = _rs:WaitForChild("Modules", 10) end
    _enumLib = require(_mods:WaitForChild("EnumLibrary", 10))
    if _enumLib then pcall(function() _enumLib:WaitForEnumBuilder() end) end
    _cosLib  = require(_mods:WaitForChild("CosmeticLibrary", 10))
    _itmLib  = require(_mods:WaitForChild("ItemLibrary", 10))
    if _ctrl2 then
        _datCtrl = require(_ctrl2:WaitForChild("PlayerDataController", 10))
    end
end)

local _eq, _favs = {}, {}
local _buildingWep, _lastWep = nil, nil
local _cfgFile = "rivals_unlocker_config.json"
local _saveLock = false

local function _mkCosmetic(nm, ctype, opts)
    if not _cosLib then return nil end
    local _base = _cosLib.Cosmetics[nm]
    if not _base then return nil end
    local _d = {}
    for k, v in pairs(_base) do _d[k] = v end
    _d.Name = nm
    _d.Type = _d.Type or ctype
    _d.Seed = _d.Seed or math.random(1, 1000000)
    if _enumLib then
        local ok, eid = pcall(_enumLib.ToEnum, _enumLib, nm)
        if ok and eid then
            _d.Enum = eid
            _d.ObjectID = _d.ObjectID or eid
        end
    end
    if opts then
        if opts.inverted ~= nil    then _d.Inverted         = opts.inverted end
        if opts.favoritesOnly ~= nil then _d.OnlyUseFavorites = opts.favoritesOnly end
    end
    return _d
end

local function _stripForSave()
    local out = {}
    for wn, cos in pairs(_eq) do
        out[wn] = {}
        for ct, cd in pairs(cos) do
            if cd and cd.Name then
                out[wn][ct] = {
                    Name             = cd.Name,
                    Inverted         = cd.Inverted,
                    OnlyUseFavorites = cd.OnlyUseFavorites
                }
            end
        end
    end
    return { equipped = out, favorites = _favs }
end

local function _loadCfg()
    if not isfile or not readfile then return end
    local ok1, ex = pcall(isfile, _cfgFile)
    if not ok1 or not ex then return end
    local ok2, raw = pcall(readfile, _cfgFile)
    if not ok2 or not raw or raw == "" then return end
    local ok3, dec = pcall(_http.JSONDecode, _http, raw)
    if not ok3 or not dec then return end
    if dec.favorites then _favs = dec.favorites end
    if dec.equipped and _cosLib then
        _eq = {}
        for wn, cos in pairs(dec.equipped) do
            _eq[wn] = {}
            for ct, sd in pairs(cos) do
                if sd and sd.Name and _cosLib.Cosmetics[sd.Name] then
                    local cl = _mkCosmetic(sd.Name, ct, {
                        inverted = sd.Inverted,
                        favoritesOnly = sd.OnlyUseFavorites
                    })
                    if cl then _eq[wn][ct] = cl end
                end
            end
            if not next(_eq[wn]) then _eq[wn] = nil end
        end
        skinStatusLbl.Text      = "Status: Loaded ✓"
        skinStatusLbl.TextColor3 = C.green
    end
end

local function _saveCfg()
    if not writefile or _saveLock then return end
    _saveLock = true
    task.spawn(function()
        task.wait(1)
        local payload = _stripForSave()
        local ok, enc = pcall(_http.JSONEncode, _http, payload)
        if ok then pcall(writefile, _cfgFile, enc) end
        _saveLock = false
    end)
end

local _cosTypes = {"Skin","Wrap","Charm","Dance","Emote"}
local function _isCosType(cosObj)
    if not cosObj then return false end
    for _, t in ipairs(_cosTypes) do
        if cosObj.Type == t then return true end
    end
    return false
end

-- ボタン接続（skinStatusLbl / skinSelectedLbl は WeaponPage UI で既に定義済み）
applySkinBtn.MouseButton1Click:Connect(function()
    if not _cosLib then
        skinStatusLbl.Text      = "Status: No CosLib"
        skinStatusLbl.TextColor3 = C.red
        return
    end
    skinStatusLbl.Text       = "Status: Active ✓"
    skinStatusLbl.TextColor3 = C.green
    skinSelectedLbl.Text     = "Equipped: All Unlocked"
end)

resetSkinBtn.MouseButton1Click:Connect(function()
    _eq = {}
    _saveCfg()
    skinStatusLbl.Text       = "Status: Reset"
    skinStatusLbl.TextColor3 = C.orange
    skinSelectedLbl.Text     = "Equipped: None"
end)

-- CosLib hooks
if _cosLib then
    _cosLib.OwnsCosmeticNormally    = function(s,i,nm,w)
        local c = _cosLib.Cosmetics[nm]; return (c and c.Type=="Skin") or false end
    _cosLib.OwnsCosmeticUniversally = function(s,i,nm,w)
        local c = _cosLib.Cosmetics[nm]; return (c and c.Type=="Skin") or false end
    _cosLib.OwnsCosmeticForWeapon   = function(s,i,nm,w)
        local c = _cosLib.Cosmetics[nm]; return (c and c.Type=="Skin") or false end

    local _origOwns = _cosLib.OwnsCosmetic
    _cosLib.OwnsCosmetic = function(s,i,nm,w)
        if nm:find("MISSING_") or nm == "Bubble Gun" then return _origOwns(s,i,nm,w) end
        local c = _cosLib.Cosmetics[nm]
        if c and _isCosType(c) then return true end
        return _origOwns(s,i,nm,w)
    end
end

-- DataCtrl hooks
if _datCtrl then
    local _origGet = _datCtrl.Get
    _datCtrl.Get = function(s, key)
        local v = _origGet(s, key)
        if key == "CosmeticInventory" then
            local prx = {}
            if v then for k,val in pairs(v) do
                local c = _cosLib and _cosLib.Cosmetics[k]
                if c and _isCosType(c) then prx[k] = val end
            end end
            return setmetatable(prx, {__index=function(t,k)
                local c = _cosLib and _cosLib.Cosmetics[k]
                return (c and _isCosType(c)) and true or nil
            end})
        end
        if key == "FavoritedCosmetics" then
            local res = v and table.clone(v) or {}
            for wep,fv in pairs(_favs) do
                res[wep] = res[wep] or {}
                for nm,isFav in pairs(fv) do
                    local c = _cosLib and _cosLib.Cosmetics[nm]
                    if c and _isCosType(c) then res[wep][nm] = isFav end
                end
            end
            return res
        end
        return v
    end

    local _origGetWep = _datCtrl.GetWeaponData
    _datCtrl.GetWeaponData = function(s, wn)
        local d = _origGetWep(s, wn)
        if not d then return nil end
        local m = {}; for k,v in pairs(d) do m[k]=v end
        m.Name = wn
        if _eq[wn] then for ct,cd in pairs(_eq[wn]) do m[ct]=cd end end
        return m
    end
end

-- namecall hook (装備/お気に入り)
if hookmetamethod and _datCtrl then
    local _rems   = _rs:FindFirstChild("Remotes")
    local _datRem = _rems and _rems:FindFirstChild("Data")
    local _eqRem  = _datRem and _datRem:FindFirstChild("EquipCosmetic")
    local _favRem = _datRem and _datRem:FindFirstChild("FavoriteCosmetic")
    local _repRem = _rems and _rems:FindFirstChild("Replication")
    local _figRem = _repRem and _repRem:FindFirstChild("Fighter")
    local _useRem = _figRem and _figRem:FindFirstChild("UseItem")
    local _fCtrl
    if _ctrl2 then pcall(function()
        _fCtrl = require(_ctrl2:WaitForChild("FighterController", 10))
    end) end

    if _eqRem then
        local _onc
        _onc = hookmetamethod(game, "__namecall", function(self, ...)
            if getnamecallmethod() ~= "FireServer" then return _onc(self,...) end
            local a = {...}

            -- UseItem: 最後に使った武器名を追跡
            if _useRem and self == _useRem then
                local oid = a[1]
                if _fCtrl then pcall(function()
                    local f = _fCtrl:GetFighter(_lp)
                    if f and f.Items then for _,itm in pairs(f.Items) do
                        if itm:Get("ObjectID") == oid then _lastWep = itm.Name; break end
                    end end
                end) end
            end

            -- EquipCosmetic: インターセプト
            if self == _eqRem then
                local wn, ct, cn, opts = a[1], a[2], a[3], a[4] or {}
                if cn and cn ~= "None" and cn ~= "" then
                    local inv = _datCtrl:Get("CosmeticInventory")
                    if inv and rawget(inv, cn) then return _onc(self,...) end
                end
                _eq[wn] = _eq[wn] or {}
                if not cn or cn == "None" or cn == "" then
                    _eq[wn][ct] = nil
                    if not next(_eq[wn]) then _eq[wn] = nil end
                else
                    local cl = _mkCosmetic(cn, ct, {
                        inverted       = opts.IsInverted,
                        favoritesOnly  = opts.OnlyUseFavorites
                    })
                    if cl then
                        _eq[wn][ct] = cl
                        skinSelectedLbl.Text     = "Equipped: "..cn
                        skinSelectedLbl.TextColor3 = C.text
                        skinStatusLbl.Text       = "Status: Active ✓"
                        skinStatusLbl.TextColor3 = C.green
                    end
                end
                task.defer(function()
                    pcall(function() _datCtrl.CurrentData:Replicate("WeaponInventory") end)
                end)
                _saveCfg()
                return
            end

            -- FavoriteCosmetic
            if self == _favRem then
                local cos = _cosLib and _cosLib.Cosmetics[a[2]]
                if cos then
                    _favs[a[1]] = _favs[a[1]] or {}
                    _favs[a[1]][a[2]] = a[3] or nil
                    task.spawn(function()
                        pcall(function() _datCtrl.CurrentData:Replicate("FavoritedCosmetics") end)
                    end)
                    _saveCfg()
                end
                return
            end

            return _onc(self,...)
        end)
    end
end

-- ClientViewModel hook (スキンプレビュー)
local _cliItem
pcall(function()
    _cliItem = require(_lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem)
end)

if _cliItem and _cliItem._CreateViewModel then
    local _origCVM = _cliItem._CreateViewModel
    _cliItem._CreateViewModel = function(self, vmRef)
        local _wn = self.Name
        local _wp = self.ClientFighter and self.ClientFighter.Player
        _buildingWep = (_wp == _lp) and _wn or nil
        if _wp == _lp and _eq[_wn] then
            local _dk = self:ToEnum("Data")
            if vmRef[_dk] then
                if _eq[_wn].Skin  then vmRef[_dk][self:ToEnum("Skin")] = _eq[_wn].Skin; vmRef[_dk][self:ToEnum("Name")] = _eq[_wn].Skin.Name end
                if _eq[_wn].Charm then vmRef[_dk][self:ToEnum("Charm")] = _eq[_wn].Charm end
                if _eq[_wn].Wrap  then vmRef[_dk][self:ToEnum("Wrap")]  = _eq[_wn].Wrap  end
            elseif vmRef.Data then
                if _eq[_wn].Skin  then vmRef.Data.Skin = _eq[_wn].Skin; vmRef.Data.Name = _eq[_wn].Skin.Name end
                if _eq[_wn].Charm then vmRef.Data.Charm = _eq[_wn].Charm end
                if _eq[_wn].Wrap  then vmRef.Data.Wrap  = _eq[_wn].Wrap  end
            end
        end
        local r = _origCVM(self, vmRef)
        _buildingWep = nil
        return r
    end
end

local _vmMod = _lp.PlayerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem:FindFirstChild("ClientViewModel")
if _vmMod then
    local _CVM = require(_vmMod)
    local _origNew = _CVM.new
    _CVM.new = function(repData, cliItm)
        local _wp = cliItm.ClientFighter and cliItm.ClientFighter.Player
        local _wn = _buildingWep or cliItm.Name
        if _wp == _lp and _eq[_wn] then
            local _RC = require(_rs.Modules.ReplicatedClass)
            local _dk = _RC:ToEnum("Data")
            repData[_dk] = repData[_dk] or {}
            local cos = _eq[_wn]
            if cos.Skin  then repData[_dk][_RC:ToEnum("Skin")]  = cos.Skin  end
            if cos.Charm then repData[_dk][_RC:ToEnum("Charm")] = cos.Charm end
            if cos.Wrap  then repData[_dk][_RC:ToEnum("Wrap")]  = cos.Wrap  end
        end
        return _origNew(repData, cliItm)
    end
end

-- 起動時にコンフィグを読み込む
_loadCfg()

print("✅ Yokai Named v5 Loaded  ─  Skin Changer Active")
