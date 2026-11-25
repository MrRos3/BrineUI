-- Headless Roblox GUI boundary: executes the real BrineUI bundle, lays the
-- instance tree out (UDim2, AnchorPoint, AutomaticSize, UIListLayout, UIPadding)
-- and prints JSON for scripts/render.mjs. Approximate: not the Roblox renderer.
local realTypeof = typeof
local function class(name, index)
	return { __type = name, __index = index or {} }
end
function typeof(v)
	local mt = type(v) == "table" and getmetatable(v)
	if type(mt) == "table" and rawget(mt, "__type") then
		return mt.__type
	end
	return realTypeof(v)
end

-- Datatypes ---------------------------------------------------------------
local V2 = class("Vector2")
V2.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
V2.__add = function(a, b) return Vector2.new(a.X + b.X, a.Y + b.Y) end
V2.__sub = function(a, b) return Vector2.new(a.X - b.X, a.Y - b.Y) end
V2.__mul = function(a, b) return Vector2.new(a.X * b, a.Y * b) end
V2.__div = function(a, b) return Vector2.new(a.X / b, a.Y / b) end
Vector2 = { new = function(x, y) return setmetatable({ X = x or 0, Y = y or 0 }, V2) end }
Vector2.zero = Vector2.new(0, 0)
local V3 = class("Vector3")
V3.__add = function(a, b) return Vector3.new(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
V3.__sub = function(a, b) return Vector3.new(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
V3.__mul = function(a, b) return Vector3.new(a.X * b, a.Y * b, a.Z * b) end
V3.__div = function(a, b) return Vector3.new(a.X / b, a.Y / b, a.Z / b) end
V3.__index = function(v, k) return k == "Magnitude" and math.sqrt(v.X ^ 2 + v.Y ^ 2 + v.Z ^ 2) or nil end
Vector3 = { new = function(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, V3) end }
Vector3.zero = Vector3.new()
CFrame = { new = function() return { XVector = Vector3.new(1), YVector = Vector3.new(0, 1), ZVector = Vector3.new(0, 0, 1) } end }
CFrame.fromMatrix = CFrame.new
local UD = class("UDim")
UD.__eq = function(a, b) return a.Scale == b.Scale and a.Offset == b.Offset end
UDim = { new = function(s, o) return setmetatable({ Scale = s or 0, Offset = o or 0 }, UD) end }
local UD2 = class("UDim2")
UD2.__eq = function(a, b) return a.X == b.X and a.Y == b.Y end
UDim2 = {
	new = function(a, b, c, d)
		if type(a) == "table" then
			return setmetatable({ X = a, Y = b }, UD2)
		end
		return setmetatable({ X = UDim.new(a, b), Y = UDim.new(c, d) }, UD2)
	end,
}
UDim2.fromOffset = function(x, y) return UDim2.new(0, x, 0, y) end
UDim2.fromScale = function(x, y) return UDim2.new(x, 0, y, 0) end
local C3 = class("Color3", {})
C3.__eq = function(a, b) return a.R == b.R and a.G == b.G and a.B == b.B end
Color3 = { new = function(r, g, b) return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, C3) end }
Color3.fromRGB = function(r, g, b) return Color3.new(r / 255, g / 255, b / 255) end
Color3.fromHex = function(h)
	h = string.gsub(h, "#", "")
	return Color3.fromRGB(tonumber(h:sub(1, 2), 16), tonumber(h:sub(3, 4), 16), tonumber(h:sub(5, 6), 16))
end
Color3.fromHSV = function(h, s, v)
	local i = math.floor(h * 6)
	local f = h * 6 - i
	local p, q, t = v * (1 - s), v * (1 - f * s), v * (1 - (1 - f) * s)
	local m = ({ { v, t, p }, { q, v, p }, { p, v, t }, { p, q, v }, { t, p, v }, { v, p, q } })[i % 6 + 1]
	return Color3.new(m[1], m[2], m[3])
end
C3.__index.ToHSV = function(c)
	local mx, mn = math.max(c.R, c.G, c.B), math.min(c.R, c.G, c.B)
	local d, h = mx - mn, 0
	if d > 0 then
		h = mx == c.R and ((c.G - c.B) / d) % 6 or mx == c.G and (c.B - c.R) / d + 2 or (c.R - c.G) / d + 4
	end
	return h / 6, mx == 0 and 0 or d / mx, mx
end
C3.__index.ToHex = function(c)
	local function b(x) return math.floor(math.clamp(x, 0, 1) * 255 + 0.5) end
	return string.format("%02x%02x%02x", b(c.R), b(c.G), b(c.B))
end
Color3.toHSV = C3.__index.ToHSV
local RectMt = class("Rect")
Rect = { new = function(a, b, c, d) return setmetatable({ a, b, c, d }, RectMt) end }
local CSQ, CSK, NSQ, NSK = class("ColorSequence"), class("ColorSequenceKeypoint"), class("NumberSequence"), class("NumberSequenceKeypoint")
ColorSequenceKeypoint = { new = function(t, v) return setmetatable({ Time = t, Value = v }, CSK) end }
NumberSequenceKeypoint = { new = function(t, v) return setmetatable({ Time = t, Value = v }, NSK) end }
ColorSequence = {
	new = function(a, b)
		if typeof(a) == "Color3" then
			a = { ColorSequenceKeypoint.new(0, a), ColorSequenceKeypoint.new(1, b or a) }
		end
		return setmetatable({ Keypoints = a }, CSQ)
	end,
}
NumberSequence = {
	new = function(a, b)
		if type(a) == "number" then
			a = { NumberSequenceKeypoint.new(0, a), NumberSequenceKeypoint.new(1, b or a) }
		end
		return setmetatable({ Keypoints = a }, NSQ)
	end,
}
local FontMt = class("Font")
Font = { new = function(f, w, s) return setmetatable({ Family = f, Weight = w or Enum.FontWeight.Regular, Style = s }, FontMt) end }
Font.fromEnum = function() return Font.new("enum") end
local TI = class("TweenInfo")
TweenInfo = { new = function(t, st) return setmetatable({ Time = t, EasingStyle = st }, TI) end }
local EnumItem = class("EnumItem")
local enumCache = {}
Enum = setmetatable({}, {
	__index = function(_, group)
		enumCache[group] = enumCache[group] or setmetatable({}, {
			__index = function(t, k)
				local item = setmetatable({ Name = k, EnumType = group, Value = 0 }, EnumItem)
				rawset(t, k, item)
				return item
			end,
		})
		return enumCache[group]
	end,
})
local function en(v) return type(v) == "table" and v.Name or v end

-- Signals and scheduler -----------------------------------------------------
local pendingError = {}
local function report(err) table.insert(pendingError, tostring(err)) end
local function newSignal()
	local list = {}
	local s = {}
	function s:Connect(fn)
		local c = { Connected = true, fn = fn }
		function c:Disconnect() c.Connected = false end
		table.insert(list, c)
		return c
	end
	s.Once = s.Connect
	function s:Wait() return coroutine.yield() end
	function s:Fire(...)
		for _, c in table.clone(list) do
			if c.Connected then
				task.spawn(c.fn, ...)
			end
		end
	end
	return s
end
local clock, queue = 0, {}
local function resume(co, ...)
	local ok, err = coroutine.resume(co, ...)
	if not ok then
		report(tostring(err) .. "\n" .. debug.traceback(co))
	end
end
task = {
	spawn = function(fn, ...)
		local co = type(fn) == "thread" and fn or coroutine.create(fn)
		resume(co, ...)
		return co
	end,
	defer = function(fn, ...)
		local co = type(fn) == "thread" and fn or coroutine.create(fn)
		table.insert(queue, { t = clock, co = co, args = { ... } })
		return co
	end,
	delay = function(d, fn, ...)
		local co = coroutine.create(fn)
		table.insert(queue, { t = clock + d, co = co, args = { ... } })
		return co
	end,
	wait = function(d)
		table.insert(queue, { t = clock + (d or 0.016), co = coroutine.running(), args = {} })
		coroutine.yield()
		return d
	end,
	cancel = function(co)
		for _, q in queue do
			if q.co == co then q.dead = true end
		end
	end,
}
wait = task.wait
spawn = task.spawn
tick = function() return clock end
warn = function(...)
	local parts = {}
	for _, v in { ... } do table.insert(parts, tostring(v)) end
	report("warn: " .. table.concat(parts, " "))
end

-- Instances -------------------------------------------------------------------
local EVENTS = {}
for e in string.gmatch("MouseButton1Click MouseButton1Down MouseButton1Up MouseEnter MouseLeave MouseMoved InputBegan InputEnded InputChanged ChildAdded ChildRemoved Destroying FocusLost Focused Changed Activated MouseButton2Click Heartbeat RenderStepped Ended Loaded Move DescendantAdded AncestryChanged", "%S+") do
	EVENTS[e] = true
end
local DEFAULTS = {
	Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0, 0), Visible = true, ZIndex = 1,
	LayoutOrder = 0, BackgroundTransparency = 0, BackgroundColor3 = Color3.new(0.64, 0.64, 0.64), ImageTransparency = 0,
	ImageColor3 = Color3.new(1, 1, 1), Image = "", TextTransparency = 0, TextColor3 = Color3.new(0.1, 0.1, 0.1), Text = "", TextSize = 8,
	AutomaticSize = "None", ClipsDescendants = false, Rotation = 0, Active = false, SliceScale = 1, TextWrapped = false,
	TextXAlignment = "Center", TextYAlignment = "Center", PlaceholderText = "", Scale = 1, Transparency = 0, Thickness = 1,
	CanvasPosition = Vector2.new(0, 0), CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = "None", ScrollingEnabled = true,
	AbsoluteSize = Vector2.new(0, 0), AbsolutePosition = Vector2.new(0, 0), TextBounds = Vector2.new(0, 0), AbsoluteContentSize = Vector2.new(0, 0),
	AbsoluteCanvasSize = Vector2.new(0, 0), AbsoluteWindowSize = Vector2.new(0, 0), Padding = UDim.new(0, 0), FillDirection = "Vertical",
	HorizontalAlignment = "Left", VerticalAlignment = "Top", HorizontalFlex = "None", VerticalFlex = "None", SortOrder = "Name",
	PaddingTop = UDim.new(0, 0), PaddingBottom = UDim.new(0, 0), PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0),
	CornerRadius = UDim.new(0, 8), Offset = Vector2.new(0, 0), ScaleType = "Stretch", ImageRectOffset = Vector2.new(0, 0),
	ImageRectSize = Vector2.new(0, 0), MinSize = Vector2.new(0, 0), MaxSize = Vector2.new(math.huge, math.huge), Enabled = true,
	TextTruncate = "None", Color = Color3.new(), RichText = false, MultiLine = false, PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7),
	ViewportSize = Vector2.new(1280, 800), LineHeight = 1, ResetOnSpawn = true,
}
-- Anything written outside this list is almost certainly a typo.
local KNOWN = {}
for k in DEFAULTS do KNOWN[k] = true end
for k in string.gmatch("Name Parent ClassName FontFace Font BorderSizePixel BorderColor3 AutoButtonColor ClearTextOnFocus ScrollBarThickness ScrollBarImageTransparency ScrollingDirection ElasticBehavior VerticalScrollBarPosition ZIndexBehavior IgnoreGuiInset ScreenInsets DisplayOrder SliceCenter ApplyStrokeMode GroupTransparency Video Looped Volume Playing Ambient LightColor LightDirection CurrentCamera CFrame FieldOfView AspectRatio TextScaled TextEditable Modal Selectable TileSize TextStrokeTransparency BorderMode ScrollBarImageColor3 HorizontalScrollBarInset VerticalScrollBarInset Interactable Material Anchored CanCollide Locked CastShadow MeshType FarIntensity NearIntensity InFocusRadius FlexMode Wraps CursorPosition SelectionStart LineJoinMode AspectType DominantAxis", "%S+") do
	KNOWN[k] = true
end
local methods = {}
local Instance_mt = { __type = "Instance" }
local forceLayout -- reading a content size makes Roblox lay out right away
local function fireChanged(inst, k)
	local s = rawget(inst, "__changed")[k]
	if s then s:Fire() end
end
function methods:GetPropertyChangedSignal(k)
	local ch = rawget(self, "__changed")
	ch[k] = ch[k] or newSignal()
	return ch[k]
end
function methods:FindFirstChild(n)
	for _, c in rawget(self, "__children") do
		if c.Name == n then return c end
	end
	return nil
end
function methods:FindFirstChildOfClass(n)
	for _, c in rawget(self, "__children") do
		if c.ClassName == n then return c end
	end
	return nil
end
methods.FindFirstChildWhichIsA = methods.FindFirstChildOfClass
function methods:WaitForChild(n) return methods.FindFirstChild(self, n) end
function methods:GetChildren() return table.clone(rawget(self, "__children")) end
function methods:IsA(n) return self.ClassName == n or n == "GuiObject" or n == "Instance" end
function methods:Destroy()
	local d = rawget(self, "__events").Destroying
	if d then d:Fire() end
	self.Parent = nil
end
function methods:CaptureFocus() end
function methods:ReleaseFocus() end
function methods:Play() end
function methods:IsDescendantOf() return true end
function methods:FindFirstAncestorOfClass(n)
	local p = self.Parent
	while p and p.ClassName ~= n do p = p.Parent end
	return p
end
function methods:ViewportPointToRay(x, y) return { Origin = Vector3.new(x, y, 0), Direction = Vector3.new(0, 0, 1) } end
Instance_mt.__index = function(t, k)
	local p = rawget(t, "__props")
	if k == "AbsoluteContentSize" and forceLayout then forceLayout() end
	local v = p[k]
	if v ~= nil then return v end
	if k == "AbsoluteSize" and p.Size then -- not laid out yet: Roblox resolves the offset part
		return Vector2.new(math.max(p.Size.X.Offset, 0), math.max(p.Size.Y.Offset, 0))
	end
	-- Roblox resolves real properties before child names.
	for _, c in rawget(t, "__children") do
		if rawget(c, "__props").Name == k then return c end
	end
	if methods[k] then return methods[k] end
	if EVENTS[k] then
		local ev = rawget(t, "__events")
		ev[k] = ev[k] or newSignal()
		return ev[k]
	end
	if DEFAULTS[k] ~= nil then return DEFAULTS[k] end
	if KNOWN[k] then return nil end
	error(string.format("%s is not a valid member of %s %q", tostring(k), tostring(p.ClassName), tostring(p.Name)), 2)
end
Instance_mt.__newindex = function(t, k, v)
	local p = rawget(t, "__props")
	if k == "Parent" then
		if p.Parent then
			local list = rawget(p.Parent, "__children")
			local i = table.find(list, t)
			if i then table.remove(list, i) end
		end
		p.Parent = v
		if v then
			table.insert(rawget(v, "__children"), t)
			local added = rawget(v, "__events").ChildAdded
			if added then added:Fire(t) end
		end
		return
	end
	if not KNOWN[k] then
		error(string.format("%s is not a valid property of %s %q", tostring(k), tostring(p.ClassName), tostring(p.Name)), 2)
	end
	if p[k] == v then return end
	p[k] = v
	fireChanged(t, k)
end
Instance_mt.__tostring = function(t) return rawget(t, "__props").Name end
local uid = 0
Instance = {
	new = function(cls, parent)
		uid += 1
		local inst = setmetatable({ __props = { ClassName = cls, Name = cls == "SpecialMesh" and "Mesh" or cls }, __children = {}, __events = {}, __changed = {}, __id = uid }, Instance_mt)
		if parent then inst.Parent = parent end
		return inst
	end,
}

-- Services ---------------------------------------------------------------------
local playerGui = Instance.new("Folder")
playerGui.Name = "PlayerGui"
local guid = 0
local camera = Instance.new("Camera")
camera.ViewportSize = Vector2.new(VIEW_W, VIEW_H)
camera.CFrame = CFrame.new()
workspace = Instance.new("Workspace")
rawget(workspace, "__props").CurrentCamera = camera
local mouse = { X = 0, Y = 0, Move = newSignal() }
local player = { UserId = 1, Name = "brine", DisplayName = "Brine", GetMouse = function() return mouse end, WaitForChild = function() return playerGui end }
UIS = { InputBegan = newSignal(), InputEnded = newSignal(), InputChanged = newSignal(), TouchEnabled = false, KeyboardEnabled = true, GetFocusedTextBox = function() end, GetMouseLocation = function() return UIS_Point or Vector2.new(0, 0) end }
UIS_MouseMove = function(x, y) UIS_Point = Vector2.new(x, y) UIS.InputChanged:Fire({ UserInputType = Enum.UserInputType.MouseMovement, Position = Vector3.new(x, y, 0) }) end
local services = {
	RunService = { IsStudio = function() return true end, Heartbeat = newSignal(), RenderStepped = newSignal() },
	UserInputService = UIS,
	LocalizationService = { SystemLocaleId = "en-us" },
	HttpService = { GenerateGUID = function() guid += 1; return "g" .. guid end, JSONDecode = function() return { version = "test" } end },
	Players = { LocalPlayer = player, GetUserThumbnailAsync = function() return "" end },
	TweenService = {
		Create = function(_, obj, info, props)
			return {
				Play = function()
					-- Long linear tweens are timers (notification, indeterminate bar): freeze them in frame one.
					if en(info.EasingStyle) == "Linear" and info.Time > 0.5 then return end
					for k, v in props do obj[k] = v end
				end,
				Cancel = function() end,
			}
		end,
	},
	Workspace = workspace,
}
game = { GetService = function(_, n)
	services[n] = services[n] or Instance.new(n)
	return services[n]
end }

-- Layout -------------------------------------------------------------------------
local function charW(face, size, text)
	local w = en(face and face.Weight)
	local t = (w == "Bold" or w == "SemiBold" or w == "Heavy" or w == "ExtraBold") and METRICS.bold or METRICS.regular
	local n = 0
	for i = 1, #text do n += t[string.byte(text, i)] or 0.55 end
	return n * size * METRICS.scale * (w == "Medium" and 1.035 or 1)
end
local function measureText(inst, maxW)
	local size = inst.TextSize
	local text = string.gsub(tostring(inst.Text), "<[^>]+>", "")
	local lh = math.ceil(size * METRICS.line)
	if text == "" then return 0, lh end
	local full = charW(inst.FontFace, size, text)
	if not inst.TextWrapped or full <= maxW + 0.5 or maxW <= 0 then
		return math.ceil(full), lh
	end
	local lines, cur, widest = 1, 0, 0
	for word in string.gmatch(text, "%S+%s*") do
		local w = charW(inst.FontFace, size, word)
		local bare = string.gsub(word, "%s+$", "")
		if cur > 0 and cur + charW(inst.FontFace, size, bare) > maxW then
			lines += 1
			widest = math.max(widest, cur)
			cur = 0
		end
		cur += w
	end
	return math.ceil(math.max(widest, cur)), lines * lh
end
local GUI = { Frame = 1, TextLabel = 1, TextButton = 1, TextBox = 1, ImageLabel = 1, ImageButton = 1, ScrollingFrame = 1, CanvasGroup = 1, ViewportFrame = 1, VideoFrame = 1 }
local function kidsOf(inst) return rawget(inst, "__children") end
local function helper(inst, cls)
	for _, c in kidsOf(inst) do
		if rawget(c, "__props").ClassName == cls then return c end
	end
	return nil
end
local changes = {}
local function setAbs(inst, k, v)
	local p = rawget(inst, "__props")
	local old = p[k] or DEFAULTS[k]
	p[k] = v
	if math.abs(old.X - v.X) > 0.49 or math.abs(old.Y - v.Y) > 0.49 then
		table.insert(changes, { inst, k })
	end
end
local function pads(inst)
	local p = helper(inst, "UIPadding")
	if not p then return 0, 0, 0, 0 end
	return p.PaddingLeft.Offset, p.PaddingTop.Offset, p.PaddingRight.Offset, p.PaddingBottom.Offset
end
local function auto(inst)
	local a = en(inst.AutomaticSize)
	return a == "X" or a == "XY", a == "Y" or a == "XY"
end
local function isText(inst)
	local c = rawget(inst, "__props").ClassName
	return c == "TextLabel" or c == "TextButton" or c == "TextBox"
end
local sizeOf
local function sorted(inst)
	local list = {}
	for i, c in kidsOf(inst) do
		if GUI[rawget(c, "__props").ClassName] and c.Visible then
			table.insert(list, { c, c.LayoutOrder, i })
		end
	end
	table.sort(list, function(a, b)
		if a[2] ~= b[2] then return a[2] < b[2] end
		return a[3] < b[3]
	end)
	local out = {}
	for _, e in list do table.insert(out, e[1]) end
	return out
end
-- Content extent of inst given its inner box. A child scaled along an automatic
-- axis contributes only its own automatic content.
local function extent(inst, iw, ih, ax, ay)
	local list = helper(inst, "UIListLayout")
	local w, h, count = 0, 0, 0
	local horizontal = list and en(list.FillDirection) == "Horizontal"
	for _, c in sorted(inst) do
		local cw, ch = sizeOf(c, iw, ih, ax, ay)
		if list then
			count += 1
			if horizontal then
				w += cw
				h = math.max(h, ch)
			else
				h += ch
				w = math.max(w, cw)
			end
		else
			w = math.max(w, cw > 0 and cw + math.max(0, c.Position.X.Offset) or 0)
			h = math.max(h, ch > 0 and ch + math.max(0, c.Position.Y.Offset) or 0)
		end
	end
	if list and count > 1 then
		local gap = list.Padding.Offset * (count - 1)
		if horizontal then w += gap else h += gap end
	end
	return w, h
end
function sizeOf(inst, pw, ph, ignoreX, ignoreY)
	local s = inst.Size
	local ax, ay = auto(inst)
	local w = s.X.Scale * pw + s.X.Offset
	local h = s.Y.Scale * ph + s.Y.Offset
	if ignoreX and s.X.Scale ~= 0 then
		w = 0
		if not ax then
			local l, _, r = pads(inst)
			local ew = extent(inst, 0, math.max(h, 0), true, false)
			w = ew + l + r
		end
	end
	if ignoreY and s.Y.Scale ~= 0 then
		h = 0
		if not ay then -- a filled child still passes its own content up
			local l, t, r, b = pads(inst)
			local _, eh = extent(inst, math.max(w - l - r, 0), 0, false, true)
			h = eh + t + b
		end
	end
	if ay and s.Y.Scale ~= 0 and inst.Parent and helper(inst.Parent, "UIListLayout") and select(2, auto(inst.Parent)) then h = math.max(s.Y.Offset, 0) end
	w, h = math.max(w, 0), math.max(h, 0)
	if ax or ay then
		local l, t, r, b = pads(inst)
		local realW = s.X.Scale * pw + s.X.Offset -- width used for wrapping
		local ew, eh = extent(inst, math.max(realW - l - r, 0), math.max(h - t - b, 0), ax, ay)
		if isText(inst) and (inst.Text ~= "" or inst.ClassName == "TextBox") then
			local tw, th = measureText(inst, ax and math.huge or math.max(realW - l - r, 0))
			ew, eh = math.max(ew, tw), math.max(eh, th)
		end
		if ax then w = math.max(w, ew + l + r) end
		if ay then h = math.max(h, eh + t + b) end
	end
	local con = helper(inst, "UISizeConstraint")
	if con then
		w = math.clamp(w, con.MinSize.X, con.MaxSize.X)
		h = math.clamp(h, con.MinSize.Y, con.MaxSize.Y)
	end
	local sc = helper(inst, "UIScale")
	if sc and not rawget(inst, "__root") then
		w *= sc.Scale
		h *= sc.Scale
	end
	return w, h
end
local function place(inst, x, y, w, h)
	setAbs(inst, "AbsolutePosition", Vector2.new(x, y))
	setAbs(inst, "AbsoluteSize", Vector2.new(w, h))
	local l, t, r, b = pads(inst)
	if isText(inst) then
		local tw, th = measureText(inst, w - l - r)
		setAbs(inst, "TextBounds", Vector2.new(tw, th))
	end
	local ix, iy, iw, ih = x + l, y + t, w - l - r, h - t - b
	if inst.ClassName == "ScrollingFrame" then
		setAbs(inst, "AbsoluteWindowSize", Vector2.new(w, h))
		local _, eh = extent(inst, iw, ih, false, true)
		setAbs(inst, "AbsoluteCanvasSize", Vector2.new(w, math.max(h, eh + t + b)))
		iy -= inst.CanvasPosition.Y
	end
	local kids = sorted(inst)
	local list = helper(inst, "UIListLayout")
	if not list then
		-- Seen in Roblox: without a list layout, a scrolling frame's children scale to the whole window.
		if inst.ClassName == "ScrollingFrame" then iw, ih = w, h end
		for _, c in kids do
			local cw, ch = sizeOf(c, iw, ih)
			place(c, ix + c.Position.X.Scale * iw + c.Position.X.Offset - c.AnchorPoint.X * cw,
				iy + c.Position.Y.Scale * ih + c.Position.Y.Offset - c.AnchorPoint.Y * ch, cw, ch)
		end
		return
	end
	local horizontal = en(list.FillDirection) == "Horizontal"
	local gap = list.Padding.Offset + list.Padding.Scale * (horizontal and iw or ih)
	local dims, total, cross = {}, 0, 0
	for _, c in kids do
		local cw, ch = sizeOf(c, iw, ih)
		table.insert(dims, { cw, ch })
		total += horizontal and cw or ch
		cross = math.max(cross, horizontal and ch or cw)
	end
	if #kids > 1 then total += gap * (#kids - 1) end
	if horizontal and en(list.HorizontalFlex) == "Fill" and #kids > 0 then
		local extra = (iw - total) / #kids
		for _, d in dims do d[1] += extra end
		total = iw
	end
	setAbs(list, "AbsoluteContentSize", horizontal and Vector2.new(total, cross) or Vector2.new(cross, total))
	local ha, va = en(list.HorizontalAlignment), en(list.VerticalAlignment)
	local fx = ha == "Center" and 0.5 or ha == "Right" and 1 or 0
	local fy = va == "Center" and 0.5 or va == "Bottom" and 1 or 0
	local cur = horizontal and ix + (iw - total) * fx or iy + (ih - total) * fy
	for i, c in kids do
		local cw, ch = dims[i][1], dims[i][2]
		if horizontal then
			place(c, cur, iy + (ih - ch) * fy, cw, ch)
			cur += cw + gap
		else
			place(c, ix + (iw - cw) * fx, cur, cw, ch)
			cur += ch + gap
		end
	end
end
local function eachRoot(fn)
	for _, g in kidsOf(playerGui) do
		if g.ClassName == "ScreenGui" then
			setAbs(g, "AbsoluteSize", Vector2.new(VIEW_W, VIEW_H))
			local function walk(nd)
				for _, c in kidsOf(nd) do
					if c.ClassName == "Folder" then
						walk(c)
					elseif GUI[c.ClassName] then
						fn(c)
					end
				end
			end
			walk(g)
		end
	end
end
local busy, carried = false, {}
local function pass()
	eachRoot(function(c)
		rawset(c, "__root", true)
		local w, h = sizeOf(c, VIEW_W, VIEW_H)
		place(c, c.Position.X.Scale * VIEW_W + c.Position.X.Offset - c.AnchorPoint.X * w,
			c.Position.Y.Scale * VIEW_H + c.Position.Y.Offset - c.AnchorPoint.Y * h, w, h)
	end)
end
function forceLayout()
	if busy then return end
	busy = true
	changes = {}
	pass()
	for _, c in changes do table.insert(carried, c) end
	busy = false
end
local function layout()
	if busy then return end
	busy = true
	for _ = 1, 14 do
		changes = carried
		carried = {}
		pass()
		if #changes == 0 then break end
		for _, c in table.clone(changes) do fireChanged(c[1], c[2]) end
	end
	busy = false
end
function run(seconds)
	local limit = clock + seconds
	layout()
	while true do
		local best
		for i, q in queue do
			if not q.dead and q.t <= limit and (not best or q.t < queue[best].t) then best = i end
		end
		if not best then break end
		local q = table.remove(queue, best)
		clock = math.max(clock, q.t)
		resume(q.co, table.unpack(q.args))
		layout()
	end
	clock = limit
	layout()
end
-- Scene helpers: press a control the way a mouse would.
function click(inst)
	inst.MouseButton1Click:Fire()
	run(0.6)
end
function press(inst)
	local input = { UserInputType = Enum.UserInputType.MouseButton1, Position = Vector3.new(0, 0, 0) }
	inst.InputBegan:Fire(input)
	UIS.InputEnded:Fire(input)
	run(0.6)
end
function find(root, name)
	for _, c in kidsOf(root) do
		if c.Name == name then return c end
		local f = find(c, name)
		if f then return f end
	end
	return nil
end
GUI_ROOT = playerGui

-- Dump ----------------------------------------------------------------------------
local function jstr(s)
	return '"' .. string.gsub(tostring(s), '[%c"\\]', function(c) return string.format("\\u%04x", string.byte(c)) end) .. '"'
end
local function num(n) return string.format("%.2f", n) end
local function hex(c) return jstr("#" .. c:ToHex()) end
local function dump(inst, out)
	if not inst.Visible then return end
	local cls, a, s = inst.ClassName, inst.AbsolutePosition, inst.AbsoluteSize
	local f = { '"c":' .. jstr(cls), '"n":' .. jstr(inst.Name), '"x":' .. num(a.X), '"y":' .. num(a.Y), '"w":' .. num(s.X), '"h":' .. num(s.Y), '"z":' .. string.format("%.0f", math.clamp(inst.ZIndex, -99999, 2000000)) }
	local function add(v) table.insert(f, v) end
	if inst.BackgroundTransparency < 1 then add('"bg":' .. hex(inst.BackgroundColor3) .. ',"bt":' .. num(inst.BackgroundTransparency)) end
	if inst.ClipsDescendants or cls == "ScrollingFrame" then add('"clip":true') end
	if inst.Rotation ~= 0 then add('"rot":' .. num(inst.Rotation)) end
	if string.find(cls, "Image") and inst.Image and inst.Image ~= "" and inst.ImageTransparency < 1 then
		add('"img":' .. jstr(inst.Image) .. ',"ic":' .. hex(inst.ImageColor3) .. ',"it":' .. num(inst.ImageTransparency) .. ',"ss":' .. string.format("%.5f", inst.SliceScale))
	end
	if isText(inst) then
		local text, col, tt = inst.Text, inst.TextColor3, inst.TextTransparency
		if cls == "TextBox" and text == "" then text, col = inst.PlaceholderText, inst.PlaceholderColor3 end
		if text ~= "" and tt < 1 then
			local l, t, r, b = pads(inst)
			add('"t":' .. jstr(text) .. ',"tc":' .. hex(col) .. ',"tt":' .. num(tt) .. ',"ts":' .. num(inst.TextSize) .. ',"tw":' .. tostring(inst.TextWrapped) .. ',"ta":' .. jstr(en(inst.TextXAlignment)) .. ',"tv":' .. jstr(en(inst.TextYAlignment)) .. ',"fw":' .. jstr(inst.FontFace and en(inst.FontFace.Weight) or "Regular") .. ',"tp":[' .. l .. "," .. t .. "," .. r .. "," .. b .. "]")
		end
	end
	local corner = helper(inst, "UICorner")
	if corner then add('"r":' .. num(math.max(0, corner.CornerRadius.Scale * math.min(s.X, s.Y) + corner.CornerRadius.Offset))) end
	local stroke = helper(inst, "UIStroke")
	local function gradientOf(owner)
		local grad = helper(owner, "UIGradient")
		if not grad then return nil end
		local p, cs, ts = rawget(grad, "__props"), {}, {}
		for _, k in p.Color and p.Color.Keypoints or {} do table.insert(cs, "[" .. num(k.Time) .. "," .. hex(k.Value) .. "]") end
		for _, k in p.Transparency and typeof(p.Transparency) == "NumberSequence" and p.Transparency.Keypoints or {} do table.insert(ts, "[" .. num(k.Time) .. "," .. num(k.Value) .. "]") end
		return '{"c":[' .. table.concat(cs, ",") .. '],"t":[' .. table.concat(ts, ",") .. '],"r":' .. num(grad.Rotation) .. "}"
	end
	if stroke and stroke.Enabled and stroke.Transparency < 1 then
		add('"sc":' .. hex(stroke.Color) .. ',"st":' .. num(stroke.Transparency) .. ',"sw":' .. num(stroke.Thickness))
		local g = gradientOf(stroke)
		if g then add('"sg":' .. g) end
	end
	local g = gradientOf(inst)
	if g then add('"g":' .. g) end
	local kids = {}
	for _, c in kidsOf(inst) do
		if GUI[c.ClassName] then dump(c, kids) end
	end
	add('"k":[' .. table.concat(kids, ",") .. "]")
	table.insert(out, "{" .. table.concat(f, ",") .. "}")
end
function emit()
	local all, errs = {}, {}
	eachRoot(function(c) dump(c, all) end)
	-- Seen in Roblox: a UICorner on a sliced image rounds each slice separately.
	local function check(inst)
		if helper(inst, "UICorner") and en(inst.ScaleType) == "Slice" then
			report("UICorner on sliced image " .. tostring(inst.Parent) .. "." .. inst.Name)
		end
		for _, c in kidsOf(inst) do check(c) end
	end
	check(playerGui)
	for _, e in pendingError do table.insert(errs, jstr(e)) end
	print('@@{"nodes":[' .. table.concat(all, ",") .. '],"errors":[' .. table.concat(errs, ",") .. "]}")
end
-- INSERT BUNDLE
-- INSERT SCENE
