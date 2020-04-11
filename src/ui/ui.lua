local ui = {}

local utils = require 'utils'

do
	local cache = {}
	function ui.rgb(str)
		if cache[str] then
			return cache[str]
		end

		local out = {}
		for i = 1, 6, 2 do
			local tmp = str:sub(i, i+1)
			local val = utils.fromBase(tmp, 16) / 255
			table.insert(out, val)
		end
		cache[str] = out

		return out
	end
end

local widthCache = {}
function ui.centerText(text, x, y, ...)
	local f = love.graphics.getFont()
	local w = 0
	local c = {}

	if not widthCache[f] then
		widthCache[f] = c
	else
		c = widthCache[f]
	end

	if not c[text] then
		w = f:getWidth(text)
		c[text] = w
	else
		w = c[text]
	end

	love.graphics.print(text, utils.round(x-w/2), y, ...)
end

ui.buttons = require 'ui/buttons'

ui.colors = {
	white = {1, 1, 1},
	bg = {0.2, 0.2, 0.2},
	black = {0, 0, 0},
	selected1 = ui.rgb("ff6e6e"),
	selected2 = ui.rgb("ad2222"),
	notselected1 = ui.rgb("b2b2b2"),
	notselected2 = ui.rgb("7a7a7a")
}

return ui