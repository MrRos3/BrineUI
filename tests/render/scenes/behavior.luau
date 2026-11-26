-- Interactions through the real public API; asserts instead of pictures.
-- themes: Liquid
local Window = Brine:CreateWindow({ Title = "Brine", Theme = THEME, Size = UDim2.fromOffset(620, 460), AutoScale = false, HidePanelBackground = true, HideSearchBar = false })
run(0.1)
local Section = Window:Section({ Title = "Group", Opened = true })
local A = Section:Tab({ Title = "A", Icon = "layers" })
local B = Window:Tab({ Title = "B" })
local got = {}
local Slider = A:Slider({ Title = "S", Value = { Min = 0, Max = 10, Default = 5 }, Callback = function(v) got.slider = v end })
local Toggle = A:Toggle({ Title = "T", Value = false, Callback = function(v) got.toggle = v end })
local Check = A:Toggle({ Title = "C", Type = "Checkbox", Value = false, Callback = function(v) got.check = v end })
local Drop = A:Dropdown({ Title = "D", Values = { "x", "y" }, Value = "x", Callback = function(v) got.drop = v end })
local Button = A:Button({ Title = "Go", Callback = function() got.button = (got.button or 0) + 1 end })
local Key = A:Keybind({ Title = "K", Value = "K" })
local Input = A:Input({ Title = "I", Value = "", Callback = function(v) got.input = v end })
A:Select()
run(1)
local page = Window.UIElements.MainBar.Background
assert(not page.Visible, "HidePanelBackground")
Slider:Set(8)
assert(got.slider == 8 and Slider.UIElements.SliderIcon.Frame.Size.X.Scale == 0.8, "slider")
press(find(Toggle.ToggleFrame.UIElements.Main, "Hitbox"))
assert(got.toggle == true and Toggle.Value == true, "toggle click")
Check:Set(true)
run(0.2)
assert(got.check == true, "checkbox")
Drop:Select("y")
run(0.2)
assert(Drop.Value == "y", "dropdown")
click(Button.ButtonFrame.UIElements.Main)
assert(got.button == 1, "button")
-- Each menu places itself: below its field, or above it near the bottom of the screen.
local Low = A:Dropdown({ Title = "Low", Values = { "1", "2", "3", "4", "5", "6" }, Value = "1", Callback = function() end })
run(0.3)
for _, d in { Drop, Low } do
	local field, menu = d.UIElements.Dropdown, d.UIElements.MenuCanvas
	d:Open()
	run(0.3)
	local top, bottom = menu.AbsolutePosition.Y, menu.AbsolutePosition.Y + menu.AbsoluteSize.Y
	assert(bottom <= VIEW_H and top >= 0, "menu leaves the screen")
	assert(top >= field.AbsolutePosition.Y + field.AbsoluteSize.Y or bottom <= field.AbsolutePosition.Y, "menu covers its field")
	d:Close()
	run(0.5)
end
-- Clicking the field opens the menu; clicking it again closes it.
click(Drop.UIElements.Dropdown)
assert(Drop.UIElements.MenuCanvas.Visible and Drop.UIElements.Menu.Visible, "a click opens the menu")
click(Drop.UIElements.Dropdown)
assert(not Drop.UIElements.MenuCanvas.Visible, "a second click closes the menu")
Button:Lock()
click(Button.ButtonFrame.UIElements.Main)
assert(got.button == 1 and Button.ButtonFrame.UIElements.Locked.Visible, "locked button fired")
Button:Unlock()
Key:Set("RightShift")
run(0.2)
assert(Key.Value == "RightShift", "keybind")
click(B.UIElements.Main)
assert(B.Selected and not A.Selected and B.ContainerFrame.Visible and not A.ContainerFrame.Visible, "tab switch")
assert(B.UIElements.Glass.Visible and not A.UIElements.Glass.Visible, "glass follows tab")
local back = Window.UIElements.Main.Background
assert(math.abs(back.ImageTransparency - 0.22) < 0.01, "Liquid window is translucent")
Brine:SetTheme("Dark")
assert(back.ImageTransparency == 0, "opaque themes stay opaque")
Window:ToggleTransparency(true)
assert(back.ImageTransparency > 0.1, "Transparent still works on them")
Window:ToggleTransparency(false)
Brine:SetTheme(THEME)
local light = find(back, "Glass").Light.UIGradient
UIS_MouseMove(0, 0)
local first = light.Rotation
UIS_MouseMove(900, 640)
assert(light.Rotation ~= first, "rim light follows the pointer")
for name in Brine:GetThemes() do assert(Brine:SetTheme(name), name) end
Brine:SetTheme(THEME)
-- Notifications rest 56px above the bottom, or 29px when lowered, and stack upward.
local function bottoms()
	local out = {}
	local function walk(o)
		for _, c in o:GetChildren() do
			if c.Name == "ImageLabel" and find(c, "DurationFrame") then
				table.insert(out, c.AbsolutePosition.Y + c.AbsoluteSize.Y)
			else
				walk(c)
			end
		end
	end
	walk(Brine.NotificationGui)
	table.sort(out)
	return out
end
Brine:Notify({ Title = "One", Content = "First", Duration = 600 })
Brine:Notify({ Title = "Two", Content = "Second", Duration = 600 })
run(2)
local rest = bottoms()
assert(#rest == 2 and math.abs(VIEW_H - rest[2] - 56) < 1 and rest[1] < rest[2] - 40, "notification position")
Brine:SetNotificationLower(true)
run(0.2)
assert(math.abs(VIEW_H - bottoms()[2] - 29) < 1, "lowered notification position")
Brine:SetNotificationLower(false)
run(0.2)
-- Traffic lights: the three window buttons are lights at the top right; a script's own button is not.
local topbar = Window.UIElements.Main.Main.Topbar
local order, custom = {}, 0
Window:CreateTopbarButton("Custom", "settings", function() custom += 1 end, 990)
run(0.3)
for _, b in Window.TopBarButtons do
	if b.Name ~= "Custom" then table.insert(order, b) end
end
assert(#order == 3 and topbar.Actions, "three lights and one action")
table.sort(order, function(a, b) return a.Object.AbsolutePosition.X < b.Object.AbsolutePosition.X end)
assert(order[1].Name == "Fullscreen" and order[2].Name == "Minimize" and order[3].Name == "Close", "green, yellow, red")
local edge = topbar.AbsolutePosition.X + topbar.AbsoluteSize.X
assert(order[3].Object.AbsolutePosition.X + 22 <= edge and order[1].Object.AbsolutePosition.X > edge - 100, "lights sit at the top right")
assert(topbar.Actions.AbsolutePosition.X + topbar.Actions.AbsoluteSize.X <= order[1].Object.AbsolutePosition.X, "actions sit beside the lights")
for _, b in order do
	local dot = b.Object:GetChildren()[1]
	assert(dot.AbsoluteSize.X == dot.AbsoluteSize.Y and dot.UICorner.CornerRadius.Scale == 1, "lights are true circles")
end
local dot = order[2].Object.AbsolutePosition
UIS_MouseMove(dot.X + 11, dot.Y + 18)
run(0.2)
assert(find(order[2].Object, "Glyph").Visible, "the pointed light shows its symbol")
assert(not find(order[1].Object, "Glyph").Visible and not find(order[3].Object, "Glyph").Visible, "the other lights stay plain")
local red = order[3].Object.AbsolutePosition
UIS_MouseMove(red.X + 11, red.Y + 18)
run(0.2)
assert(find(order[3].Object, "Glyph").Visible and not find(order[2].Object, "Glyph").Visible, "the symbol follows the pointer")
UIS_MouseMove(dot.X + 300, dot.Y + 300)
run(0.2)
for _, b in order do assert(not find(b.Object, "Glyph").Visible, "symbols hide again") end
click(topbar.Actions:GetChildren()[4]:GetChildren()[1])
assert(custom == 1, "custom topbar button")
click(order[1].Object.Hitbox)
assert(Window.IsFullscreen, "green goes fullscreen")
click(order[1].Object.Hitbox)
-- Minimizing leaves a badge on every device; a click on it reopens the window, a drag moves it.
Window:Close()
run(1)
local badge = Window.OpenButtonMain.Button
assert(badge.Parent.Visible and badge.AbsoluteSize.X == badge.AbsoluteSize.Y, "square badge after minimize")
assert(badge.AbsolutePosition.Y >= 58 + 10, "badge sits below Roblox's top bar, not under it")
local function tap(dx)
	local hit = badge.TextButton
	local input = { UserInputType = Enum.UserInputType.MouseButton1, Position = Vector3.new(100, 100, 0) }
	hit.InputBegan:Fire(input)
	if dx then UIS.InputChanged:Fire({ UserInputType = Enum.UserInputType.MouseMovement, Position = Vector3.new(100 + dx, 100, 0) }) end
	UIS.InputEnded:Fire(input)
	run(1)
end
local before = badge.Parent.Position
tap(60)
assert(Window.Closed and badge.Parent.Position.X.Offset == before.X.Offset + 60, "dragging moves the badge")
tap()
assert(not Window.Closed and not badge.Parent.Visible, "clicking the badge reopens")
Window:SetTitle("New"); Window:SetSize(UDim2.fromOffset(700, 500)); Window:ToggleTransparency(true); Window:SetUIScale(0.8); Window:SetUIScale(1)
Window:EditOpenButton({ Title = "Open", Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")), CornerRadius = UDim.new(1, 0) })
Brine:Popup({ Title = "Popup", Content = "Text", Icon = "info", Buttons = { { Title = "OK", Variant = "Primary", Callback = function() end } } })
Window:Dialog({ Title = "Dialog", Content = "Text", Buttons = { { Title = "OK" }, { Title = "Cancel", Variant = "Secondary" } } })
run(1)
print("PASS behavior")
emit()
