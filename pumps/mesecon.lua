buildtest.pumps.register_pump("buildtest:pump_mesecon", "default_wood.png", {
	description = "Buildtest Mesecon Pump",
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