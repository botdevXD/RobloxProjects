-- Made by _Ben#2902 / 0x74_Dev
local AnimationController = {
    LoadPosition = 0
}
AnimationController.__index = AnimationController
local Controllers = getmetatable(newproxy(true))

function AnimationController.new(Operator, scope)
    scope = type(scope) == "string" and scope or ""
    if Controllers[tostring(Operator) .. "+" .. scope] ~= nil then return Controllers[tostring(Operator) .. "+" .. scope] end

    local self = setmetatable({}, AnimationController)
    self.Operator = Operator
    self.Animations = {}
    self.scope = scope

    Controllers[tostring(Operator) .. "+" .. scope] = self

    return self
end

function AnimationController.GetControllersForOperator(Operator)
    local ControllerResults = {}

    for ControllerName, ControllerData in pairs(Controllers) do
        if type(ControllerName) == "string" then
            local _ControllerName = ControllerName:split("+")

            if #_ControllerName >= 1 then
                if tostring(_ControllerName[1]) == tostring(Operator) then
                    table.insert(ControllerResults, ControllerData)
                end
            end
        end
    end

    return ControllerResults
end

function AnimationController.GetController(Operator, scope)
    scope = type(scope) == "string" and scope or ""

    return Operator ~= nil and Controllers[tostring(Operator) .. "+" .. scope] or nil
end

-----------------------------------------
-- Animation functions
function AnimationController:Exists(Name)
    local Controller = AnimationController.GetController(self.Operator, self.scope)

    if Controller ~= nil then
        if rawget(Controller.Animations, Name) ~= nil then
            return true
        end
    else
        return false, warn("Animation controller doesn't exist")
    end

    return false
end

function AnimationController:Get(Name)
    local Controller = AnimationController.GetController(self.Operator, self.scope)

    if Controller ~= nil then
        if self:Exists(Name) then
            return rawget(Controller.Animations, Name)
        end
    else
        return warn("Animation controller doesn't exist")
    end
    
    return self
end

function AnimationController:Finished(Func)
    local Controller = AnimationController.GetController(self.Operator, self.scope)

    if Controller ~= nil then
        if self.FinishedQueue ~= nil then
            self.FinishedQueue[#self.FinishedQueue + 1] = Func
        end
    else
        return warn("Animation controller doesn't exist")
    end

    return self
end

function AnimationController:StopAll()
    local Controller = AnimationController.GetController(self.Operator, self.scope)

    if Controller ~= nil then
        self:Stop()
        for Animation_IDX, Animation in pairs(Controller.Animations) do
            if Animation.AnimationInstance ~= nil then
                Animation.AnimationInstance:Stop()
            end
        end
    else
        return warn("Animation controller doesn't exist")
    end
end

function AnimationController:Play()
    local Controller = AnimationController.GetController(self.Operator, self.scope)

    if Controller ~= nil then
        if self.AnimationInstance ~= nil then
            self.AnimationInstance:Play()
        end
    else
        return warn("Animation controller doesn't exist")
    end

    return self
end

function AnimationController:Stop()
    local Controller = AnimationController.GetController(self.Operator, self.scope)
    if Controller ~= nil then
        if self.AnimationInstance ~= nil then
            self.AnimationInstance:Stop()
        end
        
    else
        return warn("Animation controller doesn't exist")
    end
    return self
end

function AnimationController:Pause()
    return self
end

function AnimationController:Resume()
    return self
end

function AnimationController:Remove()
    local Controller = AnimationController.GetController(self.Operator, self.scope)

    if Controller ~= nil then
        if self.AnimationName ~= nil then
            rawset(Controller.Animations, self.AnimationName, nil)
            table.clear(self)
        end
    else
        return warn("Animation controller doesn't exist")
    end
    
    return Controller
end
-----------------------------------------
-- Controller functions
function AnimationController:Reload()
    local Controller = AnimationController.GetController(self.Operator, self.scope)
    if Controller ~= nil then
        local Character = self.Operator.Character
        local Humanoid = Character ~= nil and Character:FindFirstChild("Humanoid") or nil
        
        if Humanoid ~= nil then
            for Animation_IDX, Animation in pairs(Controller.Animations) do
                if type(Animation) == "table" then
                    local ANI_OBJ = Instance.new("Animation", nil)
                    ANI_OBJ.AnimationId = rawget(Controller.Animations[Animation_IDX], "AnimationId")
                    
                    rawset(Controller.Animations[Animation_IDX], "AnimationInstance", Humanoid:LoadAnimation(ANI_OBJ))
                    
                    ANI_OBJ:Destroy()
                end
            end
        end
    else
        return warn("Animation controller doesn't exist")
    end
end
function AnimationController:Add(AnimationData)
    local Controller = AnimationController.GetController(self.Operator, self.scope)
    if Controller ~= nil then
        AnimationData = type(AnimationData) == "table" and AnimationData or {}

        if not self:Exists(AnimationData.Name or "") then
            if self.Operator ~= nil and AnimationData.Name ~= nil then
                local Character = self.Operator.Character
                local Humanoid = Character ~= nil and Character:FindFirstChild("Humanoid") or nil
                local _self = setmetatable({}, AnimationController)
                
                _self.scope = self.scope
                _self.Operator = self.Operator
                _self.AnimationName = AnimationData.Name
                _self.AnimationId = AnimationData.ID
                _self.FinishedQueue = {}
                _self.FinishedSignal = nil

                if Humanoid ~= nil then
                    local ANI_OBJ = Instance.new("Animation", nil)
                    ANI_OBJ.AnimationId = AnimationData.ID

                    rawset(_self, "AnimationInstance", Humanoid:LoadAnimation(ANI_OBJ))
                    
                    ANI_OBJ:Destroy()
                end

                rawset(Controller.Animations, AnimationData.Name, _self)

                return _self
            end
        else
            return rawget(Controller.Animations, AnimationData.Name)
        end
    else
        return warn("Animation controller doesn't exist")
    end
end
-----------------------------------------

return AnimationController
