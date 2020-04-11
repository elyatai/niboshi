local utils = require 'utils'

local assets = {}

local assetData = {
	dir = "assets/",
	types = {
		images = {
			dir = "images/",
			load = love.graphics.newImage
		},
		sounds = {
			dir = "sounds/",
			load = love.audio.newSource
		}
	},
	fontsDir = "fonts/",
	fonts = {
		title = 160,
		big = 64,
		med = 32,
		small = 24,
		xsmall = 16
	},
}

function assets.load()
	for k, a in pairs(assetData.types) do
		local tmp = {}
		local path = assetData.dir .. a.dir
		for _, f in ipairs(love.filesystem.getDirectoryItems(path)) do
			tmp[utils.stripExt(f)] = a.load(path .. f)
		end
		assets[k] = tmp
	end
	
	local path = assetData.dir .. assetData.fontsDir
	assets.fonts = {
		noto = love.graphics.newFont(path .. "NotoSansCJKjp-Regular.otf", 32)
	}
end

function assets.loadFonts(fonts)
	local path = assetData.dir .. assetData.fontsDir
	for k, s in pairs(assetData.fonts) do
		assets.fonts[k] = love.graphics.newFont(path .. fonts[k], s)
	end
end

return assets
