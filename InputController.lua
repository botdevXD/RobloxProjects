local InputController = {
    LoadPosition = 0
}
InputController.__index = InputController

function InputController.new()
    local self = setmetatable({}, InputController)
    self.Functions = getmetatable(newproxy(true))
    self.Signals = getmetatable(newproxy(true))
    self.Connected = getmetatable(newproxy(true))
    return self
end

function InputController:Add(Name, Function, ServiceOrSignal, ...)
    if type(Function) == "function" then
        if typeof(ServiceOrSignal) == "RBXScriptSignal" then
            -- InputBegan, InputEnded
            
            self.Functions[Name] = Function
            self.Signals[Name] = ServiceOrSignal:Connect(Function, ...)
            self.Connected[Name] = true
        elseif tostring(ServiceOrSignal) == "ContextActionService" then
            -- BindAction

            self.Functions[Name] = Function
            self.Signals[Name] = ServiceOrSignal:BindAction(Name, Function, ...)
            self.Connected[Name] = true
        end
    end
end

function InputController:Enable()
    
end

function InputController:Disable()
    
end

return InputController
