local utils = require 'utils'

local buttons = {} 

local keys = {
	u = -1, d = 1,
	l = -1, r = 1
}

local function call(fn, state)
	if type(fn) == "function" then
		fn()
	elseif type(fn) == "string" and state then
		setState(fn)
	end
end

function buttons:new(sel, font, data, onBack, onConfirm)
	for id, b in pairs(data) do
		b.type = b.type or "button"
		b.font = b.font or font

		if b.type == "select" then
			if type(b.opts.cur) ~= "number" then
				b.opts.cur = utils.indexOf(b.opts.order, b.opts.cur)
			end
		end
	end

	local me = {
		sel = sel,
		default = sel,
		font = font,
		buttons = data,
		onBack = onBack,
		selected = false,
		onConfirm = onConfirm
	}
	setmetatable(me, {__index = self})
	return me
end

do
	local short = {
		mup = "u",
		mdown = "d",
		mleft = "l",
		mright = "r",
		mback = "back",
		menter = "enter"
	}
	function buttons:handleInput(key)
		local b = self.buttons[self.sel]
		local s = short[key]
		if not s then return end

		if self.selected then
			self["handle" .. b.type](self, b, s)
			return
		end

		if s == "enter" then
			if b.type == "button" then
				call(b.call, true)
				call(self.onConfirm, false)

				if b.resetSelection then
					self.sel = self.default
				end
				return
			end

			self.selected = true
			self["handle" .. b.type](self, b, nil)
		end

		if s == "back" then
			call(self.onBack, true)
			return
		end

		if b[s] then
			self.sel = b[s]
		end
	end
end

function buttons:draw()
	for id, b in pairs(self.buttons) do
		love.graphics.setFont(assets.fonts[b.font])

		-- draw primary buttons

		if id == self.sel then
			if self.selected then
				love.graphics.setColor(ui.colors.selected2)
			else
				love.graphics.setColor(ui.colors.selected1)
			end
		else
			love.graphics.setColor(ui.colors.notselected1)
		end

		local text = b.text or t(b.label)

		if b.center then
			ui.centerText(text, b.x, b.y)
		else
			love.graphics.print(text, b.x, b.y)
		end

		if b.type ~= "button" then
			-- draw secondary selector
			local sel = self.selected and id == self.sel
			love.graphics.push()
			love.graphics.translate(b.x+b.dx, b.y+b.dy)
			self["draw" .. b.type](self, b, sel)
			love.graphics.pop()
		end
	end
end

function buttons:handleselect(b, k)
	if not k then
		b.opts.last = b.opts.cur
		return
	end

	if k == "enter" then
		b.call(b.opts.order[b.opts.cur])
		call(self.onConfirm, false)
		self.selected = false
		return
	end

	if k == "back" then
		b.opts.cur = b.opts.last
		self.selected = false
		return
	end

	b.opts.cur = utils.imod(b.opts.cur + keys[k], #b.opts.order)
end

function buttons:drawselect(b, sel)
	if sel then
		love.graphics.setColor(ui.colors.selected1)
	else
		love.graphics.setColor(ui.colors.notselected2)
	end

	local text = b.opts.display[b.opts.order[b.opts.cur]]
	if b.opts.translate then
		text = t(text)
	end
	local hh = assets.fonts[self.font]:getHeight()
	local h = hh/2
	local dx = assets.fonts[b.font]:getWidth(text) + h + 50

	love.graphics.print(text, h+25, 0)
	love.graphics.polygon("fill", {
		0, h,
		h, 0,
		h, hh
	})
	love.graphics.polygon("fill", {
		dx, 0,
		dx, hh,
		h+dx, h,
	})
end

function buttons:handlenumber(b, k)
	if not k then
		b.opts.last = b.opts.cur
		return
	end

	if k == "enter" then
		b.call(b.opts.cur)
		call(self.onConfirm, false)
		self.selected = false
		return
	end

	if k == "back" then
		b.opts.cur = b.opts.last
		self.selected = false
		return
	end

	local d = keys[k] * b.opts.step
	local next = b.opts.cur + d
	if next < b.opts.min or b.opts.max < next then
		return
	end

	b.opts.cur = next
end

function buttons:drawnumber(b, sel)
	if sel then
		love.graphics.setColor(ui.colors.selected1)
	else
		love.graphics.setColor(ui.colors.notselected2)
	end

	local f = assets.fonts[b.font]
	local hh = f:getHeight()
	local h = hh/2
	local dx = f:getWidth(b.opts.maxw or tostring(b.opts.max)) + h + 50

	love.graphics.print(b.opts.cur, h+25, 0)
	
	if b.opts.min <= b.opts.cur - b.opts.step then
		love.graphics.polygon("fill", {
			0, h,
			h, 0,
			h, hh
		})
	end
	if b.opts.cur + b.opts.step <= b.opts.max then
		love.graphics.polygon("fill", {
			dx, 0,
			dx, hh,
			h+dx, h,
		})
	end
end

return buttons