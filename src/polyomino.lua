local utils = require 'utils'

local polyomino = {}

-- COMPLEXITY ANALYSIS NOTES:
-- n refers to the number of elements of the table argument (usually `t`)
-- k refers to the length of the adjacency set (usually `adjs`)
-- o refers to the number of tiles per piece (usually `order`)

-- these helper functions aren't going in utils.lua
-- because they're specific to 2d tables
-- which isn't very helpful in most cases

-- O(1)
local function set(t, x, y, v)
	if t[x] then
		t[x][y] = v
	else
		t[x] = {[y] = v}
	end
end

-- O(1)
local function get(t, x, y)
	if not t[x] then
		return nil
	end
	return t[x][y]
end

-- O(n)
local function find(t, n)
	for i, x in pairs(t) do
		for j, y in pairs(x) do
			if y == n then
				return i, j
			end
		end
	end
end

-- O(n)
local function copy(t)
	local out = {}
	for i, x in pairs(t) do
		local tmp = {}
		for j, y in pairs(x) do
			tmp[j] = y
		end
		out[i] = tmp
	end
	return out
end

-- O(1)
local function ok(t, x, y)
	if y < 0 then return false end
	if y == 0 and x < 0 then return false end
	if get(t, x, y) ~= nil then return false end
	return true
end

-- O(1)
local function min(x, y)
	if x == nil then return y end
	return math.min(x, y)
end

-- O(n)
local function denumber(t)
	local t_ = t[1]
	for i, x in pairs(t_) do
		for j, y in pairs(x) do
			if y == 0 then
				x[j] = true
			else
				x[j] = nil
			end
		end
		-- remove empty rows
		if next(x) == nil then
			t_[i] = nil
		end
	end
	return t_
end

-- O(n)
local function rotate(t)
	local out = {}
	local minx, miny = nil, nil

	for i, x in pairs(t) do
		for j, y in pairs(x) do
			set(out, j, -i, y)
		end
	end

	return out
end

-----

-- O(n+k)
function polyomino.number(t, x, y, n, adjs)
	-- O(n)
	local t_ = copy(t)

	set(t_, x, y, 0)

	-- O(k)
	for _, a in ipairs(adjs) do
		local dx, dy = unpack(a)
		local x_, y_ = x+dx, y+dy

		if ok(t_, x_, y_) then
			set(t_, x_, y_, n)
			n = n + 1
		end
	end

	return t_, n
end

-- O(n)
function polyomino.normalize(t)
	local out = {}
	local minx, miny = nil, nil
	-- O(n)
	for i, x in pairs(t) do
		minx = min(minx, i)
		for j, y in pairs(x) do
			miny = min(miny, j)
		end
	end

	local dx = (-minx)
	local dy = (-miny)
	-- O(n)
	for i, x in pairs(t) do
		local tmp = {}
		for j, y in pairs(x) do
			tmp[j+dy] = y
		end
		out[i+dx] = tmp
	end
	return out
end

-- O(k(n+k)) worst case
function polyomino.one(t, m, n, adjs)
	local out = {}
	for i = m, n-1 do
		-- O(n)
		local x, y = find(t, i)
		-- O(n+k)
		local t_, n_ = polyomino.number(t, x, y, n, adjs)
		out[#out+1] = {t_, i+1, n_}
	end
	return out
end

-- (k^(o+1)) / (k-1) reduces to O(k^o)
function polyomino.fixed(order, adjs)
	local t1, n1 = polyomino.number({}, 0, 0, 1, adjs)

	local boards = {{t1, 1, n1}}
	-- O(o)
	for i = order-1, 1, -1 do
		local bs = {}
		-- O(k ^ i) roughly
		for _, b in ipairs(boards) do
			local t, m, n = unpack(b)
			-- O(nk + k²)
			local bs_ = polyomino.one(t, m, n, adjs)
			-- O(k)
			for _, b_ in ipairs(bs_) do
				bs[#bs+1] = b_
			end
		end
		boards = bs
	end

	local out = {}
	-- we don't know n here but it depends on k^o anyway
	for i, b in ipairs(boards) do
		out[i] = denumber(b)
	end

	return out
end

-- O(n)
function polyomino.rotate(t)
	local out = {t}
	for i = 2, 4 do
		t = rotate(t)
		out[i] = polyomino.normalize(t)
	end
	return out
end

-- O(n log n)
function polyomino.hash(t)
	local tmp = {}
	for i, x in pairs(t) do
		for j, y in pairs(x) do
			tmp[#tmp+1] = string.char((i*16) + j + 32)
		end
	end
	table.sort(tmp)
	return table.concat(tmp, "")
end

-- O(n)
function polyomino.listify(t)
	local out = {}

	for i, x in pairs(t) do
		for j, y in pairs(x) do
			out[#out+1] = {i, j}
		end
	end

	return out
end

-- O(n)
function polyomino.flip(t)
	local out = {}
	for i, x in pairs(t) do
		local tmp = {}
		for j, y in pairs(x) do
			tmp[-j] = y
		end
		out[-i] = tmp
	end
	return polyomino.normalize(out)
end

-- O(k^o)
function polyomino.oneSided(order, adjs)
	local seen = {}
	local out = {}
	-- O(k^o)
	local fixed = polyomino.fixed(order, adjs)
	for i, p in ipairs(fixed) do
		-- n here is k² roughly
		-- O(k²)
		p = polyomino.normalize(p)
		if not seen[polyomino.hash(p)] then
			out[#out+1] = p
			-- O(k²)
			for _, r in ipairs(polyomino.rotate(p)) do
				seen[polyomino.hash(r)] = true
			end
		end
	end
	return out
end

-- O(k^o)
function polyomino.generate(order, adjs)
	-- O(k^o)
	local raw = polyomino.oneSided(order, adjs)
	local out = {}
	local len = #raw

	-- this function's only being called like once per game
	-- and you don't need this table otherwise
	-- so i'm not saving it outside this function definition
	local offsets = {
		{0, 0},
		{1, -1},
		{0, -1},
		{0, -1}
	}

	for i, p in ipairs(raw) do
		local color = utils.hsl((i-1) / len, 1, 0.5)

		local w, h = 0, 0
		-- O(k²)
		for i, x in pairs(p) do
			w = math.max(w, i)
			for j, y in pairs(x) do
				h = math.max(h, j)
			end
		end

		-- O(k²)
		local rots = polyomino.rotate(p)

		if w < h then
			local tmp2 = table.remove(rots)
			table.insert(rots, 1, tmp2)
			w, h = h, w
		end

		local weird = (w + h) % 2 == 1

		local tmp = {
			color = color,
			data = {},
			w = w, h = h,
			weird = weird
		}

		-- O(k²)
		for j, r in ipairs(rots) do
			tmp.data[j] = polyomino.listify(r)
		end

		if weird then
			w = w - 1

			-- O(k²)
			for j, r in ipairs(tmp.data) do
				local ox, oy = unpack(offsets[j])
				for k, pt in ipairs(r) do
					local px, py = unpack(pt)
					r[k] = {ox+px, oy+py}
				end
			end
		end

		tmp.ox = w / 2
		tmp.oy = h / 2

		out[i] = tmp
	end
	return out
end

return polyomino