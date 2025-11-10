local intScale = 6

local width = 120
local height = 120

local center = { 59, 66 }

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest", 2)

	scene = love.graphics.newImage("art/scene.png")
	anaLeft = love.graphics.newImage("art/anaLeft.png")
	anaRight = love.graphics.newImage("art/anaRight.png")

	require("hands")
	Hands.load()
end

function love.update(dt)
	Hands.update(dt)
end

-- function love.keypressed(key)
-- end

function love.draw()
	love.graphics.draw(scene, 0, 0, 0, intScale, intScale)

	if Hands.x < Hands.center[1] then
		love.graphics.draw(anaLeft, 0, 0, 0, intScale, intScale)
	else
		love.graphics.draw(anaRight, 0, 0, 0, intScale, intScale)
	end

	Hands.draw()
end
