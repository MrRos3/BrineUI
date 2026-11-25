-- Liquid glass parts. A pane is a translucent fill (drawn by its owner), a sheen that
-- falls from the top, and a rim: one thin line whose brightness changes around the edge.
local Creator = require("./Creator")
local New = Creator.New

local Glass = {}

-- Light enters top left, leaves bottom right, and fades along the sides.
local RIM_LIGHT = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.35, 0.72),
	NumberSequenceKeypoint.new(0.65, 0.85),
	NumberSequenceKeypoint.new(1, 0.3),
})
local SHEEN_FALL = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.86),
	NumberSequenceKeypoint.new(0.45, 0.97),
	NumberSequenceKeypoint.new(1, 1),
})

-- The lit line itself, for parents that already have a UICorner.
function Glass.Stroke()
	return New("UIStroke", {
		Name = "Light",
		Thickness = 1,
		ApplyStrokeMode = "Border",
		ThemeTag = {
			Color = "GlassRim",
			Transparency = "GlassRimTransparency",
		},
	}, {
		New("UIGradient", {
			Rotation = 55,
			Transparency = RIM_LIGHT,
		}),
	})
end

-- Sheen and rim as one frame that fills its parent. Inset by the line's width, so a
-- clipping parent cannot cut the line off.
function Glass.Pane(Radius, Properties)
	local Pane = New("Frame", {
		Name = "Glass",
		Size = UDim2.new(1, -2, 1, -2),
		Position = UDim2.new(0, 1, 0, 1),
		ThemeTag = {
			BackgroundColor3 = "GlassSheen",
			BackgroundTransparency = "GlassSheenTransparency",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, math.max(Radius - 1, 0)),
		}),
		New("UIGradient", {
			Rotation = 90,
			Transparency = SHEEN_FALL,
		}),
		Glass.Stroke(),
	})
	for Property, Value in next, Properties or {} do
		Pane[Property] = Value
	end
	return Pane
end

-- White thumbs need an edge to show on light glass. It is its own frame: a UICorner
-- placed on a sliced image rounds every slice and breaks the shape apart.
function Glass.ThumbEdge()
	return New("Frame", {
		Name = "Edge",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		New("UIStroke", {
			Thickness = 1,
			ApplyStrokeMode = "Border",
			ThemeTag = { Color = "Black" },
			Transparency = 0.78,
		}),
	})
end

return Glass
