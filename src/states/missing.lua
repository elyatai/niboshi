local state = {
	autorepeat = data.ar.menu
}

function state:load()
	self.buttons = ui.buttons:new("menu", "med", {
		menu = {
			label = "back_to_menu",
			x = data.window.wcenter,
			y = 400,
			center = true,
			u = "quit",
			d = "quit",
			call = function() setState("menu") end
		},
		quit = {
			label = "quit",
			x = data.window.wcenter,
			y = 440,
			center = true,
			u = "menu",
			d = "menu",
			call = function() love.event.quit() end
		}
	})
end

function state:onmount()
end

function state:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(assets.fonts.title)
	ui.centerText("oh jeez", data.window.wcenter, 60)

	love.graphics.setFont(assets.fonts.big)
	ui.centerText(t("unfinished"), data.window.wcenter, 250)

	self.buttons:draw()

	love.graphics.setFont(assets.fonts.small)
	love.graphics.print(game.keys.last or "", 0, 0)
end

function state:onkey(key)
	self.buttons:handleInput(key)
end

function state:update(dt)
end

return state