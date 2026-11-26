-- Search popup with results.
local Window = Brine:CreateWindow({ Title = "Brine", Author = "by Salty", Theme = THEME, Size = UDim2.fromOffset(620, 460), AutoScale = false, HideSearchBar = false })
run(0.1)
local T = Window:Tab({ Title = "Session", Icon = "layers", ShowTabTitle = true })
T:Toggle({ Title = "Notifications", Desc = "Show updates during this session", Value = true })
T:Slider({ Title = "Session volume", Value = { Min = 0, Max = 100, Default = 70 } })
T:Select()
run(1)
for _, c in Window.UIElements.SideBarContainer:GetChildren() do
	if c.ClassName == "TextButton" then click(c) end
end
run(0.5)
-- Before anything is typed the popup is just the search row, not a big empty box.
local popup
for _, c in Window.UIElements.Main:GetChildren() do
	if c.ClassName == "Frame" and c.Name == "Frame" and find(c, "TextBox") then popup = c end
end
assert(popup and popup.Visible and popup.AbsoluteSize.Y > 30 and popup.AbsoluteSize.Y < 70, "empty search is one row, got " .. (popup and popup.AbsoluteSize.Y or -1))
find(popup, "TextBox").Text = "session"
run(1)
assert(popup.AbsoluteSize.Y > 90, "results make it grow")
emit()
