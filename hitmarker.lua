HitMarker = Object.extend(Object)

function HitMarker.new(self, x, y)
	self.x = x
	self.y = y
	self.timer = 0.4
	self.sprite = love.graphics.newImage("art/hitMark.png")
	self.spriteOffsetX = 3
	self.spriteOffsetY = 6
end

function HitMarker.update(self, dt)
	self.timer = math.max(0, self.timer - dt)
end

function HitMarker.draw(self)
	-- if self.timer <= 0 then
	-- 	return
	-- end
	--
	local x = (math.floor(self.x + 0.5) - self.spriteOffsetX) * 6
	local y = (math.floor(self.y + 0.5) - self.spriteOffsetY) * 6
	love.graphics.draw(self.sprite, x, y, 0, 6, 6)
end
