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

function aStar.findPath(startPart, endPart, nodesFolder, _2dCalculation)
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

			if neighbourDistance < 85 then
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


			Neighbour.g = aStar.heuristic(currentNode.part, Neighbour.part, _2dCalculation)
			Neighbour.h = aStar.heuristic(Neighbour.part, endPart, _2dCalculation)
			Neighbour.f = Neighbour.g + Neighbour.h
			Neighbour.parent = currentNode

			if not isInOpen(Neighbour.part) then
				table.insert(openList, Neighbour)
			end
		end

	end

	return nil
end

return aStar
