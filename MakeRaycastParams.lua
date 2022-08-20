local function MakeRaycastParams(Properties)
    local RayParamsMT = {}
    RayParamsMT.__index = RayParamsMT

    local self = setmetatable({}, RayParamsMT)
    self.Params = RaycastParams.new()

    function self:Update(Properties)
        for PropName, PropValue in pairs(Properties) do
            pcall(function()
                self.Params[PropName] = PropValue
            end)
        end

        return self
    end

    function self:Get()
        return self.Params
    end

    function self:Destroy()
        table.clear(self)
    end

    self:Update(Properties)
    return self
end
