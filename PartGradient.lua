local PartGradient = {}

local Surfaces = {
	Enum.NormalId.Top,
	Enum.NormalId.Bottom,
	Enum.NormalId.Front,
	Enum.NormalId.Back,
	Enum.NormalId.Left,
	Enum.NormalId.Right
}

function PartGradient.Add(Part, Color, Offset, Rotation, Transparency)
	if Part:IsA("BasePart") then
		Offset = typeof(Offset) == "Vector2" and Offset or Vector2.new(0, 0)
		Rotation = type(Rotation) == "number" and Rotation or 0
		Transparency = typeof(Transparency) == "NumberSequence" and Transparency or NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0)}
		
		for Index, Face in ipairs(Surfaces) do
			local SurfaceGui = Instance.new("SurfaceGui", Part)
			SurfaceGui.Name = "Gradient | " .. tostring(Index)
			SurfaceGui.Face = Face
			SurfaceGui.ResetOnSpawn = false
			SurfaceGui.Adornee = Part
			
			local Background = Instance.new("Frame", SurfaceGui)
			Background.Size = UDim2.new(1, 0, 1, 0)
			Background.Name = "Background"
			Background.BorderSizePixel = 0
			Background.Visible = true
			Background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			
			local Gradient = Instance.new("UIGradient", Background)
			Gradient.Color = Color
			Gradient.Offset = Offset
			Gradient.Transparency = Transparency
			Gradient.Rotation = Rotation
		end
	else
		return warn(("{PartGradient} expected a BasePart got '%s'"):format(Part.ClassName))
	end
end

return PartGradient
