-- Made by _Ben#7494 / (0x74_Dev, UserId = 152711071)

-- Made by _Ben#7494 / (0x74_Dev, UserId = 152711071)

local Types = {
	["string"] = "StringValue",
	["cframe"] = "CFrameValue",
	["boolean"] = "BoolValue",
	["vector3"] = "Vector3Value",
	["number"] = "NumberValue",
	["instance"] = "ObjectValue"
}

local function Convert(Object, TableName, Parent)
	if type(Object) == "table" then
		local Folder = Instance.new("Folder", Parent)
		Folder.Name = TableName or "UnknownName"
		
		for Index, Value in pairs(Object) do
			if type(Value) == "table" then
				local TableFolder = Convert(Value, tostring(Index), Folder)
				
				if TableFolder ~= nil then
					TableFolder.Parent = Folder
				end
			else
				local ValueType = Types[tostring(typeof(Value)):lower()]

				if ValueType ~= nil then
					local ValueInstance = Instance.new(ValueType, Folder)
					ValueInstance.Name = Index
					ValueInstance.Value = Value
				end
			end
		end
		
		return Folder
	end
end

return function(Table : table, FolderName : string, Parent : Instance)
	local Converted = Convert(Table, FolderName, Parent)
end

local function Convert(Object, TableName, Parent)
	if type(Object) == "table" then
		local Folder = Instance.new("Folder", Parent)
		Folder.Name = TableName or "UnknownName"
		
		for Index, Value in pairs(Object) do
			if type(Value) == "table" then
				local TableFolder = Convert(Value, tostring(Index), Folder)
				
				if TableFolder ~= nil then
					TableFolder.Parent = Folder
				end
			else
				local ValueType = Types[tostring(typeof(Value)):lower()]
				
				if ValueType ~= nil then
					local ValueInstance = Instance.new(ValueType, Folder)
					ValueInstance.Name = Index
					ValueInstance.Value = Value
				end
			end
		end
		
		return Folder
	end
end

return function(Table : table, FolderName : string, Parent : Instance)
	local Converted = Convert(Table, FolderName, Parent)
end
