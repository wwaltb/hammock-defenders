Hands = {}

function Hands.load()
	Hands.center = { 59, 70 }
	Hands.x = Hands.center[1]
	Hands.y = Hands.center[2]
	Hands.speed = 8 * 6
	Hands.maxDistance = 20

	Hands.crosshair = love.graphics.newImage("art/crosshair.png")
	Hands.armsIdle = love.graphics.newImage("art/armsIdle.png")
end

function Hands.update(dt)
	-- check and calculate movement (need to address diagonal speed bug)
	local inputExists = false
	if love.keyboard.isDown("w") then
		Hands.y = Hands.y - Hands.speed * dt
		inputExists = true
	end
	if love.keyboard.isDown("a") then
		Hands.x = Hands.x - Hands.speed * dt
		inputExists = true
	end
	if love.keyboard.isDown("s") then
		Hands.y = Hands.y + Hands.speed * dt
		inputExists = true
	end
	if love.keyboard.isDown("d") then
		Hands.x = Hands.x + Hands.speed * dt
		inputExists = true
	end

	-- calculate the crosshairs offset and distance from its center
	local xOffset = Hands.center[1] - Hands.x
	local yOffset = Hands.center[2] - Hands.y
	local magnitude = math.sqrt(xOffset * xOffset + yOffset * yOffset)

	-- clamp the crosshair by the maxDistance from its center
	if magnitude > Hands.maxDistance then
		Hands.x = Hands.center[1] - xOffset / magnitude * Hands.maxDistance
		Hands.y = Hands.center[2] - yOffset / magnitude * Hands.maxDistance
	end

	-- add negative inertia dragging the crosshair back to center
	if not inputExists then
		xOffset = Hands.center[1] - Hands.x
		yOffset = Hands.center[2] - Hands.y
		Hands.x = Hands.x + xOffset * dt * 1.8
		Hands.y = Hands.y + yOffset * dt * 1.8
	end
end

function Hands.draw()
	love.graphics.draw(Hands.armsIdle, 0, 0, 0, 6, 6)
	love.graphics.draw(Hands.crosshair, Hands.x * 6, Hands.y * 6, 0, 6, 6)
end
