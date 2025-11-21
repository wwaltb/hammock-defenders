local intScale = 6
local width = 120
local height = 120

local state = "title"
local score = 0

function love.load()
	require("lib.slam")
	Object = require("lib.classic")

	math.randomseed(os.time())
	love.graphics.setDefaultFilter("nearest", "nearest", 2)

	scene = love.graphics.newImage("art/scene.png")
	anaLeft = love.graphics.newImage("art/anaLeft.png")
	anaRight = love.graphics.newImage("art/anaRight.png")
	waltAndAnaLeft = love.graphics.newImage("art/waltAndAnaLeft.png")
	waltAndAnaRight = love.graphics.newImage("art/waltAndAnaRight.png")

	require("hands")
	Hands.load()

	require("hitmarker")
	hitmarkers = {}

	require("zzzs")
	zzzs = Zzzs()

	require("spawner")
	s = Spawner()

	scoreText = love.graphics.newImage("art/scoreText.png")
	numbers = love.graphics.newImageFont("art/numbers.png", "1234567890", 1)

	titleText = love.graphics.newImage("art/titleText.png")
	gameOverText = love.graphics.newImage("art/gameOverText.png")

	clapSound = love.audio.newSource({ "sfx/clap1.wav", "sfx/clap2.wav" }, "stream")
	bugMushSound = love.audio.newSource({ "sfx/mush1.wav", "sfx/mush2.wav" }, "stream")
	hitSoundLow = love.audio.newSource("sfx/hit2.wav", "stream")
	hitSoundHigh = love.audio.newSource("sfx/hit1.wav", "stream")
end

function love.update(dt)
	if state == "game" and zzzs.zsLeft == 0 then
		state = "crying"

		for _, moth in ipairs(s.moths) do
			moth.state = "crying"
			moth.stateTimer = 0.5 + math.random() * 2.5
			moth.angularSpeed = 0.6 + math.random() * 0.5
			moth.recoverTime = moth.stateTimer
			moth.recoverFromX = moth.x
			moth.recoverFromY = moth.y
		end
	end
	if state == "game" then
		s:update(dt)

		Hands.update(dt)

		for _, moth in ipairs(s.moths) do
			moth:update(dt)
			if moth.state == "attack" and not moth.hasAttacked then
				moth.hasAttacked = true
				if math.random() < 0.5 then
					s:spawnMothSoon()
				end
			end
			if moth.hitWalt and not moth.hasHitWalt then
				zzzs:minusOne()
				table.insert(hitmarkers, HitMarker(moth.x, moth.y))
				moth.hasHitWalt = true
				if zzzs.zsLeft <= 0 then
					hitSoundLow:play()
				else
					hitSoundHigh:play()
				end
			end
		end

		for index, hitmarker in ipairs(hitmarkers) do
			hitmarker:update(dt)
			if hitmarker.timer <= 0 then
				table.remove(hitmarkers, index)
			end
		end
	elseif state == "crying" then
		Hands.update(dt)
		for _, moth in ipairs(s.moths) do
			moth:update(dt)
		end
		for index, hitmarker in ipairs(hitmarkers) do
			hitmarker:update(dt)
			if hitmarker.timer <= 0 then
				table.remove(hitmarkers, index)
			end
		end
	elseif state == "title" then
		Hands.update(dt)
	end
end

function love.keypressed(key)
	if state == "game" then
		local clap = key == "x" or key == "z" or key == "y" or key == "u"
		if clap and not Hands.clapping then
			Hands.clapping = true

			local bugsHit = 0
			for index, moth in ipairs(s.moths) do
				local dx = math.abs(Hands.x - moth.x)
				local dy = math.abs(Hands.y - moth.y)
				if dx < 3.5 and dy < 3.5 then
					table.remove(s.moths, index)
					score = score + 10
					bugsHit = bugsHit + 1
				end
			end

			love.audio.play(clapSound)
			if bugsHit == 1 then
				love.audio.play(bugMushSound)
			elseif bugsHit > 1 then
				love.audio.play(bugMushSound)
			end
		end
	else
		if key == "p" then
			state = "game"
			initGame()
		end
		local clap = key == "x" or key == "z" or key == "y" or key == "u"
		if clap and not Hands.clapping then
			Hands.clapping = true

			local bugsHit = 0
			for index, moth in ipairs(s.moths) do
				local dx = math.abs(Hands.x - moth.x)
				local dy = math.abs(Hands.y - moth.y)
				if dx < 3.5 and dy < 3.5 then
					table.remove(s.moths, index)
					bugsHit = bugsHit + 1
				end
			end

			love.audio.play(clapSound)
			if bugsHit == 1 then
				love.audio.play(bugMushSound)
			elseif bugsHit > 1 then
				love.audio.play(bugMushSound)
			end
		end
	end
end

function love.draw()
	if state == "game" then
		-- draw the background scene and hammock
		love.graphics.draw(scene, 0, 0, 0, intScale, intScale)

		if Hands.x < Hands.center[1] then
			love.graphics.draw(anaLeft, 0, 0, 0, intScale, intScale)
		else
			love.graphics.draw(anaRight, 0, 0, 0, intScale, intScale)
		end

		-- draw the game ui
		zzzs:draw()

		love.graphics.draw(scoreText, 0, 0, 0, intScale, intScale)
		love.graphics.setFont(numbers)
		love.graphics.printf(score, 4 * 6, 16 * 6, 30, "left", 0, 6, 6)

		-- draw the hands and arms
		Hands.draw()

		-- draw all potential hitmarkers
		for index, hitmarker in ipairs(hitmarkers) do
			hitmarker:draw()
		end

		-- draw all moths
		for _, moth in ipairs(s.moths) do
			moth:draw()
		end

		Hands.drawJustTopsOfHands()
	elseif state == "crying" then
		love.graphics.draw(scene, 0, 0, 0, intScale, intScale)
		-- if cryingTime > 0.7 then
		-- 	if Hands.x < Hands.center[1] then
		-- 		love.graphics.draw(waltAndAnaLeft, 0, 0, 0, intScale, intScale)
		-- 	else
		-- 		love.graphics.draw(waltAndAnaRight, 0, 0, 0, intScale, intScale)
		-- 	end
		-- else
		if Hands.x < Hands.center[1] then
			love.graphics.draw(anaLeft, 0, 0, 0, intScale, intScale)
		else
			love.graphics.draw(anaRight, 0, 0, 0, intScale, intScale)
		end
		-- end

		love.graphics.draw(scoreText, 0, 0, 0, intScale, intScale)
		love.graphics.setFont(numbers)
		love.graphics.printf(score, 4 * 6, 16 * 6, 30, "left", 0, 6, 6)

		Hands.draw()

		for _, hitmarker in ipairs(hitmarkers) do
			hitmarker:draw()
		end

		love.graphics.draw(gameOverText, 0, 0, 0, intScale, intScale)

		for _, moth in ipairs(s.moths) do
			moth:draw()
		end

		Hands.drawJustTopsOfHands()
	elseif state == "title" then
		love.graphics.draw(scene, 0, 0, 0, intScale, intScale)

		if Hands.x < Hands.center[1] then
			love.graphics.draw(anaLeft, 0, 0, 0, intScale, intScale)
		else
			love.graphics.draw(anaRight, 0, 0, 0, intScale, intScale)
		end

		Hands.draw()

		love.graphics.draw(titleText, 0, 0, 0, intScale, intScale)

		Hands.drawJustTopsOfHands()
	end
end

function initGame()
	score = 0
	-- Hands.load()
	hitmarkers = {}
	zzzs = Zzzs()
	s = Spawner()
end
