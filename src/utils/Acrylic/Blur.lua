-- Credits: Fluent - Dawid

local cloneref = (cloneref or clonereference or function(instance) return instance end)


local Creator = require("../../modules/Creator")
local New = Creator.New


local ScreenSpace = require("../../modules/ScreenSpace")
local viewportPointToWorld = unpack(require("./Utils"))

-- Measured in the engine: the blur spreads past a pane by about 9px sideways but hardly
-- at all up and down. Panes stop short by that much so the blur ends at the window's edge.
local SPREAD_X, SPREAD_Y = 8, 1

-- Rounded corners are stepped: each strip starts this far down, as a share of the radius,
-- and reaches as far sideways as the corner allows at that height.
local CORNER_STEPS = { 0, 0.18, 0.4, 0.75 }

local BlurFolder = Instance.new("Folder", cloneref(game:GetService("Workspace")).CurrentCamera)


local function createAcrylic()
	local Part = New("Part", {
		Name = "Body",
		Color = Color3.new(0, 0, 0),
		Material = Enum.Material.Glass,
		Size = Vector3.new(1, 1, 0),
		Anchored = true,
		CanCollide = false,
		Locked = true,
		CastShadow = false,
		Transparency = 0.98,
	}, {
		New("SpecialMesh", {
			MeshType = Enum.MeshType.Brick,
			Offset = Vector3.new(0, 0, -0.000001),
		}),
	})

	return Part
end


local function createAcrylicBlur(distance, radius)
	local cleanups = {}

	distance = distance or 0.001
	local target

	-- The middle pane is the one callers show, hide and destroy; the strips follow it.
	local model = createAcrylic()
	model.Parent = BlurFolder
	local strips = {}
	for _ = 1, (#CORNER_STEPS - 1) * 2 do
		local strip = createAcrylic()
		strip.Parent = BlurFolder
		table.insert(strips, strip)
	end
	table.insert(cleanups, model:GetPropertyChangedSignal("Transparency"):Connect(function()
		for _, strip in strips do
			strip.Transparency = model.Transparency
		end
	end))

	local function place(part, view, left, top, right, bottom)
		if right <= left or bottom <= top then
			part.Mesh.Scale = Vector3.zero
			return
		end
		local topLeft = viewportPointToWorld(Vector2.new(left, top), distance)
		local topRight = viewportPointToWorld(Vector2.new(right, top), distance)
		local bottomRight = viewportPointToWorld(Vector2.new(right, bottom), distance)

		part.CFrame = CFrame.fromMatrix((topLeft + bottomRight) / 2, view.XVector, view.YVector, view.ZVector)
		part.Mesh.Scale = Vector3.new((topRight - topLeft).Magnitude, (topRight - bottomRight).Magnitude, 0)
	end

	-- Reads the pane's place every time, so a moved window or a changed inset cannot leave
	-- the blur behind.
	local function render()
		local camera = cloneref(game:GetService("Workspace")).CurrentCamera
		if not camera or not target then
			return
		end

		local view = camera.CFrame
		local corner, size = ScreenSpace.Position(target), target.AbsoluteSize
		local left, right = corner.X + SPREAD_X, corner.X + size.X - SPREAD_X
		local top, bottom = corner.Y + SPREAD_Y, corner.Y + size.Y - SPREAD_Y
		local round = math.min((radius or 0) * Creator.GetScale(), size.X / 2, size.Y / 2)

		for step = 1, #CORNER_STEPS - 1 do
			local from, to = CORNER_STEPS[step] * round, CORNER_STEPS[step + 1] * round
			-- How far the corner's arc sits in from the side, a pixel below the strip's top.
			local rise = math.clamp(round - from - 1, 0, round)
			local inset = round - math.sqrt(round * round - rise * rise)
			place(strips[step * 2 - 1], view, left + inset, top + from, right - inset, top + to)
			place(strips[step * 2], view, left + inset, bottom - to, right - inset, bottom - from)
		end
		local middle = CORNER_STEPS[#CORNER_STEPS] * round
		place(model, view, left, top + middle, right, bottom - middle)
	end

	local function onChange(rbx)
		target = rbx
		task.spawn(render)
	end

	local function renderOnChange()
		local camera = cloneref(game:GetService("Workspace")).CurrentCamera
		if not camera then
			return
		end

		table.insert(cleanups, camera:GetPropertyChangedSignal("CFrame"):Connect(render))
		table.insert(cleanups, camera:GetPropertyChangedSignal("ViewportSize"):Connect(render))
		table.insert(cleanups, camera:GetPropertyChangedSignal("FieldOfView"):Connect(render))
		task.spawn(render)
	end

	model.Destroying:Connect(function()
		for _, strip in strips do
			strip:Destroy()
		end
		for _, item in cleanups do
			pcall(function()
				item:Disconnect()
			end)
		end
	end)

	renderOnChange()

	return onChange, model
end

return function(distance, radius)
	local Blur = {}
	local onChange, model = createAcrylicBlur(distance, radius)

	local comp = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
	})

	Creator.AddSignal(comp:GetPropertyChangedSignal("AbsolutePosition"), function()
		onChange(comp)
	end)

	Creator.AddSignal(comp:GetPropertyChangedSignal("AbsoluteSize"), function()
		onChange(comp)
	end)

	Blur.AddParent = function(Parent)
		Creator.AddSignal(Parent:GetPropertyChangedSignal("Visible"), function()
			--Blur.SetVisibility(Parent.Visible)
		end)
	end

	Blur.SetVisibility = function(Value)
		model.Transparency = Value and 0.98 or 1
	end

	Blur.Frame = comp
	Blur.Model = model

	return Blur
end