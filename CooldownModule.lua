-- Made by 0x74_Dev / _Ben

local CooldownModule = {
	Pools = {}
}

shared.CoolDownData = shared.CoolDownData or CooldownModule

function CooldownModule.AddCoolDown(Player : Player, Function : any, CooldownName : string, Time : number)
	if typeof(Player) ~= "Player" then return end
	if typeof(Function) ~= "function" then return end
	if type(CooldownName) ~= "string" then return end
	if type(Time) ~= "number" then return end
	
	shared.CoolDownData.Pools[CooldownName] = shared.CoolDownData.Pools[CooldownName] or {}
	
	if shared.CoolDownData.Pools[CooldownName][Player] then return end
	
	task.delay(Time, function()
		shared.CoolDownData.Pools[CooldownName][Player] = nil
	end)
	
	Function()
end

return CooldownModule
