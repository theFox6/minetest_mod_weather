-- Rain
weather_mod.register_downfall("weather:rain",{
	min_pos = {x=-9, y=7, z=-9},
	max_pos = {x= 9, y=7, z= 9},
	falling_speed=10,
	amount=25,
	exptime=0.8,
	size=25,
	texture="weather_rain.png",
	enable_lightning=true,
})