-- Made by _Ben#2020 / 0x74_Dev

local module = {
	Loaded = {},
	Shared_Setup = false,
	FrameUpdater = {}
}

module.__index = module

local ErrorHandler = function(Error)
	return warn(string.format("Error: %s, Stack: %s", Error, debug.traceback()))
end

local OldRequire = require
local require = function(Module)
	local DidLoad, LoadedContents = xpcall(OldRequire, ErrorHandler, Module)
	return DidLoad, LoadedContents
end

local Services = {
	GuiService = game:GetService("GuiService"),
	PlayerService = game:GetService("Players"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	ReplicatedFirst = game:GetService("ReplicatedFirst"),
	Lighting = game:GetService("Lighting"),
	WorkspaceService = game:GetService("Workspace"),
	ServerScriptService = game:GetService("ServerScriptService"),
	TeamsService = game:GetService("Teams"),
	ServerStorage = game:GetService("ServerStorage"),
	RunService = game:GetService("RunService"),
	MessageService = game:GetService("MessagingService"),
	HttpService = game:GetService("HttpService"),
	DataStoreService = game:GetService("DataStoreService"),
	TeleportService = game:GetService("TeleportService"),
	TextService = game:GetService("TextService"),
	UserInputService = game:GetService("UserInputService"),
	TweenService = game:GetService("TweenService"),
	ActionService = game:GetService("ContextActionService"),
	Debris = game:GetService("Debris")
}

-- My own implementation of the Roblox shared global

local AssetsFolder = Services.ReplicatedStorage:WaitForChild("Assets", 5)
local RepModules = AssetsFolder:WaitForChild("Modules", 5)
local ServerModules = nil

if Services.RunService:IsServer() then
	ServerModules = Services.ServerStorage:WaitForChild("ServerModules", 5)
end

function module.UpdateLoaded()
	for _, Contents in ipairs(module.Loaded) do
		if rawget(Contents, "LoadedModules") then
			rawset(Contents, "LoadedModules", module.Loaded)

			table.sort(module.Loaded, function(A, B)
				return A.LoadPosition < B.LoadPosition
			end)
		end
	end
end

local function FrameUpdater(Delta)
	for _, FuncData in pairs(module.FrameUpdater) do
		if type(FuncData) == "table" then
			xpcall(FuncData.Function, ErrorHandler, unpack(FuncData.Args), Delta)
		end
	end
end

function module.AddToFrameRender(Name : any, func : any, ...)
	if module.FrameUpdater[Name] ~= nil then return false end--warn(("<%s> already exists in the render table"):format(tostring(Name))) end

	if type(func) == "function" then
		module.FrameUpdater[Name] = {Function = func, Args = {...}}
		return true
	else
		return warn(("parameter #2 expected <function> got <%s>"):format(tostring(type(func))))
	end
end

function module.RemoveFromFrameRender(Name : any)
	module.FrameUpdater[Name] = nil
end

function module.AddModule(Module : ModuleScript)
	if Module:IsA("ModuleScript") then
		task.spawn(function()
			local StartTime = tick()
			local DidLoad, LoadedContents = require(Module)
			if DidLoad then
				if type(LoadedContents) == "table" then
					if type(LoadedContents.LoadPosition) == "number" then

						LoadedContents.ModuleName = Module.Name
						LoadedContents.ModuleInstance = Module
						LoadedContents.Services = Services
						LoadedContents.Shared = module
						LoadedContents.UpdateCache = {}
						LoadedContents.LoadedModules = {}
						LoadedContents.Signals = {}
						LoadedContents.PlayerSignals = {}
						LoadedContents.ModuleLoaded = true
						LoadedContents._LoadedTime = tostring(tick() - StartTime)

						table.insert(module.Loaded, LoadedContents)
						module.UpdateLoaded()
					end
				end
			end
		end)
	end
end

function module.GetModule(ModuleName : string)
	for I, V in ipairs(module.Loaded) do
		if type(V) == "table" then
			if V.ModuleName == tostring(ModuleName) then
				local _, Contents = require(V.ModuleInstance)
				return Contents
			end
		end
	end
end

function module.AddInstanceContents(...)
	local Objects = {...}
	for _, Object in ipairs(Objects) do
		if typeof(Object) == "Instance" then
			for _, Module in ipairs(Object:GetChildren()) do
				if Module:IsA("ModuleScript") then
					module.AddModule(Module)
				end
			end
		end		
	end
end

function module.start()	
	if module.Shared_Setup == false then
		if Services.RunService:IsServer() then
			for _, Module in ipairs(ServerModules:GetChildren()) do
				if Module:IsA("ModuleScript") then
					module.AddModule(Module)
				end
			end
		end

		table.sort(module.Loaded, function(A, B)
			return A.LoadPosition < B.LoadPosition
		end)

		for I, V in ipairs(module.Loaded) do
			if type(V) == "table" then
				task.spawn(function()
					print( ("Module: %s, LoadPosition: %s, Load Time: %s"):format( V.ModuleName, tostring(math.floor(V.LoadPosition)), tostring(V._LoadedTime) ) )
					if type(V.Init) == "function" then
						V.Init()
					end

					if type(V.PlayerRemoving) == "function" then
						Services.PlayerService.PlayerRemoving:Connect(V.PlayerRemoving)
					end

					if type(V.PlayerAdded) == "function" then
						Services.PlayerService.PlayerAdded:Connect(V.PlayerAdded)		

						for _, Player in ipairs(Services.PlayerService:GetChildren()) do
							V.PlayerAdded(Player)
						end
					end
				end)
			end
		end

		module.Shared_Setup = true
		
		if not Services.RunService:IsServer() then
			Services.RunService.RenderStepped:Connect(FrameUpdater)
		else
			Services.RunService.Heartbeat:Connect(FrameUpdater)
		end
	end
end

if Services.RunService:IsServer() then
	module.start()
else
	module.Init = module.start
end

return module
