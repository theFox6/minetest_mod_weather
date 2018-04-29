-- Weather:
-- * rain
-- * snow
-- * wind

assert(minetest.add_particlespawner, "I told you to run the latest GitHub!")

weather_mod={
	modpath=minetest.get_modpath("weather"),
}

weather = (function()
	local file_name = minetest.get_worldpath() .. "/weather"

	minetest.register_on_shutdown(function()
		local file = io.open(file_name, "w")
		file:write(minetest.serialize(weather))
		file:close()
	end)

	local file = io.open(file_name, "r")
	if file ~= nil then
		local readweather = minetest.deserialize(file:read("*a"))
		file:close()
		if type(readweather)~="table" then
			return {type = "none", wind = 0}
		end
		return readweather
	end
	return {type = "none", wind = vector.new(0,0,0)}
end) ()

dofile(weather_mod.modpath.."/api.lua")
dofile(weather_mod.modpath.."/rain.lua")
dofile(weather_mod.modpath.."/snow.lua")
dofile(weather_mod.modpath.."/command.lua")
