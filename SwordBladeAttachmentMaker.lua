local Debris = game:GetService("Debris")

function AddAttachmentsToBlade(Tool, HitBox, Rotation)
	Rotation = Rotation or CFrame.Angles(0, 0, 0)

	local Handle = Tool:WaitForChild("Handle", 5)
	local OldOrientation = Handle.Orientation
	local OriginCF = Handle.CFrame;
	local PartSizeY = HitBox.Size.Y
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Blacklist
	Params.FilterDescendantsInstances = {Tool}
	Params.IgnoreWater = true

	if not HitBox:FindFirstChild("HitBoxAttachment") then
		Handle.Parent = workspace
		Handle.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(90), math.rad(0), math.rad(0))

		for Index = 1, PartSizeY * 2 do
			local Attachment0 = Instance.new("Attachment", HitBox)

			Attachment0.Name = "HitBoxAttachment"
			Attachment0.WorldCFrame = HitBox.CFrame
			Attachment0.WorldCFrame = Attachment0.WorldCFrame + Vector3.new(0, ((PartSizeY - 2) / 2) + (-Index / 2) + 1, 0)
			Attachment0.WorldCFrame *= CFrame.Angles(0, math.rad(90), 0)
		end

		Handle.CFrame = OriginCF
		Handle.Parent = Tool
	end
end

AddAttachmentsToBlade(script.Parent.Parent, script.Parent:WaitForChild("Hitbox", 5))
