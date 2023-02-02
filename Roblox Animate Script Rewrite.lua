-- Scripted by 0x74_Dev / _Ben / ILoveToCode / botdevXD

local Services = {
	RunService = game:GetService("RunService")
}

local Character = script.Parent :: Model
local Humanoid = Character:WaitForChild("Humanoid", 5) :: Humanoid
local RootPart = Character:WaitForChild("HumanoidRootPart", 5) :: Part
local CurrentAnim = nil

if not RootPart then return end
if not Humanoid then return end

local Animations = {
	{
		type = "walk",
		AnimationId = "rbxassetid://507767714", -- Default Roblox walking animation (R15)
		Priority = Enum.AnimationPriority.Movement
	},
	{
		type = "idle",
		AnimationId = "rbxassetid://507766666", -- Default Roblox idle animation (R15)
		Priority = Enum.AnimationPriority.Idle
	},
	{
		type = "swimming",
		AnimationId = "rbxassetid://507784897", -- Default Roblox swimming animation (R15)
		Priority = Enum.AnimationPriority.Movement
	},
	{
		type = "swimming_idle",
		AnimationId = "rbxassetid://507785072", -- Default Roblox swimming idle animation (R15)
		Priority = Enum.AnimationPriority.Idle
	},
	{
		type = "sit",
		AnimationId = "rbxassetid://2506281703", -- Default  Roblox sitting animation (R15)
		Priority = Enum.AnimationPriority.Idle
	}
}

local Emotes = {}

local function PreloadAnimations()
	for _, AnimationData in ipairs(Animations) do
		if type(AnimationData) ~= "table" then continue end
		if type(AnimationData.AnimationId) ~= "string" then continue end
		if not AnimationData.AnimationId:find("rbxassetid://") then continue end
		if not AnimationData.type then continue end
		
		local Success = false
		local LoadedAnimation = nil
		
		local AnimationInstance = Instance.new("Animation", nil)
		AnimationInstance.AnimationId = AnimationData.AnimationId
		
		while not Success do
			local FunctionSuccess, FunctionReturn = pcall(Humanoid.LoadAnimation, Humanoid, AnimationInstance)
			Success = FunctionSuccess
			LoadedAnimation = FunctionReturn
			
			task.wait()
		end
		
		if AnimationData.Priority then
			LoadedAnimation.Priority = AnimationData.Priority
		end
		
		Animations[AnimationData.type] = LoadedAnimation
		
		AnimationInstance:Destroy()
	end
end

local function PlayAnimation(AnimationName, AnimationSpeed)
	local Animation = Animations[AnimationName]
	if not Animation then return end
	if Animation == CurrentAnim then return end
	
	CurrentAnim = Animation
	Animation:Play()
	
	if AnimationSpeed then
		Animation:AdjustSpeed(AnimationSpeed)
	end
end

local function StopAnimations(Exceptions)
	if Exceptions ~= nil and type(Exceptions) ~= "table" then return end
	
	Exceptions = Exceptions or {}
	
	for AnimationIndex, Animation in pairs(Animations) do
		if typeof(Animation) ~= "Instance" then continue end
		if table.find(Exceptions, AnimationIndex) then continue end
		
		Animation:Stop()
		
		if CurrentAnim == Animation then
			CurrentAnim = nil
		end
	end
end

PreloadAnimations()

Services.RunService.RenderStepped:Connect(function()
	if not Humanoid then return end
	
	local HumanoidState = Humanoid:GetState()
	local CurrentPlayerSpeed = math.floor((RootPart.Velocity * Vector3.new(1, 0, 1)).Magnitude + 0.1)
	
	if HumanoidState == Enum.HumanoidStateType.Running then
		-- Walk Animation
		
		if CurrentPlayerSpeed >= 1 then
			StopAnimations({"walk"})
			PlayAnimation("walk")
		else
			StopAnimations({"idle"})
			PlayAnimation("idle")
		end
	elseif HumanoidState == Enum.HumanoidStateType.Swimming then
		-- Swimming Animation
		
		if CurrentPlayerSpeed >= 1 then
			StopAnimations({"swimming"})
			PlayAnimation("swimming")
		else
			StopAnimations({"swimming_idle"})
			PlayAnimation("swimming_idle")
		end
	elseif HumanoidState == Enum.HumanoidStateType.Seated then
		-- Seated Animation
		
		StopAnimations({"sit"})
		PlayAnimation("sit")
	else
		StopAnimations()
	end
end)
