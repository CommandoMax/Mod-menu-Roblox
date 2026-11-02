--===========================================================================
--  DELTA ULTIMATE MOD MENU  v2.3   (Android / Delta)
--  Arbre corrigé · passthrough tactile · hooks à la demande
--===========================================================================
if getgenv().DUMM and getgenv().DUMM.Unload then pcall(getgenv().DUMM.Unload) end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Tween      = game:GetService("TweenService")
local Lighting   = game:GetService("Lighting")
local Teleport   = game:GetService("TeleportService")
local Http       = game:GetService("HttpService")
local VUser      = game:GetService("VirtualUser")
local Stats      = game:GetService("Stats")
local Pathfind   = game:GetService("PathfindingService")
local LP         = Players.LocalPlayer
local G          = getfenv()

local MM = {Connections={}, Objects={}, Setters={}, Config={}, Restore={}, Flags={},
            Loops={}, Binds={}, Logs={}, Fails={}}
getgenv().DUMM = MM

local function has(n) return type(G[n]) == "function" end
local function bind(c) table.insert(MM.Connections, c) return c end
local function keep(o) table.insert(MM.Objects, o) return o end
local function char() return LP and LP.Character end
local function hum() local c = char() return c and c:FindFirstChildOfClass("Humanoid") end
local function hrp() local c = char() return c and c:FindFirstChild("HumanoidRootPart") end
local function cam() return workspace.CurrentCamera end
local function try(name, fn)
    local ok, e = pcall(fn)
    if not ok then table.insert(MM.Fails, name.." → "..tostring(e)) end
end

local T = {bg=Color3.fromRGB(15,15,19), panel=Color3.fromRGB(23,23,29), elem=Color3.fromRGB(32,32,40),
    acc=Color3.fromRGB(84,138,255), txt=Color3.fromRGB(236,236,242), dim=Color3.fromRGB(146,146,158),
    ok=Color3.fromRGB(74,200,118), bad=Color3.fromRGB(232,80,80), warn=Color3.fromRGB(240,180,70)}
local function New(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in next, props do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(o,r) New("UICorner",{CornerRadius=UDim.new(0,r or 6)},o) end
local function stroke(o,c,t) New("UIStroke",{Color=c or Color3.new(0,0,0),Thickness=t or 1},o) end

local parentGui
pcall(function() if gethui then parentGui = gethui() end end)
if not parentGui then
    parentGui = LP:FindFirstChild("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
end

local SG = New("ScreenGui",{Name="DeltaUltimate",ResetOnSpawn=false,IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999,Parent=parentGui})
keep(SG)

local NotifHolder = New("Frame",{Size=UDim2.new(1,0,0,300),Position=UDim2.new(0,0,0,6),
    BackgroundTransparency=1,Active=false,ZIndex=30,Parent=SG})
New("UIListLayout",{Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Center,
    SortOrder=Enum.SortOrder.LayoutOrder},NotifHolder)
local function notify(title, txt, dur, col)
    local f = New("Frame",{Size=UDim2.new(0.82,0,0,42),BackgroundColor3=T.panel,BackgroundTransparency=0.05,Parent=NotifHolder})
    corner(f,8); stroke(f, col or T.acc, 1)
    New("TextLabel",{Size=UDim2.new(1,-14,0,17),Position=UDim2.new(0,7,0,3),BackgroundTransparency=1,Text=title,
        TextColor3=col or T.acc,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,TextSize=12,Parent=f})
    New("TextLabel",{Size=UDim2.new(1,-14,0,15),Position=UDim2.new(0,7,0,21),BackgroundTransparency=1,Text=txt or "",
        TextColor3=T.txt,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=10,
        TextTruncate=Enum.TextTruncate.AtEnd,Parent=f})
    task.delay(dur or 3, function()
        pcall(function() Tween:Create(f,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play() end)
        task.wait(0.25); f:Destroy()
    end)
end

local function startLoop(key, event, fn)
    MM.Loops[key] = bind(RunService[event]:Connect(fn))
end
local function stopLoop(key)
    if MM.Loops[key] then pcall(function() MM.Loops[key]:Disconnect() end); MM.Loops[key] = nil end
end
local function onCharacter(key, fn)
    stopLoop(key)
    local function attach(c) task.spawn(fn, c) end
    if char() then attach(char()) end
    MM.Loops[key] = bind(LP.CharacterAdded:Connect(attach))
end

--===========================================================================
--  FENÊTRE + BOUTON
--===========================================================================
local Win = New("Frame",{Size=UDim2.new(0,344,0,478),Position=UDim2.new(0.5,-172,0.5,-239),
    BackgroundColor3=T.bg,Visible=true,Active=false,ZIndex=10,Parent=SG})
corner(Win,12); stroke(Win,T.acc,1)

local Open = New("TextButton",{Size=UDim2.new(0,46,0,46),Position=UDim2.new(0,12,0,120),BackgroundColor3=T.acc,
    Text="Δ",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=22,Active=true,
    Visible=true,ZIndex=40,Parent=SG})
corner(Open,23); stroke(Open,Color3.new(1,1,1),1)

local function setOpen(v)
    Win.Visible = v
    Open.Visible = not v
end

-- bouton : glisser = déplacer, tap = ouvrir
do
    local input, moved, startPos, startBtn
    Open.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            input, moved, startPos, startBtn = i, false, i.Position, Open.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if input and i == input and (i.UserInputType==Enum.UserInputType.Touch
            or i.UserInputType==Enum.UserInputType.MouseMovement) then
            local d = i.Position - startPos
            if not moved and d.Magnitude > 10 then moved = true end
            if moved then
                Open.Position = UDim2.new(startBtn.X.Scale, startBtn.X.Offset + d.X,
                                          startBtn.Y.Scale, startBtn.Y.Offset + d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i == input then
            if not moved then setOpen(true) end
            input = nil
        end
    end)
end

-- déplacement fenêtre via la barre de titre
local Bar = New("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=T.panel,Active=true,Parent=Win})
corner(Bar,12)
do
    local dragInput, startPos, startFrame
    Bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragInput, startPos, startFrame = i, i.Position, Win.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragInput and i == dragInput and (i.UserInputType==Enum.UserInputType.Touch
            or i.UserInputType==Enum.UserInputType.MouseMovement) then
            local d = i.Position - startPos
            Win.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + d.X,
                                     startFrame.Y.Scale, startFrame.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i == dragInput then dragInput = nil end
    end)
end
New("TextLabel",{Size=UDim2.new(1,-88,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,
    Text="DELTA ULTIMATE v2.3",TextColor3=T.acc,TextXAlignment=Enum.TextXAlignment.Left,
    Font=Enum.Font.GothamBold,TextSize=12,Parent=Bar})
local Min = New("TextButton",{Size=UDim2.new(0,28,0,22),Position=UDim2.new(1,-36,0,7),BackgroundColor3=T.elem,
    Text="–",TextColor3=T.txt,Font=Enum.Font.GothamBold,TextSize=14,Active=true,Parent=Bar})
corner(Min,6)
Min.MouseButton1Click:Connect(function() setOpen(false) end)

local TabBar = New("ScrollingFrame",{Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,38),BackgroundTransparency=1,
    BorderSizePixel=0,ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.X,
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.X,Parent=Win})
New("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4),
    VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},TabBar)
New("UIPadding",{PaddingLeft=UDim.new(0,8)},TabBar)

local Content = New("Frame",{Size=UDim2.new(1,-14,1,-78),Position=UDim2.new(0,7,0,72),
    BackgroundTransparency=1,Parent=Win})
local Pages, TabBtns = {}, {}
local function Tab(name)
    local b = New("TextButton",{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=T.elem,
        Text="  "..name.."  ",TextColor3=T.dim,Font=Enum.Font.GothamMedium,TextSize=11,Active=true,Parent=TabBar})
    corner(b,6)
    local p = New("ScrollingFrame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,BorderSizePixel=0,
        ScrollBarThickness=3,ScrollBarImageColor3=T.acc,CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=Content})
    New("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},p)
    New("UIPadding",{PaddingBottom=UDim.new(0,24)},p)
    table.insert(Pages,p); table.insert(TabBtns,b)
    b.MouseButton1Click:Connect(function()
        for i,v in ipairs(Pages) do
            v.Visible = (v==p)
            TabBtns[i].TextColor3 = (v==p) and T.acc or T.dim
            TabBtns[i].BackgroundColor3 = (v==p) and T.panel or T.elem
        end
    end)
    return p
end
local function Section(p, t)
    return New("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,Text="▍"..t:upper(),
        TextColor3=T.acc,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,TextSize=10,Parent=p})
end
local function Label(p, t)
    return New("TextLabel",{Size=UDim2.new(1,0,0,15),BackgroundTransparency=1,Text=t,TextColor3=T.dim,
        TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=10,TextWrapped=true,Parent=p})
end
local function Toggle(p, text, default, cb, key)
    local row = New("TextButton",{Size=UDim2.new(1,0,0,32),BackgroundColor3=T.elem,Text="",Active=true,Parent=p})
    corner(row,7)
    New("TextLabel",{Size=UDim2.new(1,-52,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=text,
        TextColor3=T.txt,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=11,
        TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
    local track = New("Frame",{Size=UDim2.new(0,34,0,18),Position=UDim2.new(1,-42,0.5,-9),BackgroundColor3=T.elem,Parent=row})
    corner(track,9); stroke(track,T.dim,1)
    local knob = New("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,2,0.5,-7),BackgroundColor3=T.dim,Parent=track})
    corner(knob,7)
    local state = false
    local function set(v, silent)
        state = v and true or false
        pcall(function()
            Tween:Create(knob,TweenInfo.new(0.13),{Position=UDim2.new(0,state and 18 or 2,0.5,-7)}):Play()
            Tween:Create(track,TweenInfo.new(0.13),{BackgroundColor3=state and T.acc or T.elem}):Play()
            knob.BackgroundColor3 = state and Color3.new(1,1,1) or T.dim
        end)
        if key then MM.Config[key] = state end
        if not silent then pcall(cb, state) end
    end
    row.MouseButton1Click:Connect(function() set(not state) end)
    if key then MM.Setters[key] = function(v) set(v) end; MM.Binds[key] = set end
    if default then set(true, true); task.spawn(cb, true) end
    return set
end
local function Button(p, text, cb, col)
    local b = New("TextButton",{Size=UDim2.new(1,0,0,30),BackgroundColor3=col or T.elem,Text=text,TextColor3=T.txt,
        Font=Enum.Font.Gotham,TextSize=11,Active=true,Parent=p})
    corner(b,7)
    b.MouseButton1Click:Connect(function()
        local ok, e = pcall(cb)
        if not ok then notify("Erreur", tostring(e), 4, T.bad) end
    end)
    return b
end
local function Slider(p, text, min, max, default, cb, key)
    local row = New("Frame",{Size=UDim2.new(1,0,0,42),BackgroundColor3=T.elem,Parent=p})
    corner(row,7)
    New("TextLabel",{Size=UDim2.new(1,-50,0,16),Position=UDim2.new(0,10,0,3),BackgroundTransparency=1,Text=text,
        TextColor3=T.txt,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=11,Parent=row})
    local val = New("TextLabel",{Size=UDim2.new(0,42,0,16),Position=UDim2.new(1,-50,0,3),BackgroundTransparency=1,
        Text=tostring(default),TextColor3=T.acc,TextXAlignment=Enum.TextXAlignment.Right,Font=Enum.Font.Code,TextSize=11,Parent=row})
    local bar = New("TextButton",{Size=UDim2.new(1,-20,0,10),Position=UDim2.new(0,10,0,24),BackgroundColor3=T.panel,
        Text="",Active=true,Parent=row})
    corner(bar,5)
    local fill = New("Frame",{Size=UDim2.new((default - min) / (max - min),0,1,0),BackgroundColor3=T.acc,Parent=bar})
    corner(fill,5)
    local cur = default
    local function apply(v, silent)
        cur = math.clamp(v, min, max)
        fill.Size = UDim2.new((cur - min) / (max - min),0,1,0)
        val.Text = tostring(math.floor(cur * 100) / 100)
        if key then MM.Config[key] = cur end
        if not silent then pcall(cb, cur) end
    end
    local dragging = false
    local function fromX(x)
        apply(min + ((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X) * (max - min))
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging = true
            fromX(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            fromX(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    if key then MM.Setters[key] = function(v) apply(v) end end
    return apply
end
local function Box(p, ph, default, cb, multi)
    local t = New("TextBox",{Size=UDim2.new(1,0,0,multi and 90 or 30),BackgroundColor3=T.elem,Text=default or "",
        PlaceholderText=ph,PlaceholderColor3=T.dim,TextColor3=T.txt,Font=Enum.Font.Code,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,MultiLine=multi or false,
        ClearTextOnFocus=false,Active=true,Parent=p})
    corner(t,7); New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingTop=UDim.new(0,5)},t)
    if cb then t.FocusLost:Connect(function() pcall(cb, t.Text) end) end
    return t
end
local function Dropdown(p, text, options, cb)
    local row = New("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=T.elem,Parent=p})
    corner(row,7)
    New("TextLabel",{Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=text,
        TextColor3=T.txt,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,TextSize=11,Parent=row})
    local cur = options[1] or "?"
    local btn = New("TextButton",{Size=UDim2.new(0,84,0,20),Position=UDim2.new(1,-92,0.5,-10),BackgroundColor3=T.panel,
        Text=cur,TextColor3=T.acc,Font=Enum.Font.Code,TextSize=10,Active=true,Parent=row})
    corner(btn,5)
    local list = New("Frame",{Size=UDim2.new(1,0,0,0),BackgroundColor3=T.panel,Visible=false,ZIndex=5,Parent=row})
    New("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder},list)
    local op = false
    local function rf()
        list.Size = UDim2.new(1,0,0, op and (#options * 22) or 0)
        list.Position = UDim2.new(0,0,0,32)
    end
    btn.MouseButton1Click:Connect(function() op = not op; list.Visible = op; rf() end)
    for _, o in ipairs(options) do
        local b = New("TextButton",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,Text=o,TextColor3=T.txt,
            Font=Enum.Font.Code,TextSize=10,Active=true,Parent=list})
        b.MouseButton1Click:Connect(function()
            cur = o; btn.Text = o; op = false; list.Visible = false; rf(); pcall(cb, o)
        end)
    end
    return btn
end

--===========================================================================
--  PARTAGÉS
--===========================================================================
local Selected = nil
local espCache, chamCache, itemCache = {}, {}, {}
local fovC, ch1, ch2, hud

local function log(msg, col)
    table.insert(MM.Logs, {m=tostring(msg), c=col})
    if #MM.Logs > 200 then table.remove(MM.Logs, 1) end
end
local function ser(v, d)
    d = d or 0
    local t = typeof(v)
    if t=="Instance" then return v:GetFullName() end
    if t=="string" then return string.format("%q", v) end
    if t=="table" then
        if d>2 then return "{...}" end
        local o = {}
        for k,x in next, v do table.insert(o, tostring(k).."="..ser(x,d+1)) end
        return "{"..table.concat(o,", ").."}"
    end
    return tostring(v)
end
local function clearESP()
    for _, t in next, espCache do for _, d in next, t do pcall(function() d:Remove() end) end end
    espCache = {}
    for _, h in next, chamCache do pcall(function() h:Destroy() end) end
    chamCache = {}
end

--===========================================================================
--  CONSOLE
--===========================================================================
local PC = Tab("Console")
try("console", function()
    Section(PC, "Sortie")
    local logScroll = New("ScrollingFrame",{Size=UDim2.new(1,0,0,290),BackgroundColor3=T.panel,BorderSizePixel=0,
        ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=PC})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},logScroll)
    New("UIPadding",{PaddingLeft=UDim.new(0,4)},logScroll)
    bind(RunService.Heartbeat:Connect(function()
        if #MM.Logs == 0 or not PC.Visible then return end
        for i = #MM.Logs, 1, -1 do
            local e = MM.Logs[i]; MM.Logs[i] = nil
            New("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=e.m,TextColor3=e.c or T.dim,
                TextSize=9,Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Left,
                TextWrapped=true,Parent=logScroll})
        end
    end))
    Button(PC, "Vider", function()
        for _, c in ipairs(logScroll:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
    end)
    Section(PC, "Éditeur de script")
    local ed = Box(PC, "-- code Luau…", "", nil, true)
    Button(PC, "Exécuter le code", function()
        local fn, err = loadstring(ed.Text, "DUMM_editor")
        if not fn then return log("parse: "..tostring(err), T.bad) end
        local ok, e = pcall(fn)
        log(ok and "> exécuté" or ("runtime: "..tostring(e)), ok and T.ok or T.bad)
    end)
    Button(PC, "Exécuter un fichier local", function()
        if not has("listfiles") then return log("listfiles absent", T.bad) end
        for _, f in ipairs(listfiles()) do
            if f:sub(-4) == ".lua" then
                local b = Button(PC, "▸ "..f, function()
                    local fn = loadstring(readfile(f))
                    if fn then pcall(fn); log("> "..f, T.ok) end
                end)
                b.BackgroundColor3 = T.panel
            end
        end
    end)
end)

--===========================================================================
--  EXPLORER
--===========================================================================
local PE = Tab("Explorer")
try("explorer", function()
    Section(PE, "Arbre")
    local tree = New("ScrollingFrame",{Size=UDim2.new(1,0,0,160),BackgroundColor3=T.panel,BorderSizePixel=0,
        ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=PE})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},tree)
    New("UIPadding",{PaddingLeft=UDim.new(0,4),PaddingTop=UDim.new(0,3)},tree)

    local buildNode
    buildNode = function(parent, inst, depth)
        local node = New("Frame",{Size=UDim2.new(1,0,0,19),BackgroundTransparency=1,
            AutomaticSize=Enum.AutomaticSize.Y,Parent=parent})
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},node)

        local row = New("TextButton",{Size=UDim2.new(1,0,0,19),BackgroundTransparency=1,Text="",Active=true,Parent=node})
        local arrow = New("TextButton",{Size=UDim2.new(0,14,1,0),Position=UDim2.new(0, depth * 8, 0, 0),
            BackgroundTransparency=1,Text="+",TextColor3=T.dim,TextSize=11,Font=Enum.Font.GothamBold,
            Active=true,Parent=row})
        New("TextLabel",{Size=UDim2.new(1, -19 - depth * 8, 1, 0),
            Position=UDim2.new(0, 19 + depth * 8, 0, 0),BackgroundTransparency=1,
            Text=inst.Name.." ["..inst.ClassName.."]",TextColor3=T.txt,TextXAlignment=Enum.TextXAlignment.Left,
            TextSize=9,Font=Enum.Font.Code,TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})

        local holder = New("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,
            AutomaticSize=Enum.AutomaticSize.Y,Parent=node})
        New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},holder)

        local built = false
        row.MouseButton1Click:Connect(function() Selected = inst; notify("Sélection", inst:GetFullName(), 2) end)
        arrow.MouseButton1Click:Connect(function()
            if built then holder.Visible = not holder.Visible; arrow.Text = holder.Visible and "-" or "+"; return end
            built = true; arrow.Text = "-"
            task.spawn(function()
                local f = MM.Flags.filter or ""
                local n = 0
                for _, ch in ipairs(inst:GetChildren()) do
                    n = n + 1; if n > 300 then break end
                    if f == "" or ch.Name:lower():find(f, 1, true) or ch.ClassName:lower():find(f, 1, true) then
                        buildNode(holder, ch, depth + 1)
                    end
                end
                if #holder:GetChildren() == 1 then
                    New("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
                        Text="  (vide)",TextColor3=T.dim,TextSize=9,Font=Enum.Font.Code,
                        TextXAlignment=Enum.TextXAlignment.Left,Parent=holder})
                end
            end)
        end)
    end
    local ROOTS = function() return {workspace, game:GetService("ReplicatedStorage"), Players,
        game:GetService("CoreGui"), Lighting, game:GetService("ReplicatedFirst")} end
    local rebuild = function()
        for _, c in ipairs(tree:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        for _, r in ipairs(ROOTS()) do buildNode(tree, r, 0) end
    end
    local filter = Box(PE, "filtrer nom / classe…", "", function(v) MM.Flags.filter = v:lower(); rebuild() end)
    rebuild()
    Button(PE, "Rafraîchir", rebuild)

    Section(PE, "Propriétés de la sélection")
    local propFilter = Box(PE, "filtrer les propriétés…", "", nil)
    local propScroll = New("ScrollingFrame",{Size=UDim2.new(1,0,0,130),BackgroundColor3=T.panel,BorderSizePixel=0,
        ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Parent=PE})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},propScroll)
    Button(PE, "Lister les propriétés", function()
        if not Selected then return notify("Info","aucune sélection",2,T.warn) end
        for _, c in ipairs(propScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
        if not has("getproperties") then return log("getproperties absent", T.bad) end
        local f = propFilter.Text:lower()
        local n = 0
        for _, name in ipairs(getproperties(Selected)) do
            if f == "" or name:lower():find(f, 1, true) then
                n = n + 1; if n > 120 then break end
                local row = New("Frame",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.elem,Parent=propScroll})
                corner(row,4)
                New("TextLabel",{Size=UDim2.new(0.42,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=T.dim,
                    TextSize=9,Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
                local ok, v = pcall(function() return Selected[name] end)
                local e = New("TextBox",{Size=UDim2.new(0.42,0,1,-6),Position=UDim2.new(0.42,0,0,3),
                    BackgroundColor3=T.panel,Text=ok and tostring(v) or "?",TextColor3=T.txt,TextSize=9,
                    Font=Enum.Font.Code,ClearTextOnFocus=false,Parent=row})
                local s = New("TextButton",{Size=UDim2.new(0,30,1,-6),Position=UDim2.new(1,-33,0,3),
                    BackgroundColor3=T.acc,Text="SET",TextSize=8,TextColor3=Color3.new(1,1,1),
                    Font=Enum.Font.GothamBold,Active=true,Parent=row})
                s.MouseButton1Click:Connect(function()
                    local okv, nv = pcall(function() return loadstring("return "..e.Text)() end)
                    if okv then
                        local oks, err = pcall(function() Selected[name] = nv end)
                        log(oks and ("set "..name) or tostring(err), oks and T.ok or T.bad)
                    end
                end)
            end
        end
        notify("Propriétés", n.." affichée(s)", 2)
    end)

    Section(PE, "Actions sur l'instance")
    Button(PE, "Copier le chemin", function()
        if Selected then setclipboard(Selected:GetFullName()); notify("Copié", Selected:GetFullName(), 2) end
    end)
    Button(PE, "Téléporter dessus", function()
        local r = hrp()
        if r and Selected and Selected:IsA("BasePart") then r.CFrame = Selected.CFrame * CFrame.new(0,3,4) end
    end)
    Button(PE, "Cloner dans Workspace", function()
        if Selected then local c = Selected:Clone(); c.Parent = workspace; Selected = c end
    end)
    Button(PE, "Supprimer", function()
        if Selected then Selected:Destroy(); Selected = nil end
    end, T.bad)
    Button(PE, "Décompiler (scripts)", function()
        if not Selected or not Selected:IsA("LuaSourceContainer") then return notify("Info","pas un script",2,T.warn) end
        local src = "-- indisponible"
        if has("decompile") then
            local ok, r = pcall(decompile, Selected); if ok and r then src = r end
        elseif has("getscriptbytecode") then
            local ok, r = pcall(getscriptbytecode, Selected); if ok then src = tostring(r) end
        end
        setclipboard(src)
        log("source copiée ("..#src.." o)", T.ok)
    end)

    Section(PE, "Remote Spy (hook à la demande)")
    local spyScroll = New("ScrollingFrame",{Size=UDim2.new(1,0,0,150),BackgroundColor3=T.panel,BorderSizePixel=0,
        ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),Parent=PE})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},spyScroll)
    local spyQ = {}
    local spyHook = nil
    local function spyInstall()
        if spyHook or not has("hookmetamethod") then return end
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if not checkcaller() and (m=="FireServer" or m=="InvokeServer" or m=="Fire" or m=="Invoke") then
                if typeof(self)=="Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")
                    or self:IsA("UnreliableRemoteEvent") or self:IsA("BindableEvent")) then
                    local a = table.pack(...)
                    local o = {}
                    for i=1,a.n do o[i] = ser(a[i]) end
                    table.insert(spyQ, {n=self:GetFullName(), m=m, a=table.concat(o,", ")})
                    if #spyQ > 100 then table.remove(spyQ, 1) end
                end
            end
            return old(self, ...)
        end)
        spyHook = function() pcall(hookmetamethod, game, "__namecall", old) end
        table.insert(MM.Restore, spyHook)
    end
    local function spyRemove()
        if spyHook then spyHook(); spyHook = nil end
    end
    Toggle(PE, "Espionner les remotes", false, function(on)
        if on then spyInstall() else spyRemove() end
    end, "remoteSpy")
    bind(RunService.Heartbeat:Connect(function()
        if #spyQ == 0 or not PE.Visible then return end
        for i = #spyQ, 1, -1 do
            local e = spyQ[i]; spyQ[i] = nil
            local b = New("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=T.elem,Text="",Active=true,Parent=spyScroll})
            New("TextLabel",{Size=UDim2.new(1,-6,1,0),Position=UDim2.new(0,3,0,0),BackgroundTransparency=1,
                Text=e.m.." "..e.n.." ("..e.a..")",TextColor3=T.txt,TextSize=9,Font=Enum.Font.Code,
                TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=b})
            b.MouseButton1Click:Connect(function()
                setclipboard(e.m.." "..e.n.." ("..e.a..")"); notify("Copié", e.n, 2)
            end)
        end
    end))
    Button(PE, "Vider le log", function()
        for _, c in ipairs(spyScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    end)
    Button(PE, "Dump de place (saveinstance)", function()
        if not has("saveinstance") then return log("saveinstance absent", T.bad) end
        pcall(saveinstance, {}); notify("Dump", "généré")
    end)
end)

--===========================================================================
--  VM
--===========================================================================
local PV = Tab("VM")
try("vm", function()
    Section(PV, "Identité de thread")
    Button(PV, "Identité 8 (protégé)", function()
        if has("setthreadidentity") then pcall(setthreadidentity, 8); log("identité 8", T.ok) end
    end)
    Button(PV, "Identité 2 (normal)", function()
        if has("setthreadidentity") then pcall(setthreadidentity, 2); log("identité 2", T.ok) end
    end)

    Section(PV, "Hook de métaméthode")
    local mmKind = Dropdown(PV, "Métaméthode", {"__namecall","__index","__newindex"}, function() end)
    local mmTarget = Box(PV, "méthode / propriété ciblée", "", nil)
    local mmRet = Box(PV, "valeur retournée (Lua)", "true", nil)
    local mmActive = {}
    local function dropMM(k)
        local f = mmActive[k]
        if f then f(); mmActive[k] = nil; return true end
    end
    Button(PV, "Installer", function()
        local k = mmKind.Text
        dropMM(k)
        local old, repl
        if k == "__namecall" then
            repl = function(self, ...)
                if not checkcaller() and getnamecallmethod() == mmTarget.Text then
                    local ok, v = pcall(function() return loadstring("return "..mmRet.Text)() end)
                    if ok then return v end
                end
                return old(self, ...)
            end
        else
            repl = function(self, key)
                if not checkcaller() and key == mmTarget.Text then
                    local ok, v = pcall(function() return loadstring("return "..mmRet.Text)() end)
                    if ok then return v end
                end
                return old(self, key)
            end
        end
        old = hookmetamethod(game, k, repl)
        mmActive[k] = function() pcall(hookmetamethod, game, k, old) end
        notify("Hook", k.." "..mmTarget.Text, 2, T.ok)
    end)
    Button(PV, "Retirer", function() notify("Hook", dropMM(mmKind.Text) and "retiré" or "inactif", 2, T.warn) end)

    Section(PV, "Presets")
    Button(PV, "Anti-Kick", function()
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            if not checkcaller() and getnamecallmethod() == "Kick" then
                log("Kick intercepté", T.warn); return
            end
            return old(self, ...)
        end)
        table.insert(MM.Restore, function() pcall(hookmetamethod, game, "__namecall", old) end)
    end)
    Button(PV, "Spoof WalkSpeed (lecture)", function()
        local old
        old = hookmetamethod(game, "__index", function(self, key)
            if not checkcaller() and key == "WalkSpeed" and typeof(self)=="Instance" and self:IsA("Humanoid") then
                return 16
            end
            return old(self, key)
        end)
        table.insert(MM.Restore, function() pcall(hookmetamethod, game, "__index", old) end)
        notify("Spoof", "WalkSpeed verrouillé sur 16", 2, T.ok)
    end)

    Section(PV, "GC / Upvalues")
    local gcTarget = nil
    local gcScroll = New("ScrollingFrame",{Size=UDim2.new(1,0,0,120),BackgroundColor3=T.panel,BorderSizePixel=0,
        ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),Parent=PV})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},gcScroll)
    local upHolder = New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Parent=PV})
    New("UIListLayout",{Padding=UDim.new(0,2)},upHolder)
    local function showUp(f)
        gcTarget = f
        for _, c in ipairs(upHolder:GetChildren()) do if not c:IsA("UIListLayout") then c:Destroy() end end
        Label(upHolder, "Upvalues :")
        for i = 1, 120 do
            local name, val = debug.getupvalue(f, i)
            if not name then break end
            local row = New("Frame",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.elem,Parent=upHolder})
            corner(row,4)
            New("TextLabel",{Size=UDim2.new(0.4,0,1,0),BackgroundTransparency=1,Text=name,TextColor3=T.dim,TextSize=9,
                Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
            local e = New("TextBox",{Size=UDim2.new(0.4,0,1,-6),Position=UDim2.new(0.4,0,0,3),BackgroundColor3=T.panel,
                Text=tostring(val),TextColor3=T.txt,TextSize=9,Font=Enum.Font.Code,ClearTextOnFocus=false,Parent=row})
            local s = New("TextButton",{Size=UDim2.new(0,30,1,-6),Position=UDim2.new(1,-33,0,3),BackgroundColor3=T.acc,
                Text="SET",TextSize=8,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,Active=true,Parent=row})
            s.MouseButton1Click:Connect(function()
                local ok, v = pcall(function() return loadstring("return "..e.Text)() end)
                if ok then pcall(debug.setupvalue, f, i, v); log("upvalue "..name.." modifié", T.ok) end
            end)
        end
    end
    Button(PV, "Scanner getgc", function()
        if not has("getgc") then return log("getgc absent", T.bad) end
        for _, c in ipairs(gcScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        local n = 0
        for _, v in ipairs(getgc(true)) do
            if type(v) == "function" then
                n = n + 1; if n > 120 then break end
                local nm = "?"
                pcall(function() nm = debug.info(v, "n") or "?" end)
                local b = New("TextButton",{Size=UDim2.new(1,0,0,19),BackgroundColor3=T.elem,Text="fn "..nm,
                    TextColor3=T.txt,TextSize=9,Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Left,
                    Active=true,Parent=gcScroll})
                b.MouseButton1Click:Connect(function() showUp(v) end)
            end
        end
        log(n.." fonctions", T.ok)
    end)
    Button(PV, "Espionner la fonction (calls)", function()
        if not gcTarget then return log("sélectionne une fonction", T.warn) end
        local target = gcTarget
        local old
        old = hookfunction(target, function(...)
            local a = table.pack(...)
            local o = {}
            for i = 1, math.min(a.n, 5) do o[i] = ser(a[i]) end
            log("call: "..table.concat(o, ", "))
            return old(...)
        end)
        table.insert(MM.Restore, function() pcall(hookfunction, target, old) end)
        log("spy actif", T.ok)
    end)

    Section(PV, "Connexions de signaux")
    local sigName = Box(PV, "évènement (Changed, AncestryChanged…)", "", nil)
    Button(PV, "Lister les connexions", function()
        if not Selected then return notify("Info","sélectionne une instance",2,T.warn) end
        if not has("getconnections") then return log("getconnections absent", T.bad) end
        local sig = Selected[sigName.Text]
        if not sig then return log("signal introuvable", T.bad) end
        local list = getconnections(sig)
        local h = New("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1,Parent=PV})
        New("UIListLayout",{Padding=UDim.new(0,2)},h)
        for i, c in ipairs(list) do
            local row = New("Frame",{Size=UDim2.new(1,0,0,22),BackgroundColor3=T.elem,Parent=h})
            corner(row,4)
            New("TextLabel",{Size=UDim2.new(0.35,0,1,0),BackgroundTransparency=1,Text="#"..i,TextColor3=T.dim,
                TextSize=9,Font=Enum.Font.Code,Parent=row})
            local f = New("TextButton",{Size=UDim2.new(0,34,1,-4),Position=UDim2.new(0.35,0,0,2),
                BackgroundColor3=T.acc,Text="FIRE",TextSize=8,TextColor3=Color3.new(1,1,1),
                Font=Enum.Font.GothamBold,Active=true,Parent=row})
            f.MouseButton1Click:Connect(function() pcall(function() c:Fire() end) end)
            local d = New("TextButton",{Size=UDim2.new(0,34,1,-4),Position=UDim2.new(0.6,0,0,2),
                BackgroundColor3=T.bad,Text="OFF",TextSize=8,TextColor3=Color3.new(1,1,1),
                Font=Enum.Font.GothamBold,Active=true,Parent=row})
            d.MouseButton1Click:Connect(function() pcall(function() c:Disable() end) end)
            local e2 = New("TextButton",{Size=UDim2.new(0,34,1,-4),Position=UDim2.new(0.8,0,0,2),
                BackgroundColor3=T.ok,Text="ON",TextSize=8,TextColor3=Color3.new(1,1,1),
                Font=Enum.Font.GothamBold,Active=true,Parent=row})
            e2.MouseButton1Click:Connect(function() pcall(function() c:Enable() end) end)
        end
        log(#list.." connexions", T.ok)
    end)
end)

--===========================================================================
--  MONDE
--===========================================================================
local PW = Tab("Monde")
try("monde", function()
    Section(PW, "Propriété réseau")
    Button(PW, "Revendiquer toutes les pièces libres", function()
        local n = 0
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored then
                if pcall(function() v:SetNetworkOwner(LP) end) then n = n + 1 end
            end
        end
        notify("Réseau", n.." pièces", 2, T.ok)
    end)
    Slider(PW, "Rayon de simulation", 100, 10000, 1000, function(v)
        pcall(function()
            if has("setthreadidentity") then setthreadidentity(8) end
            LP.MaximumSimulationRadius = v; LP.SimulationRadius = v
        end)
    end, "simRadius")

    Section(PW, "Désync")
    local dOff = Vector3.new(0,8,0)
    Toggle(PW, "Désync (hitbox décalée)", false, function(on)
        MM.Flags.desync = on
        if on then
            startLoop("desync", "RenderStepped", function()
                local r = hrp(); if r then r.CFrame = r.CFrame + dOff end
            end)
        else stopLoop("desync") end
    end, "desync")
    Slider(PW, "Décalage Y", 0, 40, 8, function(v) dOff = Vector3.new(0,v,0) end, "desyncY")

    Section(PW, "Interactions à distance")
    local function nearest(class)
        local r = hrp(); if not r then return nil end
        local best, bd
        for _, v in ipairs(workspace:GetDescendants()) do
            local p
            if v:IsA(class) then
                if v:IsA("BasePart") then p = v.Position
                elseif v.Parent and v.Parent:IsA("BasePart") then p = v.Parent.Position end
            end
            if p then
                local d = (p - r.Position).Magnitude
                if not bd or d < bd then bd, best = d, v end
            end
        end
        return best
    end
    Button(PW, "Touch le plus proche", function()
        if not has("firetouchinterest") then return log("absent", T.bad) end
        local r = hrp(); local t = nearest("BasePart")
        if r and t then
            firetouchinterest(r, t, 0); task.wait(0.05); firetouchinterest(r, t, 1); log(t:GetFullName(), T.ok)
        end
    end)
    Button(PW, "Click le plus proche", function()
        if not has("fireclickdetector") then return log("absent", T.bad) end
        local t = nearest("ClickDetector")
        if t then fireclickdetector(t); log(t:GetFullName(), T.ok) end
    end)
    Button(PW, "Prompt le plus proche", function()
        if not has("fireproximityprompt") then return log("absent", T.bad) end
        local t = nearest("ProximityPrompt")
        if t then fireproximityprompt(t); log(t:GetFullName(), T.ok) end
    end)
    Button(PW, "Tous les prompts dans 60 studs", function()
        if not has("fireproximityprompt") then return end
        local r = hrp(); if not r then return end
        local n = 0
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart")
                and (v.Parent.Position - r.Position).Magnitude < 60 then
                pcall(fireproximityprompt, v); n = n + 1
            end
        end
        notify("Prompts", n.." déclenchés", 2, T.ok)
    end)

    Section(PW, "Physique")
    Button(PW, "Attirer les pièces libres proches", function()
        local r = hrp(); if not r then return end
        local n = 0
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored and (v.Position - r.Position).Magnitude < 100 then
                pcall(function() v:SetNetworkOwner(LP) end)
                pcall(function() v.CFrame = r.CFrame * CFrame.new(math.random(-6,6), 4, math.random(-6,6)) end)
                n = n + 1
            end
        end
        notify("Bring", n.." pièces", 2, T.ok)
    end)
    Toggle(PW, "Orbit (pièces autour de moi)", false, function(on)
        MM.Flags.orbit = on
        if on then
            startLoop("orbit", "Heartbeat", function()
                local r = hrp(); if not r then return end
                local i = 0
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v.Anchored and (v.Position - r.Position).Magnitude < 80 then
                        i = i + 1
                        local a = os.clock() * 1.5 + i
                        pcall(function()
                            v.CFrame = r.CFrame * CFrame.new(math.cos(a) * 8, 3, math.sin(a) * 8)
                        end)
                    end
                end
            end)
        else stopLoop("orbit") end
    end, "orbit")
    Slider(PW, "Gravité", 0, 400, 196, function(v) workspace.Gravity = v end, "gravity")
    Slider(PW, "Heure du jour", 0, 24, 14, function(v) Lighting.ClockTime = v end, "clocktime")

    Section(PW, "Waypoints & Auto-Farm")
    local wps = {}
    local wpScroll = New("ScrollingFrame",{Size=UDim2.new(1,0,0,80),BackgroundColor3=T.panel,BorderSizePixel=0,
        ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),Parent=PW})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},wpScroll)
    Button(PW, "Ajouter ma position", function()
        local r = hrp(); if not r then return end
        table.insert(wps, r.CFrame)
        New("TextButton",{Size=UDim2.new(1,0,0,17),BackgroundTransparency=1,
            Text=string.format("WP %d (%.0f, %.0f, %.0f)", #wps, r.Position.X, r.Position.Y, r.Position.Z),
            TextColor3=T.dim,TextSize=9,Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Left,
            Active=true,Parent=wpScroll})
    end)
    Button(PW, "Vider", function()
        wps = {}
        for _, c in ipairs(wpScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    end)
    Toggle(PW, "Parcours tween", false, function(on)
        MM.Flags.walk = on
        if on then
            startLoop("walk", "Heartbeat", function()
                if #wps == 0 then return end
                MM.Flags.walkIdx = ((MM.Flags.walkIdx or 0) % #wps) + 1
                local r = hrp()
                if r then pcall(function() r.CFrame = r.CFrame:Lerp(wps[MM.Flags.walkIdx], 0.08) end) end
            end)
        else stopLoop("walk") end
    end, "walkLoop")
    Toggle(PW, "Auto-Farm (pathfinding + prompts)", false, function(on)
        MM.Flags.farm = on
        if not on then return end
        task.spawn(function()
            while MM.Flags.farm do
                local h, r = hum(), hrp()
                if h and r and #wps > 0 then
                    local target = wps[math.random(1, #wps)]
                    local path = Pathfind:CreatePath({AgentRadius=2, AgentHeight=5, AgentCanJump=true})
                    local ok = pcall(function() path:ComputeAsync(r.Position, target.Position) end)
                    if ok and path.Status == Enum.PathStatus.Success then
                        for _, wp in ipairs(path:GetWaypoints()) do
                            if not MM.Flags.farm then break end
                            if wp.Action == Enum.PathWaypointAction.Jump then
                                h:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                            h:MoveTo(wp.Position)
                            local t = 0
                            while MM.Flags.farm and t < 3 do
                                task.wait(0.1); t = t + 0.1
                                if r and (r.Position - wp.Position).Magnitude < 4 then break end
                            end
                        end
                    end
                    if has("fireproximityprompt") then
                        for _, v in ipairs(workspace:GetDescendants()) do
                            if v:IsA("ProximityPrompt") and v.Parent and v.Parent:IsA("BasePart")
                                and (v.Parent.Position - r.Position).Magnitude < 12 then
                                pcall(fireproximityprompt, v)
                            end
                        end
                    end
                end
                task.wait(0.4)
            end
        end)
    end, "farm")
end)

--===========================================================================
--  COMBAT
--===========================================================================
local PX = Tab("Combat")
try("combat", function()
    local aim = {on=false, fov=150, smooth=0.22, part="Head", pred=0, team=false, walls=false}
    local aimTarget = nil
    fovC = nil
    if Drawing then pcall(function() fovC = Drawing.new("Circle") end) end
    if fovC then fovC.Thickness = 1.5; fovC.Color = T.acc; fovC.Visible = false end

    local function getTarget()
        local c, me = cam(), hrp()
        if not c or not me then return nil end
        local best, bd
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= LP then
                local ch = pl.Character
                local h = ch and ch:FindFirstChildOfClass("Humanoid")
                local root = ch and ch:FindFirstChild("HumanoidRootPart")
                if h and root and h.Health > 0 and (not aim.team or pl.Team ~= LP.Team) then
                    local part = ch:FindFirstChild(aim.part) or root
                    local p = part.Position + part.AssemblyLinearVelocity * aim.pred
                    local sp, vis = c:WorldToViewportPoint(p)
                    if vis and sp.Z > 0 then
                        local d = (Vector2.new(sp.X, sp.Y) - c.ViewportSize / 2).Magnitude
                        if d <= aim.fov then
                            local okVis = true
                            if aim.walls then
                                local params = RaycastParams.new()
                                params.FilterDescendantsInstances = {char(), ch}
                                params.FilterType = Enum.RaycastFilterType.Exclude
                                okVis = (workspace:Raycast(c.CFrame.Position, p - c.CFrame.Position, params) == nil)
                            end
                            if okVis then
                                local dist = (p - c.CFrame.Position).Magnitude
                                if not bd or dist < bd then bd, best = dist, {pos=p, part=part} end
                            end
                        end
                    end
                end
            end
        end
        return best
    end
    bind(RunService.RenderStepped:Connect(function()
        if fovC then
            fovC.Visible = aim.on
            if aim.on then
                fovC.Position = cam().ViewportSize / 2
                fovC.Radius = aim.fov
            end
        end
        if not aim.on then return end
        local t = getTarget(); aimTarget = t
        if t then
            local c = cam()
            c.CFrame = c.CFrame:Lerp(CFrame.new(c.CFrame.Position, t.pos), aim.smooth)
        end
    end))
    Section(PX, "Aimbot caméra")
    Toggle(PX, "Activer", false, function(v) aim.on = v end, "aimOn")
    Slider(PX, "FOV", 20, 500, 150, function(v) aim.fov = v end, "aimFov")
    Slider(PX, "Lissage", 0.05, 1, 0.22, function(v) aim.smooth = v end, "aimSmooth")
    Slider(PX, "Prédiction", 0, 1, 0, function(v) aim.pred = v end, "aimPred")
    Dropdown(PX, "Partie", {"Head","HumanoidRootPart","UpperTorso","Torso"}, function(v) aim.part = v end)
    Toggle(PX, "Vérif. équipe", false, function(v) aim.team = v end, "aimTeam")
    Toggle(PX, "Ligne de vue (anti-mur)", false, function(v) aim.walls = v end, "aimWalls")

    Section(PX, "Silent Aim (hook à la demande)")
    local silent = false
    local silentHook = nil
    local function silentInstall()
        if silentHook or not has("hookmetamethod") then return end
        local old
        old = hookmetamethod(game, "__index", function(self, key)
            if silent and not checkcaller() and typeof(self)=="Instance" and self:IsA("Mouse") then
                local t = aimTarget
                if t then
                    if key == "Hit" then return CFrame.new(t.pos) end
                    if key == "Target" then return t.part end
                    if key == "UnitRay" then
                        return Ray.new(cam().CFrame.Position, (t.pos - cam().CFrame.Position).Unit)
                    end
                end
            end
            return old(self, key)
        end)
        silentHook = function() pcall(hookmetamethod, game, "__index", old) end
        table.insert(MM.Restore, silentHook)
    end
    local function silentRemove()
        if silentHook then silentHook(); silentHook = nil end
    end
    Toggle(PX, "Activer", false, function(v)
        silent = v
        if v then silentInstall() else silentRemove() end
        notify("Silent Aim", v and "ON" or "OFF", 2, v and T.ok or T.warn)
    end, "silent")

    Section(PX, "TriggerBot / Hitbox / Attaque")
    Toggle(PX, "TriggerBot", false, function(v)
        MM.Flags.trigger = v
        if v then
            startLoop("trigger", "RenderStepped", function()
                local t = aimTarget; if not t then return end
                local sp, vis = cam():WorldToViewportPoint(t.pos)
                if vis and (Vector2.new(sp.X,sp.Y) - UIS:GetMouseLocation()).Magnitude < 45 then
                    if has("mouse1click") then pcall(mouse1click) end
                end
            end)
        else stopLoop("trigger") end
    end, "trigger")

    local hbSize = 12
    local hbOrig = {}
    Toggle(PX, "Hitbox Expander", false, function(on)
        MM.Flags.hitbox = on
        if on then
            startLoop("hitbox", "Heartbeat", function()
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LP then
                        local r = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            if not hbOrig[r] then hbOrig[r] = {s=r.Size, t=r.Transparency} end
                            r.Size = Vector3.new(hbSize, hbSize, hbSize)
                            r.CanCollide = false
                            r.Transparency = 0.6
                        end
                    end
                end
            end)
        else
            stopLoop("hitbox")
            for p, d in next, hbOrig do pcall(function() p.Size = d.s; p.Transparency = d.t end) end
            hbOrig = {}
        end
    end, "hitbox")
    Slider(PX, "Taille hitbox", 4, 40, 12, function(v) hbSize = v end, "hitboxSize")

    Toggle(PX, "Fast Attack", false, function(on)
        MM.Flags.fast = on
        if on then
            startLoop("fast", "Heartbeat", function()
                local h = hum()
                local an = h and h:FindFirstChildOfClass("Animator")
                if an then
                    for _, tr in ipairs(an:GetPlayingAnimationTracks()) do tr.Speed = 3 end
                end
            end)
        else stopLoop("fast") end
    end, "fastAttack")
end)

--===========================================================================
--  VISUELS
--===========================================================================
local PV2 = Tab("Visuels")
try("visuels", function()
    local esp = {box=false, skel=false, tracer=false, health=false, name=false, dist=false, chams=false, dot=false}
    local function mk(pl, kind, cls)
        espCache[pl] = espCache[pl] or {}
        if not espCache[pl][kind] then
            espCache[pl][kind] = Drawing.new(cls)
            espCache[pl][kind].Thickness = 1
        end
        return espCache[pl][kind]
    end
    if Drawing then
        bind(RunService.RenderStepped:Connect(function()
            local any = esp.box or esp.skel or esp.tracer or esp.health or esp.name or esp.dist or esp.dot or esp.chams
            if not any then
                if next(espCache) or next(chamCache) then clearESP() end
                return
            end
            local c = cam()
            local myPos = hrp() and hrp().Position
            local n = 0
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP then
                    n = n + 1
                    local ch = pl.Character
                    local h = ch and ch:FindFirstChildOfClass("Humanoid")
                    local root = ch and ch:FindFirstChild("HumanoidRootPart")
                    local head = ch and ch:FindFirstChild("Head")
                    if h and root and head and h.Health > 0 and n < 35 then
                        local col = (pl.Team and pl.Team.TeamColor.Color) or T.bad
                        local hp, hv = c:WorldToViewportPoint(head.Position + Vector3.new(0,0.6,0))
                        local fp, fv = c:WorldToViewportPoint(root.Position - Vector3.new(0,3,0))
                        local vis = hv and fv and hp.Z > 0 and fp.Z > 0
                        local hgt = fp.Y - hp.Y
                        local wid = hgt * 0.45
                        if esp.box then
                            local b = mk(pl,"box","Square")
                            b.Visible = vis; b.Size = Vector2.new(wid,hgt)
                            b.Position = Vector2.new(hp.X - wid / 2, hp.Y); b.Color = col
                        end
                        if esp.dot then
                            local d = mk(pl,"dot","Circle")
                            d.Visible = vis; d.Position = Vector2.new(hp.X,hp.Y); d.Radius = 3
                            d.Color = col; d.Filled = true
                        end
                        if esp.name then
                            local t = mk(pl,"name","Text")
                            t.Visible = vis; t.Text = pl.Name; t.Position = Vector2.new(hp.X, hp.Y - 14)
                            t.Center = true; t.Size = 13; t.Color = col; t.Outline = true
                        end
                        if esp.dist and myPos then
                            local t = mk(pl,"dist","Text")
                            t.Visible = vis; t.Text = math.floor((root.Position - myPos).Magnitude).."m"
                            t.Position = Vector2.new(hp.X, fp.Y + 2); t.Center = true; t.Size = 12
                            t.Color = Color3.new(1,1,1); t.Outline = true
                        end
                        if esp.health then
                            local bar = mk(pl,"hp","Square")
                            bar.Visible = vis; bar.Filled = true; bar.Color = Color3.fromRGB(70,220,110)
                            local ratio = h.Health / math.max(h.MaxHealth, 1)
                            bar.Size = Vector2.new(3, hgt * ratio)
                            bar.Position = Vector2.new(hp.X - wid / 2 - 6, fp.Y - hgt * ratio)
                        end
                        if esp.tracer then
                            local l = mk(pl,"tracer","Line")
                            l.Visible = vis; l.From = Vector2.new(c.ViewportSize.X / 2, c.ViewportSize.Y)
                            l.To = Vector2.new(hp.X, fp.Y); l.Color = col
                        end
                        if esp.skel then
                            local i = 0
                            for _, j in ipairs(ch:GetDescendants()) do
                                if j:IsA("Motor6D") and j.Part0 and j.Part1 then
                                    local a, av = c:WorldToViewportPoint(j.Part0.Position)
                                    local b2, bv = c:WorldToViewportPoint(j.Part1.Position)
                                    if av and bv and a.Z > 0 and b2.Z > 0 then
                                        i = i + 1
                                        local l = mk(pl,"sk"..i,"Line")
                                        l.Visible = true; l.From = Vector2.new(a.X,a.Y)
                                        l.To = Vector2.new(b2.X,b2.Y); l.Color = col
                                    end
                                end
                            end
                        end
                        if esp.chams then
                            local hl = chamCache[pl]
                            if not hl or not hl.Parent then
                                hl = New("Highlight",{Parent=workspace})
                                hl.FillColor = col; hl.FillTransparency = 0.55
                                hl.OutlineColor = col; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                chamCache[pl] = hl
                            end
                            hl.Adornee = ch
                        end
                    else
                        for _, t in next, (espCache[pl] or {}) do t.Visible = false end
                        if chamCache[pl] then chamCache[pl]:Destroy(); chamCache[pl] = nil end
                    end
                end
            end
        end))
    end
    Section(PV2, "ESP joueurs")
    Toggle(PV2, "Box", false, function(v) esp.box = v end, "espBox")
    Toggle(PV2, "Skeleton", false, function(v) esp.skel = v end, "espSkel")
    Toggle(PV2, "Tracers", false, function(v) esp.tracer = v end, "espTracer")
    Toggle(PV2, "Barres de vie", false, function(v) esp.health = v end, "espHp")
    Toggle(PV2, "Noms", false, function(v) esp.name = v end, "espName")
    Toggle(PV2, "Distance", false, function(v) esp.dist = v end, "espDist")
    Toggle(PV2, "Head dots", false, function(v) esp.dot = v end, "espDot")
    Toggle(PV2, "Chams", false, function(v) esp.chams = v end, "espChams")

    Section(PV2, "ESP objets / PNJ")
    Toggle(PV2, "Activer", false, function(on)
        MM.Flags.item = on
        if on then
            task.spawn(function()
                while MM.Flags.item do
                    for _, d in next, itemCache do pcall(function() d:Remove() end) end
                    itemCache = {}
                    local c = cam()
                    local count = 0
                    for _, v in ipairs(workspace:GetDescendants()) do
                        if count > 90 then break end
                        local nm = v.Name:lower()
                        local match = v:IsA("ProximityPrompt") or (v:IsA("BasePart")
                            and (nm:find("chest") or nm:find("coin") or nm:find("item")
                            or nm:find("crate") or nm:find("npc")))
                        if match then
                            local p = v:IsA("BasePart") and v.Position
                                or (v.Parent and v.Parent:IsA("BasePart") and v.Parent.Position)
                            if p then
                                local sp, vis = c:WorldToViewportPoint(p)
                                if vis and sp.Z > 0 then
                                    local t = Drawing.new("Text")
                                    t.Text = v.Name; t.Size = 12; t.Center = true
                                    t.Color = Color3.fromRGB(255,220,90); t.Outline = true
                                    t.Position = Vector2.new(sp.X, sp.Y)
                                    table.insert(itemCache, t); count = count + 1
                                end
                            end
                        end
                    end
                    task.wait(0.6)
                end
                for _, d in next, itemCache do pcall(function() d:Remove() end) end
                itemCache = {}
            end)
        end
    end, "itemEsp")

    Section(PV2, "Freecam")
    local fc = {on=false, speed=60, cf=nil, yaw=0, pitch=0}
    Toggle(PV2, "Activer", false, function(on)
        fc.on = on
        if on then
            fc.cf = cam().CFrame
            cam().CameraType = Enum.CameraType.Scriptable
            local y, p = fc.cf:ToEulerAnglesYXZ()
            fc.yaw, fc.pitch = y, p
            bind(UIS.InputChanged:Connect(function(i)
                if not fc.on or UIS:GetFocusedTextBox() then return end
                if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement then
                    fc.yaw = fc.yaw - i.Delta.X * 0.004
                    fc.pitch = math.clamp(fc.pitch - i.Delta.Y * 0.004, -1.5, 1.5)
                end
            end))
            startLoop("freecam", "RenderStepped", function()
                local rot = CFrame.fromEulerAnglesYXZ(fc.pitch, fc.yaw, 0)
                local h = hum()
                local dir = h and rot:VectorToWorldSpace(h.MoveDirection) or Vector3.zero
                fc.cf = CFrame.new(fc.cf.Position + dir * (fc.speed / 60)) * rot
                cam().CFrame = fc.cf
            end)
        else
            stopLoop("freecam")
            pcall(function() cam().CameraType = Enum.CameraType.Custom end)
        end
    end, "freecam")
    Slider(PV2, "Vitesse", 10, 300, 60, function(v) fc.speed = v end, "freecamSpeed")

    Section(PV2, "Monde")
    local lSave
    Toggle(PV2, "Fullbright", false, function(on)
        if on then
            lSave = {Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient, Lighting.ClockTime,
                     Lighting.GlobalShadows, Lighting.FogEnd}
            Lighting.Brightness = 3
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.OutdoorAmbient = Color3.new(1,1,1)
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e6
        elseif lSave then
            Lighting.Brightness = lSave[1]
            Lighting.Ambient = lSave[2]
            Lighting.OutdoorAmbient = lSave[3]
            Lighting.ClockTime = lSave[4]
            Lighting.GlobalShadows = lSave[5]
            Lighting.FogEnd = lSave[6]
        end
    end, "fullbright")
    Toggle(PV2, "No Fog", false, function(on) Lighting.FogEnd = on and 1e6 or 1000 end, "nofog")
    Slider(PV2, "FOV", 40, 120, 70, function(v) if cam() then cam().FieldOfView = v end end, "fov")
    local xray = {}
    Toggle(PV2, "X-Ray", false, function(on)
        if on then
            local myChar = char()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency == 0 and (not myChar or not v:IsDescendantOf(myChar)) then
                    xray[v] = v.Transparency; v.Transparency = 0.7
                end
            end
        else
            for p, t in next, xray do pcall(function() p.Transparency = t end) end
            xray = {}
        end
    end, "xray")
    if Drawing then
        pcall(function() ch1 = Drawing.new("Line"); ch2 = Drawing.new("Line") end)
    end
    if ch1 then
        ch1.Color = Color3.new(1,1,1); ch2.Color = Color3.new(1,1,1)
        ch1.Thickness = 1; ch2.Thickness = 1
    end
    Toggle(PV2, "Crosshair", false, function(on)
        if not ch1 then return end
        ch1.Visible = on; ch2.Visible = on
        if on then
            startLoop("cross", "RenderStepped", function()
                local vs = cam().ViewportSize
                ch1.From = Vector2.new(vs.X / 2 - 8, vs.Y / 2); ch1.To = Vector2.new(vs.X / 2 + 8, vs.Y / 2)
                ch2.From = Vector2.new(vs.X / 2, vs.Y / 2 - 8); ch2.To = Vector2.new(vs.X / 2, vs.Y / 2 + 8)
            end)
        else stopLoop("cross") end
    end, "crosshair")

    Section(PV2, "HUD de stats")
    if Drawing then pcall(function() hud = Drawing.new("Text") end) end
    if hud then
        hud.Size = 13; hud.Color = Color3.new(1,1,1); hud.Outline = true
        hud.Position = Vector2.new(10, 10); hud.Visible = false
    end
    Toggle(PV2, "Afficher FPS / ping / position", false, function(on)
        if not hud then return end
        hud.Visible = on
        if on then
            local frames, last = 0, os.clock()
            startLoop("hud", "RenderStepped", function()
                frames = frames + 1
                local now = os.clock()
                if now - last >= 0.5 then
                    local fps = math.floor(frames / (now - last))
                    frames, last = 0, now
                    local ping = "?"
                    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                    local r = hrp()
                    local pos = r and string.format("%.0f %.0f %.0f", r.Position.X, r.Position.Y, r.Position.Z) or "?"
                    hud.Text = string.format("FPS %d | Ping %s | %s", fps, ping, pos)
                end
            end)
        else stopLoop("hud") end
    end, "hud")
end)

--===========================================================================
--  MOUVEMENT
--===========================================================================
local PM = Tab("Mouvement")
try("mouvement", function()
    Section(PM, "Base")
    Slider(PM, "WalkSpeed", 8, 500, 16, function(v) local h = hum(); if h then h.WalkSpeed = v end end, "walkSpeed")
    Slider(PM, "JumpPower", 20, 500, 50, function(v)
        local h = hum(); if h then h.UseJumpPower = true; h.JumpPower = v end
    end, "jumpPower")
    onCharacter("speedApply", function()
        task.wait(1)
        local h = hum()
        if h and MM.Config.walkSpeed then h.WalkSpeed = MM.Config.walkSpeed end
        if h and MM.Config.jumpPower then h.UseJumpPower = true; h.JumpPower = MM.Config.jumpPower end
    end)
    Toggle(PM, "Bhop", false, function(on)
        MM.Flags.bhop = on
        if on then
            startLoop("bhop", "Heartbeat", function()
                local h = hum()
                if h and h:GetState() ~= Enum.HumanoidStateType.Jumping then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else stopLoop("bhop") end
    end, "bhop")

    Section(PM, "Vol")
    local fly = {on=false, speed=60, up=0}
    local flyVel
    Toggle(PM, "Fly", false, function(on)
        fly.on = on
        local r, h = hrp(), hum()
        if on and r then
            flyVel = Instance.new("BodyVelocity")
            flyVel.MaxForce = Vector3.new(1e5,1e5,1e5); flyVel.Velocity = Vector3.zero; flyVel.Parent = r
            if h then h.PlatformStand = true end
            startLoop("fly", "RenderStepped", function()
                if not flyVel or not flyVel.Parent then return end
                local hh = hum()
                local dir = hh and hh.MoveDirection or Vector3.zero
                flyVel.Velocity = cam().CFrame:VectorToWorldSpace(Vector3.new(dir.X,0,dir.Z)) * fly.speed
                    + Vector3.new(0, fly.up * fly.speed, 0)
            end)
        else
            stopLoop("fly")
            if flyVel then flyVel:Destroy(); flyVel = nil end
            if h then h.PlatformStand = false end
        end
    end, "fly")
    Slider(PM, "Vitesse vol", 10, 400, 60, function(v) fly.speed = v end, "flySpeed")
    Button(PM, "Monter", function() fly.up = 1; task.delay(0.7, function() fly.up = 0 end) end)
    Button(PM, "Descendre", function() fly.up = -1; task.delay(0.7, function() fly.up = 0 end) end)

    Section(PM, "Collisions")
    Toggle(PM, "NoClip", false, function(on)
        MM.Flags.noclip = on
        if on then
            startLoop("noclip", "Stepped", function()
                local c = char()
                if c then
                    for _, v in ipairs(c:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        else stopLoop("noclip") end
    end, "noclip")
    Toggle(PM, "Infinite Jump", false, function(on)
        MM.Flags.ij = on
        if on then
            bind(UIS.JumpRequest:Connect(function()
                local h = hum()
                if MM.Flags.ij and h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end))
        end
    end, "infJump")
    Toggle(PM, "AirWalk", false, function(on)
        MM.Flags.aw = on
        if on then
            local plat
            startLoop("airwalk", "Heartbeat", function()
                local r, h = hrp(), hum()
                if not r or not h then return end
                if h:GetState() == Enum.HumanoidStateType.Freefall then
                    if not plat or not plat.Parent then
                        plat = Instance.new("Part")
                        plat.Size = Vector3.new(8,1,8); plat.Anchored = true
                        plat.Transparency = 0.6; plat.CanCollide = true; plat.Parent = workspace
                    end
                    plat.CFrame = r.CFrame * CFrame.new(0,-3.2,0)
                elseif plat then
                    plat:Destroy(); plat = nil
                end
            end)
        else
            stopLoop("airwalk")
        end
    end, "airwalk")
    Toggle(PM, "Spider", false, function(on)
        MM.Flags.spider = on
        if on then
            startLoop("spider", "Heartbeat", function()
                local r = hrp(); if not r then return end
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {char()}
                if workspace:Raycast(r.Position, r.CFrame.LookVector * 3, params) then
                    r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 40, r.AssemblyLinearVelocity.Z)
                end
            end)
        else stopLoop("spider") end
    end, "spider")

    Section(PM, "Stabilité")
    Toggle(PM, "Fling", false, function(on)
        MM.Flags.fling = on
        if on then
            onCharacter("fling", function(c)
                local r = c:WaitForChild("HumanoidRootPart", 10)
                if not r then return end
                r.Touched:Connect(function(hit)
                    if not MM.Flags.fling then return end
                    local model = hit:FindFirstAncestorOfClass("Model")
                    if model and model ~= c and model:FindFirstChildOfClass("Humanoid") then
                        local t = model:FindFirstChild("HumanoidRootPart")
                        if t then t.AssemblyAngularVelocity = Vector3.new(0, 1e5, 0) end
                    end
                end)
            end)
        end
    end, "fling")
    Toggle(PM, "Anti-Fling", false, function(on)
        MM.Flags.af = on
        if on then
            startLoop("antifling", "Heartbeat", function()
                local r = hrp()
                if r then
                    local v = r.AssemblyLinearVelocity
                    if v.Magnitude > 200 then r.AssemblyLinearVelocity = v.Unit * 120 end
                end
            end)
        else stopLoop("antifling") end
    end, "antifling")
    Toggle(PM, "Anti-Ragdoll / State Disabler", false, function(on)
        MM.Flags.ar = on
        if on then
            startLoop("antirag", "Heartbeat", function()
                local h = hum()
                if h then
                    local s = h:GetState()
                    if s == Enum.HumanoidStateType.Ragdoll or s == Enum.HumanoidStateType.FallingDown
                        or s == Enum.HumanoidStateType.PlatformStanding then
                        h:ChangeState(Enum.HumanoidStateType.Running)
                    end
                end
            end)
        else stopLoop("antirag") end
    end, "antirag")
    Toggle(PM, "Anti-Void", false, function(on)
        MM.Flags.av = on
        if on then
            startLoop("antivoid", "Heartbeat", function()
                local r = hrp()
                if r and r.Position.Y < -60 then
                    r.CFrame = CFrame.new(0, 50, 0); r.AssemblyLinearVelocity = Vector3.zero
                end
            end)
        else stopLoop("antivoid") end
    end, "antivoid")
end)

--===========================================================================
--  OUTILS
--===========================================================================
local PO = Tab("Outils")
try("outils", function()
    Section(PO, "Personnage")
    Slider(PO, "HipHeight", 0, 20, 2, function(v) local h = hum(); if h then h.HipHeight = v end end, "hipHeight")
    Button(PO, "Soigner (MaxHealth)", function()
        local h = hum(); if h then h.MaxHealth = math.huge; h.Health = math.huge end
    end)
    Button(PO, "Régénérer", function() local h = hum(); if h then h.Health = 0 end end)
    Slider(PO, "Échelle du modèle", 0.5, 4, 1, function(v)
        local h = hum()
        if h then
            h.BodyDepthScale = v; h.BodyWidthScale = v; h.BodyHeightScale = v; h.HeadScale = v
        end
    end, "scale")

    Section(PO, "Téléportation")
    local tpMode = false
    Toggle(PO, "Outil TP (tap sur la carte)", false, function(on)
        tpMode = on
        if not on then return end
        bind(UIS.TouchTap:Connect(function(pos)
            if not tpMode then return end
            local r = hrp(); if not r then return end
            local ray = cam():ViewportPointToRay(pos.X, pos.Y)
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char()}
            local hit = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
            if hit then
                r.CFrame = CFrame.new(hit.Position + Vector3.new(0,3,0))
                log(string.format("tp %.0f %.0f %.0f", hit.Position.X, hit.Position.Y, hit.Position.Z), T.ok)
            end
        end))
    end, "tpTool")

    Section(PO, "Joueurs")
    local plScroll = New("ScrollingFrame",{Size=UDim2.new(1,0,0,150),BackgroundColor3=T.panel,BorderSizePixel=0,
        ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),Parent=PO})
    New("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},plScroll)
    bind(task.spawn(function()
        while true do
            task.wait(2)
            for _, c in ipairs(plScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LP then
                    local row = New("Frame",{Size=UDim2.new(1,0,0,21),BackgroundColor3=T.elem,Parent=plScroll})
                    corner(row,4)
                    New("TextLabel",{Size=UDim2.new(1,-76,1,0),Position=UDim2.new(0,6,0,0),
                        BackgroundTransparency=1,Text=pl.Name,TextColor3=T.txt,TextSize=9,Font=Enum.Font.Code,
                        TextXAlignment=Enum.TextXAlignment.Left,Parent=row})
                    local tp = New("TextButton",{Size=UDim2.new(0,32,1,-4),Position=UDim2.new(1,-70,0,2),
                        BackgroundColor3=T.acc,Text="TP",TextSize=8,TextColor3=Color3.new(1,1,1),
                        Font=Enum.Font.GothamBold,Active=true,Parent=row})
                    tp.MouseButton1Click:Connect(function()
                        local r = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                        local me = hrp()
                        if r and me then me.CFrame = r.CFrame * CFrame.new(0,0,3) end
                    end)
                    local sp = New("TextButton",{Size=UDim2.new(0,32,1,-4),Position=UDim2.new(1,-35,0,2),
                        BackgroundColor3=T.ok,Text="SPEC",TextSize=7,TextColor3=Color3.new(1,1,1),
                        Font=Enum.Font.GothamBold,Active=true,Parent=row})
                    sp.MouseButton1Click:Connect(function()
                        local r = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            cam().CameraSubject = r
                            cam().CameraType = Enum.CameraType.Custom
                        end
                    end)
                end
            end
        end
    end))

    Section(PO, "Animations & sons")
    local animBox = Box(PO, "ID d'animation", "", nil)
    Button(PO, "Jouer l'animation", function()
        local h = hum(); local an = h and h:FindFirstChildOfClass("Animator")
        if not an then return end
        local a = Instance.new("Animation"); a.AnimationId = animBox.Text
        an:LoadAnimation(a):Play()
    end)
    local sndBox = Box(PO, "ID de son", "", nil)
    Button(PO, "Jouer le son", function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://" .. (sndBox.Text:gsub("%D",""))
        s.Volume = 2; s.Parent = workspace; s:Play()
    end)

    Section(PO, "Chat")
    local chatBox = Box(PO, "message", "", nil)
    local function say(m)
        local ev = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if ev and ev:FindFirstChild("SayMessageRequest") then
            ev.SayMessageRequest:FireServer(m, "All")
            return true
        end
        return false
    end
    Button(PO, "Envoyer", function() if not say(chatBox.Text) then log("chat incompatible", T.warn) end end)
    Toggle(PO, "Chat spam", false, function(on)
        if on then
            startLoop("spam", "Heartbeat", function()
                if chatBox.Text ~= "" then
                    say(chatBox.Text)
                    task.wait(2)
                end
            end)
        else stopLoop("spam") end
    end, "spam")

    Section(PO, "Serveur & divers")
    Slider(PO, "Limite FPS", 30, 240, 60, function(v) if has("setfpscap") then pcall(setfpscap, v) end end, "fps")
    Toggle(PO, "Anti-AFK", true, function(on) MM.Flags.afk = on end, "antiafk")
    bind(LP.Idled:Connect(function()
        if MM.Flags.afk then VUser:CaptureController(); VUser:ClickButton2(Vector2.new()) end
    end))
    Button(PO, "Rejoindre le serveur", function() Teleport:Teleport(game.PlaceId, LP) end)
    Button(PO, "Server Hop", function()
        local ok, res = pcall(function()
            return Http:JSONDecode(game:HttpGet(
                ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId)))
        end)
        if ok and res and res.data then
            for _, s in ipairs(res.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    pcall(Teleport.TeleportToPlaceInstance, Teleport, game.PlaceId, s.id, LP); return
                end
            end
        end
        notify("Hop", "aucun serveur", 2, T.warn)
    end)
    Button(PO, "Copier PlaceId / JobId", function()
        local s = ("PlaceId=%d JobId=%s"):format(game.PlaceId, game.JobId)
        setclipboard(s); notify("Copié", s, 2)
    end)
end)

--===========================================================================
--  CONFIG
--===========================================================================
local PK = Tab("Config")
try("config", function()
    Section(PK, "Keybinds (clavier)")
    local keys = {}
    for k in next, MM.Setters do table.insert(keys, k) end
    table.sort(keys)
    local bindKey = Dropdown(PK, "Fonction", keys, function() end)
    Button(PK, "Assigner une touche", function()
        notify("Keybind", "appuie sur une touche…", 4)
        local c
        c = UIS.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                MM.Flags.binding = i.KeyCode
                c:Disconnect()
                notify("Keybind", bindKey.Text.." = "..i.KeyCode.Name, 3, T.ok)
            end
        end)
    end)
    bind(UIS.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if MM.Flags.binding == i.KeyCode then
            local f = MM.Binds[bindKey.Text]
            if f then f(not MM.Config[bindKey.Text]) end
        end
    end))
    Section(PK, "Sauvegarde")
    Button(PK, "Sauvegarder", function()
        if not has("writefile") then return log("writefile absent", T.bad) end
        writefile("DUMM_config.json", Http:JSONEncode(MM.Config))
        notify("Config", "sauvegardée", 2, T.ok)
    end)
    Button(PK, "Charger", function()
        if not has("isfile") or not isfile("DUMM_config.json") then return log("aucune config", T.warn) end
        local ok, data = pcall(function() return Http:JSONDecode(readfile("DUMM_config.json")) end)
        if not ok then return end
        for k, v in next, data do if MM.Setters[k] then pcall(MM.Setters[k], v) end end
        notify("Config", "chargée", 2, T.ok)
    end)
    Section(PK, "Déchargement")
    Button(PK, "Tout désactiver", function()
        for k, v in next, MM.Config do
            if type(v) == "boolean" and v and MM.Setters[k] then pcall(MM.Setters[k], false) end
        end
        notify("Reset", "features coupées", 2, T.warn)
    end)
    Button(PK, "Décharger le menu", function() pcall(MM.Unload) end, T.bad)
end)

--===========================================================================
--  FINALISATION
--===========================================================================
function MM.Unload()
    if MM.Unloaded then return end
    MM.Unloaded = true
    for _, f in ipairs(MM.Restore) do pcall(f) end
    for _, c in ipairs(MM.Connections) do pcall(function() c:Disconnect() end) end
    clearESP()
    for _, d in next, itemCache do pcall(function() d:Remove() end) end
    if fovC then pcall(function() fovC:Remove() end) end
    if ch1 then pcall(function() ch1:Remove(); ch2:Remove() end) end
    if hud then pcall(function() hud:Remove() end) end
    pcall(function() Lighting.Brightness = 2; Lighting.FogEnd = 1000 end)
    pcall(function() if cam() then cam().CameraType = Enum.CameraType.Custom end end)
    pcall(function() SG:Destroy() end)
    getgenv().DUMM = nil
end

if #Pages > 0 then
    Pages[1].Visible = true
    TabBtns[1].TextColor3 = T.acc
    TabBtns[1].BackgroundColor3 = T.panel
end
setOpen(false)

if #MM.Fails > 0 then
    local box = New("TextLabel",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        Position=UDim2.new(0,8,0,70),BackgroundColor3=T.bad,BackgroundTransparency=0.85,TextColor3=Color3.new(1,1,1),
        TextSize=9,Font=Enum.Font.Code,TextWrapped=true,ZIndex=15,Parent=Win})
    box.Text = "Blocs en échec :\n"..table.concat(MM.Fails, "\n")
    corner(box,6)
end

task.spawn(function()
    for _, f in ipairs(MM.Fails) do log(f, T.bad) end
    log("Menu chargé — "..#Pages.." onglets, "..#MM.Fails.." échec(s)", #MM.Fails > 0 and T.warn or T.ok)
    notify("Delta Ultimate v2.3", "rond bleu = ouvrir · glisse pour déplacer", 4, T.ok)
end)
