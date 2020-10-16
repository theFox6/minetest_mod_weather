weather_mod.registered_downfalls = {}
weather_mod.registered_downfall_count = 0
weather_mod.registered_weather_change_callbacks = {}

local function check_modname_prefix(name)
	if name:sub(1,1) == ":" then
		-- If the name starts with a colon, we can skip the modname prefix
		-- mechanism.
		return name:sub(2)
	else
		-- Enforce that the name starts with the correct mod name.
		local modname = minetest.get_current_modname()
		if modname == nil then
			modname=name:split(":")[1]
		end
		local expected_prefix = modname .. ":"
		if name:sub(1, #expected_prefix) ~= expected_prefix then
			error("Name " .. name .. " does not follow naming conventions: " ..
				"\"" .. expected_prefix .. "\" or \":\" prefix required")
		end

		-- Enforce that the name only contains letters, numbers and underscores.
		local subname = name:sub(#expected_prefix+1)
		if subname:find("[^%w_]") then
			error("Name " .. name .. " does not follow naming conventions: " ..
				"contains unallowed characters")
		end

		return name
	end
end

local function set_defaults(vt,rt)
  for i,v in pairs(rt) do
    if not vt[i] then
      vt[i] = v
    end
  end
end

local default_downfall = {
  --minimum starting position
  min_pos = {x=-15, y=15, z=-15},
  --maximum starting position
  max_pos = {x=15, y=15, z=15},
  --y falling speed
  falling_speed = 10,
  --number of textures spawned
  amount = 15,
  --the texture size
  size = 25,
  --whether lightning should be enabled
  enable_lightning=false,
  --whether to damage the player
  damage_player=false,
  --how much wind is needed to trigger the weather
  min_wind = 0,
  --stops weather
  disabled = false,
}

local default_damage = {
  --how many half hearts
  amount = 1,
  --chance to damage: .5 is 50%
  chance = 1,
  --after how many steps to damage
  time = 100
}

function weather_mod.register_downfall(id,def)
	local name = check_modname_prefix(id)
	if name == "none" then error("\"none\" means none, thanks") end
	assert(not weather_mod.registered_downfalls[name], name.." is already registered")
	local ndef = table.copy(def)
	--what the downfall looks like
	assert(ndef.texture,"no texture given")
	set_defaults(ndef,default_downfall)
	--when to delete the particles
	if not ndef.exptime then
		ndef.exptime = ndef.max_pos.y / (math.sqrt(ndef.falling_acceleration) + ndef.falling_speed)
	end
	if ndef.damage_player then
		set_defaults(ndef.damage_player,default_damage)
	end
	--actually register the downfall
	weather_mod.registered_downfalls[name]=ndef
	weather_mod.registered_downfall_count = weather_mod.registered_downfall_count + 1
end

function weather_mod.register_on_weather_change(callback)
	local ct = type(callback)
	assert(ct == "function", "on_weather_change callback must be a function, got a " + ct)
	table.insert(weather_mod.registered_weather_change_callbacks,callback)
end

function weather_mod.handle_weather_change(changes)
	for _,c in pairs(weather_mod.registered_weather_change_callbacks) do
		c(changes)
	end
end

function weather_mod.disable_downfall(id,disable)
  local state = disable
  if disable == nil then
    state = true
  end
  weather_mod.registered_downfalls[id].disabled = state
end

return weather_mod
