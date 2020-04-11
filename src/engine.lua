local engine = {}

local utils = require 'utils'
local json = require 'lib/json'
local polyomino = require 'polyomino'

function engine:init(w, h, order, neighborhood)
	self.board = {
		w = w, h = h,
		rw = w - 1, rh = h*2 - 1
	}

	self.pieces = polyomino.generate(order, neighborhood)
	self.pieceCount = #self.pieces
	self:restart()
end

function engine:restart()
	self.score = 0
	self.minutes = 0
	self.seconds = 0
	self.time = 0
	self.placed = 0
	self.lines = 0
	self.actions = 0
	self.gravity = 1/64
	self.g = 0
	self.holdPiece = nil
	self.held = false
	self.ghost = nil
	self.current = nil

	for i = 0, self.board.rh do
		self.board[i] = {}
	end

	self:initRandomizer()

	self.next = {}
	for i = 1, game.conf.nextCount do
		self.next[i] = self:newPiece()
	end
end

function engine:nextPiece()
	self.placed = self.placed + 1
	table.insert(self.next, self:newPiece())
	self:currentPiece(table.remove(self.next, 1))
end

function engine:currentPiece(p)
	local piece = self.pieces[p]
	self.current = {
		x = math.floor(self.board.w/2 - piece.w/2),
		y = self.board.h,
		w = piece.w,
		h = piece.h,
		ox = piece.ox,
		oy = piece.oy,
		rot = 1,
		piece = p
	}
	self.ghost = self.current.y
end

function engine:getCurrentPiece()
	local p = self.pieces[self.current.piece]
	return p, p.data[self.current.rot]
end

do
	local randomizers = {
		random = function() end,
		tgm = function() return {} end,
		nbag = function(self)
			local tmp = {}
			for i = 1, self.pieceCount do
				tmp[i] = true
			end
			return {count = self.pieceCount, data = tmp}
		end
	}

	function engine:initRandomizer()
		self.randomizer = randomizers[game.game.randomizer](self)
	end
end

do
	local randomizers = {
		random = state.randomPiece,

		tgm = function(self)
			local tries = 6
			local piece = nil
			repeat
				tries = tries - 1
				piece = self:randomPiece()
			until tries < 1 or not self.randomizer[tostring(piece)]
			self.randomizer[tostring(piece)] = 6
			for k, i in pairs(self.randomizer) do
				if i >= 1 then
					self.randomizer[k] = i - 1
				else
					self.randomizer[k] = nil
				end
			end
			return piece
		end,

		nbag = function(self)
			if self.randomizer.count == 0 then
				self:initRandomizer()
			end
			local piece = self:randomPiece()
			while not self.randomizer.data[piece] do
				piece = utils.imod(piece + 1, self.pieceCount)
			end
			self.randomizer.data[piece] = nil
			self.randomizer.count = self.randomizer.count - 1
			return piece
		end
	}

	function engine:newPiece()
		return randomizers[game.game.randomizer](self)
	end
end

function engine:randomPiece()
	return math.random(self.pieceCount)
end

function engine:update(dt)
	self.time = self.time + dt
	self.minutes, self.seconds = utils.divmod(self.time, 60)

	self.g = self.g + self.gravity * 60 * dt
	if self.g >= 1 then
		local amt = 0
		amt, self.g = utils.divmod(self.g, 1)
		self:tryMove(0, -amt)
	end
end

function engine:rotate(count)
	for i = 1, count do
		self.current.rot = utils.imod(self.current.rot + 1, 4)

		self.current.x = self.current.x + self.current.ox
		self.current.y = self.current.y + self.current.oy

		self.current.ox, self.current.oy = self.current.oy, self.current.ox
		self.current.w, self.current.h = self.current.h, self.current.w

		self.current.x = self.current.x - self.current.ox
		self.current.y = self.current.y - self.current.oy
	end

	self:handleKicks()
end

function engine:move(amt)
	self:tryMove(amt, 0)
end

function engine:drop(kind)
	if kind == "soft" then
		self:tryMove(0, -1)
		return
	end

	self:sonicDrop()

	if kind == "hard" then
		self:lockPiece()
	end
end

function engine:hold()
	if self.held then
		return
	end

	self.held = true

	if not self.holdPiece then
		self.holdPiece = self.current.piece
		self:nextPiece()
		return
	end

	local tmp = self.current.piece
	self:currentPiece(self.holdPiece)
	self.holdPiece = tmp
end

function engine:action()
	self.actions = self.actions + 1
end

function engine:handleKicks()
	local xmin, xmax, ymin = 0, 0, 0
	local _, piece = self:getCurrentPiece()
	for _, pt in ipairs(piece) do
		local x = pt[1] + self.current.x
		local y = pt[2] + self.current.y
		xmin = math.min(xmin, x)
		xmax = math.max(xmax, x)
		ymin = math.min(ymin, y)
	end
	if xmin < 0 then
		self.current.x = self.current.x - xmin
	elseif xmax > self.board.w - 1 then
		self.current.x = self.current.x - xmax + self.board.w - 1
	end
	if ymin < 0 then
		self.current.y = self.current.y - ymin
	end
end

function engine:sonicDrop()
	self.current.y = self.ghost
end

function engine:recalcGhost()
	local pts = {}

	local piece, data = self:getCurrentPiece()
	for _, pt in ipairs(data) do
		local px, py = unpack(pt)
		local x = px + self.current.x
		if not pts[x] then
			pts[x] = py
		else
			pts[x] = math.min(pts[x], py)
		end
	end

	local y = -1
	for x, c in pairs(pts) do
		local tmp = self.current.y
		while engine:checkPt(x, c + tmp) do
			tmp = tmp - 1
		end
		y = math.max(y, tmp + 1)
	end

	self.ghost = y
end

function engine:lockPiece()
	local piece, data = self:getCurrentPiece()
	for _, pt in ipairs(data) do
		local px, py = unpack(pt)
		local x = px + self.current.x
		local y = py + self.current.y
		self.board[y][x] = piece.color
	end

	self:clearLines()
	self.held = false
	self:nextPiece()
end

function engine:clearLines()
	local x = 0
	for i = 0, self.board.rh do
		if self:lineFull(i) then
			self.lines = self.lines + 1
		else
			if x ~= i then
				self.board[x] = self.board[i]
			end
			x = x + 1
		end
	end
	for i = x, self.board.rh do
		self.board[x] = {}
	end
end

function engine:lineFull(line)
	for i = 0, self.board.rw do
		if not self.board[line][i] then
			return false
		end
	end
	return true
end

function engine:tryMove(ox, oy)
	if engine:checkOffset(ox, oy) then
		self.current.x = self.current.x + ox
		self.current.y = self.current.y + oy
		self:recalcGhost()
	end
end

function engine:checkOffset(ox, oy)
	local cx, cy = self.current.x, self.current.y
	return engine:checkOk(ox+cx, oy+cy)
end

function engine:checkOk(x, y)
	local _, piece = self:getCurrentPiece()
	for _, pt in ipairs(piece) do
		local px, py = unpack(pt)
		if not self:checkPt(px+x, py+y) then
			return false
		end
	end
	return true
end

function engine:checkPt(x, y)
	if x < 0 or x > self.board.rw then
		return false end
	if y < 0 or y > self.board.rh then
		return false end
	if self.board[y] and self.board[y][x] then
		return false end
	return true
end

function engine:begin()
	self:nextPiece()
	self:recalcGhost()
end

return engine