-- not finished!

local Shared = {}
local Modules = getmetatable(newproxy(true))
Shared.__index = Shared

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

function Shared:Add(Instance : Instance, Recursive : any)
    Recursive = type(Recursive) == "boolean" and Recursive or false

    if type(Instance) == "table" then
        for _,v in ipairs(Instance:GetChildren()) do
            self:Add(v, Recursive)
        end
    end
end

function Shared:Start()
    
end

function Shared.GetMeta()
    return Shared.__Meta or warn("Shared not setup!")
end

return Shared
