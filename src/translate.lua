return function(str, ...)
	return (game.lang[str] or game.lang.missing):format(...)
end