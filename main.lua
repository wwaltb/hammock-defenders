local intScale = 6

local width = 120
local height = 120

local center = { 59, 66 }

local dead = false

function love.load()
	Object = require("lib.classic")

	math.randomseed(os.time())
	love.graphics.setDefaultFilter("nearest", "nearest", 2)

	scene = love.graphics.newImage("art/scene.png")
	anaLeft = love.graphics.newImage("art/anaLeft.png")
	anaRight = love.graphics.newImage("art/anaRight.png")

	require("hands")
	Hands.load()

	require("moth")
	m1 = Moth()
end

function love.update(dt)
	Hands.update(dt)
	m1:update(dt)
end

function love.keypressed(key)
	if (key == "x") and not Hands.clapping then
		Hands.clapping = true
		local dx = math.abs(Hands.x - m1.x)
		local dy = math.abs(Hands.y - m1.y)
		local dist = math.sqrt(dx * dx + dy * dy)
		print("dx")
		print(dx)
		print("dy")
		print(dy)
		print("dist")
		print(dist)
		if dx < 3 and dy < 3 then
			dead = true
		end
	end
end

function love.draw()
	love.graphics.draw(scene, 0, 0, 0, intScale, intScale)

	if Hands.x < Hands.center[1] then
		love.graphics.draw(anaLeft, 0, 0, 0, intScale, intScale)
	else
		love.graphics.draw(anaRight, 0, 0, 0, intScale, intScale)
	end

	Hands.draw()

	if not dead then
		m1:draw()
	end

	if Hands.clapping then
		Hands.drawJustTopsOfHands(1)
	else
		Hands.drawJustTopsOfHands(0)
	end
end
