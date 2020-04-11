local state = {
	autorepeat = data.ar.menu
}

function state:load()
	self.buttons = ui.buttons:new("start", "med", {
		start = {
			label = "start",
			x = data.window.wcenter,
			y = 400,
			center = true,
			u = "quit",
			d = "options",
			call = "gameconf"
		},

		options = {
			label = "options",
			x = data.window.wcenter,
			y = 440,
			center = true,
			u = "start",
			d = "quit",
			call = "options"
		},

		quit = {
			label = "quit",
			x = data.window.wcenter,
			y = 480,
			center = true,
			u = "options",
			d = "start",
			call = function() love.event.quit() end
		}
	})
end

function state:onmount()
end

function state:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(assets.fonts.title)
	ui.centerText(t("title"), data.window.wcenter, 60)

	love.graphics.setFont(assets.fonts.big)
	ui.centerText(t("subtitle"), data.window.wcenter, 250)

	self.buttons:draw()
end

function state:onkey(key)
	self.buttons:handleInput(key)
end

function state:update(dt)
end

return state