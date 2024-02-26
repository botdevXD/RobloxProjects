local aStar = {}

function aStar.heuristic(node, goal, _2dCalculation)

	if _2dCalculation then
		-- 2D world space calculation for GUI's
		local X = math.abs(node.AbsolutePosition.X - goal.AbsolutePosition.X)
		local Y = math.abs(node.AbsolutePosition.Y - goal.AbsolutePosition.Y)
		local distance = math.sqrt(X^2 + Y^2)
		return distance
	end

	--3D world space calculation

	local nodePosition = node.Position :: Vector3
	local nodeX = nodePosition.X
	local nodeY = nodePosition.Y
	local nodeZ = nodePosition.Z

	local goalPosition = goal.Position :: Vector3
	local goalX = goalPosition.X
	local goalY = goalPosition.Y
	local goalZ = goalPosition.Z

	local distance = math.sqrt(((goalX - nodeX)^2) + ((goalY - nodeY)^2) + ((goalZ - nodeZ)^2))

	return distance
end

function aStar.findPath(startPart, endPart, nodesFolder, _2dCalculation, maxDist, Walls)
	maxDist = type(maxDist) == "number" and maxDist or 13
	
	_2dCalculation = type(_2dCalculation) == "boolean" and _2dCalculation or false

	local openList = {}
	local closedList = {}

	local nodes = {}
	for _, nodePart in ipairs(nodesFolder) do
		table.insert(nodes, {part = nodePart})
	end

	local startNode = nil
	for _, node in ipairs(nodes) do
		if node.part == startPart then
			startNode = {part = node.part, g = 0, h = 0, f = 0, parent = nil}
			startNode.h = aStar.heuristic(startPart, endPart, _2dCalculation)
			startNode.f = startNode.g + startNode.h
			break
		end
	end

	table.insert(openList, startNode)

	local function getNeighbours(node)
		local neighbours = {}

		for _, neighbour in ipairs(nodes) do
			if neighbour.part == node then continue end

			local neighbourDistance = aStar.heuristic(node, neighbour.part, _2dCalculation)

			if neighbourDistance < maxDist then
				
				local dir = (neighbour.part.Position - node.Position).Unit * neighbourDistance

				local raycast = workspace:Raycast(node.Position, dir)

				if raycast and raycast.Instance:IsDescendantOf(Walls) then
					continue
				end
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
				table.insert(path, currentNode)

				currentNode = currentNode.parent

			end
			
			table.sort(path, function(pathA, pathB)
				return pathA.f < pathB.f
			end)

			return path
		end

		for _, Neighbour in ipairs(getNeighbours(currentNode.part)) do
			if Neighbour == currentNode then continue end
			if (isInClosed(Neighbour.part)) then continue end
			
			local gCost = currentNode.g + aStar.heuristic(currentNode.part, Neighbour.part, _2dCalculation)
			local hCost = aStar.heuristic(Neighbour.part, endPart, _2dCalculation)
			local fCost = gCost + hCost
			
			if currentNode.g <= gCost and currentNode.f <= fCost then
				Neighbour.g = gCost
				Neighbour.h = hCost
				Neighbour.f = fCost
				Neighbour.parent = currentNode
				
				if not isInOpen(Neighbour.part) then
					table.insert(openList, Neighbour)
				end
			end
		end

	end

	return nil
end

return aStar
