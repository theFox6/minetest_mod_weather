-- Weather:
-- * rain
-- * snow
-- * wind

assert(minetest.add_particlespawner, "I told you to run the latest GitHub!")

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

minetest.register_globalstep(function()
	if weather.type == "rain" or weather.type == "snow" then
		if math.random(1, 10000) == 1 then
			weather.type = "none"
			save_weather()
		end
	else
		if math.random(1, 50000) == 1 then
			weather.wind = math.random(0,10)
			weather.type = "rain"
			save_weather()
		end
		if math.random(1, 50000) == 2 then
			weather.wind = math.random(0,10)
			weather.type = "snow"
			save_weather()
		end
	end
end)

dofile(minetest.get_modpath("weather").."/rain.lua")
dofile(minetest.get_modpath("weather").."/snow.lua")
dofile(minetest.get_modpath("weather").."/command.lua")


