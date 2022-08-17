local Debris = game:GetService("Debris")

function AddAttachmentsToBlade(Tool, HitBox, Rotation)
	Rotation = Rotation or CFrame.Angles(0, 0, 0)
	
	local Origin = HitBox.Position;

	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Blacklist
	Params.FilterDescendantsInstances = {Tool}
	Params.IgnoreWater = true
	
	local PartSizeY = HitBox.Size.Y
	
	local YAxis = 0
	for Index = 1, PartSizeY * 2 do
		local Direction = Vector3.new(0, 0, 0)
		
		local Attachment0 = Instance.new("Attachment", HitBox)
		local Attachment1 = Instance.new("Attachment", HitBox)

		local Beam = Instance.new("Beam", HitBox)
		Beam.Attachment0 = Attachment0
		Beam.Width0 = .2
		Beam.Width1 = .2
		
		Attachment0.Name = tostring(Index)
		Attachment0.WorldCFrame = HitBox.CFrame
		Attachment0.WorldCFrame = Attachment0.WorldCFrame + Vector3.new(0, ((PartSizeY - 2) / 2) + (-Index / 2) + 1, 0)
		Attachment0.WorldCFrame *= CFrame.Angles(0, math.rad(90), 0)
		
		YAxis += 0.5
		
		local RayCast = workspace:Raycast(Attachment0.WorldPosition, Attachment0.WorldCFrame.LookVector  * 20, Params);

		if RayCast then
			
			Beam.Attachment1 = Attachment1

			Attachment1.Name = "Attachment1"
			Attachment1.WorldCFrame = CFrame.new(RayCast.Position, RayCast.Position + RayCast.Normal)
			
			Debris:AddItem(Beam, 1.5)
			Debris:AddItem(Attachment0, 1.5)
			Debris:AddItem(Attachment1, 1.5)
		else
			Beam:Destroy()
			Attachment1:Destroy()
			Attachment0:Destroy()
		end
	end;
end

local KrisSword = workspace.KrisSword
local GreatSword = workspace.GreatSword

AddAttachmentsToBlade(GreatSword, GreatSword.Handle.Hitbox)
AddAttachmentsToBlade(KrisSword, KrisSword.Handle.Hitbox)
