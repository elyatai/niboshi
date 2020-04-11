local json = require 'lib/json'

local save = {}
local dir = "conf/"

function save.write(file, data)
	local str = json.encode(data)
	local ok, err = love.filesystem.write(file, str)
	if err then
		error(err)
	end
end

function save.read(file)
	local str, err = love.filesystem.read(file)
	if not str then
		error(err)
	end
	return json.decode(str)
end

function save.writeGame(key)
	local data = game[key]
	save.write(dir .. key, data)
end

function save.readGame(key)
	local path = dir .. key
	local info = love.filesystem.getInfo(path)
	if not info then
		return
	end
	game[key] = save.read(path)
end

function save.createSaveDir()
	local info = love.filesystem.getInfo(dir)
	if info and info.filetype == "directory" then
		return
	end
	local ok = love.filesystem.createDirectory(dir)
	if not ok then
		error("save directory creation failed")
	end
	return true
end

return save