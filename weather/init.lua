-- Weather:
-- * rain
-- * snow
-- * wind

assert(minetest.add_particlespawner, "I told you to run the latest GitHub!")

weather_mod={
	modpath=minetest.get_modpath("weather"),
}

save_weather = function ()
	local file = io.open(minetest.get_worldpath().."/weather", "w+")
	file:write(minetest.serialize(weather))
	file:close()
end

read_weather = function ()
	local file = io.open(minetest.get_worldpath().."/weather", "r")
	if not file then return {type = "none", wind = 0} end
	local readweather = minetest.deserialize(file:read())
	file:close()
	if type(readweather)~="table" then
		return {type = "none", wind = 0}
	end
	return readweather
end

weather = read_weather()

dofile(weather_mod.modpath.."/api.lua")
dofile(weather_mod.modpath.."/rain.lua")
dofile(weather_mod.modpath.."/snow.lua")
dofile(weather_mod.modpath.."/command.lua")
