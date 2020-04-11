local utils = require 'utils'
local save = require 'save'

local state = {
	autorepeat = data.ar.menu
}

function state:load()
	local langs = utils.keysSorted(data.languages)

	self.buttons = ui.buttons:new("lang", "med", {
		lang = {
			label = "language",
			x = 100,
			y = 150,
			u = "back",
			d = "mdas",
			type = "select",
			opts = {
				display = data.languages,
				order = utils.keysSorted(data.languages),
				cur = game.conf.lang,
			},
			font = "noto",
			dx = 200,
			dy = 0,
			call = function(lang) setLang(lang) end
		},

		gdas = {
			label = "das_game",
			x = data.window.wcenter,
			y = 200,
			u = "lang",
			d = "garr",
			l = "mdas",
			r = "mdas",
			type = "number",
			dx = 350,
			dy = 0,
			opts = {
				cur = game.conf.gdas,
				step = 10,
				min = 0,
				max = 500
			},
			call = function(x) game.conf.gdas = x end
		},

		garr = {
			label = "arr_game",
			x = data.window.wcenter,
			y = 250,
			u = "gdas",
			d = "sd",
			l = "marr",
			r = "marr",
			type = "number",
			dx = 350,
			dy = 0,
			opts = {
				cur = game.conf.garr,
				step = 5,
				min = 5,
				max = 60,
				maxw = "100"
			},
			call = function(x) game.conf.garr = x end
		},

		mdas = {
			label = "das_menu",
			x = 100,
			y = 200,
			u = "lang",
			d = "marr",
			l = "gdas",
			r = "gdas",
			type = "number",
			dx = 350,
			dy = 0,
			opts = {
				cur = game.conf.mdas,
				step = 20,
				min = 100,
				max = 500
			},
			call = function(x) game.conf.mdas = x end
		},

		marr = {
			label = "arr_menu",
			x = 100,
			y = 250,
			u = "mdas",
			d = "sd",
			l = "garr",
			r = "garr",
			type = "number",
			dx = 350,
			dy = 0,
			opts = {
				cur = game.conf.marr,
				step = 10,
				min = 20,
				max = 100,
			},
			call = function(x) game.conf.marr = x end
		},

		sd = {
			label = "sd_speed",
			x = 100,
			y = 300,
			u = "marr",
			d = "fps",
			type = "number",
			dx = 350,
			dy = 0,
			opts = {
				cur = game.conf.sdarr,
				step = 0.5,
				min = 0.5,
				max = 3,
				maxw = "2.5"
			},
			call = function(x) game.conf.sdarr = x end
		},

		fps = {
			label = "toggle_fps",
			x = 100,
			y = 350,
			u = "sd",
			d = "next",
			call = function() game.conf.fps = not game.conf.fps end
		},

		next = {
			label = "next_count",
			x = 100,
			y = 400,
			u = "fps",
			d = "back",
			type = "number",
			dx = 350,
			dy = 0,
			opts = {
				cur = game.conf.nextCount,
				step = 1,
				min = 0,
				max = 6
			},
			call = function(x) game.conf.nextCount = x end
		},

		back = {
			label = "back",
			x = 100,
			y = data.window.height - 100,
			u = "next",
			d = "lang",
			call = "menu",
			resetSelection = true
		}
	}, "menu", function() save.writeGame("conf") end)
end

function state:onmount()
end

function state:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(assets.fonts.big)
	love.graphics.print(t("options"), 50, 30)

	self.buttons:draw()
end

function state:onkey(key)
	self.buttons:handleInput(key)
end

function state:update(dt)
end

return state
