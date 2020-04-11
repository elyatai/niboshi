local keys = require 'keys'
local save = require 'save'

assets = require 'assets'
ui = require 'ui/ui'
t = require 'translate'

local states = require 'states'
state = {}

data = {
	languages = {
		en = "English",
		ja = "日本語",
		ru = "Русский",
		tp = "toki pona"
	},
	window = {},
	ar = {
		menu = {
			mup = "menu",
			mdown = "menu",
			mleft = "menu",
			mright = "menu",
			menter = "none",
			mback = "none"
		}
	},
	neighborhoods = {
		vonneumann = {
			{1, 0}, {0, 1}, {-1, 0}, {0, -1}
		},
		moore = {
			{1, 0}, {1, 1}, {0, 1}, {-1, 1},
			{-1, 0}, {-1, -1}, {0, -1}, {1, -1}
		},
		diagonals = {
			{1, 1}, {-1, 1}, {-1, -1}, {1, -1}
		},
		knight = {
			{1, 2}, {2, 1}, {2, -1}, {1, -2},
			{-1, -2}, {-2, -1}, {-2, 1}, {-1, 2}
		},
		spread = {
			{2, 0}, {0, 2}, {-2, 0}, {0, -2}
		}
	}
}

game = {
	lang = {},
	conf = {
		keys = {
			mup = "up",
			mdown = "down",
			mleft = "left",
			mright = "right",
			menter = "return",
			mback = "escape",
			tleft = "left",
			tright = "right",
			tsd = "down",
			thd = "space",
			tsonic = "up",
			tcw = "x",
			tccw = "z",
			t180 = "c",
			thold = "lshift",
			tpause = "escape"
		},
		lang = "en",
		gdas = 130,
		garr = 15,
		mdas = 200,
		marr = 50,
		sdarr = 2,
		fps = true,
		nextCount = 6
	},
	game = {
		width = 10,
		height = 20,
		order = 4,
		neighborhood = "vonneumann",
		randomizer = "nbag"
	}
}

function setLang(lang)
	game.conf.lang = lang
	local lang = require ("lang/" .. lang)
	game.lang = lang.texts
	assets.loadFonts(lang.fonts)
end

function setState(st)
	state = states[st] or states.missing
	state:onmount()
end

function love.load()
	love.keyboard.setKeyRepeat(false)
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 8)))

	save.createSaveDir()
	save.readGame("conf")
	save.readGame("game")

	local w, h = love.graphics.getDimensions()
	data.window = {
		width = w,
		height = h,
		wcenter = w/2,
		hcenter = h/2
	}

	assets.load()
	setLang(game.conf.lang)
	states.load()

	setState("menu")

	love.graphics.setDefaultFilter("linear", "nearest", 1)
end

function love.draw()
	love.graphics.clear()

	if game.conf.fps then
		love.graphics.setFont(assets.fonts.small)
		love.graphics.setColor(ui.colors.white)
		love.graphics.print(t("fps", love.timer.getFPS()), 0, 0)
	end

	state:draw()
end

function love.update(dt)
	keys:update(dt)
	state:update(dt)
end

function love.keypressed(_, sc)
	keys:keypressed(sc)
end

function love.keyreleased(_, sc)
	keys:keyreleased(sc)
end

love.joystickpressed = keys.joystickpressed