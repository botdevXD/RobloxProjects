-- not finished!
local Shared = {}
local Modules = getmetatable(newproxy(true))
Shared.__index = Shared

local function safe_require(name)
    local ok, mod = pcall(require, name)
    if ok then
        return mod
    else
        return nil
    end
end

local function CopyTable(Table)
    local t = {}
    for k, v in pairs(Table) do
        t[k] = v
    end
    return t
end

function Shared.new()
    if Shared.GetMeta() then
        return Shared.__Meta
    end

    local self = setmetatable({}, Shared)
    self.Queue = {}
    self.LoadedModules = setmetatable({}, {
        __index = function(_, ModuleName)
            return Modules[ModuleName] or nil
        end,
        __newindex = function()
            return error("Attempt to modify read-only table")
        end
    })

    Shared.__Meta = self
    return self
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
                        return warn("Attempt to modify high class function!") -- warn the user that they're trying to modify a reserved key
                    end

                    ModuleCopy[key] = value -- sets the key in the copy to the value
                end
            })

            self.Queue[index] = Module -- replace the module in the queue with the modified module

            self:SortQueue() -- sort the queue by priority (lowest to highest)
        end
    end

    for _, Module in ipairs(self.Queue) do -- for each module in the queue
        Modules[Module.ModuleName] = Module -- add the module to the loaded modules table

        if Module.Init then -- if the module has an init function then call it
            Module.Init() -- call the init function
        end
    end

    table.clear(self.Queue) -- clear the queue and all it's contents
end

function Shared.GetMeta()
    return Shared.__Meta or error("Shared not setup!")
end

return Shared
