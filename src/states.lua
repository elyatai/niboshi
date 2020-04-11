local keys = require 'keys'

local states = {}

local stateFiles = {
	"menu", "missing", "gameconf", "options", "game"
}

local function process(st)
	if type(st.onkey) == "table" then
		st._onkey = st.onkey
		st.onkey = keys.table(st._onkey)
	end

	st.autorepeat = st.autorepeat or {}
end

function states.load()
	for _, s in ipairs(stateFiles) do
		local st = require ("states/" .. s)
		process(st)
		st:load()
		states[s] = st
	end
end

return states