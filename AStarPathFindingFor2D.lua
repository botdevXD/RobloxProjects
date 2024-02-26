local thread = require(script.Thread)

local function heuristic(node, goal)
	local X = math.abs(node.AbsolutePosition.X - goal.AbsolutePosition.X)
	local Y = math.abs(node.AbsolutePosition.Y - goal.AbsolutePosition.Y)
	local distance = math.sqrt(X^2 + Y^2)
	return distance
end

local function findPath(startPart, endPart, nodesFolder)
	local openList = {}
	local closedList = {}

	local nodes = {}
	for _, nodePart in ipairs(nodesFolder) do
		if nodePart:IsA("Frame") then
			table.insert(nodes, {part = nodePart})
		end
	end

	local startNode = nil
	for _, node in ipairs(nodes) do
		if node.part == startPart then
			startNode = {part = node.part, g = 0, h = 0, f = 0, parent = nil}
			startNode.h = heuristic(startPart, endPart)
			startNode.f = startNode.g + startNode.h
			break
		end
	end
	
	table.insert(openList, startNode)
	
	local function getNeighbours(node)
		local neighbours = {}
		
		for _, neighbour in ipairs(nodes) do
			if neighbour.part == node then continue end
			
			if heuristic(node, neighbour.part) <= 100 then
				table.insert(neighbours, neighbour)
			end
		end
		
		return neighbours
	end
	
	local function isInOpen(nodeA)
		for _, nodeB in ipairs(openList) do
			if nodeB.part == nodeA then
				return true
			end
		end

		return false
	end
	
	local function isInClosed(nodeA)
		for _, nodeB in ipairs(closedList) do
			if nodeB.part == nodeA then
				return true
			end
		end
		
		return false
	end
	
	while #openList > 0 do

		local currentNode = openList[1]
		local currentIndex = 1
		for i, node in ipairs(openList) do
			if node.f < currentNode.f then
				currentNode = node
				currentIndex = i
			end
		end

		table.remove(openList, currentIndex)
		table.insert(closedList, currentNode)

		if currentNode.part == endPart then
			local alreadyCheckedParents = {}

			local path = {}
			while currentNode do
				table.insert(path, currentNode.part)
				
				local parent = currentNode.parent
				if parent and not alreadyCheckedParents[parent] then
					alreadyCheckedParents[parent] = true
					currentNode = parent
				else
					currentNode = nil
				end

			end
			
			return path
		end
		
		for _, Neighbour in ipairs(getNeighbours(currentNode.part)) do
			if (isInClosed(Neighbour.part)) then continue end
			
			
			Neighbour.g = heuristic(currentNode.part, Neighbour.part)
			Neighbour.h = heuristic(Neighbour.part, endPart)
			Neighbour.f = Neighbour.g + Neighbour.h
			Neighbour.parent = currentNode
			
			if not isInOpen(Neighbour.part) then
				table.insert(openList, Neighbour)
			end
		end

	end

	return nil
end

local Container = game.StarterGui.ScreenGui.Container

local TotalToMake = 10

local SizeX, SizeY = Container.AbsoluteSize.X, Container.AbsoluteSize.Y

local index = 1
local grid = {}

for x = 1, TotalToMake do
	for y = 1, TotalToMake do
		local newFrame = Instance.new("Frame")
		newFrame.Size = UDim2.new(0, SizeX / TotalToMake, 0, SizeY / TotalToMake)
		newFrame.BorderSizePixel = 2
		newFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		newFrame.Parent = Container
		newFrame.Name = `{index}`
		
		if math.random(1, 100) < 10 then
			newFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		else
			table.insert(grid, newFrame)
		end
		
		index += 1
	end
end

table.sort(grid, function(a, b)
	return tonumber(a.Name) <= tonumber(b.Name)
end)

while task.wait(.5) do
	
	for _, Node in ipairs(grid) do
		Node.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
	
	local startNode = nil
	local endNode = nil

	repeat
		math.randomseed(tick())
		startNode = grid[math.random(1, #grid)]
		endNode = grid[math.random(1, #grid)]

		task.wait()
	until startNode ~= endNode

	startNode.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	endNode.BackgroundColor3 = Color3.fromRGB(85, 255, 0)

	local path = findPath(startNode, endNode, grid)

	if path then
		for _, Node in ipairs(path) do
			if Node == startNode or Node == endNode then continue end

			Node.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
		end
	end
	
end
