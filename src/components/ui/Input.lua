local Input = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween
local Glass = require("../../modules/Glass")

function Input.New(Placeholder, Icon, Parent, Type, Callback, OnChange, Radius, ClearTextOnFocus, RemoveGlass)
	Type = Type or "Input"
	local Radius = Radius or 14
	local IconInputFrame
	local IconData = Creator.Icon(Icon)
	if Icon and Icon ~= "" and IconData then
		IconInputFrame = New("ImageLabel", {
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

	local isMulti = Type == "Textarea"

	local TextBox = New("TextBox", {
		BackgroundTransparency = 1,
		TextSize = 17,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.Regular),
		Size = UDim2.new(1, IconInputFrame and -29 or 0, 1, 0),
		PlaceholderText = Placeholder,
		ClearTextOnFocus = ClearTextOnFocus or false,
		ClipsDescendants = true,
		TextWrapped = isMulti,
		MultiLine = isMulti,
		TextXAlignment = "Left",
		TextYAlignment = Type ~= "Textarea" and "Center" or "Top",
		--AutomaticSize = "XY",
		ThemeTag = {
			PlaceholderColor3 = "PlaceholderText",
			TextColor3 = "Text",
		},
	})

	local Pane = not RemoveGlass and Glass.Pane(Radius, { ZIndex = 2, BackgroundTransparency = 1 }) or nil

	local InputFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 42),
		Parent = Parent,
		BackgroundTransparency = 1,
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
			Pane,
			Creator.NewRoundFrame(Radius, "Squircle", {
				Size = UDim2.new(1, 0, 1, 0),
				Name = "Frame",
				ThemeTag = {
					ImageColor3 = "LabelBackground",
					ImageTransparency = "LabelBackgroundTransparency",
				},
				--[[ImageColor3 = Color3.new(1, 1, 1),
				ImageTransparency = 1,]]
			}, {
				New("UIPadding", {
					PaddingTop = UDim.new(0, Type ~= "Textarea" and 0 or 12),
					PaddingLeft = UDim.new(0, 12),
					PaddingRight = UDim.new(0, 12),
					PaddingBottom = UDim.new(0, Type ~= "Textarea" and 0 or 12),
				}),
				New("UIListLayout", {
					FillDirection = "Horizontal",
					Padding = UDim.new(0, 8),
					VerticalAlignment = Type ~= "Textarea" and "Center" or "Top",
					HorizontalAlignment = "Left",
				}),
				IconInputFrame,
				TextBox,
			}),
		}),
	})

	-- InputFrame:GetPropertyChangedSignal("AbsoluteSize"), function()
	--     TextBox.Size = UDim2.new(
	--         0,
	--         IconInputFrame and InputFrame.AbsoluteSize.X -29-12 or InputFrame.AbsoluteSize.X-12,
	--         1,
	--         0
	--     )
	-- end)

	-- Focus has to be visible: the rim becomes one full line in the accent color.
	if Pane then
		local function SetFocus(Focused)
			Pane.Light.UIGradient.Enabled = not Focused
			Creator.SetThemeTag(Pane.Light, { Color = Focused and "Primary" or "GlassRim" }, 0.12)
		end
		Creator.AddSignal(TextBox.Focused, function()
			SetFocus(true)
		end)
		Creator.AddSignal(TextBox.FocusLost, function()
			SetFocus(false)
		end)
	end

	if OnChange then
		Creator.AddSignal(TextBox:GetPropertyChangedSignal("Text"), function()
			if Callback then
				Creator.SafeCallback(Callback, TextBox.Text)
			end
		end)
	else
		Creator.AddSignal(TextBox.FocusLost, function()
			if Callback then
				Creator.SafeCallback(Callback, TextBox.Text)
			end
		end)
	end

	return InputFrame
end

return Input
