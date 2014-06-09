buildtest.pumps.register_pump("buildtest:engine_mesecon", "default_wood.png", {
	description = "Buildtest Mesecon Engine",
},
{
	abm = function(pos)
		buildtest.pumps.send(pos)
	end,
	
	runConf = function(pos)
		local meta = minetest.get_meta(pos)
		return true
	end,
}
)

buildtest.pumps.crafts.mesecon = {
	mat = "group:wood",
	gear = "buildtest:gear_wood",
}