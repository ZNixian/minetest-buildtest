for name, val in pairs(buildtest.pipes.types) do
	minetest.register_craft({
		output = (val.outname or ("buildtest:pipe_" .. name .. "_000000_0")),
		recipe = {
			{val.base, "default:glass", val.base},
		}
	})
end