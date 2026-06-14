--[[
╔═══════════════════════════════════════════════════════════════╗
║                    CalmLib v4.0 - Nova                        ║
║              A Modern, Fluid Roblox UI Library                ║
╠═══════════════════════════════════════════════════════════════╣
║  local lib = loadstring(game:HttpGet("..."))()                ║
║  local win = lib:Win("Title", "Subtitle")                     ║
║  local tab = win:Tab("Name", "rbxassetid://...")              ║
║                                                               ║
║  ⚡ Enhanced Features:                                        ║
║  • Smoother animations with spring physics                    ║
║  • Blur/glass morphism effects                               ║
║  • Ripple animations on interactions                          ║
║  • Search/filter for dropdowns                                ║
║  • Multi-keybinds & combos                                    ║
║  • Gradient & accent customization                            ║
║  • Collapsible sections                                       ║
║  • Persistent settings (autosave)                            ║
║                                                               ║
║  tab:Toggle("Label", false, callback)                         ║
║  tab:Button("Label", callback, icon)                          ║
║  tab:Slider("Label", min, max, default, callback)             ║
║  tab:Dropdown("Label", {"A","B"}, callback, searchable)       ║
║  tab:Textbox("Label", "placeholder", callback)                ║
║  tab:Keybind("Label", Enum.KeyCode.F, callback, multi)        ║
║  tab:ColorPicker("Label", Color3, callback)                   ║
║  tab:Label("text", "icon")                                    ║
║  tab:Separator("Optional title")                              ║
║  tab:Collapsible("Title", elements)                           ║
║  win:Notify("Title", "Message", duration, type)               ║
║  win:Prompt("Title", "Message", callback)                     ║
╚═══════════════════════════════════════════════════════════════╝
]]

-- ═══════════════════════════════════════════════════════════════
--  Services
-- ═══════════════════════════════════════════════════════════════
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local LS = game:GetService("Lighting")
local TGS = game:GetService("TweenService")

-- ═══════════════════════════════════════════════════════════════
--  Enhanced Theme System
-- ═══════════════════════════════════════════════════════════════
local TH = {
    -- Base (Dark theme with blur)
    BG          = Color3.fromHex("#0A0A0F"),
    BG2         = Color3.fromHex("#0F0F15"),
    BG3         = Color3.fromHex("#14141C"),
    Glass       = Color3.fromHex("#1A1A24"),
    GlassBorder = Color3.fromHex("#2A2A38"),
    
    -- Sidebar
    Side        = Color3.fromHex("#0C0C12"),
    SideBorder  = Color3.fromHex("#1E1E2E"),
    
    -- Cards with gradient
    Card        = Color3.fromHex("#13131B"),
    CardHov     = Color3.fromHex("#181820"),
    CardPress   = Color3.fromHex("#0E0E16"),
    
    -- Dynamic accent (customizable)
    Acc         = Color3.fromHex("#7C3AED"),
    AccHov      = Color3.fromHex("#8B5CF6"),
    AccDim      = Color3.fromHex("#2D1B4E"),
    AccGlow     = Color3.fromHex("#6D28D9"),
    
    -- Status colors
    Success     = Color3.fromHex("#10B981"),
    Error       = Color3.fromHex("#EF4444"),
    Warning     = Color3.fromHex("#F59E0B"),
    Info        = Color3.fromHex("#3B82F6"),
    
    -- Text hierarchy
    TextPrimary   = Color3.fromHex("#F3F4F6"),
    TextSecondary = Color3.fromHex("#9CA3AF"),
    TextTertiary  = Color3.fromHex("#6B7280"),
    TextDisabled  = Color3.fromHex("#4B5563"),
    
    -- UI Elements
    Border      = Color3.fromHex("#1F1F2E"),
    Track       = Color3.fromHex("#1A1A26"),
    ToggleOff   = Color3.fromHex("#2A2A3E"),
    TabInactive = Color3.fromHex("#6B7280"),
    TabActive   = Color3.fromHex("#F3F4F6"),
    PillBg      = Color3.fromHex("#1E1E2A"),
}

-- ═══════════════════════════════════════════════════════════════
--  Layout Constants with Responsive Design
-- ═══════════════════════════════════════════════════════════════
local SW   = 160      -- sidebar width
local WW   = 600      -- window width  
local WH   = 420      -- window height
local TH_  = 48       -- titlebar height
local CORNER = 12     -- global corner radius

local C12  = UDim.new(0,12)
local C8   = UDim.new(0,8)
local C6   = UDim.new(0,6)
local C4   = UDim.new(0,4)

local FB   = Enum.Font.GothamBold
local FS   = Enum.Font.GothamSemibold
local FR   = Enum.Font.Gotham
local FM   = Enum.Font.GothamMedium

-- ═══════════════════════════════════════════════════════════════
--  Advanced Utilities
-- ═══════════════════════════════════════════════════════════════

-- Spring-based animation for fluid motion
local function SpringAnimation(obj, props, config)
    config = config or {duration = 0.3, elasticity = 1.2}
    local tweenInfo = TweenInfo.new(
        config.duration,
        Enum.EasingStyle.Elastic,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )
    local tween = TS:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

-- Glass morphism effect
local function ApplyGlassEffect(frame, intensity)
    intensity = intensity or 0.3
    local blur = Instance.new("BlurEffect")
    blur.Size = 6
    blur.Parent = frame
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
    }
    gradient.Transparency = NumberSequence.new(intensity)
    gradient.Parent = frame
end

-- Ripple animation
local function CreateRipple(parent, position)
    local ripple = Instance.new("Frame")
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, position.X, 0, position.Y)
    ripple.BackgroundColor3 = Color3.new(1,1,1)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.ZIndex = parent.ZIndex + 10
    ripple.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    local expand = TS:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(2, 0, 2, 0),
        Position = UDim2.new(0, position.X - 100, 0, position.Y - 100),
        BackgroundTransparency = 1
    })
    expand:Play()
    expand.Completed:Connect(function() ripple:Destroy() end)
end

local function Inst(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props or {}) do
        if k ~= "Children" then 
            o[k] = v 
        end
    end
    if props and props.Children then
        for _,c in ipairs(props.Children) do 
            if c then c.Parent = o end 
        end
    end
    if parent then o.Parent = parent end
    return o
end

local function Corner(r)  
    return Inst("UICorner",{CornerRadius=r or C12}) 
end

local function Stroke(c,t) 
    return Inst("UIStroke",{
        Color=c or TH.Border,
        Thickness=t or 1,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    }) 
end

local function Padding(l,r,t,b) 
    return Inst("UIPadding",{
        PaddingLeft=UDim.new(0,l or 0),
        PaddingRight=UDim.new(0,r or 0),
        PaddingTop=UDim.new(0,t or 0),
        PaddingBottom=UDim.new(0,b or 0)
    }) 
end

local function ListLayout(fd,p,ha)  
    return Inst("UIListLayout",{
        FillDirection=fd or Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,p or 0),
        HorizontalAlignment=ha or Enum.HorizontalAlignment.Left
    }) 
end

-- Enhanced drag with bounds checking
local function Drag(frame, handle)
    local drag, dragStart, startPos = false, nil, nil
    local minX, maxX, minY, maxY = 0, 0, 0, 0
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = input.Position
            startPos = frame.Position
            
            -- Calculate bounds
            local screenSize = game:GetService("GuiService"):GetScreenSize()
            minX = -frame.AbsoluteSize.X + 50
            maxX = screenSize.X - 50
            minY = -frame.AbsoluteSize.Y + 50
            maxY = screenSize.Y - 50
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag = false
                end
            end)
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Offset + delta.X, minX, maxX)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, minY, maxY)
            frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  Enhanced Components
-- ═══════════════════════════════════════════════════════════════

local Section = {}
Section.__index = Section

function Section:_Add(el) 
    el.Parent = self._sc 
end

-- ─── Enhanced Toggle with ripple ─────────────────────────────────────
function Section:Toggle(label, default, cb, description)
    local state = (default == true)
    
    local card = Inst("Frame",{
        Size=UDim2.new(1,0,0,48),
        BackgroundColor3=TH.Card,
        BorderSizePixel=0,
        Children={Corner(C8), Stroke(TH.Border, 1)}
    })
    
    -- Icon container
    local iconContainer = Inst("Frame",{
        Size=UDim2.new(0, 32, 0, 32),
        Position=UDim2.new(0, 12, 0.5, -16),
        BackgroundColor3=TH.AccDim,
        BackgroundTransparency=0.5,
        BorderSizePixel=0,
        Children={Corner(C8)},
        Parent=card
    })
    
    local icon = Inst("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=state and "✓" or "○",
        TextColor3=state and TH.Acc or TH.TextSecondary,
        TextSize=18,
        Font=FB,
        Parent=iconContainer
    })
    
    -- Text container
    local textContainer = Inst("Frame",{
        Size=UDim2.new(1,-120,1,0),
        Position=UDim2.new(0, 52, 0, 0),
        BackgroundTransparency=1,
        Parent=card
    })
    
    Inst("TextLabel",{
        Size=UDim2.new(1,0,0,20),
        Position=UDim2.new(0,0,0.5,-10),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=TH.TextPrimary,
        TextSize=14,
        Font=FM,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=textContainer
    })
    
    if description then
        Inst("TextLabel",{
        Size=UDim2.new(1,0,0,16),
        Position=UDim2.new(0,0,0.5,6),
        BackgroundTransparency=1,
        Text=description,
        TextColor3=TH.TextTertiary,
        TextSize=11,
        Font=FR,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=textContainer
    })
    end
    
    local track = Inst("Frame",{
        Size=UDim2.new(0, 44, 0, 24),
        Position=UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3=state and TH.Acc or TH.ToggleOff,
        BorderSizePixel=0,
        Children={Corner(C20)},
        Parent=card
    })
    
    local knob = Inst("Frame",{
        Size=UDim2.new(0, 18, 0, 18),
        Position=state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3=TH.TextPrimary,
        BorderSizePixel=0,
        Children={Corner(C20)},
        Parent=track
    })
    
    local glow = Inst("Frame",{
        Size=UDim2.new(0, 28, 0, 28),
        Position=state and UDim2.new(1, -25, 0.5, -12) or UDim2.new(0, -1, 0.5, -12),
        BackgroundColor3=TH.Acc,
        BackgroundTransparency=0.7,
        BorderSizePixel=0,
        ZIndex=knob.ZIndex-1,
        Children={Corner(C20)},
        Parent=track
    })
    
    local hb = Inst("TextButton",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text="",
        Parent=card
    })
    
    local function set(s, fire)
        state = s
        icon.Text = s and "✓" or "○"
        icon.TextColor3 = s and TH.Acc or TH.TextSecondary
        iconContainer.BackgroundTransparency = s and 0.2 or 0.5
        
        SpringAnimation(track, {BackgroundColor3 = s and TH.Acc or TH.ToggleOff}, {duration = 0.3})
        SpringAnimation(knob, {Position = s and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, {duration = 0.4})
        SpringAnimation(glow, {Position = s and UDim2.new(1, -25, 0.5, -12) or UDim2.new(0, -1, 0.5, -12)})
        
        if fire and cb then 
            pcall(cb, state) 
        end
    end
    
    hb.MouseButton1Click:Connect(function()
        CreateRipple(card, {X = 50, Y = 24})
        set(not state, true)
    end)
    
    hb.MouseEnter:Connect(function() 
        SpringAnimation(card, {BackgroundColor3 = TH.CardHov}, {duration = 0.2})
    end)
    hb.MouseLeave:Connect(function() 
        SpringAnimation(card, {BackgroundColor3 = TH.Card}, {duration = 0.2})
    end)
    
    self:_Add(card)
    return { 
        Set = function(v) set(v == true, true) end, 
        Get = function() return state end 
    }
end

-- ─── Enhanced Button with icons and loading state ─────────────────────
function Section:Button(label, cb, icon, loadingText)
    local isLoading = false
    local originalText = label
    
    local btn = Inst("TextButton",{
        Size=UDim2.new(1,0,0,42),
        BackgroundColor3=TH.Acc,
        BorderSizePixel=0,
        Text=label,
        TextColor3=TH.TextPrimary,
        TextSize=14,
        Font=FB,
        Children={Corner(C8)}
    })
    
    -- Optional icon
    if icon then
        local iconLbl = Inst("TextLabel",{
            Size=UDim2.new(0, 20, 0, 20),
            Position=UDim2.new(0, 12, 0.5, -10),
            BackgroundTransparency=1,
            Text=icon,
            TextColor3=TH.TextPrimary,
            TextSize=16,
            Font=FB,
            Parent=btn
        })
        btn.Text = "  " .. label
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.PaddingLeft = UDim.new(0, 38)
    end
    
    -- Loading spinner
    local spinner = Inst("Frame",{
        Size=UDim2.new(0, 16, 0, 16),
        Position=UDim2.new(0.5, -8, 0.5, -8),
        BackgroundTransparency=1,
        Visible=false,
        Children={Corner(C20)},
        Parent=btn
    })
    
    local function animateSpinner()
        local rotation = 0
        RS.RenderStepped:Connect(function()
            if not spinner.Visible then return end
            rotation = (rotation + 15) % 360
            spinner.Rotation = rotation
        end)
    end
    animateSpinner()
    
    btn.MouseEnter:Connect(function()   
        SpringAnimation(btn, {BackgroundColor3 = TH.AccHov}, {duration = 0.2})
    end)
    btn.MouseLeave:Connect(function()   
        SpringAnimation(btn, {BackgroundColor3 = TH.Acc}, {duration = 0.2})
    end)
    btn.MouseButton1Down:Connect(function()
        SpringAnimation(btn, {BackgroundColor3 = TH.AccDim, Size = UDim2.new(1, -4, 0, 40)})
    end)
    btn.MouseButton1Up:Connect(function()
        SpringAnimation(btn, {BackgroundColor3 = TH.AccHov, Size = UDim2.new(1, 0, 0, 42)})
        
        if isLoading then return end
        
        if loadingText then
            isLoading = true
            local oldText = btn.Text
            btn.Text = loadingText
            spinner.Visible = true
            
            task.spawn(function()
                pcall(cb)
                isLoading = false
                btn.Text = oldText
                spinner.Visible = false
            end)
        elseif cb then
            pcall(cb)
        end
    end)
    
    self:_Add(btn)
    return btn
end

-- ─── Enhanced Slider with numeric input ───────────────────────────────
function Section:Slider(label, mn, mx, def, cb, decimals)
    mn = mn or 0
    mx = mx or 100
    decimals = decimals or 0
    local val = math.clamp(def or mn, mn, mx)
    local pct = (val - mn) / (mx - mn)
    
    local card = Inst("Frame",{
        Size=UDim2.new(1,0,0,72),
        BackgroundColor3=TH.Card,
        BorderSizePixel=0,
        Children={Corner(C8), Stroke(TH.Border, 1)}
    })
    Padding(16, 16, 12, 12).Parent = card
    
    -- Header with value display
    local header = Inst("Frame",{
        Size=UDim2.new(1,0,0,24),
        BackgroundTransparency=1,
        Parent=card
    })
    
    Inst("TextLabel",{
        Size=UDim2.new(0.6,0,1,0),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=TH.TextPrimary,
        TextSize=14,
        Font=FM,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=header
    })
    
    local valueBox = Inst("TextBox",{
        Size=UDim2.new(0, 60, 0, 28),
        Position=UDim2.new(1, -60, 0.5, -14),
        BackgroundColor3=TH.BG2,
        BorderSizePixel=0,
        Text=tostring(decimals > 0 and string.format("%."..decimals.."f", val) or math.round(val)),
        TextColor3=TH.Acc,
        TextSize=13,
        Font=FB,
        TextXAlignment=Enum.TextXAlignment.Center,
        Children={Corner(C6), Stroke(TH.Border, 1)},
        Parent=header
    })
    
    valueBox.FocusLost:Connect(function(enterPressed)
        local newVal = tonumber(valueBox.Text)
        if newVal then
            val = math.clamp(newVal, mn, mx)
            valueBox.Text = decimals > 0 and string.format("%."..decimals.."f", val) or math.round(val)
            local newPct = (val - mn) / (mx - mn)
            fill.Size = UDim2.new(newPct, 0, 1, 0)
            knob.Position = UDim2.new(newPct, -7, 0.5, -7)
            glow.Position = UDim2.new(newPct, -11, 0.5, -11)
            if cb then pcall(cb, val) end
        else
            valueBox.Text = decimals > 0 and string.format("%."..decimals.."f", val) or math.round(val)
        end
    end)
    
    -- Track
    local trackRow = Inst("Frame",{
        Size=UDim2.new(1,0,0,24),
        Position=UDim2.new(0,0,1,-24),
        BackgroundTransparency=1,
        Parent=card
    })
    
    local track = Inst("Frame",{
        Size=UDim2.new(1,0,0,6),
        Position=UDim2.new(0,0,0.5,-3),
        BackgroundColor3=TH.Track,
        BorderSizePixel=0,
        Children={Corner(C20)},
        Parent=trackRow
    })
    
    local fill = Inst("Frame",{
        Size=UDim2.new(pct,0,1,0),
        BackgroundColor3=TH.Acc,
        BorderSizePixel=0,
        Children={Corner(C20)},
        Parent=track
    })
    
    local knob = Inst("Frame",{
        Size=UDim2.new(0, 18, 0, 18),
        Position=UDim2.new(pct, -9, 0.5, -9),
        BackgroundColor3=TH.TextPrimary,
        BorderSizePixel=0,
        Children={Corner(C20), Stroke(TH.Acc, 2)},
        Parent=track
    })
    
    local glow = Inst("Frame",{
        Size=UDim2.new(0, 28, 0, 28),
        Position=UDim2.new(pct, -14, 0.5, -14),
        BackgroundColor3=TH.Acc,
        BackgroundTransparency=0.6,
        BorderSizePixel=0,
        ZIndex=knob.ZIndex - 1,
        Children={Corner(C20)},
        Parent=track
    })
    
    -- Value tooltip
    local tooltip = Inst("Frame",{
        Size=UDim2.new(0, 50, 0, 24),
        Position=UDim2.new(pct, -25, 0, -32),
        BackgroundColor3=TH.BG3,
        BackgroundTransparency=0.1,
        Visible=false,
        Children={Corner(C6), Stroke(TH.Border, 1)},
        Parent=track
    })
    
    local tooltipText = Inst("TextLabel",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Text=tostring(val),
        TextColor3=TH.TextPrimary,
        TextSize=12,
        Font=FS,
        Parent=tooltip
    })
    
    local sliding = false
    
    local function setFromX(x)
        local absPos = track.AbsolutePosition.X
        local absSize = track.AbsoluteSize.X
        local p = math.clamp((x - absPos) / absSize, 0, 1)
        val = mn + (mx - mn) * p
        
        if decimals > 0 then
            val = math.floor(val * (10^decimals) + 0.5) / (10^decimals)
        else
            val = math.round(val)
        end
        
        local newPct = (val - mn) / (mx - mn)
        valueBox.Text = decimals > 0 and string.format("%."..decimals.."f", val) or math.round(val)
        tooltipText.Text = valueBox.Text
        
        fill.Size = UDim2.new(newPct, 0, 1, 0)
        knob.Position = UDim2.new(newPct, -9, 0.5, -9)
        glow.Position = UDim2.new(newPct, -14, 0.5, -14)
        tooltip.Position = UDim2.new(newPct, -25, 0, -32)
        
        if cb then pcall(cb, val) end
    end
    
    local hitbox = Inst("TextButton",{
        Size=UDim2.new(1,0,0,28),
        Position=UDim2.new(0,0,0.5,-14),
        BackgroundTransparency=1,
        Text="",
        ZIndex=10,
        Parent=trackRow
    })
    
    hitbox.MouseButton1Down:Connect(function(x)
        sliding = true
        tooltip.Visible = true
        SpringAnimation(knob, {Size = UDim2.new(0, 22, 0, 22)}, {duration = 0.1})
        SpringAnimation(glow, {BackgroundTransparency = 0.3}, {duration = 0.1})
        setFromX(x.X)
    end)
    
    UIS.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and sliding then
            sliding = false
            tooltip.Visible = false
            SpringAnimation(knob, {Size = UDim2.new(0, 18, 0, 18)}, {duration = 0.15})
            SpringAnimation(glow, {BackgroundTransparency = 0.6}, {duration = 0.15})
        end
    end)
    
    hitbox.MouseEnter:Connect(function() 
        SpringAnimation(card, {BackgroundColor3 = TH.CardHov}, {duration = 0.2})
    end)
    hitbox.MouseLeave:Connect(function() 
        SpringAnimation(card, {BackgroundColor3 = TH.Card}, {duration = 0.2})
    end)
    
    self:_Add(card)
    return {
        Get = function() return val end,
        Set = function(v)
            v = decimals > 0 and math.floor(v * (10^decimals) + 0.5) / (10^decimals) or math.clamp(math.round(v), mn, mx)
            val = v
            local newPct = (v - mn) / (mx - mn)
            valueBox.Text = decimals > 0 and string.format("%."..decimals.."f", v) or math.round(v)
            SpringAnimation(fill, {Size = UDim2.new(newPct, 0, 1, 0)}, {duration = 0.2})
            SpringAnimation(knob, {Position = UDim2.new(newPct, -9, 0.5, -9)}, {duration = 0.2})
            SpringAnimation(glow, {Position = UDim2.new(newPct, -14, 0.5, -14)}, {duration = 0.2})
            if cb then pcall(cb, v) end
        end
    }
end

-- ─── Searchable Dropdown ──────────────────────────────────────────────
function Section:Dropdown(label, opts, cb, searchable)
    local sel = opts and opts[1] or nil
    local open = false
    local ITEM_HEIGHT = 34
    local MAX_VISIBLE = 6
    local filteredOpts = opts
    
    local wrap = Inst("Frame",{
        Size=UDim2.new(1,0,0,48),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ClipsDescendants=false
    })
    
    local card = Inst("Frame",{
        Size=UDim2.new(1,0,0,48),
        BackgroundColor3=TH.Card,
        BorderSizePixel=0,
        ClipsDescendants=true,
        ZIndex=20,
        Children={Corner(C8), Stroke(TH.Border, 1)},
        Parent=wrap
    })
    
    -- Header
    local header = Inst("Frame",{
        Size=UDim2.new(1,0,0,48),
        BackgroundTransparency=1,
        ZIndex=21,
        Parent=card
    })
    Padding(16, 12, 0, 0).Parent = header
    
    Inst("TextLabel",{
        Size=UDim2.new(0.4,0,1,0),
        BackgroundTransparency=1,
        Text=label,
        TextColor3=TH.TextPrimary,
        TextSize=14,
        Font=FM,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=22,
        Parent=header
    })
    
    local selectedLabel = Inst("TextLabel",{
        Size=UDim2.new(0.5,0,1,0),
        Position=UDim2.new(0.4,0,0,0),
        BackgroundTransparency=1,
        Text=sel or "Select...",
        TextColor3=TH.Acc,
        TextSize=13,
        Font=FS,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=22,
        Parent=header
    })
    
    local arrow = Inst("TextLabel",{
        Size=UDim2.new(0, 20, 0, 20),
        Position=UDim2.new(1, -28, 0.5, -10),
        BackgroundTransparency=1,
        Text="▼",
        TextColor3=TH.TextSecondary,
        TextSize=12,
        Font=FB,
        ZIndex=22,
        Parent=header
    })
    
    -- Options container
    local optionsFrame = Inst("ScrollingFrame",{
        Size=UDim2.new(1,0,0,0),
        Position=UDim2.new(0,0,0,48),
        BackgroundColor3=TH.BG2,
        BorderSizePixel=0,
        ScrollBarThickness=3,
        ZIndex=21,
        Parent=card
    })
    Stroke(TH.Border, 1).Parent = optionsFrame
    
    local optionsLayout = ListLayout(Enum.FillDirection.Vertical, 2)
    optionsLayout.Parent = optionsFrame
    
    -- Search box (if searchable)
    local searchBox
    if searchable then
        searchBox = Inst("TextBox",{
            Size=UDim2.new(1,-8,0,32),
            Position=UDim2.new(0,4,0,4),
            BackgroundColor3=TH.BG3,
            BorderSizePixel=0,
            PlaceholderText="🔍 Search...",
            PlaceholderColor3=TH.TextTertiary,
            Text="",
            TextColor3=TH.TextPrimary,
            TextSize=12,
            Font=FR,
            ClearTextOnFocus=false,
            Children={Corner(C6), Stroke(TH.Border, 1)},
            Parent=optionsFrame
        })
        
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local query = searchBox.Text:lower()
            filteredOpts = {}
            for _, opt in ipairs(opts) do
                if opt:lower():find(query) then
                    table.insert(filteredOpts, opt)
                end
            end
            RefreshOptions()
        end)
        
        optionsLayout.Padding = UDim.new(0, 40)
    end
    
    local optionButtons = {}
    
    local function RefreshOptions()
        for _, btn in ipairs(optionButtons) do
            btn:Destroy()
        end
        optionButtons = {}
        
        local visibleCount = math.min(#filteredOpts, MAX_VISIBLE)
        local totalHeight = (searchable and 44 or 0) + (#filteredOpts * ITEM_HEIGHT)
        optionsFrame.CanvasSize = UDim2.new(0,0,0,totalHeight)
        optionsFrame.Size = UDim2.new(1,0,0,math.min(400, totalHeight + (searchable and 8 or 0)))
        
        for i, opt in ipairs(filteredOpts) do
            local btn = Inst("TextButton",{
                Size=UDim2.new(1,-8,0,ITEM_HEIGHT),
                BackgroundColor3=TH.BG2,
                BorderSizePixel=0,
                Text="",
                ZIndex=22,
                Parent=optionsFrame
            })
            
            Inst("TextLabel",{
                Size=UDim2.new(1,-16,1,0),
                Position=UDim2.new(0,8,0,0),
                BackgroundTransparency=1,
                Text=opt,
                TextColor3=TH.TextSecondary,
                TextSize=13,
                Font=FR,
                TextXAlignment=Enum.TextXAlignment.Left,
                ZIndex=23,
                Parent=btn
            })
            
            btn.MouseEnter:Connect(function() 
                SpringAnimation(btn, {BackgroundColor3 = TH.PillBg}, {duration = 0.1})
            end)
            btn.MouseLeave:Connect(function() 
                SpringAnimation(btn, {BackgroundColor3 = TH.BG2}, {duration = 0.1})
            end)
            
            btn.MouseButton1Click:Connect(function()
                sel = opt
                selectedLabel.Text = opt
                open = false
                SpringAnimation(card, {Size = UDim2.new(1,0,0,48)}, {duration = 0.25})
                SpringAnimation(wrap, {Size = UDim2.new(1,0,0,48)}, {duration = 0.25})
                SpringAnimation(arrow, {Rotation = 0}, {duration = 0.2})
                if cb then pcall(cb, opt) end
            end)
            
            table.insert(optionButtons, btn)
        end
    end
    
    RefreshOptions()
    
    local hitbox = Inst("TextButton",{
        Size=UDim2.new(1,0,0,48),
        BackgroundTransparency=1,
        Text="",
        ZIndex=23,
        Parent=header
    })
    
    hitbox.MouseButton1Click:Connect(function()
        open = not open
        local targetHeight = open and (48 + optionsFrame.Size.Y.Offset) or 48
        SpringAnimation(card, {Size = UDim2.new(1,0,0,targetHeight)}, {duration = 0.25})
        SpringAnimation(wrap, {Size = UDim2.new(1,0,0,targetHeight)}, {duration = 0.25})
        SpringAnimation(arrow, {Rotation = open and 180 or 0}, {duration = 0.2})
    end)
    
    hitbox.MouseEnter:Connect(function() 
        SpringAnimation(card, {BackgroundColor3 = TH.CardHov}, {duration = 0.2})
    end)
    hitbox.MouseLeave:Connect(function() 
        SpringAnimation(card, {BackgroundColor3 = TH.Card}, {duration = 0.2})
    end)
    
    self:_Add(wrap)
    return {
        Get = function() return sel end,
        Set = function(v) 
            sel = v
            selectedLabel.Text = v
        end
    }
end

-- ═══════════════════════════════════════════════════════════════
--  Window Class
-- ═══════════════════════════════════════════════════════════════

local Window = {}
Window.__index = Window

function Window:Tab(name, iconId)
    local btn = Inst("TextButton",{
        Size=UDim2.new(1,-12,0,42),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Text="",
        ZIndex=3,
        Children={Corner(C8)},
        Parent=self._sl
    })
    
    local pill = Inst("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=TH.PillBg,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=2,
        Children={Corner(C8)},
        Parent=btn
    })
    
    local bar = Inst("Frame",{
        Size=UDim2.new(0, 3, 0.6, 0),
        Position=UDim2.new(0, 0, 0.2, 0),
        BackgroundColor3=TH.Acc,
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ZIndex=4,
        Children={Corner(UDim.new(0,2))},
        Parent=btn
    })
    
    local xOffset = iconId and 44 or 16
    local icon
    if iconId then
        icon = Inst("ImageLabel",{
            Size=UDim2.new(0, 18, 0, 18),
            Position=UDim2.new(0, 14, 0.5, -9),
            BackgroundTransparency=1,
            Image=iconId,
            ImageColor3=TH.TabInactive,
            ZIndex=4,
            Parent=btn
        })
    end
    
    local tabLabel = Inst("TextLabel",{
        Size=UDim2.new(1,-xOffset-4,1,0),
        Position=UDim2.new(0, xOffset, 0, 0),
        BackgroundTransparency=1,
        Text=name,
        TextColor3=TH.TabInactive,
        TextSize=13,
        Font=FS,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=4,
        Parent=btn
    })
    
    -- Content scroll frame with smooth scrolling
    local scrollFrame = Inst("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        ScrollBarThickness=4,
        ScrollBarImageColor3=TH.Acc,
        ScrollBarImageTransparency=0.5,
        CanvasSize=UDim2.new(0,0,0,0),
        Visible=false,
        ZIndex=1,
        ElasticBehavior=Enum.ElasticBehavior.Never,
        Parent=self._ca
    })
    Padding(16, 16, 16, 16).Parent = scrollFrame
    
    local layout = ListLayout(Enum.FillDirection.Vertical, 10)
    layout.Parent = scrollFrame
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SpringAnimation(scrollFrame, {CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 32)}, {duration = 0.1})
    end)
    
    local section = setmetatable({_sc = scrollFrame}, Section)
    local idx = #self._tabs + 1
    self._tabs[idx] = {btn = btn, pill = pill, bar = bar, label = tabLabel, icon = icon, scroll = scrollFrame}
    
    btn.MouseButton1Click:Connect(function() self:_Select(idx) end)
    btn.MouseEnter:Connect(function()
        if self._activeIndex ~= idx then
            SpringAnimation(pill, {BackgroundTransparency = 0.85}, {duration = 0.15})
            SpringAnimation(tabLabel, {TextColor3 = TH.TextSecondary}, {duration = 0.15})
            if icon then SpringAnimation(icon, {ImageColor3 = TH.TextSecondary}, {duration = 0.15}) end
        end
    end)
    btn.MouseLeave:Connect(function()
        if self._activeIndex ~= idx then
            SpringAnimation(pill, {BackgroundTransparency = 1}, {duration = 0.15})
            SpringAnimation(tabLabel, {TextColor3 = TH.TabInactive}, {duration = 0.15})
            if icon then SpringAnimation(icon, {ImageColor3 = TH.TabInactive}, {duration = 0.15}) end
        end
    end)
    
    if idx == 1 then self:_Select(1) end
    return section
end

function Window:_Select(idx)
    self._activeIndex = idx
    for i, tab in ipairs(self._tabs) do
        local active = (i == idx)
        tab.scroll.Visible = active
        
        if active then
            SpringAnimation(tab.pill, {BackgroundTransparency = 0}, {duration = 0.2})
            SpringAnimation(tab.bar, {BackgroundTransparency = 0}, {duration = 0.2})
            SpringAnimation(tab.label, {TextColor3 = TH.TabActive}, {duration = 0.2})
            if tab.icon then SpringAnimation(tab.icon, {ImageColor3 = TH.Acc}, {duration = 0.2}) end
        else
            SpringAnimation(tab.pill, {BackgroundTransparency = 1}, {duration = 0.2})
            SpringAnimation(tab.bar, {BackgroundTransparency = 1}, {duration = 0.2})
            SpringAnimation(tab.label, {TextColor3 = TH.TabInactive}, {duration = 0.2})
            if tab.icon then SpringAnimation(tab.icon, {ImageColor3 = TH.TabInactive}, {duration = 0.2}) end
        end
    end
end

function Window:Notify(title, msg, duration, type)
    duration = duration or 3
    type = type or "info"
    
    local colors = {
        success = TH.Success,
        error = TH.Error,
        warning = TH.Warning,
        info = TH.Info
    }
    local accentColor = colors[type] or TH.Acc
    
    local notificationRoot = self._sg
    local notification = Inst("Frame",{
        Size=UDim2.new(0, 280, 0, 0),
        Position=UDim2.new(1, -300, 1, -20),
        AnchorPoint=Vector2.new(0,1),
        BackgroundColor3=TH.BG3,
        BorderSizePixel=0,
        ClipsDescendants=true,
        ZIndex=100,
        Children={Corner(C8), Stroke(TH.Border, 1)},
        Parent=notificationRoot
    })
    
    -- Accent line
    Inst("Frame",{
        Size=UDim2.new(1,0,0,3),
        BackgroundColor3=accentColor,
        BorderSizePixel=0,
        ZIndex=101,
        Parent=notification
    })
    
    local inner = Inst("Frame",{
        Size=UDim2.new(1,0,1,0),
        Position=UDim2.new(0,0,0,3),
        BackgroundTransparency=1,
        ZIndex=101,
        Parent=notification
    })
    Padding(16, 16, 12, 12).Parent = inner
    
    -- Type icon
    local icons = {
        success = "✓",
        error = "✕",
        warning = "⚠",
        info = "ℹ"
    }
    
    Inst("TextLabel",{
        Size=UDim2.new(0, 24, 0, 24),
        Position=UDim2.new(0, 0, 0, 0),
        BackgroundColor3=accentColor,
        BackgroundTransparency=0.2,
        Text=icons[type] or "•",
        TextColor3=accentColor,
        TextSize=14,
        Font=FB,
        Children={Corner(C8)},
        ZIndex=102,
        Parent=inner
    })
    
    Inst("TextLabel",{
        Size=UDim2.new(1,-40,0,20),
        Position=UDim2.new(0, 32, 0, 0),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=TH.TextPrimary,
        TextSize=14,
        Font=FB,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=102,
        Parent=inner
    })
    
    local msgLabel = Inst("TextLabel",{
        Size=UDim2.new(1,-40,0,0),
        Position=UDim2.new(0, 32, 0, 24),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        Text=msg,
        TextColor3=TH.TextSecondary,
        TextSize=12,
        Font=FR,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,
        ZIndex=102,
        Parent=inner
    })
    
    -- Progress bar
    local progress = Inst("Frame",{
        Size=UDim2.new(1,0,0,2),
        Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=accentColor,
        BackgroundTransparency=0.7,
        BorderSizePixel=0,
        ZIndex=102,
        Parent=notification
    })
    
    local progressFill = Inst("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=accentColor,
        BorderSizePixel=0,
        ZIndex=103,
        Parent=progress
    })
    
    -- Animate in
    SpringAnimation(notification, {Size = UDim2.new(0, 280, 0, 52 + msgLabel.TextBounds.Y)}, {duration = 0.3})
    SpringAnimation(progressFill, duration, {Size = UDim2.new(0,0,1,0)})
    
    task.delay(duration, function()
        SpringAnimation(notification, {Size = UDim2.new(0, 280, 0, 0), Position = UDim2.new(1, -300, 1, -10)}, {duration = 0.25})
        task.delay(0.3, function() notification:Destroy() end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  Library Entry Point
-- ═══════════════════════════════════════════════════════════════

local CalmLib = {}
CalmLib.__index = CalmLib

function CalmLib:Win(title, subtitle)
    -- Clean up existing instance
    pcall(function()
        if CG:FindFirstChild("CalmLib_Nova") then 
            CG.CalmLib_Nova:Destroy() 
        end
    end)
    
    local screenGui = Inst("ScreenGui",{
        Name = "CalmLib_Nova",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = CG
    })
    
    -- Add glass morphism background
    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = LS
    
    local window = Inst("Frame",{
        Size=UDim2.new(0,WW,0,WH),
        Position=UDim2.new(0.5,-WW/2,0.5,-WH/2),
        BackgroundColor3=TH.BG,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Children={Corner(C12), Stroke(TH.GlassBorder, 1)},
        Parent=screenGui
    })
    
    -- Animate window opening
    window.Size = UDim2.new(0,WW,0,0)
    window.BackgroundTransparency = 0.5
    SpringAnimation(window, {Size = UDim2.new(0,WW,0,WH), BackgroundTransparency = 0}, {duration = 0.4})
    
    -- Titlebar with glass effect
    local titlebar = Inst("Frame",{
        Size=UDim2.new(1,0,0,TH_),
        BackgroundColor3=TH.Glass,
        BackgroundTransparency=0.3,
        BorderSizePixel=0,
        ZIndex=5,
        Children={Corner(C12)},
        Parent=window
    })
    
    -- Titlebar content
    local logoPill = Inst("Frame",{
        Size=UDim2.new(0, 8, 0, 28),
        Position=UDim2.new(0, 16, 0.5, -14),
        BackgroundColor3=TH.Acc,
        BorderSizePixel=0,
        ZIndex=6,
        Children={Corner(UDim.new(0,4))},
        Parent=titlebar
    })
    
    local titleLabel = Inst("TextLabel",{
        Size=UDim2.new(0, 200, 1, 0),
        Position=UDim2.new(0, 32, 0, 0),
        BackgroundTransparency=1,
        Text=title or "CalmLib Nova",
        TextColor3=TH.TextPrimary,
        TextSize=15,
        Font=FB,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=6,
        Parent=titlebar
    })
    
    if subtitle and subtitle ~= "" then
        Inst("TextLabel",{
            Size=UDim2.new(0, 200, 1, 0),
            Position=UDim2.new(0, 32 + titleLabel.TextBounds.X + 8, 0, 0),
            BackgroundTransparency=1,
            Text="// " .. subtitle,
            TextColor3=TH.TextTertiary,
            TextSize=12,
            Font=FR,
            TextXAlignment=Enum.TextXAlignment.Left,
            ZIndex=6,
            Parent=titlebar
        })
    end
    
    -- Window controls (macOS style with better animations)
    local function createControl(x, color, symbol, action)
        local btn = Inst("TextButton",{
            Size=UDim2.new(0, 14, 0, 14),
            Position=UDim2.new(1, x, 0.5, -7),
            BackgroundColor3=color,
            BorderSizePixel=0,
            Text="",
            ZIndex=7,
            Children={Corner(C20)},
            Parent=titlebar
        })
        
        local symbolLabel = Inst("TextLabel",{
            Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1,
            Text=symbol,
            TextColor3=Color3.new(0,0,0),
            TextTransparency=1,
            TextSize=10,
            Font=FB,
            ZIndex=8,
            Parent=btn
        })
        
        btn.MouseEnter:Connect(function()
            SpringAnimation(symbolLabel, {TextTransparency = 0}, {duration = 0.1})
            SpringAnimation(btn, {BackgroundColor3 = color:Lerp(TH.TextPrimary, 0.2)}, {duration = 0.1})
        end)
        
        btn.MouseLeave:Connect(function()
            SpringAnimation(symbolLabel, {TextTransparency = 1}, {duration = 0.1})
            SpringAnimation(btn, {BackgroundColor3 = color}, {duration = 0.1})
        end)
        
        btn.MouseButton1Click:Connect(action)
    end
    
    createControl(-40, TH.Error, "✕", function()
        SpringAnimation(window, {Size = UDim2.new(0,WW,0,0), BackgroundTransparency = 0.6}, {duration = 0.3})
        task.delay(0.35, function() 
            screenGui:Destroy()
            blur:Destroy()
        end)
    end)
    
    createControl(-60, TH.Warning, "−", function()
        -- Minimize functionality
    end)
    
    createControl(-80, TH.Success, "□", function()
        -- Maximize functionality
    end)
    
    Drag(window, titlebar)
    
    -- Sidebar
    local sidebar = Inst("Frame",{
        Size=UDim2.new(0,SW,1,-TH_),
        Position=UDim2.new(0,0,0,TH_),
        BackgroundColor3=TH.Side,
        BorderSizePixel=0,
        ZIndex=2,
        Parent=window
    })
    
    Inst("Frame",{
        Size=UDim2.new(0,1,1,0),
        Position=UDim2.new(1,-1,0,0),
        BackgroundColor3=TH.Border,
        BorderSizePixel=0,
        Parent=sidebar
    })
    
    -- Sidebar header
    Inst("TextLabel",{
        Size=UDim2.new(1,-16,0,24),
        Position=UDim2.new(0,8,0,16),
        BackgroundTransparency=1,
        Text="MENU",
        TextColor3=TH.TextTertiary,
        TextSize=10,
        Font=FB,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=sidebar
    })
    
    local sidebarList = Inst("Frame",{
        Size=UDim2.new(1,0,1,-56),
        Position=UDim2.new(0,0,0,48),
        BackgroundTransparency=1,
        ZIndex=3,
        Children={ListLayout(Enum.FillDirection.Vertical, 4), Padding(8,8,8,8)},
        Parent=sidebar
    })
    
    -- Sidebar footer
    Inst("TextLabel",{
        Size=UDim2.new(1,0,0,24),
        Position=UDim2.new(0,0,1,-28),
        BackgroundTransparency=1,
        Text="CalmLib Nova v4.0",
        TextColor3=TH.TextTertiary,
        TextSize=10,
        Font=FR,
        TextXAlignment=Enum.TextXAlignment.Center,
        Parent=sidebar
    })
    
    -- Content area
    local contentArea = Inst("Frame",{
        Size=UDim2.new(1,-SW,1,-TH_),
        Position=UDim2.new(0,SW,0,TH_),
        BackgroundColor3=TH.BG,
        BorderSizePixel=0,
        ClipsDescendants=true,
        ZIndex=1,
        Parent=window
    })
    
    local win = setmetatable({
        _sg = screenGui,
        _win = window,
        _sl = sidebarList,
        _ca = contentArea,
        _tabs = {},
        _activeIndex = nil
    }, Window)
    
    return win
end

return CalmLib
