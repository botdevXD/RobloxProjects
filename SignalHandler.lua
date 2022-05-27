-------------------------------------
--- Connection handler rewrite    ---
--- 12/20/2021		 	  ---
--- 0x74_Dev / _Ben#2902          ---
--- Finished: 12/20/2021, 3:04 PM ---
-------------------------------------

local ConnectionsHandler = {
	LoadPosition = 1,
	ServerData = {}
}
ConnectionsHandler.__index = ConnectionsHandler

local V2Services = {
	HttpService = game:GetService("HttpService"),
	RunService = game:GetService("RunService")
}
local Format, Split = string.format, string.split
local BooleanTypes = {
	["true"] = true,
	["false"] = false
}

local function GetEvent(Object : any)
	if typeof(Object) == "Instance" then
		local Types = {
			["RemoteEvent"] = {
				Server = "OnServerEvent",
				Client = "OnClientEvent"
			},
			["BindableEvent"] = {
				Server = "Event",
				Client = "Event"
			}
		}

		local TypeCheck = Types[Object.ClassName]
		if TypeCheck then
			if V2Services.RunService:IsClient() then
				return TypeCheck.Client
			elseif V2Services.RunService:IsServer() then
				return TypeCheck.Server
			end
		end

		return Types
	end
	return nil
end

function ConnectionsHandler.new_v2(Player : Player)
	local Proxy = newproxy(true)
	local MetaTable = getmetatable(Proxy)
	MetaTable.Connections = getmetatable(newproxy(true))

	MetaTable.AddCallback = function(event : any, func : any, CanRemove : boolean)		
		if event ~= nil then
			local EventType = GetEvent(event)

			if EventType or typeof(event) == "RBXScriptSignal" then
				local UUID = V2Services.HttpService:GenerateGUID(false)
				CanRemove = CanRemove or false

				local String = UUID .. ","
				String = String .. tostring(CanRemove)

				if type(EventType) == "string" then
					MetaTable.Connections[String] = event[EventType]:Connect(function(...)
						return func(...)
					end)
				elseif typeof(event) == "RBXScriptSignal" then
					MetaTable.Connections[String] = event:Connect(function(...)
						return func(...)
					end)
				end

				return String
			end
		end

		return nil
	end

	MetaTable.RemoveCallback = function(UUID : string, ForceDisconnect : boolean)
		if type(UUID) == "string" then
			if MetaTable.Connections[UUID] then
				ForceDisconnect = ForceDisconnect or false

				if typeof(MetaTable.Connections[UUID]) == "RBXScriptConnection" then
					local CanDisconnect = BooleanTypes[Split(UUID)[2]]

					if CanDisconnect == true then
						MetaTable.Connections[UUID]:Disconnect()
						MetaTable.Connections[UUID] = nil
						return true
					elseif CanDisconnect == false then
						return false
					end
				end
			else
				return warn("<UUID> doesn't exist!")
			end
		else
			return error(Format("<UUID> is meant to be a string got %s", tostring(type(UUID))))
		end
	end

	MetaTable.RemoveCallbacks = function(ForceDisconnect : boolean)
		ForceDisconnect = ForceDisconnect or false
	end

	MetaTable.Destroy = function()
		for UUID, Signal in pairs(MetaTable.Connections) do
			if typeof(Signal) == "RBXScriptConnection" then
				Signal:Disconnect()
				MetaTable.Connections[UUID] = nil
			end
		end

		MetaTable = nil
		Proxy = nil

		if V2Services.RunService:IsServer() then
			ConnectionsHandler.ServerData[Player] = nil
		end
	end

	if V2Services.RunService:IsServer() then
		ConnectionsHandler.ServerData[Player] = MetaTable
	end

	return MetaTable
end

if V2Services.RunService:IsServer() then
	function ConnectionsHandler.GetData(Player : Player)
		return ConnectionsHandler.ServerData[Player]
	end
end

return ConnectionsHandler
