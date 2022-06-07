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

function Shared.new()
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

function Shared:Init()
    for _, object in ipairs(self.Queue) do -- for each module in queue (modules added by Add)
        local Module = safe_require(object) -- safely attempt to require the module without erroring and stopping the script
        Module = type(Module) == "table" and Module.Priority ~= nil and Module or nil -- if the module is a table and has a priority then return the module else return nil

        if Module ~= nil then -- if the module is a table then add it to the loaded modules table
            Modules[object.Name] = Module -- add to loaded modules
        end
    end

    table.clear(self.Queue) -- clear the queue and all it's contents
end

function Shared.GetMeta()
    return Shared.__Meta or error("Shared not setup!")
end

return Shared
