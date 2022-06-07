-- not finished!
local Shared = {
    Services = {
        Players = game:GetService("Players")
    }
} -- create the Shared table
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

function Shared.new()
    if Shared.__Meta ~= nil then -- if we already have a shared object then return it
        return Shared.__Meta -- return the shared object
    end

    local self = setmetatable({}, Shared) -- create a new shared object and set the metatable
    self.Queue = {} -- empty table to hold the queued modules
    self.LoadedModules = setmetatable({}, {
        __index = function(_, ModuleName) -- create custom __index metamethod to return the module if it's already loaded or nil if it's not
            return Modules[ModuleName] or nil -- if the module is already loaded then return it, otherwise return nil
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
                self:Add(v, Recursive) -- add the child to the queue while going through the childs children
            end
        end
    end
end

function Shared:SortQueue()
    table.sort(self.Queue, function(a, b)
        return a.Priority < b.Priority -- sort the queue by priority in ascending order (lowest priority first)
    end)
end

function Shared:Init()
    for index, object in ipairs(self.Queue) do -- for each module in queue (modules added by Add)
        local Module = safe_require(object) -- safely attempt to require the module without erroring and stopping the script
        Module = type(Module) == "table" and Module.Priority ~= nil and Module or nil -- if the module is a table and has a priority then return the module else return nil

        if Module ~= nil then -- if the module is a table then replace old instance with loaded module
            local ModuleCopy = CopyTable(Module) -- create a copy of the module to be added to the loaded modules table

            Module.ModuleName = object.Name -- set the module name to the name of the module

            setmetatable(Module, {
                __index = function(_, key) -- create our own index metatable to allow us to access the module's functions and properties
                    if key == "GetModule" then -- if the key is GetModule then return the function to get the module
                        return function (module_name) -- return the function to get the module
                            return self.LoadedModules[module_name] or nil -- return the loaded module or nil if it doesn't exist
                        end
                    end

                    return ModuleCopy[key] -- return the value of the key in the module copy
                end,
                __newindex = function(_, key, value) -- create our own new index metatable to allow us to set the module's functions and properties and to prevent them from being changed
                    if key == "GetModule" then -- if the key is GetModule then error because it's a reserved key
                        return error("Attempted to modify high class function!") -- warn the user that they're trying to modify a reserved key
                    end

                    return error("Attempted to modify locked table!") -- warn the user that they're trying to modify a locked table
                end
            })

            self.Queue[index] = Module -- replace the module in the queue with the modified module

            self:SortQueue() -- sort the queue by priority (lowest to highest)
        end
    end

    for _, Module in ipairs(self.Queue) do -- for each module in the queue
        Modules[Module.ModuleName] = Module -- add the module to the loaded modules table

        if type(Module.Init) == "function" then -- if the module has an init function then call it
            Module.Init() -- call the init function
        end

        if type(Module.PlayerAdded) == "function" then -- if the module has a player added function then call it and connect up to the player added event
            for _, Player in ipairs(Shared.Services.Players:GetPlayers()) do -- for each player in the game
                Module:PlayerAdded(Player) -- call the player added function and pass the player as an argument
            end

            Shared.Services.Players.PlayerAdded:Connect(function(Player) -- connect to the player added event and listen for when a player is added
                Module.PlayerAdded(Player) -- when player added call the player added function along with the player as the argument
            end)
        end
    end

    table.clear(self.Queue) -- clear the queue and all it's contents
end

function Shared.GetMeta()
    return Shared.__Meta or error("Shared not setup!") -- return the shared object or error if it doesn't exist
end

return Shared -- return the shared table to the main script
