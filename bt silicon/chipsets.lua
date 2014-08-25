for name, val in pairs({
	mesecon = {
	},
	steel = {
		mat = {name="default:steel_ingot", count=1},
	},
	gold = {
		mat = {name="default:gold_ingot", count=1},
	},
	diamond = {
		mat = {name="default:diamond", count=1},
	},
}) do
	minetest.register_craftitem("buildtest:chipset_"..name, {
		description = name.." chipset",
		inventory_image = "buildtest_chipset_"..name..".png",
	})
	
	buildtest.assembly.register_craft({
		from={
			{name = "mesecons:wire_00000000_off", count=1},
			val.mat,
		},
		energy = 100,
		output = {name="buildtest:gear_"..name, count=1},
	})
end