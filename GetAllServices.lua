-- Made by _Ben#2020 / 0x74_Dev

local Services = {}

for I,V in pairs(game:FindFirstChild("Instance", true).Parent:GetChildren()) do
	local Accessed, AccessFail = pcall(function()
		Services[tostring(V):gsub(" ", "")] = V 
	end)
end

return Services
