minetest.register_privilege("weather", {
	description = "Change the weather",
	give_to_singleplayer = false
})

local function list_types()
  local types="none"
  for i,_ in pairs(weather.registered_downfalls) do
    types=types..", "..i
  end
end

-- Set weather
minetest.register_chatcommand("setweather", {
  params = "<weather>",
  description = "Set weather to a registered type of downfall\
      show all types when no parameters are given", -- full description
  privs = {weather = true},
  func = function(name, param)
    if param == nil or param == "" or param == "?" then
      return false, "registered weather types: "..list_types()
    end
    local w = weather.registered_downfalls[param] 
    if (not w) and param ~= "none" then
      return false, "This type of weather is not registered.\n"..
        "registered types: "..list_types()
    end
    if w.disabled then
      minetest.chat_send_player(name,param.." is disabled.")
    end
    weather.set_weather(name,param)
    --weather_mod.handle_lightning()
    return true
  end
})

-- Set wind
minetest.register_chatcommand("setwind", {
	params = "<wind>",
	description = "Set windspeed to the given x,z direction", -- full description
	privs = {weather = true},
	func = function(name, param)
		if param==nil or param=="" then
			return false,"please provide two comma seperated numbers"
		end
		local x,z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)$")
		x=tonumber(x)
		z=tonumber(z)
		if (not x) or (not z) then
			x, z = string.match(param, "^%( *([%d.-]+)[, ] *([%d.-]+) *%)$")
		end
		if x and z then
			weather.set_wind(x,z)
			return true
		else
			return false,param.." are not two comma seperated numbers"
		end
	end
})
