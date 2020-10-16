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
local check_light = minetest.is_yes(minetest.settings:get_bool('light_roofcheck',true))
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
    if minetest.get_node_light(player:get_pos(), 0.5) ~= 15 then return end
  end
  if math.random() < damage.chance then
    player:set_hp(player:get_hp()-damage.amount)
  end
end

local function has_light(minp,maxp)
  local manip = minetest.get_voxel_manip()
  local e1, e2 = manip:read_from_map(minp, maxp)
  local area = VoxelArea:new{MinEdge=e1, MaxEdge=e2}
  local data = manip:get_light_data()
  
  local node_num = 0
  local light = false
  
  for i in area:iterp(minp, maxp) do
      node_num = node_num + 1
      if node_num < 5 then
          if data[i] and data[i] == 15 then
              light = true
              break
          end
      else
          node_num = 0
      end
  end
  
  return light
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

    if check_light and not has_light(minp,maxp) then return end

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
      texture=current_downfall.texture, playername=player:get_player_name()
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
    weather_mod.handle_weather_change({type = "none", reason = "globalstep"})
  else
    local cnum = 10000 * weather_mod.registered_downfall_count
    for id,w in pairs(weather_mod.registered_downfalls) do
      if math.random(1, cnum) == 1 then
        weather.wind = {
          x = math.random(0,10),
          y = 0,
          z = math.random(0,10)
        }
        if (not w.disabled) and vector.length(weather.wind) >= w.min_wind then
          weather.type = id
          weather_mod.handle_lightning(w)
          weather_mod.handle_weather_change({type = id, wind = true, reason = "globalstep"})
          break
        end
      end
    end
  end

  weather_step()
end)
