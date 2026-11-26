-- The symbols inside the traffic lights, drawn from frames so they stay crisp at 14px.
-- Each is the dark shade of its light, as on macOS.
local Creator = require("../../modules/Creator")
local New = Creator.New

local INK = {
	Close = Color3.fromRGB(77, 0, 0),
	Minimize = Color3.fromRGB(153, 87, 0),
	Fullscreen = Color3.fromRGB(0, 101, 0),
}

local function Bar(Color, Rotation)
	return New("Frame", {
		Size = UDim2.new(0.56, 0, 0, 1.6),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Rotation = Rotation,
		BackgroundColor3 = Color,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})
end

-- A right triangle with its right angle in the given corner (0,0 is top left, 1,1 bottom
-- right): a clip box holding a diamond centred on that corner, whose edge is the box's diagonal.
local function Triangle(Color, Corner)
	local Side = 0.32
	local Start = Corner == 0 and 0.22 or 0.46
	return New("Frame", {
		Size = UDim2.new(Side, 0, Side, 0),
		Position = UDim2.new(Start, 0, Start, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
	}, {
		New("Frame", {
			Size = UDim2.new(math.sqrt(2), 0, math.sqrt(2), 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(Corner, 0, Corner, 0),
			Rotation = 45,
			BackgroundColor3 = Color,
		}),
	})
end

return function(Kind)
	local Color = INK[Kind]
	if not Color then
		return nil
	end
	local Parts
	if Kind == "Close" then
		Parts = { Bar(Color, 45), Bar(Color, -45) }
	elseif Kind == "Minimize" then
		Parts = { Bar(Color, 0) }
	else
		Parts = { Triangle(Color, 0), Triangle(Color, 1) }
	end
	return New("Frame", {
		Name = "Glyph",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Visible = false,
	}, Parts)
end
