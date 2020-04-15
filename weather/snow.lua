-- Snow
weather.register_downfall("weather:snow",{
	min_pos = {x=-15, y=7, z=-15},
	max_pos = {x= 15, y=7, z= 15},
	falling_speed=5,
	amount=15,
	exptime=5,
	size=25,
	texture="weather_snow.png",
})

weather.register_downfall("weather:hail",{
  min_pos = {x=-15, y=7, z=-15},
  max_pos = {x= 15, y=7, z= 15},
  falling_speed=25,
  amount=15,
  exptime=0.8,
  size=25,
  texture="weather_hail.png",
  enable_lightning = true,
})

local snow_box =
{
	type  = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, -0.4, 0.5}
}

-- Snow cover
minetest.register_node("weather:snow_cover", {
	tiles = {"weather_snow_cover.png"},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = snow_box,
	selection_box = snow_box,
	groups = {not_in_creative_inventory = 1, crumbly = 3, attached_node = 1},
	drop = {}
})

local function get_nearest_player(pos,range_distance)
  local player, min_distance = nil, range_distance
  local position = pos

  local all_objects = minetest.get_objects_inside_radius(position, range_distance)
  for _, object in pairs(all_objects) do
    if object:is_player() then
      local player_position = object:getpos()
      local distance = vector.distance(position, player_position)

      if distance < min_distance then
        min_distance = distance
        player = object
      end
    end
  end
  return player
end

-- Snow cover ABM when snow_covers_abm setting is set to `true`
if minetest.is_yes(minetest.settings:get_bool('snow_covers_abm')) then
	minetest.log('action', '[weather] Loaded fast computer ABM (snow covers when weather:snow is set)')
	minetest.register_abm({
		nodenames = {"group:crumbly", "group:snappy", "group:cracky", "group:choppy"},
		neighbors = {"default:air"},
		interval = 10.0,
		chance = 80,
		action = function (pos, node)
		  local player = get_nearest_player(pos,50)
		  if not player then return end
			if weather.get_type(player) ~= "weather:snow" then
			 return
		  end
			if minetest.registered_nodes[node.name].drawtype == "normal"
          or minetest.registered_nodes[node.name].drawtype == "allfaces_optional" then
        local np = vector.add(pos, {x=0, y=1, z=0})
        if minetest.env:get_node_light(np, 0.5) == 15
            and minetest.env:get_node(np).name == "air" then
          minetest.env:add_node(np, {name="weather:snow_cover"})
        end
      end
    end
	})
end
