local save = require 'save'

local state = {
	autorepeat = data.ar.menu
}

function state:load()
	self.buttons = ui.buttons:new("play", "small", {
		play = {
			label = "start",
			font = "med",
			u = "back",
			d = "width",
			x = 100,
			y = 130,
			resetSelection = true,
			call = "game"
		},

		width = {
			label = "width",
			x = 100,
			y = 200,
			u = "play",
			d = "order",
			l = "height",
			r = "height",
			type = "number",
			dx = 300,
			dy = 0,
			opts = {
				cur = game.game.width,
				min = 3,
				max = 40,
				step = 1
			},
			call = function(x) game.game.width = x end
		},

		height = {
			label = "height",
			x = data.window.wcenter,
			y = 200,
			u = "play",
			d = "neighborhoods",
			l = "width",
			r = "width",
			type = "number",
			dx = 300,
			dy = 0,
			opts = {
				cur = game.game.height,
				min = 5,
				max = 60,
				step = 1
			},
			call = function(x) game.game.height = x end
		},

		order = {
			label = "order",
			x = 100,
			y = 235,
			u = "width",
			d = "randomizer",
			l = "neighborhoods",
			r = "neighborhoods",
			type = "number",
			dx = 300,
			dy = 0,
			opts = {
				cur = game.game.order,
				min = 1,
				max = 15,
				step = 1
			},
			call = function(x) game.game.order = x end
		},

		neighborhoods = {
			label = "neighborhood_type",
			x = data.window.wcenter,
			y = 235,
			u = "height",
			d = "randomizer",
			l = "order",
			r = "order",
			type = "select",
			dx = 300,
			dy = 0,
			opts = {
				cur = game.game.neighborhood,
				order = {"vonneumann", "diagonals", "moore", "knight", "spread"},
				display = {
					vonneumann = "vonneumann_neighborhood",
					diagonals = "diagonal_neighborhood",
					moore = "moore_neighborhood",
					knight = "knights_neighborhood",
					spread = "spread_neighborhood"
				},
				translate = true
			},
			call = function(x) game.game.neighborhood = x end
		},

		randomizer = {
			label = "randomizer",
			x = 100,
			y = 270,
			u = "order",
			d = "back",
			type = "select",
			dx = 300,
			dy = 0,
			opts = {
				cur = game.game.randomizer,
				order = {"random", "tgm", "nbag"},
				display = {random = "nes", tgm = "tgm", nbag = "nbag"},
				translate = true
			},
			call = function(x) game.game.randomizer = x end
		},

		back = {
			label = "back",
			font = "med",
			x = 100,
			y = data.window.height - 100,
			u = "randomizer",
			d = "play",
			resetSelection = true,
			call = "menu"
		}
	}, "menu", function() save.writeGame("game") end)
end

function state:onmount()
	self.saved = false
end

function state:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(assets.fonts.big)
	love.graphics.print(t("game_settings"), 50, 30)

	local order = self.buttons.buttons.order.opts.cur 
	if order < 10 then
		local amt = (order - 4) / 6
		love.graphics.setColor(amt, amt, amt)
	else
		local amt = 1 - (order - 10)/5
		love.graphics.setColor(1, amt, amt)
	end
	love.graphics.setFont(assets.fonts.xsmall)
	love.graphics.print(t("order_oom"), 100, 170)

	self.buttons:draw()
end

function state:onkey(key)
	self.buttons:handleInput(key)
end

function state:update(dt)
end

return state