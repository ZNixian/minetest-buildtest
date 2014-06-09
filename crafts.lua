for name, val in pairs(buildtest.pipes.types) do
	minetest.register_craft({
		output = (val.outname or ("buildtest:pipe_" .. name .. "_000000_0")),
		recipe = {
			{val.base, "default:glass", val.base},
		}
	})
end

for name, val in pairs({
	wood = {
		mat = "default:stick",
		prev = "",
	},
	stone = {
		mat = "group:stone",
		prev = "buildtest:gear_wood",
	},
	steel = {
		mat = "default:steel_ingot",
		prev = "buildtest:gear_stone",
	},
	gold = {
		mat = "default:gold_ingot",
		prev = "buildtest:gear_steel",
	},
	diamond = {
		mat = "default:diamond",
		prev = "buildtest:gear_gold",
	},
}) do
	minetest.register_craftitem("buildtest:gear_"..name, {
		description = name.." gear",
		inventory_image = "buildtest_gear_"..name..".png",
	})
	
	minetest.register_craft({
		output = "buildtest:gear_"..name,
		recipe = {
			{"",			val.mat,						""		},
			{val.mat,		val.prev,						val.mat	},
			{"",			val.mat,						""		},
		}
	})
end




for name, val in pairs(buildtest.pumps.crafts) do
	local piston = "mesecons_pistons:piston_normal_off"
	minetest.register_craft({
		output = "buildtest:engine_"..name.."_blue",
		recipe = {
			{	val.mat,		val.mat,						val.mat		},
			{	"",				"default:glass",				""			},
			{	val.gear,		piston,							val.gear	},
		}
	})
end


minetest.register_craft({
	output = "buildtest:quarry",
	recipe = {
		{	"buildtest:gear_steel",		"mesecons:wire_00000000_off",		"buildtest:gear_steel"		},
		{	"buildtest:gear_gold",		"buildtest:gear_steel",				"buildtest:gear_gold"		},
		{	"buildtest:gear_diamond",	"default:pick_diamond",				"buildtest:gear_diamond"	},
	}
})


minetest.register_craft({
	output = "buildtest:landmark",
	recipe = {
		{"dye:blue"},
		{"mesecons_torch:mesecon_torch_on"},
	}
})