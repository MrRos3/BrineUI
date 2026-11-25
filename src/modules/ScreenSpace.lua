-- One coordinate space for everything on screen: pixels from the viewport's top left.
-- Where AbsolutePosition starts counting depends on the host (below the top bar or at
-- the very top), so positions are taken relative to their own ScreenGui.
local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

local UserInputService = cloneref(game:GetService("UserInputService"))

local GuiService = cloneref(game:GetService("GuiService"))
local Workspace = cloneref(game:GetService("Workspace"))

local ScreenSpace = {}

-- Where a ScreenGui starts. Zero when it covers the viewport, as ours ask to; the top bar's
-- size in a host that keeps it below the bar anyway.
function ScreenSpace.Origin(Gui)
	local Camera = Workspace.CurrentCamera
	if not Camera then
		return Vector2.zero
	end
	local Missing = Camera.ViewportSize - Gui.AbsoluteSize
	if Missing.X < 1 and Missing.Y < 1 then
		return Vector2.zero
	end
	local Inset = GuiService:GetGuiInset()
	return Vector2.new(math.clamp(Missing.X, 0, Inset.X), math.clamp(Missing.Y, 0, Inset.Y))
end

function ScreenSpace.Position(Object)
	local Gui = Object:FindFirstAncestorOfClass("ScreenGui")
	if not Gui then
		return Object.AbsolutePosition
	end
	return Object.AbsolutePosition - Gui.AbsolutePosition + ScreenSpace.Origin(Gui)
end

function ScreenSpace.Mouse()
	return UserInputService:GetMouseLocation()
end

function ScreenSpace.Contains(Object, Point)
	local Corner = ScreenSpace.Position(Object)
	local Size = Object.AbsoluteSize
	return Point.X >= Corner.X
		and Point.X <= Corner.X + Size.X
		and Point.Y >= Corner.Y
		and Point.Y <= Corner.Y + Size.Y
end

return ScreenSpace
