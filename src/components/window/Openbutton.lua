-- The badge a minimized window leaves behind: a rounded glass square with the window's
-- icon. Click it to reopen the window, or drag it out of the way.
local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween
local Glass = require("../../modules/Glass")
local CreateBrineMark = require("./BrineMark")

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local UserInputService = cloneref(game:GetService("UserInputService"))
local GuiService = cloneref(game:GetService("GuiService"))

local SIZE = 52
local DefaultCorner = UDim.new(0, 16)
-- Movement under this many pixels still counts as a click.
local DRAG_THRESHOLD = 4
-- Gap between Roblox's top bar and the badge.
local TOP_GAP = 14

-- The window's ScreenGui ignores the top bar inset, so the default spot starts below it.
local function DefaultPosition()
	local Ok, Inset = pcall(function()
		return GuiService:GetGuiInset()
	end)
	local Top = Ok and Inset and Inset.Y or 0
	return UDim2.new(0.5, 0, 0, Top + TOP_GAP + SIZE / 2)
end

function OpenButton.New(Window)
	local OpenButtonMain = {
		Button = nil,
		OnClick = nil,
	}

	local Icon
	local CanDrag = true
	-- Once dragged or placed by a script, the badge stays where it was put.
	local Placed = false
	local BaseScale = 1

	local Title = New("TextLabel", {
		Text = Window.Title,
		TextSize = 16,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		BackgroundTransparency = 1,
		AutomaticSize = "XY",
		Visible = false,
		LayoutOrder = 2,
		ThemeTag = {
			TextColor3 = "WindowTopbarTitle",
		},
	})

	local Stroke = Glass.Stroke()
	Stroke.Name = "UIStroke"

	local Container = New("Frame", {
		Size = UDim2.fromOffset(SIZE, SIZE),
		Position = DefaultPosition(),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Parent = Window.Parent,
		BackgroundTransparency = 1,
		Visible = false,
	})

	local UIScale = New("UIScale", {
		Scale = 1,
	})

	-- Keeps the old names (Button, Button.TextButton, UIStroke, UICorner) that scripts reach for.
	local Button = New("Frame", {
		Size = UDim2.fromOffset(SIZE, SIZE),
		AutomaticSize = "X",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Parent = Container,
		BackgroundTransparency = 0.15,
		ZIndex = 99,
		ThemeTag = {
			BackgroundColor3 = "WindowBackground",
		},
	}, {
		UIScale,
		New("UICorner", {
			CornerRadius = DefaultCorner,
		}),
		Stroke,
		Glass.Pane(DefaultCorner.Offset, { ZIndex = 99 }),
		New("TextButton", {
			Text = "",
			AutomaticSize = "X",
			Size = UDim2.new(0, SIZE, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 100,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, DefaultCorner.Offset - 4),
			}),
			New("UIListLayout", {
				Padding = UDim.new(0, 10),
				FillDirection = "Horizontal",
				VerticalAlignment = "Center",
				HorizontalAlignment = "Center",
				SortOrder = "LayoutOrder",
			}),
			Title,
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15),
			}),
		}),
	})
	local Hit = Button.TextButton

	OpenButtonMain.Button = Button

	function OpenButtonMain:SetIcon(newIcon)
		if Icon then
			Icon:Destroy()
		end
		if newIcon then
			Icon = Creator.Image(newIcon, Window.Title, 0, Window.Folder, "OpenButton", true, Window.IconThemed, "WindowTopbarIcon")
			Icon.Size = UDim2.fromOffset(24, 24)
		else
			Icon = CreateBrineMark(nil)
		end
		Icon.LayoutOrder = 1
		Icon.Parent = Hit
	end
	OpenButtonMain:SetIcon(Window.Icon)

	-- Press feedback, then a click or a drag, decided by how far the pointer moved.
	local Pressed, Start, StartPosition, Dragged
	Creator.AddSignal(Hit.InputBegan, function(Input)
		if
			Input.UserInputType ~= Enum.UserInputType.MouseButton1
			and Input.UserInputType ~= Enum.UserInputType.Touch
		then
			return
		end
		Pressed, Dragged = Input, false
		Start, StartPosition = Input.Position, Container.Position
		Tween(UIScale, 0.12, { Scale = BaseScale * 0.92 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
	end)
	Creator.AddSignal(UserInputService.InputChanged, function(Input)
		if not Pressed or not CanDrag then
			return
		end
		local Moved = Input.UserInputType == Enum.UserInputType.MouseMovement
			or (Input.UserInputType == Enum.UserInputType.Touch and Input == Pressed)
		if not Moved then
			return
		end
		local Delta = Input.Position - Start
		if Dragged or Delta.Magnitude > DRAG_THRESHOLD then
			Dragged, Placed = true, true
			Container.Position = UDim2.new(
				StartPosition.X.Scale,
				StartPosition.X.Offset + Delta.X,
				StartPosition.Y.Scale,
				StartPosition.Y.Offset + Delta.Y
			)
		end
	end)
	Creator.AddSignal(UserInputService.InputEnded, function(Input)
		if not Pressed then
			return
		end
		if Input ~= Pressed and Input.UserInputType ~= Pressed.UserInputType then
			return
		end
		Pressed = nil
		Tween(UIScale, 0.18, { Scale = BaseScale }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
		if not Dragged and OpenButtonMain.OnClick then
			OpenButtonMain.OnClick()
		end
	end)
	Creator.AddSignal(Hit.MouseEnter, function()
		if not Pressed then
			Tween(UIScale, 0.15, { Scale = BaseScale * 1.06 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		end
	end)
	Creator.AddSignal(Hit.MouseLeave, function()
		if not Pressed then
			Tween(UIScale, 0.15, { Scale = BaseScale }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		end
	end)

	function OpenButtonMain:Visible(v)
		if v and not Container.Visible then
			if not Placed then
				Container.Position = DefaultPosition()
			end
			UIScale.Scale = BaseScale * 0.6
			Container.Visible = true
			Tween(UIScale, 0.32, { Scale = BaseScale }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
		else
			Container.Visible = v
		end
	end

	function OpenButtonMain:SetScale(scale)
		BaseScale = scale
		Container.Size = UDim2.fromOffset(SIZE * scale, SIZE * scale)
		UIScale.Scale = scale
	end

	function OpenButtonMain:Edit(OpenButtonConfig)
		local OpenButtonModule = {
			Title = OpenButtonConfig.Title,
			Icon = OpenButtonConfig.Icon,
			Enabled = OpenButtonConfig.Enabled,
			Position = OpenButtonConfig.Position,
			OnlyIcon = OpenButtonConfig.OnlyIcon,
			Draggable = OpenButtonConfig.Draggable,
			OnlyMobile = OpenButtonConfig.OnlyMobile,
			CornerRadius = OpenButtonConfig.CornerRadius or DefaultCorner,
			StrokeThickness = OpenButtonConfig.StrokeThickness or (OpenButtonConfig.Color and 2 or 1),
			Scale = OpenButtonConfig.Scale or 1,
			Color = OpenButtonConfig.Color,
		}

		if OpenButtonModule.Enabled == false then
			Window.IsOpenButtonEnabled = false
		end
		-- The badge shows on every device unless a script asks for touch only.
		Window.OpenButtonMobileOnly = OpenButtonModule.OnlyMobile == true

		if OpenButtonModule.Draggable == false then
			CanDrag = false
		end

		if OpenButtonModule.Position then
			Placed = true
			Container.Position = OpenButtonModule.Position
		end

		-- A badge by default; a title makes it a wider pill unless OnlyIcon says otherwise.
		if OpenButtonModule.Title then
			Title.Text = OpenButtonModule.Title
			Creator:ChangeTranslationKey(Title, OpenButtonModule.Title)
		end
		Title.Visible = OpenButtonModule.OnlyIcon == false
			or (OpenButtonModule.OnlyIcon == nil and OpenButtonModule.Title ~= nil)

		if OpenButtonModule.Icon then
			OpenButtonMain:SetIcon(OpenButtonModule.Icon)
		end

		-- A caller's gradient replaces the glass rim.
		if OpenButtonModule.Color then
			Creator.AddThemeObject(Button.UIStroke, { Color = "White", Transparency = "BackgroundTransparency" })
			Button.UIStroke.Transparency = 0
			Button.UIStroke.UIGradient.Transparency = NumberSequence.new(0)
			Button.UIStroke.UIGradient.Color = OpenButtonModule.Color
		end

		Button.UICorner.CornerRadius = OpenButtonModule.CornerRadius
		Hit.UICorner.CornerRadius =
			UDim.new(OpenButtonModule.CornerRadius.Scale, OpenButtonModule.CornerRadius.Offset - 4)
		Button.UIStroke.Thickness = OpenButtonModule.StrokeThickness

		OpenButtonMain:SetScale(OpenButtonModule.Scale)
	end

	return OpenButtonMain
end

return OpenButton
