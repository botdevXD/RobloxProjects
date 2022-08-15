---!strict

local ExampleCode = [===[
    -- Made by _Ben#2020 / 0x74_Dev / benthreadgold
    -- EXAMPLE CODE BELOW

    local AnimationController = require(game:GetService("ReplicatedStorage"):WaitForChild("AnimationController", 5));
    local AnimationObject = AnimationController.new(<player>, <scope> optional but needed if you want to create multiple classes / objects on one instance!); -- Creates a new animation object / class
    local TestAnimation = AnimationObject:Add({
        ID = "rbxassetid://0", -- The animation ID
        Name = "Test1", -- The name of your animation (can be anything but must be a string) this will be used for grabbing animations with the 'GetAnimation' (Function)
        Type = "Walking" -- The type for your animation this is optional but lets say you used it... you could stop all animations with the same type using the 'StopAnimationType' (Function) useful for movement systems etc
    });

    TestAnimation:AddMarkerHit("Hit", function() -- The first parameter / arg is meant to be the name of your event within the animation so as soon as your animation hits that keyframe with the event it will fire and this function will listen for that and respond back to your function with it's data!
        print("omg the hit event within my keyframe was fired!")
    end)

    TestAnimation:Finished(function() -- Adds your function into the animations finished queue, this will be called as soon as the animation finishes (does not get removed!)
        print("Test animation finished playing!")
    end)

    TestAnimation:Play() -- Plays your animation
    TestAnimation:Pause() -- Pauses the animation at it's current keyframe / position
    
    task.delay(0.15, function()
        TestAnimation:Resume() -- Unpauses the animation and continues from it's current position
    end)

    TestAnimation:Stop() -- Completely stops the animation and cannot be resumed you must replay it using the 'Play' (Function)

    TestAnimation:Remove() -- Completely destroys the animation and it's contents and stops the animation (you must create a new animation after using this function!)

    AnimationObject:Reload() -- Reloads all animations in this animation object, useful for when a player dies, prevents constant removing and adding new tables and instances, meaning you can just play the animation instantly without a problem!

    for Index, Controller in ipairs(AnimationController.GetControllersForOperator(<player>)) do -- gets all the animation objects / controllers made by the player / instance provided in the first arg and returns them in an array!
        Controller:Reload() -- Reload the animations within the controller / object!
    end

    local BeansController = AnimationController.GetController(<player>, <scope> optional) -- gets and returns the animation object / controller for that instance / player with the scope if it's included!

    if BeansController ~= nil then
        print("Found the beans controller!", BeansController)
    end

    local BowAnimationExist = AnimationObject:Exists("Shoot") -- Returns false if the animation name provided doesn't exist, if the animation name exists it will return true!
    
    if BowAnimationExist == true then
        local BowShootAnimation = AnimationObject:GetAnimation("Shoot") -- (First arg is the animation name!) Returns nil if the animation is not found else returns the animations object / class!

        if BowShootAnimation ~= nil then
            print("Found and got the bow shoot animation object!")
            BowShootAnimation:Play() -- Play the bow shoot animation!
        end

        print("Yay the shooting animation for the bow exists!")
    end

    AnimationObject:StopAnimationType("Walking") -- Stops all animations with the 'Walking' Type, Type cannot be empty or nil else will return a warning... Animation type can be set when using the 'Add' (Function) see example above
    AnimationObject:StopAll() -- Stops all playing animations within the object!

    AnimationObject:Destroy() -- Completely destroys all animations within the object and destroys the object along with it (This renders all functions in the object useless and will cause a error, you must create a new object after using this function!)
]===]

local AnimationFunctions = {}
local AnimationEndTrackFunctions = {}
local AnimationController = {}
AnimationController.__index = AnimationController
AnimationFunctions.__index = AnimationFunctions
AnimationEndTrackFunctions.__index = AnimationEndTrackFunctions

local Controllers = getmetatable(newproxy(true))

local function GetCharacter(Player: Instance)
	local _S, _F = pcall(function()
		Player = Player.Character
	end)
	return Player
end

function AnimationController.GetControllerWithScope(Operator: Instance, scope: string)
	for _, ControllerData in ipairs(Controllers) do
		local ControllerOperator = type(ControllerData) == "table" and ControllerData.Operator

		if ControllerOperator == Operator and ControllerData.scope == scope then
			return ControllerData
		end
	end

	return nil
end

function AnimationController.new(Operator: Instance, Options: any)
	Options = type(Options) == "table" and Options or {}
	Options.scope = type(Options.scope) == "string" and Options.scope or ""

	local CurrentController = AnimationController.GetControllerWithScope(Operator, Options.scope)

	if CurrentController ~= nil then
		return CurrentController
	end

	local self = setmetatable({}, AnimationController)
	self.Operator = Operator
	self.Animations = {}
	self.scope = Options.scope

	table.insert(Controllers, self)
	return self
end

function AnimationController.GetControllersForOperator(Operator: Instance)
	local ControllerResults = {}

	for _, ControllerData in ipairs(Controllers) do
		local ControllerOperator = type(ControllerData) == "table" and ControllerData.Operator

		if ControllerOperator == Operator then
			table.insert(ControllerResults, ControllerData)
		end
	end

	return ControllerResults
end

function AnimationController.ReloadAllControllers(Operator: Instance)
	local Results = AnimationController.GetControllersForOperator(Operator)

	if #Results > 0 then
		for _, AnimationObject in ipairs(Results) do
			AnimationObject:Reload()
		end
	end
end

function AnimationController.GetController(Operator: Instance, scope: any)
	scope = type(scope) == "string" and scope or ""

	return Operator ~= nil and AnimationController.GetControllerWithScope(Operator, scope) or nil
end

-----------------------------------------
-- Animation functions (None Controller)
function AnimationFunctions:AddMarkerHit(MarkerName: string, Func: any, ...)
	-- Start here
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		self.Markers[MarkerName] = { Function = Func, Args = { ... } }
	else
		return warn("Animation controller doesn't exist")
	end

	return self
end

function AnimationFunctions:Stopped(Func: any, ...)
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		if self.StoppedFunctions ~= nil then
			self.StoppedFunctions[#self.StoppedFunctions + 1] = { Function = Func, Args = { ... } }
		end
	else
		return warn("Animation controller doesn't exist")
	end

	return self
end

function AnimationFunctions:Finished(Func: any, ...)
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		if self.FinishedQueue ~= nil then
			self.FinishedQueue[#self.FinishedQueue + 1] = { Function = Func, Args = { ... } }
		end
	else
		return warn("Animation controller doesn't exist")
	end

	return self
end

function AnimationFunctions:IsPlaying()
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		if self.AnimationInstance ~= nil then
			return self.AnimationInstance.IsPlaying
		end
	else
		return warn("Animation controller doesn't exist")
	end

	return self
end

function AnimationFunctions:Play()
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		if self.AnimationInstance ~= nil then
			if not self.AnimationInstance.IsPlaying then
				self:DestroySignals()

				table.insert(
					self.Signals,
					self.AnimationInstance.Changed:Connect(function()
						if not self.AnimationInstance.IsPlaying then
							for _, FuncData in ipairs(self.FinishedQueue) do
								if type(FuncData) == "table" then
									if type(FuncData.Function) == "function" then
										pcall(FuncData.Function, unpack(FuncData.Args))
									end
								end
							end
						end
					end)
				)

				for Index, Value in pairs(self.Markers) do
					Index = tostring(Index)

					if type(Value) == "table" and self.Signals[Index] == nil then
						self.Signals[Index] = self.AnimationInstance:GetMarkerReachedSignal(Index):Connect(function(...)
							for MarkerName, _ in pairs(self.Markers) do
								if tostring(MarkerName) == Index then
									return Value.Function(unpack(Value.Args), ...)
								end
							end
						end)
					end
				end

				self.AnimationInstance:Play()
			end
		end
	else
		return warn("Animation controller doesn't exist")
	end

	return self
end

function AnimationFunctions:SetSpeed(NewSpeed: number)
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		if self.AnimationInstance ~= nil then
			NewSpeed = type(NewSpeed) == "number" and NewSpeed or self.AnimationInstance.Speed

			self.AnimationInstance:AdjustSpeed(NewSpeed)
		end
	else
		return warn("Animation controller doesn't exist")
	end
	return self
end

function AnimationFunctions:GetPlayingSpeed()
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		if self.AnimationInstance ~= nil then
			return self.AnimationInstance.Speed or self.NormalAnimationSpeed
		end
	else
		return 0, warn("Animation controller doesn't exist")
	end
	return 0
end

function AnimationFunctions:GetOriginalSpeed()
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		if self.AnimationInstance ~= nil then
			return self.NormalAnimationSpeed or 0
		end
	else
		return 0, warn("Animation controller doesn't exist")
	end
	return 0
end

function AnimationFunctions:Stop()
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		self:DestroySignals()

		if self.AnimationInstance ~= nil then
			self.AnimationInstance:Stop()

			for _, FuncData in ipairs(self.StoppedFunctions) do
				if type(FuncData) == "table" then
					if type(FuncData.Function) == "function" then
						FuncData.Function(unpack(FuncData.Args))
					end
				end
			end
		end
	else
		return warn("Animation controller doesn't exist")
	end
	return self
end

function AnimationFunctions:Pause()
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		if self.OldAnimationSpeed == nil then
			self.OldAnimationSpeed = self.AnimationInstance.Speed
		end

		self.AnimationInstance:AdjustSpeed(0)
	else
		return warn("Animation controller doesn't exist")
	end
	return self
end

function AnimationFunctions:Resume()
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		if self.OldAnimationSpeed ~= nil then
			self.AnimationInstance:AdjustSpeed(self.OldAnimationSpeed)
			self.OldAnimationSpeed = nil
		end
	else
		return warn("Animation controller doesn't exist")
	end
	return self
end

function AnimationFunctions:Remove()
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		if self.AnimationName ~= nil then
			self:DestroySignals()
			self:Stop()

			table.clear(self.FinishedQueue)
			table.clear(self.StoppedFunctions)
			table.clear(self.Signals)
			table.clear(self.Markers)

			for AnimationIndex, AnimationData_ in ipairs(Controller.Animations) do
				if AnimationData_.Type == self.Type and AnimationData_.AnimationName == self.AnimationName then
					table.remove(Controller.Animations, AnimationIndex)
				end
			end

			table.clear(self)
		end
	else
		return warn("Animation controller doesn't exist")
	end

	return Controller
end

function AnimationFunctions:DestroySignals()
	if type(self.Signals) == "table" then
		for I, V in pairs(self.Signals) do
			if typeof(V) == "RBXScriptConnection" then
				V:Disconnect()
			end
		end

		table.clear(self.Signals)
	end
end
-------------------------------------------
-- Animation functions (Controller)
function AnimationController:Exists(Name: string, Options: any)
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		local Animation = self:GetAnimation(Name, Options)

		if Animation ~= nil then
			return true
		end
	else
		return false, warn("Animation controller doesn't exist")
	end

	return false
end

function AnimationController:GetAnimation(Name: string, Options: any)
	Options = type(Options) == "table" and Options or {}
	Options.Type = type(Options.Type) == "string" and Options.Type or ""

	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		for _, Animation in ipairs(self.Animations) do
			if Animation.AnimationName == Name then
				if Options.Type ~= "" then
					if Options.Type == Animation.Type then
						return Animation
					end
				else
					return Animation
				end
			end
		end
	else
		return nil, warn("Animation controller doesn't exist")
	end

	return nil
end

function AnimationController:GetAnimationSize(Type)
	Type = type(Type) == "string" and Type or ""

	local Size = 0
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		for _, Animation in ipairs(self.Animations) do
			if Type == Animation.Type then
				Size += 1
			end
		end
	else
		return nil, warn("Animation controller doesn't exist")
	end

	return Size
end

function AnimationController:StopAll()
	local Controller = AnimationController.GetController(self.Operator, self.scope)

	if Controller ~= nil then
		for _, Animation in ipairs(self.Animations) do
			if Animation.AnimationInstance ~= nil then
				Animation:DestroySignals()
				Animation:Stop()
			end
		end
	else
		return warn("Animation controller doesn't exist")
	end
end

function AnimationController:StopAnimationType(Type: string, Blacklist: any)
	if Type == nil or #tostring(Type) <= 0 then
		return warn("<Type> cannot be empty nor nil!")
	end
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		Blacklist = type(Blacklist) == "table" and Blacklist or {}

		for _, Animation in ipairs(self.Animations) do
			if type(Animation) == "table" then
				if Animation.Type == tostring(Type) then
					if not table.find(Blacklist, Animation) then
						Animation:DestroySignals()
						Animation:Stop()
					end
				end
			end
		end
	else
		return warn("Animation controller doesn't exist")
	end
end

function AnimationController:Reload()
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		local Character = GetCharacter(self.Operator)
		local Humanoid = Character ~= nil and Character:FindFirstChild("Humanoid") or nil

		if Humanoid ~= nil then
			for _, Animation in ipairs(self.Animations) do
				if type(Animation) == "table" then
					Animation:Stop()
					Animation:DestroySignals()

					local ANI_OBJ = Instance.new("Animation", nil)
					ANI_OBJ.AnimationId = Animation.AnimationId

					local Loaded = Humanoid:LoadAnimation(ANI_OBJ)
					Loaded:Stop()

					rawset(Animation, "NormalAnimationSpeed", Loaded.Speed)
					rawset(Animation, "AnimationInstance", Loaded)

					ANI_OBJ:Destroy()
				end
			end
		end
	else
		return warn("Animation controller doesn't exist")
	end
end

function AnimationController:Destroy()
	for _, Animation in ipairs(type(self.Animations) == "table" and self.Animations or {}) do
		Animation:DestroySignals()
		Animation:Remove()
	end

	table.clear(type(self.Animations) == "table" and self.Animations or {})

	for ControllerIndex, ControllerData in ipairs(Controllers) do
		local ControllerOperator = type(ControllerData) == "table" and ControllerData.Operator

		if ControllerOperator == self.Operator then
			table.remove(Controllers, ControllerIndex)
			break
		end
	end

	table.clear(self)
end

function AnimationController:Add(AnimationData: table)
	local Controller = AnimationController.GetController(self.Operator, self.scope)
	if Controller ~= nil then
		AnimationData = type(AnimationData) == "table" and AnimationData or {}
		AnimationData.Type = type(AnimationData.Type) == "string" and AnimationData.Type or ""

		--#Quick Add animation Optimize
		for _, V in pairs(AnimationController.GetControllersForOperator(self.Operator)) do
			if type(V) == "table" then
				if V.Animations ~= nil then
					local FoundSameAnimation = nil

					for _, _AnimationData in pairs(V.Animations) do
						if _AnimationData.AnimationId ~= nil then
							if _AnimationData.AnimationId == AnimationData.ID then
								FoundSameAnimation = _AnimationData
								break
							end
						end
					end

					if FoundSameAnimation ~= nil then
						return FoundSameAnimation
					end
				end
			end
		end
		--#End of Optimize

		if not self:Exists(AnimationData.Name or "", AnimationData) then
			if self.Operator ~= nil and AnimationData.Name ~= nil then
				local Character = GetCharacter(self.Operator)
				local Humanoid = Character ~= nil and Character:FindFirstChild("Humanoid") or nil
				local _self = setmetatable({}, AnimationFunctions)

				_self.scope = self.scope
				_self.Operator = self.Operator
				_self.AnimationName = AnimationData.Name
				_self.AnimationId = AnimationData.ID
				_self.FinishedQueue = {}
				_self.StoppedFunctions = {}
				_self.Signals = {}
				_self.Markers = {}
				_self.Type = AnimationData.Type

				if Humanoid ~= nil then
					local ANI_OBJ = Instance.new("Animation", nil)
					ANI_OBJ.AnimationId = AnimationData.ID

					local Loaded = Humanoid:LoadAnimation(ANI_OBJ)

					_self.NormalAnimationSpeed = Loaded.Speed

					_self.AnimationInstance = Loaded

					ANI_OBJ:Destroy()
				end

				table.insert(self.Animations, _self)

				return _self
			end
		else
			return self:GetAnimation(self.Animations, AnimationData)
		end
	else
		return warn("Animation controller doesn't exist")
	end
end
-----------------------------------------

return AnimationController
