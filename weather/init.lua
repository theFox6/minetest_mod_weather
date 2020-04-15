assert(minetest.add_particlespawner, "Weather doesn't work with this really old minetest.")

weather = {
  modpath = minetest.get_modpath("weather"),
}

dofile(weather.modpath.."/api.lua")
dofile(weather.modpath.."/rain.lua")
dofile(weather.modpath.."/sand.lua")
dofile(weather.modpath.."/snow.lua")
dofile(weather.modpath.."/command.lua")
