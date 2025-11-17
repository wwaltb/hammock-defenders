Zzzs = Object.extend(Object)

function Zzzs.new(self)
	self.zsLeft = 6

	self.x, self.y = 88, 1

	self.outline = love.graphics.newImage("art/zzzsOutline.png")

	self.health = love.graphics.newImage("art/zzzs.png")
	self.numFrames = self.zsLeft + 1
	self.w, self.h = 28, 12
	self.sw = self.w * self.numFrames
	self.frames = {}
	for i = 0, self.zsLeft do
		table.insert(self.frames, love.graphics.newQuad(i * self.w, 0, self.w, self.h, self.sw, self.h))
	end
end

function Zzzs.minusOne(self)
	self.zsLeft = math.max(0, self.zsLeft - 2)
	if self.zsLeft == 0 then
		return true
	end
	return false
end

function Zzzs.draw(self)
	-- if self.timer <= 0 then
	-- 	return
	-- end
	--
	local x = self.x * 6
	local y = self.y * 6
	love.graphics.draw(self.outline, x, y, 0, 6, 6)
	love.graphics.draw(self.health, self.frames[self.numFrames - self.zsLeft], x, y, 0, 6, 6)
end
