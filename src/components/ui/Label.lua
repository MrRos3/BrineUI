local Label = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween
local Glass = require("../../modules/Glass")

function Label.New(Text, Icon, Parent, IsPlaceholder, Radius, RemoveGlass)
	local Radius = Radius or 14
	local IconLabelFrame
	local IconData = Creator.Icon(Icon)
	if Icon and Icon ~= "" and IconData then
		IconLabelFrame = New("ImageLabel", {
			Image = IconData[1],
			ImageRectSize = IconData[2].ImageRectSize,
			ImageRectOffset = IconData[2].ImageRectPosition,
			Size = UDim2.new(0, 18, 0, 18),
			BackgroundTransparency = 1,
			ThemeTag = {
				ImageColor3 = "Icon",
			},
		})
	end

	local TextLabel = New("TextLabel", {
		BackgroundTransparency = 1,
		TextSize = 17,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Regular),
		Size = UDim2.new(1, IconLabelFrame and -29 or 0, 1, 0),
		TextXAlignment = "Left",
		ThemeTag = {
			TextColor3 = IsPlaceholder and "Placeholder" or "Text",
		},
		Text = Text,
	})

	local LabelFrame = New("TextButton", {
		Size = UDim2.new(1, 0, 0, 42),
		Parent = Parent,
		BackgroundTransparency = 1,
		Text = "",
	}, {
		New("Frame", {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
		}, {
			Creator.NewRoundFrame(Radius, "Squircle", {
				ThemeTag = {
					ImageColor3 = "Field",
					ImageTransparency = "FieldTransparency",
				},
				Size = UDim2.new(1, 0, 1, 0),
				Name = "Field",
			}),
			not RemoveGlass and Glass.Pane(Radius, { ZIndex = 2, BackgroundTransparency = 1 }) or nil,
			Creator.NewRoundFrame(Radius, "Squircle", {
				Size = UDim2.new(1, 0, 1, 0),
				Name = "Frame",
				ThemeTag = {
					ImageColor3 = "LabelBackground",
					ImageTransparency = "LabelBackgroundTransparency",
				},
				-- ImageColor3 = Color3.new(1,1,1),
				-- ImageTransparency = .95
			}, {
				New("UIPadding", {
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
				}),
				New("UIListLayout", {
					FillDirection = "Horizontal",
					Padding = UDim.new(0, 8),
					VerticalAlignment = "Center",
					HorizontalAlignment = "Left",
				}),
				IconLabelFrame,
				TextLabel,
			}),
		}),
	})

	return LabelFrame
end

return Label
