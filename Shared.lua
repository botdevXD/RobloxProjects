local Shared = {
    Services = {
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

    },
    FrameUpdater = {}
} -- create the Shared table
local AntiTamper = false
local IsServer = Shared.Services.RunService:IsServer() -- check if we are on the server else we are on the client
local Modules = getmetatable(newproxy(true)) -- get the metatable of the newproxy
Shared.__index = Shared -- set __index to itself so we can use metatables

local function safe_require(module)
    local ok, mod = pcall(require, module) -- wrap require in pcall to catch errors
    return ok and mod or nil -- return module if ok, otherwise nil
end

local function CopyTable(Table)
    local t = {} -- create new table
    for k, v in pairs(Table) do -- loop through destired table to copy
        t[k] = v -- copy the value and set it's index along with it's value to the new table (Table[Index] = Value)
    end
    return t -- return a copy of the table
end

--------------------------------------------------------------------------------

local ErrorHandler = function(Error)
	return warn(string.format("Error: %s, Stack: %s", Error, debug.traceback()))
end

local function FrameUpdater(Delta)
	for _, FuncData in pairs(Shared.FrameUpdater) do
		if type(FuncData) == "table" then
			xpcall(FuncData.Function, ErrorHandler, unpack(FuncData.Args), Delta)
		end
	end
end

function Shared.AddToFrameRender(Name : any, func : any, ...)
	if Shared.FrameUpdater[Name] ~= nil then return false end--warn(("<%s> already exists in the render table"):format(tostring(Name))) end

	if type(func) == "function" then
		Shared.FrameUpdater[Name] = {Function = func, Args = {...}}
		return true
	else
		return warn(("parameter #2 expected <function> got <%s>"):format(tostring(type(func))))
	end
end

function Shared.RemoveFromFrameRender(Name : any)
	Shared.FrameUpdater[Name] = nil
end
--------------------------------------------------------------------------------

function Shared.GetModule(ModuleName) -- get a module from the shared table with the module name argument
    return Modules[ModuleName] or nil -- return the module if it exists else return nil
end

function Shared.new()
    if Shared.__Meta ~= nil then -- if we already have a shared object then return it
        return Shared.__Meta -- return the shared object
    end

    local self = setmetatable({}, Shared) -- create a new shared object and set the metatable
    self.Queue = {} -- empty table to hold the queued modules
    self.LoadedModules = setmetatable({}, {
        __index = function(_, ModuleName) -- create custom __index metamethod to return the module if it's already loaded or nil if it's not
            return Shared.GetModule(ModuleName) -- if the module is already loaded then return it, otherwise return nil
        end,
        __newindex = function() -- create custom __newindex metamethod to prevent new modules from being added and to prevent modules from being overwritten
            return error("Attempt to modify read-only table") -- throw an error if someone tries to add a module / overwrite a module
        end
    }) -- create new object to hold loaded modules and set metatable

    Shared.__Meta = self -- set the shared object as the metatable for the shared object
    return self -- return the shared object
end

function Shared:Add(object : Instance, Recursive : any)
    Recursive = type(Recursive) == "boolean" and Recursive or false -- default to false if not a boolean else use the Recursive value

    if typeof(object) == "Instance" then -- if it's an instance add it to the queue and check if it's a module and check if recursive is true
        
        if object:IsA("ModuleScript") then -- if it's a module then add it to the queue
            table.insert(self.Queue, object) -- add it to the queue
        end

        if Recursive then -- if recursive is true then add all of the module's children to the queue
            for _,v in ipairs(object:GetChildren()) do -- for each child of the object
                self:Add(v, false) -- add the child to the queue while going through the childs children
            end
        end
    end
end

function Shared:SortQueue()
    table.sort(self.Queue, function(Table1, Table2)
        local A =  type(Table1) == "table" and Table1.LoadPosition or nil
        A = type(Table1) == "table" and A == nil and Table1.Priority or A

        local B =  type(Table2) == "table" and Table2.LoadPosition or nil
        B = type(Table2) == "table" and B == nil and Table2.Priority or B

        A = A or 0
        B = B or 0
        return A < B -- sort the queue by priority / LoadPosition in ascending order (lowest priority first)
    end)
end

function Shared:Init()
    for index, object in ipairs(self.Queue) do -- for each module in queue (modules added by Add)
        local LoadTime = tick()
        local Module = safe_require(object) -- safely attempt to require the module without erroring and stopping the script
        local CanPass = type(Module) == "table" and Module.Priority ~= nil and true or false -- if the module is a table and has a priority then return the module else return nil
        CanPass = type(Module) == "table" and CanPass == false and Module.LoadPosition ~= nil and true or CanPass -- if the module is a table and has a loadposition then return the module else return first module check

        if type(Module) == "table" and CanPass then -- if the module is a table then replace old instance with loaded module
            local ModuleCopy = CopyTable(Module) -- create a copy of the module to be added to the loaded modules table

            ModuleCopy.ModuleName = object.Name -- set the module name to the name of the module
            ModuleCopy.LoadTime = tostring(tick() - LoadTime) -- set the module name to the name of the module

            setmetatable(Module, {
                __index = function(_, key) -- create our own index metatable to allow us to access the module's functions and properties
                    if key == "GetModule" then -- if the key is GetModule then return the function to get the module
                        return function (module_name) -- return the function to get the module
                            return Shared.GetModule(module_name) -- return the loaded module or nil if it doesn't exist
                        end
                    elseif key == "Services" then -- if the key is Services then return the services table
                        return Shared.Services -- return the services table
                    elseif key == "Shared" then -- if the key is Shared then return the shared object
                        return Shared.__Meta -- return the shared object
                    end

                    return ModuleCopy[key] -- return the value of the key in the module copy
                end,

                __newindex = function(_, key, value) -- create our own new index metatable to allow us to set the module's functions and properties and to prevent them from being changed
                    if key == "GetModule" or key == "Shared" then -- if the key is GetModule then error because it's a reserved key
                        return error("Attempted to modify high class function / propertie!") -- warn the user that they're trying to modify a reserved key
                    end

                    ModuleCopy[key] = value -- set the value of the key in the module copy
                    --return error("Attempted to modify locked table!") -- warn the user that they're trying to modify a locked table
                end
            })

            self.Queue[index] = Module -- replace the module in the queue with the modified module
            Modules[object.Name] = Module -- add the module to the loaded modules table
        else
            self.Queue[index] = function()
                return nil
            end
        end
    end

    self:SortQueue() -- sort the queue by priority (lowest to highest)

    for _, Module in ipairs(self.Queue) do -- for each module in the queue
        if type(Module) == "table" then
			print( ("Module: %s, LoadPosition: %s, Load Time: %s"):format( Module.ModuleName, tostring(math.floor(Module.LoadPosition or Module.Priority)), tostring(Module.LoadTime) ) )

            if type(Module.Init) == "function" then -- if the module has an init function then call it
                Module.Init() -- call the init function
            end

            if type(Module.PlayerAdded) == "function" then -- if the module has a player added function then call it and connect up to the player added event
                for _, Player in ipairs(Shared.Services.PlayerService:GetPlayers()) do -- for each player in the game
                    Module:PlayerAdded(Player) -- call the player added function and pass the player as an argument
                end

                Shared.Services.PlayerService.PlayerAdded:Connect(function(Player) -- connect to the player added event and listen for when a player is added
                    Module.PlayerAdded(Player) -- when player added call the player added function along with the player as the argument
                end)
            end

            if type(Module.PlayerRemoving) == "function" then -- if the module has a player removing function then call it and connect up to the player removing event
                Shared.Services.PlayerService.PlayerRemoving:Connect(function(Player) -- connect to the player removing event and listen for when a player is removed
                    Module.PlayerRemoving(Player) -- when player removing call the player removing function along with the player as the argument
                end)
            end
        end
    end

    table.clear(self.Queue) -- clear the queue and all it's contents

    if not IsServer then
        Shared.Services.RunService.RenderStepped:Connect(FrameUpdater)
    else
        Shared.Services.RunService.Heartbeat:Connect(FrameUpdater)
    end

    if not IsServer and AntiTamper then
        task.spawn(function()
            while true do -- loop forever
                for _, Module in pairs(Modules) do -- for each module in the loaded modules table (modules added by Add)
                    local Success, Fail = pcall(function()
                        Module.BadVarible = math.random()
                    end) -- wrap function in pcall to catch errors

                    if Success or Success == nil then -- if the function ran without error then or pcall returned nil then
                        while true do end -- infinite loop to crash the game / freeze the game
                    end
                end

                task.wait(0.15) -- wait 0.15 seconds before looping again
            end
        end)
    end
end

function Shared.GetMeta()
    return Shared.__Meta or error("Shared not setup!") -- return the shared object or error if it doesn't exist
end

return Shared -- return the shared table to the main script
