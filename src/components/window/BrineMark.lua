-- A split salt crystal, built from native frames; no new hosted asset.
local Creator = require("../../modules/Creator")
return function(parent)
	local mark = Creator.New("Frame", {
		Name = "BrineMark", Size = UDim2.fromOffset(22, 22),
		BackgroundTransparency = 1, Parent = parent, LayoutOrder = -1,
	})
	for _, point in ipairs({ Vector2.new(6, 7), Vector2.new(15, 7), Vector2.new(6, 16), Vector2.new(15, 16) }) do
		Creator.New("Frame", {
			Size = UDim2.fromOffset(5, 5), Position = UDim2.fromOffset(point.X, point.Y),
			AnchorPoint = Vector2.new(0.5, 0.5), Rotation = 45,
			ThemeTag = { BackgroundColor3 = "WindowTopbarIcon" }, Parent = mark,
		})
	end
	return mark
end
