local UserInputService = game:GetService("UserInputService")
local InputController = {
    LoadPosition = 0,
}
local Services = {
    UserInputService = game:GetService("UserInputService"),
    ContextActionService = game:GetService("ContextActionService")
}

InputController.__index = InputController

function InputController.new()
    local self = setmetatable({}, InputController)
    self.Functions = getmetatable(newproxy(true))
    self.Signals = getmetatable(newproxy(true))
    self.Connected = getmetatable(newproxy(true))
    self.VarArgs = getmetatable(newproxy(true))
    self.ServiceOrSignal = getmetatable(newproxy(true))
    return self
end

function InputController:Add(Name, Function, ServiceOrSignal, ...)
    if type(Function) == "function" then
        if typeof(ServiceOrSignal) == "RBXScriptSignal" then
            -- InputBegan, InputEnded

            self.VarArgs[Name] = {...}
            self.Functions[Name] = Function
            self.ServiceOrSignal[Name] = ServiceOrSignal
            self.Signals[Name] = ServiceOrSignal:Connect(Function, ...) or 9e9
            self.Connected[Name] = true
        elseif tostring(ServiceOrSignal) == "ContextActionService" then
            -- BindAction

            self.VarArgs[Name] = {...}
            self.Functions[Name] = Function
            self.ServiceOrSignal[Name] = ServiceOrSignal
            self.Signals[Name] = Services.ContextActionService:BindAction(Name, Function, ...) or 9e9
            self.Connected[Name] = true
        end
    end

    return self
end

function InputController:Enable()
    for FunctionName, Function in pairs(self.Functions) do
        if self.Connected[FunctionName] == false then
            local VarArgs = self.VarArgs[FunctionName]
            local ServiceOrSignal = self.ServiceOrSignal[FunctionName]

            if typeof(ServiceOrSignal) == "RBXScriptSignal" then
                self.Signals[FunctionName] = ServiceOrSignal:Connect(Function, VarArgs and unpack(VarArgs) or unpack({})) or 9e9
                self.Connected[FunctionName] = true
            elseif tostring(ServiceOrSignal) == "ContextActionService" then
                self.Signals[FunctionName] = Services.ContextActionService:BindAction(FunctionName, Function, VarArgs and unpack(VarArgs) or unpack({})) or 9e9
                self.Connected[FunctionName] = true
            end
        end
    end

    return self
end

function InputController:Disable()
    for FunctionName, Signal in pairs(self.Signals) do
        if typeof(Signal) == "RBXScriptConnection" then
            Signal:Disconnect()
        else
            pcall(function()
                Services.ContextActionService:UnbindAction(FunctionName)
            end)
        end

        self.Connected[FunctionName] = false
    end

    table.clear(self.Signals)

    return self
end

return InputController
