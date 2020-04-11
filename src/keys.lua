local keys = {}

keys.ar = {}
keys.das = {} -- number if delay completed, nil otherwise

function keys:update(dt)
	for k, t in pairs(self.ar) do
		local das, arr = 1000, 100
		local type = state.autorepeat[k]

		if type == "sd" then
			t = t + game.conf.sdarr
			while t >= 1 do
				state:onkey(k, true)
				t = t - 1
			end
			self.ar[k] = t
			return
		end

		if type == "menu" then
			das, arr = game.conf.mdas, game.conf.marr
		else
			das, arr = game.conf.gdas, game.conf.garr
		end

		t = t + dt*1000

		if self.das[k] then
			while t >= arr do
				t = t - arr
				state:onkey(k, self.das[k])
				self.das[k] = self.das[k] + 1
			end
		else
			if t >= das then
				t = t - das
				self.das[k] = 1
				state:onkey(k, true)
			end
		end

		self.ar[k] = t
	end
end

function keys:keypressed(scancode)
	for id, sc in pairs(game.conf.keys) do
		if sc == scancode then
			local ar = state.autorepeat[id]

			if ar then
				state:onkey(id, false)

				if ar ~= "none" then
					self.ar[id] = 0
				
					if ar == "sd" then
						self.das[id] = nil
					end
				end
			end
		end
	end
end

function keys:keyreleased(scancode)
	for id, sc in pairs(game.conf.keys) do
		if sc == scancode and state.autorepeat[id] then
			self.ar[id] = nil
			self.das[id] = nil
		end
	end
end

function keys.joystickpressed()
end

function keys.table(table)
	-- unused argument is self
	return function(_, key)
		if table[key] then
			table[key](state)
		end
	end
end

return keys