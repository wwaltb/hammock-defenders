Spawner = Object.extend(Object)

function Spawner.new(self)
	require("moth")
	self.moths = {}

	self.mothTimer = 3
	self.mothInterval = 10
	self.firstMoth = true
end

function Spawner.update(self, dt)
	-- print(self.mothTimer)

	self.mothTimer = self.mothTimer - dt

	if #self.moths == 0 and not self.firstMoth then
		self:spawnMothSoon()
	end

	if self.mothTimer < 0 then
		self:spawnMoth()
		self.mothTimer = self.mothInterval
	end
end

function Spawner.spawnMoth(self)
	table.insert(self.moths, Moth())
	if math.random() < 0.15 and not self.firstMoth then
		table.insert(self.moths, Moth())
	end

	if self.firstMoth then
		self.firstMoth = false
	end
end

function Spawner.spawnMothSoon(self)
	local t = 0.8
	if self.mothTimer > t then
		self.mothTimer = t
	end
end
