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
    Recursive = type(Recursive) == "boolean" and Recursive or false

    if typeof(object) == "Instance" then
        
        if object:IsA("ModuleScript") then
            table.insert(self.Queue, object)
        end

        if Recursive then
            for _,v in ipairs(object:GetChildren()) do
                self:Add(v, Recursive)
            end
        end
    end
end

function Shared:Init()
    for _, object in ipairs(self.Queue) do -- for each module in queue (modules added by Add)
        local Module = safe_require(object) -- safely attempt to require the module without erroring and stopping the script

        if Module ~= nil then -- if module is loaded
            Modules[object.Name] = Module -- add to loaded modules
        end
    end

    table.clear(self.Queue) -- clear the queue
end

function Shared.GetMeta()
    return Shared.__Meta or error("Shared not setup!")
end

return Shared
