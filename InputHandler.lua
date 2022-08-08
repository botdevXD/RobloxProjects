-- This is not finished!

local InputController = {
    LoadPosition = 0
}
InputController.__index = InputController

function InputController.new()
    local self = setmetatable({}, InputController)
    return self
end

function InputController:Add()
    
end

function InputController:Enable()
    
end

function InputController:Disable()
    
end

return InputController
