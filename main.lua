--[[
╔══════════════════════════════════════════════════════╗
║                  CalmLib  v3.0                       ║
║          A Modern Roblox UI Library                  ║
╠══════════════════════════════════════════════════════╣
║  local lib = loadstring(game:HttpGet("..."))()       ║
║  local win = lib:Win("Title", "Subtitle")            ║
║  local tab = win:Tab("Name", "rbxassetid://...")     ║
║                                                      ║
║  tab:Toggle("Label", false, callback)                ║
║  tab:Button("Label", callback)                       ║
║  tab:Slider("Label", min, max, default, callback)    ║
║  tab:Dropdown("Label", {"A","B"}, callback)          ║
║  tab:Textbox("Label", "placeholder", callback)       ║
║  tab:Keybind("Label", Enum.KeyCode.F, callback)      ║
║  tab:ColorPicker("Label", Color3, callback)          ║
║  tab:Label("text")                                   ║
║  tab:Separator("Optional title")                     ║
║  win:Notify("Title", "Message", duration)            ║
╚══════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════
--  Services
-- ═══════════════════════════════════════════════
local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS  = game:GetService("RunService")
local CG  = game:GetService("CoreGui")

-- ═══════════════════════════════════════════════
--  Theme
-- ═══════════════════════════════════════════════
local TH = {
    -- Base
    BG          = Color3.fromRGB(12, 12, 18),
    BG2         = Color3.fromRGB(16, 16, 24),
    BG3         = Color3.fromRGB(20, 20, 30),
    -- Sidebar
    Side        = Color3.fromRGB(14, 14, 22),
    SideBorder  = Color3.fromRGB(26, 26, 40),
    -- Cards
    Card        = Color3.fromRGB(19, 19, 29),
    CardHov     = Color3.fromRGB(23, 23, 35),
    CardPress   = Color3.fromRGB(15, 15, 24),
    -- Accent (violet-blue)
    Acc         = Color3.fromRGB(113, 95, 252),
    AccHov      = Color3.fromRGB(133, 116, 255),
    AccDim      = Color3.fromRGB(48, 40, 110),
    AccGlow     = Color3.fromRGB(90, 75, 200),
    -- Status
    Green       = Color3.fromRGB(68, 210, 145),
    Red         = Color3.fromRGB(235, 80, 90),
    Yellow      = Color3.fromRGB(245, 185, 50),
    -- Text
    T1          = Color3.fromRGB(228, 225, 248),
    T2          = Color3.fromRGB(145, 140, 180),
    T3          = Color3.fromRGB(85,  82, 120),
    -- Misc
    Border      = Color3.fromRGB(26, 26, 42),
    White       = Color3.fromRGB(255, 255, 255),
    Black       = Color3.fromRGB(0, 0, 0),
    Track       = Color3.fromRGB(28, 28, 44),
    TogOff      = Color3.fromRGB(38, 38, 58),
    TabIdl      = Color3.fromRGB(75, 72, 110),
    TabAct      = Color3.fromRGB(225, 222, 248),
    TabPill     = Color3.fromRGB(24, 22, 40),
}

-- ═══════════════════════════════════════════════
--  Layout constants
-- ═══════════════════════════════════════════════
local SW   = 148      -- sidebar width
local WW   = 560      -- window width
local WH   = 390      -- window height
local TH_  = 44       -- titlebar height

local C10  = UDim.new(0,10)
local C6   = UDim.new(0,6)
local C4   = UDim.new(0,4)
local C20  = UDim.new(1,0)

local FB   = Enum.Font.GothamBold
local FS   = Enum.Font.GothamSemibold
local FR   = Enum.Font.Gotham

-- ═══════════════════════════════════════════════
--  Utility
-- ═══════════════════════════════════════════════
local function TW(obj, dur, props, sty, dir)
    local ti = TweenInfo.new(dur or 0.18, sty or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local t = TS:Create(obj, ti, props); t:Play(); return t
end

local function Inst(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do
        if k ~= "Ch" then o[k] = v end
    end
    if props and props.Ch then
        for _,c in ipairs(props.Ch) do if c then c.Parent = o end end
    end
    if parent then o.Parent = parent end
    return o
end

local function Cor(r)  return Inst("UICorner",{CornerRadius=r or C6}) end
local function Str(c,t) return Inst("UIStroke",{Color=c or TH.Border,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function Pad(l,r,t,b) return Inst("UIPadding",{PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0)}) end
local function LL(fd,p,ha)  return Inst("UIListLayout",{FillDirection=fd or Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,p or 0),HorizontalAlignment=ha or Enum.HorizontalAlignment.Left}) end

local function Drag(frame, handle)
    local drag, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        drag = true; ds = i.Position; sp = frame.Position
        i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then drag = false end end)
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

local function HoverCard(card)
    local hb = Inst("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=card.ZIndex+5},card)
    hb.MouseEnter:Connect(function() TW(card,0.12,{BackgroundColor3=TH.CardHov}) end)
    hb.MouseLeave:Connect(function() TW(card,0.12,{BackgroundColor3=TH.Card}) end)
    return hb
end

-- ═══════════════════════════════════════════════
--  Section
-- ═══════════════════════════════════════════════
local Section = {}
Section.__index = Section

function Section:_Add(el) el.Parent = self._sc end

-- ─── Toggle ─────────────────────────────────────
function Section:Toggle(label, default, cb)
    local state = (default == true)

    local card = Inst("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=TH.Card,BorderSizePixel=0,Ch={Cor(C4),Str(TH.Border)}})

    Inst("TextLabel",{Size=UDim2.new(1,-62,1,0),Position=UDim2.new(0,14,0,0),BackgroundTransparency=1,
        Text=label,TextColor3=TH.T1,TextSize=13,Font=FS,TextXAlignment=Enum.TextXAlignment.Left},card)

    local track = Inst("Frame",{Size=UDim2.new(0,42,0,24),Position=UDim2.new(1,-56,0.5,-12),
        BackgroundColor3=state and TH.Acc or TH.TogOff,BorderSizePixel=0,Ch={Cor(C20)},Parent=card})

    local knob = Inst("Frame",{Size=UDim2.new(0,18,0,18),
        Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
        BackgroundColor3=TH.White,BorderSizePixel=0,Ch={Cor(C20)},Parent=track})

    local hb = HoverCard(card)
    local function set(s, fire)
        state = s
        TW(track,0.2,{BackgroundColor3=s and TH.Acc or TH.TogOff})
        TW(knob,0.22,{Position=s and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        if fire and cb then pcall(cb,state) end
    end
    hb.MouseButton1Click:Connect(function() set(not state,true) end)

    self:_Add(card)
    return { Set=function(v) set(v==true,true) end, Get=function() return state end }
end

-- ─── Button ─────────────────────────────────────
function Section:Button(label, cb)
    local btn = Inst("TextButton",{Size=UDim2.new(1,0,0,38),BackgroundColor3=TH.Acc,
        BorderSizePixel=0,Text=label,TextColor3=TH.White,TextSize=13,Font=FB,Ch={Cor(C4)}})

    btn.MouseEnter:Connect(function()   TW(btn,0.13,{BackgroundColor3=TH.AccHov}) end)
    btn.MouseLeave:Connect(function()   TW(btn,0.13,{BackgroundColor3=TH.Acc}) end)
    btn.MouseButton1Down:Connect(function()
        TW(btn,0.08,{BackgroundColor3=TH.AccDim,Size=UDim2.new(1,-6,0,36)})
    end)
    btn.MouseButton1Up:Connect(function()
        TW(btn,0.15,{BackgroundColor3=TH.AccHov,Size=UDim2.new(1,0,0,38)})
        if cb then pcall(cb) end
    end)

    self:_Add(btn)
    return btn
end

-- ─── Slider ─────────────────────────────────────
function Section:Slider(label, mn, mx, def, cb)
    mn=mn or 0; mx=mx or 100
    local val = math.clamp(def or mn, mn, mx)
    local pct = (val-mn)/(mx-mn)

    local card = Inst("Frame",{Size=UDim2.new(1,0,0,60),BackgroundColor3=TH.Card,BorderSizePixel=0,Ch={Cor(C4),Str(TH.Border)}})
    Pad(14,14,10,10).Parent = card

    -- Header
    local hdr = Inst("Frame",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Parent=card})
    Inst("TextLabel",{Size=UDim2.new(0.6,0,1,0),BackgroundTransparency=1,Text=label,
        TextColor3=TH.T1,TextSize=13,Font=FS,TextXAlignment=Enum.TextXAlignment.Left},hdr)
    local vlbl = Inst("TextLabel",{Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.6,0,0,0),
        BackgroundTransparency=1,Text=tostring(val),TextColor3=TH.Acc,TextSize=13,Font=FB,
        TextXAlignment=Enum.TextXAlignment.Right},hdr)

    -- Track row
    local trow = Inst("Frame",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,1,-16),
        BackgroundTransparency=1,Parent=card})
    local trk = Inst("Frame",{Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,0.5,-2),
        BackgroundColor3=TH.Track,BorderSizePixel=0,Ch={Cor(C20)},Parent=trow})
    local fill = Inst("Frame",{Size=UDim2.new(pct,0,1,0),BackgroundColor3=TH.Acc,
        BorderSizePixel=0,Ch={Cor(C20)},Parent=trk})
    local knob = Inst("Frame",{Size=UDim2.new(0,15,0,15),
        Position=UDim2.new(pct,-7,0.5,-7),BackgroundColor3=TH.White,
        BorderSizePixel=0,Ch={Cor(C20)},Parent=trk})
    -- Glow ring behind knob
    local glow = Inst("Frame",{Size=UDim2.new(0,23,0,23),
        Position=UDim2.new(pct,-11,0.5,-11),BackgroundColor3=TH.Acc,
        BackgroundTransparency=0.7,BorderSizePixel=0,ZIndex=knob.ZIndex-1,Ch={Cor(C20)},Parent=trk})

    local hb = Inst("TextButton",{Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0.5,-14),
        BackgroundTransparency=1,Text="",ZIndex=10,Parent=trow})

    local sliding = false
    local function setFromX(x)
        local ap = trk.AbsolutePosition.X
        local aw = trk.AbsoluteSize.X
        local p  = math.clamp((x-ap)/aw,0,1)
        val = math.round(mn+(mx-mn)*p)
        local np = (val-mn)/(mx-mn)
        vlbl.Text = tostring(val)
        fill.Size         = UDim2.new(np,0,1,0)
        knob.Position     = UDim2.new(np,-7,0.5,-7)
        glow.Position     = UDim2.new(np,-11,0.5,-11)
        if cb then pcall(cb,val) end
    end

    hb.MouseButton1Down:Connect(function(x)
        sliding=true
        TW(knob,0.1,{Size=UDim2.new(0,17,0,17)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
        TW(glow,0.1,{BackgroundTransparency=0.5})
        setFromX(x)
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            setFromX(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and sliding then
            sliding=false
            TW(knob,0.12,{Size=UDim2.new(0,15,0,15)})
            TW(glow,0.12,{BackgroundTransparency=0.7})
        end
    end)

    hb.MouseEnter:Connect(function() TW(card,0.12,{BackgroundColor3=TH.CardHov}) end)
    hb.MouseLeave:Connect(function() TW(card,0.12,{BackgroundColor3=TH.Card}) end)

    self:_Add(card)
    return {
        Get=function() return val end,
        Set=function(v)
            v=math.clamp(math.round(v),mn,mx); val=v
            local np=(v-mn)/(mx-mn)
            vlbl.Text=tostring(v)
            TW(fill,0.15,{Size=UDim2.new(np,0,1,0)})
            TW(knob,0.15,{Position=UDim2.new(np,-7,0.5,-7)})
            TW(glow,0.15,{Position=UDim2.new(np,-11,0.5,-11)})
            if cb then pcall(cb,v) end
        end
    }
end

-- ─── Dropdown ───────────────────────────────────
function Section:Dropdown(label, opts, cb)
    local sel  = opts and opts[1]
    local open = false
    local IH   = 30
    local CH   = 44

    local wrap = Inst("Frame",{Size=UDim2.new(1,0,0,CH),BackgroundTransparency=1,BorderSizePixel=0,ClipsDescendants=false})
    local card = Inst("Frame",{Size=UDim2.new(1,0,0,CH),BackgroundColor3=TH.Card,BorderSizePixel=0,
        ClipsDescendants=true,ZIndex=20,Ch={Cor(C4),Str(TH.Border)},Parent=wrap})

    -- header
    local hdr = Inst("Frame",{Size=UDim2.new(1,0,0,CH),BackgroundTransparency=1,ZIndex=21,Parent=card})
    Pad(14,12,0,0).Parent=hdr
    Inst("TextLabel",{Size=UDim2.new(0.46,0,1,0),BackgroundTransparency=1,Text=label,
        TextColor3=TH.T1,TextSize=13,Font=FS,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=22},hdr)
    local sLbl=Inst("TextLabel",{Size=UDim2.new(0.44,0,1,0),Position=UDim2.new(0.46,0,0,0),
        BackgroundTransparency=1,Text=sel or "Select...",TextColor3=TH.Acc,TextSize=13,Font=FB,
        TextXAlignment=Enum.TextXAlignment.Right,ZIndex=22},hdr)
    local arrow=Inst("TextLabel",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(1,-20,0.5,-8),
        BackgroundTransparency=1,Text="▾",TextColor3=TH.T2,TextSize=14,Font=FB,ZIndex=22},hdr)

    -- options
    local oFrame=Inst("Frame",{Size=UDim2.new(1,0,0,#opts*IH),Position=UDim2.new(0,0,0,CH),
        BackgroundColor3=TH.BG2,BorderSizePixel=0,ZIndex=21,
        Ch={LL(Enum.FillDirection.Vertical,0),Str(TH.Border)},Parent=card})

    for _,opt in ipairs(opts) do
        local ob=Inst("TextButton",{Size=UDim2.new(1,0,0,IH),BackgroundColor3=TH.BG2,
            BorderSizePixel=0,Text="",ZIndex=22,Parent=oFrame})
        Inst("TextLabel",{Size=UDim2.new(1,-14,1,0),Position=UDim2.new(0,14,0,0),
            BackgroundTransparency=1,Text=opt,TextColor3=TH.T2,TextSize=12,Font=FS,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=23},ob)
        ob.MouseEnter:Connect(function() TW(ob,0.09,{BackgroundColor3=TH.TabPill}) end)
        ob.MouseLeave:Connect(function() TW(ob,0.09,{BackgroundColor3=TH.BG2}) end)
        ob.MouseButton1Click:Connect(function()
            sel=opt; sLbl.Text=opt; open=false
            TW(card,0.2,{Size=UDim2.new(1,0,0,CH)},Enum.EasingStyle.Quint)
            TW(wrap,0.2,{Size=UDim2.new(1,0,0,CH)},Enum.EasingStyle.Quint)
            TW(arrow,0.18,{Rotation=0})
            if cb then pcall(cb,opt) end
        end)
    end

    local hb=Inst("TextButton",{Size=UDim2.new(1,0,0,CH),BackgroundTransparency=1,Text="",ZIndex=23,Parent=hdr})
    hb.MouseButton1Click:Connect(function()
        open=not open
        local th=open and (CH+#opts*IH) or CH
        TW(card,0.22,{Size=UDim2.new(1,0,0,th)},Enum.EasingStyle.Quint)
        TW(wrap,0.22,{Size=UDim2.new(1,0,0,th)},Enum.EasingStyle.Quint)
        TW(arrow,0.2,{Rotation=open and 180 or 0})
    end)
    hb.MouseEnter:Connect(function() TW(card,0.12,{BackgroundColor3=TH.CardHov}) end)
    hb.MouseLeave:Connect(function() TW(card,0.12,{BackgroundColor3=TH.Card}) end)

    self:_Add(wrap)
    return {Get=function() return sel end, Set=function(v) sel=v; sLbl.Text=v end}
end

-- ─── Textbox ────────────────────────────────────
function Section:Textbox(label, hint, cb)
    local card=Inst("Frame",{Size=UDim2.new(1,0,0,62),BackgroundColor3=TH.Card,BorderSizePixel=0,Ch={Cor(C4),Str(TH.Border)}})
    Pad(14,14,9,9).Parent=card

    Inst("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=label,
        TextColor3=TH.T1,TextSize=12,Font=FS,TextXAlignment=Enum.TextXAlignment.Left},card)

    local boxWrap=Inst("Frame",{Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,1,-26),
        BackgroundColor3=TH.BG,BorderSizePixel=0,Ch={Cor(C4)},Parent=card})
    local bstr=Str(TH.Border); bstr.Parent=boxWrap

    local box=Inst("TextBox",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,PlaceholderText=hint or "Type here...",PlaceholderColor3=TH.T3,
        Text="",TextColor3=TH.T1,TextSize=12,Font=FR,ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Left},boxWrap)

    box.Focused:Connect(function()   TW(bstr,0.15,{Color=TH.Acc}) end)
    box.FocusLost:Connect(function(e)
        TW(bstr,0.15,{Color=TH.Border})
        if cb then pcall(cb,box.Text,e) end
    end)

    self:_Add(card)
    return box
end

-- ─── Keybind ────────────────────────────────────
function Section:Keybind(label, default, cb)
    local key    = default or Enum.KeyCode.Unknown
    local listen = false

    local card=Inst("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=TH.Card,BorderSizePixel=0,Ch={Cor(C4),Str(TH.Border)}})
    Inst("TextLabel",{Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,Text=label,TextColor3=TH.T1,TextSize=13,Font=FS,
        TextXAlignment=Enum.TextXAlignment.Left},card)

    local badge=Inst("TextButton",{Size=UDim2.new(0,72,0,26),Position=UDim2.new(1,-84,0.5,-13),
        BackgroundColor3=TH.BG3,BorderSizePixel=0,Text=key.Name,TextColor3=TH.Acc,
        TextSize=11,Font=FB,Ch={Cor(C4),Str(TH.AccDim)}},card)

    badge.MouseButton1Click:Connect(function()
        if listen then return end
        listen=true
        badge.Text="..."
        TW(badge,0.1,{BackgroundColor3=TH.AccDim})
    end)

    UIS.InputBegan:Connect(function(i, gpe)
        if not listen or gpe then return end
        if i.UserInputType==Enum.UserInputType.Keyboard then
            key=i.KeyCode
            badge.Text=key.Name
            TW(badge,0.12,{BackgroundColor3=TH.BG3})
            listen=false
            if cb then pcall(cb,key) end
        end
    end)

    -- Global keybind fire
    UIS.InputBegan:Connect(function(i, gpe)
        if gpe or listen then return end
        if i.UserInputType==Enum.UserInputType.Keyboard and i.KeyCode==key then
            if cb then pcall(cb,key) end
        end
    end)

    self:_Add(card)
    return {Get=function() return key end, Set=function(k) key=k; badge.Text=k.Name end}
end

-- ─── ColorPicker ────────────────────────────────
function Section:ColorPicker(label, default, cb)
    local col   = default or Color3.fromRGB(113,95,252)
    local open  = false
    local CH    = 44
    local PH    = 130

    local wrap=Inst("Frame",{Size=UDim2.new(1,0,0,CH),BackgroundTransparency=1,BorderSizePixel=0})
    local card=Inst("Frame",{Size=UDim2.new(1,0,0,CH),BackgroundColor3=TH.Card,BorderSizePixel=0,
        ClipsDescendants=true,ZIndex=20,Ch={Cor(C4),Str(TH.Border)},Parent=wrap})

    Inst("TextLabel",{Size=UDim2.new(1,-68,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,Text=label,TextColor3=TH.T1,TextSize=13,Font=FS,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=21},card)

    local preview=Inst("Frame",{Size=UDim2.new(0,28,0,20),Position=UDim2.new(1,-42,0.5,-10),
        BackgroundColor3=col,BorderSizePixel=0,ZIndex=21,Ch={Cor(C4),Str(TH.Border)}},card)

    -- Expanded picker (simple H/S square + brightness)
    local picker=Inst("Frame",{Size=UDim2.new(1,0,0,PH),Position=UDim2.new(0,0,0,CH),
        BackgroundColor3=TH.BG2,BorderSizePixel=0,ZIndex=21,Parent=card})
    Pad(12,12,10,10).Parent=picker

    -- H slider
    Inst("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text="Hue",
        TextColor3=TH.T2,TextSize=11,Font=FS,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=22},picker)

    local htrack=Inst("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,18),
        BorderSizePixel=0,ZIndex=22,Parent=picker})
    Cor(C20).Parent=htrack
    -- Rainbow gradient for hue
    local hgrad=Inst("UIGradient",{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromHSV(0,1,1)),
        ColorSequenceKeypoint.new(1/6, Color3.fromHSV(1/6,1,1)),
        ColorSequenceKeypoint.new(2/6, Color3.fromHSV(2/6,1,1)),
        ColorSequenceKeypoint.new(3/6, Color3.fromHSV(3/6,1,1)),
        ColorSequenceKeypoint.new(4/6, Color3.fromHSV(4/6,1,1)),
        ColorSequenceKeypoint.new(5/6, Color3.fromHSV(5/6,1,1)),
        ColorSequenceKeypoint.new(1,   Color3.fromHSV(0,1,1)),
    })},htrack)

    local h0,s0,v0 = col:ToHSV()
    local hKnob=Inst("Frame",{Size=UDim2.new(0,12,0,12),
        Position=UDim2.new(h0,-6,0.5,-6),BackgroundColor3=TH.White,
        BorderSizePixel=0,ZIndex=23,Ch={Cor(C20),Str(TH.Border)},Parent=htrack})

    -- S/V sliders
    Inst("TextLabel",{Size=UDim2.new(0.5,0,0,14),Position=UDim2.new(0,0,0,36),BackgroundTransparency=1,
        Text="Saturation",TextColor3=TH.T2,TextSize=11,Font=FS,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=22},picker)
    local strack=Inst("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,54),
        BackgroundColor3=TH.Track,BorderSizePixel=0,ZIndex=22,Ch={Cor(C20)},Parent=picker})
    local sFill=Inst("Frame",{Size=UDim2.new(s0,0,1,0),BackgroundColor3=TH.Acc,BorderSizePixel=0,Ch={Cor(C20)},Parent=strack})
    local sKnob=Inst("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(s0,-6,0.5,-6),
        BackgroundColor3=TH.White,BorderSizePixel=0,ZIndex=23,Ch={Cor(C20),Str(TH.Border)},Parent=strack})

    Inst("TextLabel",{Size=UDim2.new(0.5,0,0,14),Position=UDim2.new(0,0,0,72),BackgroundTransparency=1,
        Text="Brightness",TextColor3=TH.T2,TextSize=11,Font=FS,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=22},picker)
    local vtrack=Inst("Frame",{Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,90),
        BackgroundColor3=TH.Track,BorderSizePixel=0,ZIndex=22,Ch={Cor(C20)},Parent=picker})
    local vFill=Inst("Frame",{Size=UDim2.new(v0,0,1,0),BackgroundColor3=TH.White,BorderSizePixel=0,Ch={Cor(C20)},Parent=vtrack})
    local vKnob=Inst("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(v0,-6,0.5,-6),
        BackgroundColor3=TH.White,BorderSizePixel=0,ZIndex=23,Ch={Cor(C20),Str(TH.Border)},Parent=vtrack})

    local function rebuild()
        col=Color3.fromHSV(h0,s0,v0)
        preview.BackgroundColor3=col
        sFill.BackgroundColor3=Color3.fromHSV(h0,1,1)
        vFill.BackgroundColor3=Color3.fromHSV(h0,s0,1)
        if cb then pcall(cb,col) end
    end

    local function makeSlide(track, knob, fill, getter, setter)
        local sliding=false
        local hb=Inst("TextButton",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0.5,-10),
            BackgroundTransparency=1,Text="",ZIndex=25,Parent=track})
        local function setFromX(x)
            local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            setter(p)
            if fill then fill.Size=UDim2.new(p,0,1,0) end
            knob.Position=UDim2.new(p,-6,0.5,-6)
            rebuild()
        end
        hb.MouseButton1Down:Connect(function(x) sliding=true; setFromX(x) end)
        UIS.InputChanged:Connect(function(i)
            if sliding and i.UserInputType==Enum.UserInputType.MouseMovement then setFromX(i.Position.X) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end
        end)
    end

    makeSlide(htrack,hKnob,nil,function() return h0 end,function(p) h0=p end)
    makeSlide(strack,sKnob,sFill,function() return s0 end,function(p) s0=p end)
    makeSlide(vtrack,vKnob,vFill,function() return v0 end,function(p) v0=p end)

    local hb2=Inst("TextButton",{Size=UDim2.new(1,0,0,CH),BackgroundTransparency=1,Text="",ZIndex=23,Parent=card})
    hb2.MouseButton1Click:Connect(function()
        open=not open
        local th=open and (CH+PH) or CH
        TW(card,0.22,{Size=UDim2.new(1,0,0,th)},Enum.EasingStyle.Quint)
        TW(wrap,0.22,{Size=UDim2.new(1,0,0,th)},Enum.EasingStyle.Quint)
    end)
    hb2.MouseEnter:Connect(function() TW(card,0.12,{BackgroundColor3=TH.CardHov}) end)
    hb2.MouseLeave:Connect(function() TW(card,0.12,{BackgroundColor3=TH.Card}) end)

    self:_Add(wrap)
    return {Get=function() return col end, Set=function(c) col=c; preview.BackgroundColor3=c; h0,s0,v0=c:ToHSV() end}
end

-- ─── Label ──────────────────────────────────────
function Section:Label(text)
    local l=Inst("TextLabel",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=text,
        TextColor3=TH.T2,TextSize=12,Font=FR,TextXAlignment=Enum.TextXAlignment.Left,
        Ch={Pad(4,0,0,0)}})
    self:_Add(l)
    return l
end

-- ─── Separator ──────────────────────────────────
function Section:Separator(title)
    if title and title ~= "" then
        local row=Inst("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1})
        Inst("Frame",{Size=UDim2.new(0.3,0,0,1),Position=UDim2.new(0,0,0.5,-0.5),
            BackgroundColor3=TH.Border,BorderSizePixel=0},row)
        Inst("TextLabel",{Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.3,0,0,0),
            BackgroundTransparency=1,Text=title,TextColor3=TH.T3,TextSize=11,Font=FS,
            TextXAlignment=Enum.TextXAlignment.Center},row)
        Inst("Frame",{Size=UDim2.new(0.3,0,0,1),Position=UDim2.new(0.7,0,0.5,-0.5),
            BackgroundColor3=TH.Border,BorderSizePixel=0},row)
        self:_Add(row)
    else
        local sep=Inst("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=TH.Border,BorderSizePixel=0})
        self:_Add(sep)
    end
end

-- ═══════════════════════════════════════════════
--  Window
-- ═══════════════════════════════════════════════
local Window = {}
Window.__index = Window

function Window:Tab(name, iconId)
    -- Sidebar button
    local btn=Inst("TextButton",{Size=UDim2.new(1,-10,0,36),BackgroundTransparency=1,
        BorderSizePixel=0,Text="",ZIndex=3,Parent=self._sl,Ch={Cor(C4)}})
    local pill=Inst("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=TH.TabPill,
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=2,Ch={Cor(C4)},Parent=btn})
    local bar=Inst("Frame",{Size=UDim2.new(0,3,0.5,0),Position=UDim2.new(0,0,0.25,0),
        BackgroundColor3=TH.Acc,BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4,
        Ch={Cor(UDim.new(0,2))},Parent=btn})

    local xoff = iconId and 36 or 12
    local icon
    if iconId then
        icon=Inst("ImageLabel",{Size=UDim2.new(0,15,0,15),Position=UDim2.new(0,12,0.5,-7),
            BackgroundTransparency=1,Image=iconId,ImageColor3=TH.TabIdl,ZIndex=4},btn)
    end
    local tlbl=Inst("TextLabel",{Size=UDim2.new(1,-xoff-4,1,0),Position=UDim2.new(0,xoff,0,0),
        BackgroundTransparency=1,Text=name,TextColor3=TH.TabIdl,TextSize=13,Font=FS,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},btn)

    -- Content scroll
    local sc=Inst("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=TH.Acc,
        CanvasSize=UDim2.new(0,0,0,0),Visible=false,ZIndex=1,Parent=self._ca})
    Pad(10,10,10,10).Parent=sc
    local lay=LL(Enum.FillDirection.Vertical,7); lay.Parent=sc
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sc.CanvasSize=UDim2.new(0,0,0,lay.AbsoluteContentSize.Y+20)
    end)

    local sec=setmetatable({_sc=sc},Section)
    local idx=#self._tabs+1
    self._tabs[idx]={btn=btn,pill=pill,bar=bar,lbl=tlbl,icon=icon,sc=sc}

    btn.MouseButton1Click:Connect(function() self:_Select(idx) end)
    btn.MouseEnter:Connect(function()
        if self._ai~=idx then
            TW(pill,0.12,{BackgroundTransparency=0.88})
            TW(tlbl,0.12,{TextColor3=TH.T2})
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._ai~=idx then
            TW(pill,0.12,{BackgroundTransparency=1})
            TW(tlbl,0.12,{TextColor3=TH.TabIdl})
        end
    end)

    if idx==1 then self:_Select(1) end
    return sec
end

function Window:_Select(idx)
    self._ai=idx
    for i,t in ipairs(self._tabs) do
        local a=(i==idx)
        t.sc.Visible=a
        if a then
            TW(t.pill,0.18,{BackgroundTransparency=0})
            TW(t.bar,0.18,{BackgroundTransparency=0})
            TW(t.lbl,0.18,{TextColor3=TH.TabAct})
            if t.icon then TW(t.icon,0.18,{ImageColor3=TH.Acc}) end
        else
            TW(t.pill,0.18,{BackgroundTransparency=1})
            TW(t.bar,0.18,{BackgroundTransparency=1})
            TW(t.lbl,0.18,{TextColor3=TH.TabIdl})
            if t.icon then TW(t.icon,0.18,{ImageColor3=TH.TabIdl}) end
        end
    end
end

function Window:Notify(title, msg, dur)
    dur = dur or 3
    local nroot = self._sg

    local ncard = Inst("Frame",{Size=UDim2.new(0,240,0,0),
        Position=UDim2.new(1,-250,1,-20),AnchorPoint=Vector2.new(0,1),
        BackgroundColor3=TH.BG3,BorderSizePixel=0,ClipsDescendants=true,
        ZIndex=100,Ch={Cor(C6),Str(TH.Border)}},nroot)

    -- accent line top
    Inst("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=TH.Acc,BorderSizePixel=0,ZIndex=101},ncard)

    local inner=Inst("Frame",{Size=UDim2.new(1,0,1,0),Position=UDim2.new(0,0,0,2),
        BackgroundTransparency=1,ZIndex=101},ncard)
    Pad(12,12,8,8).Parent=inner

    Inst("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text=title,
        TextColor3=TH.T1,TextSize=13,Font=FB,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=102},inner)
    Inst("TextLabel",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,20),
        AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,Text=msg,
        TextColor3=TH.T2,TextSize=12,Font=FR,TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,ZIndex=102},inner)

    -- progress bar
    local prog=Inst("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=TH.AccDim,BorderSizePixel=0,ZIndex=102},ncard)
    local progFill=Inst("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=TH.Acc,
        BorderSizePixel=0,ZIndex=103},prog)

    TW(ncard,0.25,{Size=UDim2.new(0,240,0,70)},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
    TW(progFill,dur,{Size=UDim2.new(0,0,1,0)},Enum.EasingStyle.Linear)

    task.delay(dur, function()
        TW(ncard,0.2,{Size=UDim2.new(0,240,0,0),Position=UDim2.new(1,-250,1,-10)},Enum.EasingStyle.Quint)
        task.delay(0.22, function() ncard:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════
--  Library entry
-- ═══════════════════════════════════════════════
local Calm = {}
Calm.__index = Calm

function Calm:Win(title, subtitle)
    pcall(function()
        if CG:FindFirstChild("CalmLib_v3") then CG.CalmLib_v3:Destroy() end
    end)

    local sg=Inst("ScreenGui",{Name="CalmLib_v3",ResetOnSpawn=false,
        IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CG})

    local win=Inst("Frame",{Size=UDim2.new(0,WW,0,WH),
        Position=UDim2.new(0.5,-WW/2,0.5,-WH/2),BackgroundColor3=TH.BG,
        BorderSizePixel=0,ClipsDescendants=true,
        Ch={Cor(C10),Str(TH.Border,1)}},sg)

    -- Open animation
    win.Size=UDim2.new(0,WW,0,0)
    win.BackgroundTransparency=0.5
    TW(win,0.4,{Size=UDim2.new(0,WW,0,WH),BackgroundTransparency=0},Enum.EasingStyle.Back,Enum.EasingDirection.Out)

    -- ── Titlebar ───────────────────────────────
    local tb=Inst("Frame",{Size=UDim2.new(1,0,0,TH_),BackgroundColor3=TH.Side,BorderSizePixel=0,ZIndex=5},win)
    -- patch corners
    Inst("Frame",{Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),
        BackgroundColor3=TH.Side,BorderSizePixel=0,ZIndex=5},tb)
    -- bottom line
    Inst("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=TH.Border,BorderSizePixel=0,ZIndex=6},tb)

    -- Logo pill
    local logoPill=Inst("Frame",{Size=UDim2.new(0,6,0,22),Position=UDim2.new(0,14,0.5,-11),
        BackgroundColor3=TH.Acc,BorderSizePixel=0,ZIndex=6,Ch={Cor(UDim.new(0,3))}},tb)

    local titleLbl=Inst("TextLabel",{Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,26,0,0),
        BackgroundTransparency=1,Text=title or "CalmLib",TextColor3=TH.T1,TextSize=14,Font=FB,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},tb)

    if subtitle and subtitle~="" then
        Inst("TextLabel",{Size=UDim2.new(0,200,1,0),Position=UDim2.new(0,26+titleLbl.TextBounds.X+8,0,0),
            BackgroundTransparency=1,Text="/ "..subtitle,TextColor3=TH.T3,TextSize=13,Font=FR,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},tb)
    end

    -- Controls (macOS dots)
    local function mkCtrl(ox, col, sym, action)
        local b=Inst("TextButton",{Size=UDim2.new(0,13,0,13),
            Position=UDim2.new(1,ox,0.5,-6),BackgroundColor3=col,BorderSizePixel=0,
            Text="",ZIndex=7,Ch={Cor(C20)}},tb)
        local sl=Inst("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            Text=sym,TextColor3=Color3.new(0,0,0),TextTransparency=1,TextSize=9,Font=FB,ZIndex=8},b)
        b.MouseEnter:Connect(function()
            TW(sl,0.1,{TextTransparency=0})
            TW(b,0.1,{BackgroundColor3=col:Lerp(TH.White,0.25)})
        end)
        b.MouseLeave:Connect(function()
            TW(sl,0.1,{TextTransparency=1})
            TW(b,0.1,{BackgroundColor3=col})
        end)
        b.MouseButton1Click:Connect(action)
    end

    -- Close
    mkCtrl(-30, TH.Red, "✕", function()
        TW(win,0.22,{Size=UDim2.new(0,WW,0,0),BackgroundTransparency=0.6},Enum.EasingStyle.Quint)
        task.delay(0.25, function() sg:Destroy() end)
    end)
    -- Minimise
    local mini=false
    mkCtrl(-48, TH.Yellow, "−", function()
        mini=not mini
        TW(win,0.25,{Size=mini and UDim2.new(0,WW,0,TH_) or UDim2.new(0,WW,0,WH)},Enum.EasingStyle.Quint)
    end)
    -- Resize hint
    mkCtrl(-66, TH.Green, "+", function() end)

    Drag(win, tb)

    -- ── Sidebar ───────────────────────────────
    local side=Inst("Frame",{Size=UDim2.new(0,SW,1,-TH_),Position=UDim2.new(0,0,0,TH_),
        BackgroundColor3=TH.Side,BorderSizePixel=0,ZIndex=2},win)
    Inst("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=TH.SideBorder,BorderSizePixel=0},side)

    -- Sidebar header
    Inst("TextLabel",{Size=UDim2.new(1,-10,0,22),Position=UDim2.new(0,5,0,8),
        BackgroundTransparency=1,Text="NAVIGATION",TextColor3=TH.T3,TextSize=10,Font=FB,
        TextXAlignment=Enum.TextXAlignment.Left},side)

    local sl=Inst("Frame",{Size=UDim2.new(1,0,1,-38),Position=UDim2.new(0,0,0,32),
        BackgroundTransparency=1,ZIndex=3,Ch={LL(Enum.FillDirection.Vertical,3),Pad(5,5,4,4)}},side)

    -- Sidebar footer (version)
    Inst("TextLabel",{Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,1,-22),
        BackgroundTransparency=1,Text="CalmLib v3.0",TextColor3=TH.T3,TextSize=10,Font=FR,
        TextXAlignment=Enum.TextXAlignment.Center},side)

    -- ── Content ───────────────────────────────
    local ca=Inst("Frame",{Size=UDim2.new(1,-SW,1,-TH_),Position=UDim2.new(0,SW,0,TH_),
        BackgroundColor3=TH.BG,BorderSizePixel=0,ClipsDescendants=true,ZIndex=1},win)

    local w=setmetatable({_sg=sg,_win=win,_sl=sl,_ca=ca,_tabs={},_ai=nil},Window)
    return w
end

return Calm
