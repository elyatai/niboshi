local utils = {}

do
	local alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
	function utils.fromBase(str, b)
		local out = 0
		str = str:lower()
		for _, i in ipairs(utils.chars(str)) do
			local d = alphabet:find(i) - 1
			out = (out * b) + d
		end
		return out
	end
end

function utils.chars(str)
	local out = {}
	for i = 1, #str do
		table.insert(out, str:sub(i, i))
	end
	return out
end

function utils.stripExt(str)
	return str:match("^(.+)%.[^.]-$")
end

function utils.keysSorted(tbl)
	local out = {}
	for k, _ in pairs(tbl) do
		table.insert(out, k)
	end
	table.sort(out)
	return out
end

function utils.indexOf(tbl, x)
	for i, v in ipairs(tbl) do
		if v == x then
			return i
		end
	end
	return nil
end

function utils.imod(x, y)
	local m = x % y
	if m == 0 then
		return y
	end
	return m
end

function utils.divmod(x, y)
	local d, m = x/y, x%y
	return math.floor(d), m
end

function utils.round(x)
	return math.floor(x + 0.5)
end

function utils.sign(x)
	if x < 0 then
		return -1
	end
	if x > 0 then
		return 1
	end
	return 0
end

-- taken from https://love2d.org/wiki/HSL_color
-- modified to use 0-1 instead of 0-255
function utils.hsl(h, s, l, a)
	if s<=0 then return l,l,l,a end
	h = h * 6
	local c = (1-math.abs(2*l-1))*s
	local x = (1-math.abs(h%2-1))*c
	local m = (l-.5*c)
	local r, g, b = 0, 0, 0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end
	return {r+m, g+m, b+m, a}
end

function utils.setAlpha(rgb, a)
	local r, g, b = unpack(rgb)
	return {r, g, b, a}
end

return utils