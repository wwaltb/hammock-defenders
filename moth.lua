Moth = Object.extend(Object)

function Moth.new(self)
	self.x, self.y = 0, 0
	self.radius = 40 + math.random() * 10
	self.angle = math.random() * math.pi
	self.target = { x = 57, y = 79 }

	-- Base orbit parameters
	self.minOrbit = 6 + math.random() * 8
	self.angularSpeed = 1.7 + math.random() * 1.7
	self.wobble = 0.25
	self.stretchX, self.stretchY = 1.2, 1.

	-- Burst motion controls
	self.state = "rest" -- can be "rest", "burst", "prepare", or "attack"
	self.stateTimer = 1.3
	self.baseSpeed = 18
	self.arcAngle = 2
	self.burstDir = -1

	self.attackSpeed = 99
	self.attackDir = { x = 0, y = 0 }
	self.recoverTime = 0.8
	self.recoverFromX = self.x
	self.recoverFromY = self.y
	self.hasAttacked = false
	self.hitWalt = false
	self.hasHitWalt = false

	-- Sprite setup
	self.w, self.h = 3, 2
	self.sw = self.w * 3

	self.sprite = love.graphics.newImage("art/moth.png")
	self.frame = 1
	self.frames = {}
	for i = 0, 2 do
		table.insert(self.frames, love.graphics.newQuad(i * self.w, 0, self.w, self.h, self.sw, self.h))
	end

	self.glowSprite = love.graphics.newImage("art/mothGlow.png")
	self.glowFrames = {}
	for i = 0, 2 do
		table.insert(self.glowFrames, love.graphics.newQuad(i * self.w, 0, self.w, self.h, self.sw, self.h))
	end
	self.glowing = false
end

function Moth.update(self, dt)
	local t = love.timer.getTime()

	-- === State transitions ===
	self.stateTimer = self.stateTimer - dt
	if self.stateTimer <= 0 then
		local dx = self.target.x - self.x
		local dy = self.target.y - self.y
		local dist = math.sqrt(dx * dx + dy * dy)
		if self.state == "rest" or self.state == "recover" then
			-- burst phase: start a new dart / arc
			self.state = "burst"
			self.stateTimer = 0.20 + math.random() * 0.6
			self.arcAngle = (math.random() - 0.5) * 0.8 -- arc direction
			self.angularSpeed = 2.7 + math.random() * 1.8
			if math.random() > 0.7 then
				self.burstDir = 1
			else
				self.burstDir = -1
			end
		elseif self.state == "burst" and dist < 20 and math.random() > 0.7 then
			-- prepare phase: hover quietly and glow once
			self.state = "prepare"
			self.stateTimer = 1.1
			self.angularSpeed = 0.3 + math.random() * 0.3
		elseif self.state == "burst" then
			-- rest phase: hover quietly
			self.state = "rest"
			self.stateTimer = 0.2 + math.random() * 0.6
			self.angularSpeed = 0.6 + math.random() * 0.5
		elseif self.state == "prepare" then
			self.state = "attack"
			self.stateTimer = 0.15 + math.random() * 0.25
			self.attackDir = { x = dx / dist, y = dy / dist }
		elseif self.state == "attack" then
			self.hitWalt = false
			self.hasHitWalt = false
			self.state = "recover"
			self.stateTimer = self.recoverTime
			self.recoverFromX = self.x
			self.recoverFromY = self.y
		elseif self.state == "crying" then
			self.state = "invisible"
			self.stateTimer = 9999
		end
	end

	-- === Motion ===
	local prevX, prevY = self.x, self.y

	if self.state == "attack" then
		self.x = self.x + self.attackDir.x * self.attackSpeed * dt
		self.y = self.y + self.attackDir.y * self.attackSpeed * dt

		local dx = self.target.x - self.x
		local dy = self.target.y - self.y
		self.angle = math.atan2(dy, dx)

		if math.abs(dx) < 3 and math.abs(dy) < 2 then
			self.hitWalt = true
		end
	elseif self.state == "recover" or self.state == "crying" then
		local total = self.recoverTime
		local remaining = self.stateTimer
		local alpha = 1 - (remaining / total)

		-- target orbital position (ellipse) using current angle
		local wobbleAngle = self.angle + math.sin(t * 12) * self.wobble
		local targetX = self.target.x + math.cos(wobbleAngle) * self.radius * self.stretchX
		local targetY = self.target.y + math.sin(wobbleAngle) * self.radius * self.stretchY

		-- lerp from current pos to target orbit pos (alpha eased)
		local ease = alpha * alpha * (3 - 2 * alpha) -- smoothstep
		self.x = self.recoverFromX * (1 - ease) + targetX * ease
		self.y = self.recoverFromY * (1 - ease) + targetY * ease
	else
		local distFactor = 1 - (self.radius / 60) * 0.5
		if self.state == "burst" then
			-- fast angular and radius motion
			self.angle = self.angle + self.burstDir * (self.angularSpeed + self.arcAngle) * dt * distFactor
			self.radius = self.radius - self.baseSpeed * dt * 2 * distFactor
		else
			-- gentle drift / small recovery toward ellipse
			self.angle = self.angle + self.angularSpeed * dt * distFactor
			self.radius = self.radius + math.sin(t * 2) * dt * 10 * distFactor
		end

		-- clamp radius so it doesn't collapse
		if self.radius < self.minOrbit then
			self.radius = self.minOrbit
		end
		if self.radius > 70 then
			self.radius = 70
		end

		-- wobble for wing motion
		local wobbleAngle = self.angle + math.sin(t * 8) * self.wobble

		-- === Elliptical position ===
		self.x = self.target.x + math.cos(wobbleAngle) * self.radius * self.stretchX
		self.y = self.target.y + math.sin(wobbleAngle) * self.radius * self.stretchY
	end

	-- === Animation ===
	local dx, dy = self.x - prevX, self.y - prevY
	if math.abs(dy) > math.abs(dx) then
		self.frame = 1
	elseif dx < -0.1 then
		self.frame = 2
	elseif dx > 0.1 then
		self.frame = 3
	else
		self.frame = 1
	end

	if self.state == "prepare" and self.stateTimer > 0.69 then
		self.glowing = true
	elseif self.state == "attack" then
		self.glowing = true
	else
		self.glowing = false
	end
end

function Moth.draw(self)
	if self.state == "invisible" then
		return
	end

	love.graphics.draw(self.sprite, self.frames[self.frame], (self.x - 1) * 6, self.y * 6, 0, 6, 6)
	if self.glowing then
		love.graphics.draw(self.glowSprite, self.glowFrames[self.frame], (self.x - 1) * 6, self.y * 6, 0, 6, 6)
	end
end
