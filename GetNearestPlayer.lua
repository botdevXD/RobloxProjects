local Players = game:GetService("Players")

local PlayerUtils = {}

function PlayerUtils.GetNearPlayer(Player, MaxDistance)
	MaxDistance = type(MaxDistance) == "number" and MaxDistance or 100

	local OldDistance = math.huge
	local Target = nil
	local Attacker = nil

	for _, GamePlayer in ipairs(Players:GetPlayers()) do
		if GamePlayer ~= Player then
			local GameCharacter = GamePlayer.Character
			local LocalCharacter = Player

			if GameCharacter and LocalCharacter then
				local GameRoot = GameCharacter:FindFirstChild("HumanoidRootPart")
				local GameHumanoid = GameCharacter:FindFirstChild("Humanoid")
				local LocalRoot = LocalCharacter:FindFirstChild("HumanoidRootPart")

				if GameRoot and LocalRoot and GameHumanoid then
					local Distance = (LocalRoot.Position - GameRoot.Position).Magnitude

					if (Distance <= MaxDistance) and (Distance < OldDistance) and GameHumanoid.Health > 0 then
						OldDistance = Distance
						Target = GameCharacter
						Attacker = LocalCharacter
					end
				end
			end
		end
	end

	return Target, Attacker, OldDistance
end

return PlayerUtils
