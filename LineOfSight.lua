function LineOfSight(LocalCharacter, TargetCharacter)
	if typeof(TargetCharacter) == "Instance" then

		if LocalCharacter then
			local Blacklist = {}
			local Parts = (function()
				local Parts = {}

				for _, Object in ipairs(TargetCharacter:GetChildren()) do
					if Object:IsA("BasePart") then
						Parts[Object.Name] = Object
					elseif Object:IsA("Accessory") then
						table.insert(Blacklist, Object)
					end
				end

				return Parts
			end)()

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			raycastParams.FilterDescendantsInstances = {LocalCharacter, unpack(Blacklist)}
			raycastParams.IgnoreWater = true
			
			for _, Object in ipairs(LocalCharacter:GetChildren()) do
				local TargetObject = Parts[Object.Name]

				if typeof(TargetObject) == "Instance" then
					local ObjectPosition = Object.Position
					local RayResult = workspace:Raycast(ObjectPosition, CFrame.lookAt(ObjectPosition, TargetObject.Position).LookVector * 1000, raycastParams)

					if RayResult then
						if RayResult.Instance:IsDescendantOf(TargetCharacter) then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

-- Example code below:

if LineOfSight(game.Players.LocalPlayer.Character, workspace:WaitForChild("Dummy", 5)) then
  print("Target is visible")
else
  print("Target is not visible")
end
