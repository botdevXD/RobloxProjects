-- Made by 0x74_Dev on the 26/11/2023

local ragdollModule = {
	cached = {},
	debugging = false
}
ragdollModule.__index = ragdollModule

local oldPrintFunction = print
local function print(...)
	if not ragdollModule.debugging then return end
	
	return oldPrintFunction(...)
end

local function getMotor6D(startObject, motorName)
	-- TODO probably remove this function as it's probably not going to be used.
	if typeof(startObject) ~= "Instance" or type(motorName) ~= "string" then return end
	
	for _, Motor in ipairs(startObject:GetDescendants()) do
		if not Motor:IsA("Motor6D") or Motor.Name ~= motorName then continue end
		
		return Motor
	end
end

local function tableCombine(table1, table2)
	local tableClone = table.clone(table1)
	
	for _, Object in ipairs(table2) do
		table.insert(tableClone, Object)
	end
	
	return tableClone
end

function ragdollModule.new(Player)
	if ragdollModule.cached[Player] then return ragdollModule.cached[Player] end
	
	local self = setmetatable({}, ragdollModule)
	
	self.Player = Player :: Player
	self.defaultJoints = {}
	self.customJoints = {}
	self.Attachments = {}
	self.Connections = {}
	
	self:SetupConnections()
	
	table.insert(self.Connections, self.Player.CharacterAdded:Connect(function()
		self:SetupConnections()
	end))
	
	ragdollModule.cached[Player] = self
	
	return self
end

function ragdollModule:BuildJoints()
	if type(self.defaultJoints) ~= "table" or type(self.customJoints) ~= "table" then return end
	
	local character = self.Player.Character :: Model
	if not character then return end
	
	if #self.defaultJoints <= 0 then
		-- grab all default joints and smack them into the table for later use and cached to reduce memory and increase speed

		for _, characterPart in ipairs(character:GetChildren()) do
			if not characterPart:IsA("BasePart") then continue end

			for _, Joint in ipairs(characterPart:GetChildren()) do
				if not Joint:IsA("Motor6D") then continue end

				table.insert(self.defaultJoints, Joint)
			end
		end		

		print(`defaullt joints for {self.Player.Name}'s character`, self.defaultJoints)
	end

	if #self.defaultJoints > 0 and #self.customJoints <= 0 then
		-- set up custom joints once per character
		for _, Joint in ipairs(self.defaultJoints) do
			if not Joint.Part0 or not Joint.Part1 then continue end

			local ballSocket = Instance.new("BallSocketConstraint")
			ballSocket.LimitsEnabled = true
			ballSocket.TwistLimitsEnabled = true
			ballSocket.Enabled = false

			local attachment0 = Instance.new("Attachment")
			local attachment1 = Instance.new("Attachment")
			
			attachment0.CFrame = Joint.C0
			attachment1.CFrame = Joint.C1
			
			attachment0.Parent =  Joint.Part0
			attachment1.Parent =  Joint.Part1
			
			ballSocket.Attachment0 = attachment0
			ballSocket.Attachment1 = attachment1

			ballSocket.Parent = Joint.Parent

			table.insert(self.customJoints, ballSocket)

			table.insert(self.Attachments, attachment0)
			table.insert(self.Attachments, attachment1)
		end

		print("making custom joints!")
	end
end

function ragdollModule:Ragdoll()
	if type(self.defaultJoints) ~= "table" or type(self.customJoints) ~= "table" then return end
	
	local character = self.Player.Character :: Model
	if not character then return end
	
	local humanoid = character:FindFirstChildWhichIsA("Humanoid") :: Humanoid
	if not humanoid then return end
	
	humanoid.AutoRotate = false
	
	local allJoints = tableCombine(self.defaultJoints, self.customJoints)
	
	for _, Joint in ipairs(allJoints) do
		if Joint:IsA("BallSocketConstraint") then
			Joint.Enabled = true
		else
			Joint.Enabled = false
		end
	end
	
	table.clear(allJoints) -- clear off all joints table to the garbage collector to reduce memory after use
end

function ragdollModule:UnRagdoll()
	local character = self.Player.Character :: Model
	if not character then return end

	local humanoid = character:FindFirstChildWhichIsA("Humanoid") :: Humanoid
	if not humanoid then return end

	humanoid.AutoRotate = true
	
	local allJoints = tableCombine(self.defaultJoints, self.customJoints)

	for _, Joint in ipairs(allJoints) do
		if Joint:IsA("BallSocketConstraint") then
			Joint.Enabled = false
		else
			Joint.Enabled = true
		end
	end

	table.clear(allJoints) -- clear off all joints table to the garbage collector to reduce memory after use
end

function ragdollModule:SetupConnections()
	self:ClearConnections()
	
	local character = self.Player.Character :: Model
	if not character then return end
	
	local humanoid = character:FindFirstChildWhichIsA("Humanoid") :: Humanoid
	if not humanoid then return end
	
	humanoid.BreakJointsOnDeath = false
	
	table.clear(self.Attachments)
	table.clear(self.defaultJoints)
	table.clear(self.customJoints)
	
	self:BuildJoints()
	
	table.insert(self.Connections, humanoid.StateChanged:Connect(function(_, newState)
		if newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Dead then
			print(`attempting to ragdoll {self.Player.Name}'s character`)
			self:Ragdoll()
		end
	end))
end

function ragdollModule:ClearConnections()
	if type(self.Connections) == "table" then
		for _, Connection in ipairs(self.Connections) do
			if typeof(Connection) ~= "RBXScriptConnection" then continue end

			pcall(Connection.Disconnect, Connection)
		end

		table.clear(self.Connections)
	end
end

function ragdollModule:Destroy()
	if type(self.ClearConnections) == "function" then
		self:ClearConnections()
	end
	
	if type(self.defaultJoints) == "table" then
		table.clear(self.defaultJoints)
	end
	
	if type(self.customJoints) == "table" then
		table.clear(self.customJoints)
	end
	
	ragdollModule.cached[self.Player] = nil
	
	table.clear(self)
end

return ragdollModule
