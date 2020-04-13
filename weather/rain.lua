-- Rain
weather_mod.register_downfall("weather:rain",{
	min_pos = {x=-15, y=7, z=-15},
	max_pos = {x= 15, y=7, z= 15},
	falling_speed=10,
	amount=25,
	exptime=0.8,
	size=25,
	texture="weather_rain.png",
	enable_lightning=true,
})

weather_mod.register_downfall("weather:storm",{
  min_pos = {x = -15, y = 7, z = -15},
  max_pos = {x = 15, y = 7, z = 15},
  falling_speed = 10,
  amount = 30,
  exptime = 0.8,
  size = 30,
  texture = "weather_rain_dark.png",
  enable_lightning = true,
})
