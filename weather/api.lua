weather_mod.registered_downfalls = {}

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
  min_pos = {x=-15, y=10, z=-15},
  --maximum starting position
  max_pos = {x=15, y=10, z=15},
  --y falling speed
  falling_speed = 10,
  --number of textures spawned
  amount = 15,
  --the texture size
  size = 25,
  --whether lightning schould be enabled
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
	if weather_mod.registered_downfalls[name]~=nil then error(name.." is already registered") end
	local ndef = table.copy(def)
	--what the downfall looks like
	if not ndef.texture then
    error("no texture given")
  end
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
end

function weather_mod.disable_downfall(id,disable)
  local state = disable
  if disable == nil then
    state = true
  end
  weather_mod.registered_downfalls[id].disabled = state
end

if minetest.get_modpath("lightning") then
	lightning.auto = false
	--rawset(lightning,"auto",false)
end

function weather_mod.handle_lightning(current_weather)
  if not minetest.get_modpath("lightning") then return end
  if not current_weather then return end
  lightning.auto = current_weather.enable_lightning
  --rawset(lightning,"auto",current_weather.enable_lightning)
  if current_weather.enable_lightning and math.random(1,2) == 1 then
  local time = math.floor(math.random(lightning.interval_low/2,lightning.interval_low))
    minetest.after(time, lightning.strike)
  end
end

local do_raycasts = minetest.is_yes(minetest.settings:get_bool('raycast_hitcheck'))
local damage_steps = 0

local function handle_damage(damage,player, downfall_origin)
	if not damage then return end
	damage_steps = damage_steps +1
	if damage_steps < damage.time then return end
	damage_steps = 0
	if do_raycasts then
		-- this check should be more accurate
		local hitpos = vector.add(player:get_pos(),vector.new(0,1,0))
		local ray = minetest.raycast(downfall_origin,hitpos)
		local o = ray:next()
		if o.type~="object" then return end -- hit node or something
		if not o.ref:is_player() then return end -- hit different object
		if o.ref:get_player_name() ~= player:get_player_name() then
			return --hit other player
		end
		o = ray:next()
		if o then
			minetest.log("warning","[weather] raycast hit more after hitting the player\n"..
				dump2(o,"o"))
		end
	else
		--check if player is affected by downfall, if it's dark there are nodes nearby
		if minetest.env:get_node_light(player:get_pos(), 0.5) ~= 15 then return end
	end
	if math.random() < damage.chance then
		player:set_hp(player:get_hp()-damage.amount)
	end
end

local function weather_step()
  local current_downfall = weather_mod.registered_downfalls[weather.type]
  if current_downfall==nil then return end
  for _, player in ipairs(minetest.get_connected_players()) do
    local ppos = player:get_pos()

    if ppos.y > 120 then return end

    local wind_pos = vector.multiply(weather.wind,-1)

    local minp = vector.add(vector.add(ppos, current_downfall.min_pos),wind_pos)
    local maxp = vector.add(vector.add(ppos, current_downfall.max_pos),wind_pos)

    local vel = {x=weather.wind.x,y=-current_downfall.falling_speed,z=weather.wind.z}
    local acc = {x=0, y=0, z=0}

    local exp = current_downfall.exptime

    minetest.add_particlespawner({
      amount=current_downfall.amount, time=0.5,
      minpos=minp, maxpos=maxp,
      minvel=vel, maxvel=vel,
      minacc=acc, maxacc=acc,
      minexptime=exp, maxexptime=exp,
      minsize=current_downfall.size, maxsize=current_downfall.size,
      collisiondetection=true, collision_removal=true,
      vertical=true,
      texture=current_downfall.texture, player=player:get_player_name()
    })

    local downfall_origin = vector.divide(vector.add(minp,maxp),2)
    handle_damage(current_downfall.damage_player,player,downfall_origin)
  end
end

minetest.register_globalstep(function()
  if math.random(1, 10000) == 1 then
    weather.type = "none"
    if minetest.get_modpath("lightning") then
      lightning.auto = false
      --rawset(lightning,"auto",false)
    end
  else
    for id,w in pairs(weather_mod.registered_downfalls) do
      if math.random(1, 50000) == 1 then
        weather.wind = {
          x = math.random(0,10),
          y = 0,
          z = math.random(0,10)
        }
        if (not w.disabled) and vector.length(weather.wind) >= w.min_wind then
          weather.type = id
          weather_mod.handle_lightning(w)
          break
        end
      end
    end
  end

  weather_step()
end)