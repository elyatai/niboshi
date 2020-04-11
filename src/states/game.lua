local state = {
	autorepeat = {
		tleft = "game",
		tright = "game",
		tsd = "sd",
		thd = "none",
		tsonic = "none",
		tcw = "none",
		tccw = "none",
		t180 = "none",
		thold = "none",
		tpause = "none",
		mup = "menu",
		mdown = "menu",
		mleft = "menu",
		mright = "menu",
		menter = "none",
		mback = "none"
	}
}

local engine = require 'engine'
local utils = require 'utils'

function state:load()
end

function state:startCountdown()
	self:restart()
	self.countdown = 2
end

function state:restart()
	self.paused = false
	engine:restart()
end

function state:onmount()
	local nh = data.neighborhoods[game.game.neighborhood]
	engine:init(
		game.game.width,
		game.game.height,
		game.game.order,
		nh
	)
	self:startCountdown()

	-- horizontally we need space for
	-- - at least 100px padding
	-- - hold piece, half size, should be as wide as longest piece
	--   (longest piece in tiles * tile size / 2 * x)
	-- - small margin
	-- - board, as wide as possible (width in tiles * tile size * some x)
	-- - small margin, same as before
	-- - next pieces, same width as hold piece
	-- - small margin, same as before
	-- - some text
	-- - more padding, same as before

	-- let w{w/h} = window's {width/height},
	local ww, wh = data.window.width, data.window.height
	--     g{w/h} = game's {width/height} in tiles,
	local gw, gh = game.game.width, game.game.height
	--     t{w/h} = tile texture's {width/height} in pixels,
	local tw, th = assets.images.tile:getDimensions()
	--     p      = padding in px
	local p = 100
	--     t      = text in px
	local t = 300
	--     m      = margin in px
	local m = 15
	--     lp     = longest piece in tiles
	--              we get this by finding the longest space between two tiles
	--              on the x axis, given by the neighborhood (nh),
	--              and then multiplying by the amount of cells in each piece
	local lp = 0
	for _, adj in ipairs(nh) do
		local x, _ = unpack(adj)
		if lp < x then
			lp = x
		end
	end
	lp = lp * game.game.order
	--     np     = width of next/hold pieces, in pixels
	--     b{w/h} = {width/height} of board in pixels
	--     s{w/h} = the {width/height}'s pieces' scale

	-- ww = p + np + m + bw + m + np + m + t + p
	-- ww = 2p + 2np + 3m + bw + t
	-- ww = 2p + 2(lp*(tw/2)*sw) + 3m + gw*tw*sw + t
	-- ww = 2p + lp*tw*sw + 3m + gw*tw*sw + t
	-- ww = 2p + (sw)(tw)(lp+gw) + 3m + t
	-- ww - 2p - 3m - t = sw * (tw)(gw + lp)
	-- sw = (ww - 2p - 3m - t) / (tw)(gw + lp)
	local sw = (ww - 2*p - 3*m - t) / (tw * (gw+lp))

	-- vertically, we only need space for
	-- - 100px+ padding
	-- - board, as tall as possible (height in tiles * tile size * some x)
	-- - same padding

	-- wh = p + (gh*th*sh) + p
	-- wh = 2p + gh*th*sh
	-- wh - 2p = gh*th*sh
	-- sh = (wh - 2p) / (gh * th)
	local sh = (wh - 2*p) / (gh * th)

	-- to get the final scale value, the minimum of the two is taken
	local scale = math.min(sw, sh)
	-- the board's width and height in pixels can be calculated from this value
	local bw, bh = gw * tw * scale, gh * th * scale
	-- and so can the width of the next and hold piece boxes
	local np = scale * tw * lp / 2
	-- the height should have one margin of space
	local nh = np + m

	-- the padding above and below the board will need to be recalculated
	-- wh = ph + bh + ph
	-- wh = 2ph + bh
	-- wh - bh = 2ph
	-- ph = (wh - bh) / 2
	local ph = (wh - bh) / 2

	-- and so will the padding to the left and right, but the other factors must
	-- be included as well
	-- ww = pw + np + m + bw + m + np + m + t + pw
	-- ww = 2pw + 2np + 3m + bw + t
	-- pw = (ww - 2np - 3m - bw - t) / 2
	local pw = (ww - 2*np - 3*m - bw - t) / 2

	-- these values have already been calculated
	self.board = {
		width = bw,
		height = bh,
	}
	self.tile = {
		scale = scale,
		width = tw * scale,
		height = th * scale
	}
	self.nextWidth = math.ceil(np)
	self.nextHeight = math.ceil(nh)
	self.edges = {
		-- the top edge of the board begins at the end of the padding
		boardTop = ph,
		-- the pixel at which the hold piece starts does too
		hold = pw
	}
	-- the board's left edge is after the hold piece and margin
	self.edges.boardLeft = self.edges.hold + np + m
	-- the board's bottom edge is after the width of the board
	self.edges.boardBottom = self.edges.boardTop + bh
	-- the next pieces start after the board and another margin
	self.edges.next = self.edges.boardLeft + bw + m
	-- the text starts after that
	self.edges.text = self.edges.next + np + m

	self.board.wcenter = self.edges.boardLeft + bw/2
	self.board.hcenter = self.edges.boardTop + bh/2

	for _, k in pairs({"edges", "board"}) do
		for i, x in pairs(self[k]) do
			self[k][i] = utils.round(x)
		end
	end

	self.pauseMenu = ui.buttons:new("restart", "med", {
		restart = {
			label = "restart",
			x = self.board.wcenter,
			y = self.board.hcenter,
			u = "back",
			d = "back",
			center = true,
			call = function() self:startCountdown() end
		},
		back = {
			label = "back",
			x = self.board.wcenter,
			y = self.board.hcenter + 50,
			u = "restart",
			d = "restart",
			center = true,
			call = "gameconf"
		}
	})
end

function state:draw()
	love.graphics.setColor(ui.colors.bg)
	love.graphics.rectangle("fill",
		self.edges.boardLeft, self.edges.boardTop,
		self.board.width, self.board.height
	)

	self:drawGame()

	if self.countdown then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(assets.fonts.title)
		local fh = assets.fonts.title:getHeight()
		local word = self.countdown >= 1 and t("ready") or t("go")
		ui.centerText(word, self.board.wcenter, self.board.hcenter - fh/2)

	elseif self.paused then
		love.graphics.setColor(utils.setAlpha(ui.colors.bg, 0.7))
		love.graphics.rectangle("fill",
			self.edges.boardLeft, self.edges.boardTop,
			self.board.width, self.board.height
		)

		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(assets.fonts.big)
		ui.centerText(t("paused"), self.board.wcenter, self.edges.boardTop + 100)

		self.pauseMenu:draw()
	end

	local info = {}
	if self.countdown then
		info = {
			t("score_blank"),
			t("lines_blank"),
			t("time_blank"),
			t("piece_count", engine.pieceCount),
			t("pps_blank"),
			t("kpp_blank")
		}
	else
		info = {
			t("score", engine.current and engine.current.piece or 0),
			t("lines", engine.lines),
			t("time", engine.minutes, engine.seconds),
			t("piece_count", engine.pieceCount),
			t("pps", engine.placed / engine.time),
			t("kpp", engine.placed > 0 and (engine.actions / engine.placed) or engine.actions)
		}
	end
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(assets.fonts.small)
	local fh = assets.fonts.small:getHeight()
	for i, s in ipairs(info) do
		local y = self.edges.boardTop + fh*(i-1)
		love.graphics.print(s, self.edges.text, y)
	end
end

function state:drawGame()
	love.graphics.push()
	love.graphics.translate(self.edges.boardLeft, self.edges.boardBottom)
	love.graphics.scale(1, -1)
	for y = 0, engine.board.rh do
		for x = 0, engine.board.rw do
			local c = engine.board[y][x]
			if c then
				love.graphics.setColor(c)
				love.graphics.draw(assets.images.tile,
					x * self.tile.width, y * self.tile.height,
					0,
					self.tile.scale, self.tile.scale
				)
			end
		end
	end
	love.graphics.pop()

	if engine.current then
		self:drawPiece(
			engine.current.piece, engine.current.rot,
			self.edges.boardLeft, self.edges.boardBottom,
			engine.current.x, engine.ghost,
			{img = assets.images.ghost}
		)

		self:drawPiece(
			engine.current.piece, engine.current.rot,
			self.edges.boardLeft, self.edges.boardBottom,
			engine.current.x, engine.current.y
		)
	end

	if engine.holdPiece then
		self:drawPiece(
			engine.holdPiece, 1,
			self.edges.hold, self.edges.boardTop,
			0, 0,
			{scale = 0.5, gray = engine.held, align = "top"}
		)
	end

	for i, p in ipairs(engine.next) do
		local y = self.edges.boardTop + (i-1)*self.nextHeight
		self:drawPiece(
			p, 1,
			self.edges.next, y,
			0, 0,
			{scale = 0.5, align = "top"}
		)
	end
end

function state:drawPiece(id, rot, x, y, px, py, opts)
	local piece = engine.pieces[id]
	opts = opts or {}
	opts.scale = opts.scale or 1
	local color = opts.gray and {0.7, 0.7, 0.7} or piece.color
	local oh = opts.align == "top" and piece.h or -1
	local img = opts.img or assets.images.tile

	love.graphics.setColor(color)
	for _, p in ipairs(piece.data[rot]) do
		local rx, ry = unpack(p)
		local x_ = x + (rx + px) * self.tile.width * opts.scale
		local y_ = y + (oh - ry - py) * self.tile.height * opts.scale
		love.graphics.draw(img,
			x_, y_,
			0,
			self.tile.scale*opts.scale, self.tile.scale*opts.scale
		)
	end
end

do
	local onkey = {
		tpause = function(self)
			self.paused = true
			self.current = nil
		end,
		tleft = function() engine:move(-1) end,
		tright = function() engine:move(1) end,
		tsd = function() engine:drop("soft") end,
		thd = function() engine:drop("hard") end,
		tsonic = function() engine:drop("sonic") end,
		thold = function() engine:hold() end,
		tcw = function() engine:rotate(1) end,
		tccw = function() engine:rotate(3) end,
		t180 = function() engine:rotate(2) end
	}

	local aps = {
		tleft = true, tright = true, thold = true,
		tcw = true, tccw = true, t180 = true,
		thd = true, tsd = true, tsonic = true
	}

	function state:onkey(key, ar)
		if self.paused then
			self.pauseMenu:handleInput(key)
			return
		end

		if (not ar or ar == 1) and aps[key] then
			engine:action()
		end

		if not self.countdown and not self.paused and onkey[key] then
			onkey[key](self)
			engine:recalcGhost()
		end
	end
end

function state:update(dt)
	if self.countdown then
		local cd = self.countdown - dt
		if cd < 0 then
			self.countdown = nil
			engine:begin()
			return
		end
		self.countdown = cd
		return
	end

	if self.paused then
		return
	end

	engine:update(dt)
end

return state
