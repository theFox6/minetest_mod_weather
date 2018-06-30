minetest.register_privilege("weather", {
	description = "Change the weather",
	give_to_singleplayer = false
})

-- Set weather
minetest.register_chatcommand("setweather", {
	params = "<weather>",
	description = "Set weather to a registered type of downfall\
		show all types when no parameters are given", -- full description
	privs = {weather = true},
	func = function(name, param)
		if param == nil or param == "" or param == "?" then
			local types="none"
			for i,_ in pairs(weather_mod.registered_downfalls) do
				types=types..", "..i
			end
			minetest.chat_send_player(name, "avalible weather types: "..types)
		else
			if weather_mod.registered_downfalls[param] == nil and not param == "none" then
				minetest.chat_send_player(name, "This type of weather is not registered.\n"..
					"To list all types of weather run the command without parameters.")
			else
				weather.type = param
				weather_mod.handle_lightning()
			end
		end
	end
})

-- Set weather
minetest.register_chatcommand("setwind", {
	params = "<weather>",
	description = "Set windspeed to the given x,z direction", -- full description
	privs = {weather = true},
	func = function(name, param)
		if param==nil or param=="" then
			minetest.chat_send_player(name, "please provide two comma seperated numbers")
			return
		end
		local x,z = string.match(param, "^([%d.-]+)[, ] *([%d.-]+)$")
		x=tonumber(x)
		z=tonumber(z)
		if (not x) or (not z) then
			x, z = string.match(param, "^%( *([%d.-]+)[, ] *([%d.-]+) *%)$")
		end
		if x and z then
			weather.wind = vector.new(x,0,z)
		else
			minetest.chat_send_player(name, param.." are not two comma seperated numbers")
		end
	end
})
