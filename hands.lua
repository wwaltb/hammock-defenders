Hands = {}

function Hands.load()
	Hands.clapping = false
	Hands.idle = true
	Hands.timer = 0.

	Hands.center = { 58, 71 }
	Hands.x = Hands.center[1] + 0.01
	Hands.y = Hands.center[2]
	Hands.speed = 9 * 6
	Hands.distance = 0
	Hands.maxDistance = 20

	Hands.arms = love.graphics.newImage("art/arms.png")
	Hands.armsIdle = love.graphics.newImage("art/armsIdle.png")
	Hands.armsCloseLeft = love.graphics.newImage("art/armsCloseLeft.png")
	Hands.armsCloseRight = love.graphics.newImage("art/armsCloseRight.png")
	Hands.armsLeft = {}
	Hands.armsRight = {}
	for i = 0, 4 do
		local w = 120
		local sw = w * 10
		table.insert(Hands.armsLeft, love.graphics.newQuad(i * w, 0, w, w, sw, w))
		table.insert(Hands.armsRight, love.graphics.newQuad((i + 5) * w, 0, w, w, sw, w))
	end

	Hands.hands = love.graphics.newImage("art/hands.png")
	Hands.topHands = love.graphics.newImage("art/topHands.png")
	Hands.handsOffsetX = 5
	Hands.handsOffsetY = 3
	Hands.handsLeft = {}
	Hands.handsRight = {}
	Hands.topHandsLeft = {}
	Hands.topHandsRight = {}
	for i = 0, 7 do
		local w = 10
		local h = 6
		local sw = w * 16
		table.insert(Hands.handsLeft, love.graphics.newQuad(i * w, 0, w, h, sw, h))
		table.insert(Hands.handsRight, love.graphics.newQuad((i + 8) * w, 0, w, h, sw, h))
		table.insert(Hands.topHandsLeft, love.graphics.newQuad(i * w, 0, w, h, sw, h))
		table.insert(Hands.topHandsRight, love.graphics.newQuad((i + 8) * w, 0, w, h, sw, h))
	end
	Hands.handIndex = 0

	Hands.crosshair = love.graphics.newImage("art/crosshair.png")
	Hands.crosshairOffset = 2
end

function Hands.update(dt)
	if Hands.clapping then
		Hands.timer = Hands.timer + dt
		if Hands.timer > 0.24 then
			Hands.clapping = false
			Hands.timer = 0
		end
		return
	end

	-- check and calculate movement (need to address diagonal speed bug)
	Hands.idle = true
	local dir = { x = 0, y = 0 }
	if love.keyboard.isDown("w") then
		dir.y = dir.y - 1
		Hands.idle = false
	end
	if love.keyboard.isDown("a") then
		dir.x = dir.x - 1
		Hands.idle = false
	end
	if love.keyboard.isDown("s") then
		dir.y = dir.y + 1
		Hands.idle = false
	end
	if love.keyboard.isDown("d") then
		dir.x = dir.x + 1
		Hands.idle = false
	end

	local mag = math.sqrt(dir.x * dir.x + dir.y * dir.y)
	if mag > 1 then
		dir.x = dir.x / mag
		dir.y = dir.y / mag
	end

	local dx = Hands.center[1] - Hands.x
	local dy = Hands.center[2] - Hands.y
	local dist = math.sqrt(dx * dx + dy * dy)
	local distFactor = math.max(1, (Hands.maxDistance - dist) * 0.08)

	Hands.x = Hands.x + dir.x * Hands.speed * dt / distFactor
	Hands.y = Hands.y + dir.y * Hands.speed * dt / distFactor

	-- calculate the crosshairs offset and distance from its center
	local xOffset = Hands.center[1] - Hands.x
	local yOffset = Hands.center[2] - Hands.y
	Hands.distance = math.sqrt(xOffset * xOffset + yOffset * yOffset)

	-- clamp the crosshair by the maxDistance from its center
	if Hands.distance > Hands.maxDistance then
		Hands.x = Hands.center[1] - xOffset / Hands.distance * Hands.maxDistance
		Hands.y = Hands.center[2] - yOffset / Hands.distance * Hands.maxDistance
	end

	-- add negative inertia dragging the crosshair back to center
	if Hands.idle then
		xOffset = Hands.center[1] - Hands.x
		yOffset = Hands.center[2] - Hands.y
		Hands.x = Hands.x + xOffset * dt * 1.8
		Hands.y = Hands.y + yOffset * dt * 1.8
	end
end

function Hands.drawHandsAndArms(handIdxOffset)
	local handIdx
	local drawX = (Hands.x - Hands.handsOffsetX) * 6
	local drawY = (Hands.y - Hands.handsOffsetY) * 6
	if Hands.x < Hands.center[1] then
		if Hands.distance < Hands.maxDistance / 2 then
			love.graphics.draw(Hands.armsCloseLeft, 0, 0, 0, 6, 6)
		else
			love.graphics.draw(Hands.arms, Hands.armsLeft[Hands.getLeftArm()], 0, 0, 0, 6, 6)
		end

		handIdx = Hands.getLeftHand() + handIdxOffset
		love.graphics.draw(Hands.hands, Hands.handsLeft[handIdx], drawX, drawY, 0, 6, 6)
	else
		if Hands.distance < Hands.maxDistance / 2 then
			love.graphics.draw(Hands.armsCloseRight, 0, 0, 0, 6, 6)
		else
			love.graphics.draw(Hands.arms, Hands.armsRight[Hands.getRightArm()], 0, 0, 0, 6, 6)
		end

		handIdx = Hands.getRightHand() + handIdxOffset
		love.graphics.draw(Hands.hands, Hands.handsRight[handIdx], drawX, drawY, 0, 6, 6)
	end
end

function Hands.drawJustTopsOfHands()
	if Hands.idle and Hands.distance < Hands.maxDistance / 4 then
		return
	end

	local handIdxOffset = 0
	if Hands.clapping then
		handIdxOffset = 1
	end

	local handIdx
	local drawX = (Hands.x - Hands.handsOffsetX) * 6
	local drawY = (Hands.y - Hands.handsOffsetY) * 6
	if Hands.x < Hands.center[1] then
		handIdx = Hands.getLeftHand() + handIdxOffset
		love.graphics.draw(Hands.topHands, Hands.topHandsLeft[handIdx], drawX, drawY, 0, 6, 6)
	else
		handIdx = Hands.getRightHand() + handIdxOffset
		love.graphics.draw(Hands.topHands, Hands.topHandsRight[handIdx], drawX, drawY, 0, 6, 6)
	end
end

function Hands.draw()
	if Hands.clapping then
		Hands.drawHandsAndArms(1)
	elseif Hands.idle and Hands.distance < Hands.maxDistance / 4 then
		love.graphics.draw(Hands.armsIdle, 0, 0, 0, 6, 6)
	else
		Hands.drawHandsAndArms(0)
	end
end

function Hands.getLeftArm()
	-- using atan2, get the angle in the range [0,pi] in the direction of the
	-- sprite sheet and quantize it to the corresponding frame
	local xOffset = Hands.center[1] - Hands.x
	local yOffset = Hands.center[2] - Hands.y
	local rad = math.atan2(yOffset, xOffset)
	rad = -(rad - math.pi / 2)
	return math.floor((rad / math.pi) * (#Hands.armsLeft - 1) + 0.5) + 1
end

function Hands.getRightArm()
	-- using atan2, get the angle in the range [0,pi] in the direction of the
	-- sprite sheet and quantize it to the corresponding frame
	local xOffset = Hands.center[1] - Hands.x
	local yOffset = Hands.center[2] - Hands.y
	local rad = math.atan2(yOffset, xOffset)
	if rad < 0 then
		rad = rad + 2 * math.pi
	end
	rad = -(rad - 3 * math.pi / 2)
	return math.floor((rad / math.pi) * (#Hands.armsRight - 1) + 0.5) + 1
end

function Hands.getLeftHand()
	-- using atan2, get the angle in the range [0,pi] in the direction of the
	-- sprite sheet and quantize it to the corresponding frame
	local xOffset = Hands.center[1] - Hands.x
	local yOffset = Hands.center[2] - Hands.y
	local rad = math.atan2(yOffset, xOffset)
	rad = -(rad - math.pi / 2)
	return math.floor((rad / math.pi) * (#Hands.handsLeft / 2 - 1) + 0.5) * 2 + 1
end

function Hands.getRightHand()
	-- using atan2, get the angle in the range [0,pi] in the direction of the
	-- sprite sheet and quantize it to the corresponding frame
	local xOffset = Hands.center[1] - Hands.x
	local yOffset = Hands.center[2] - Hands.y
	local rad = math.atan2(yOffset, xOffset)
	if rad < 0 then
		rad = rad + 2 * math.pi
	end
	rad = -(rad - 3 * math.pi / 2)
	return math.floor((rad / math.pi) * (#Hands.handsRight / 2 - 1) + 0.5) * 2 + 1
end
