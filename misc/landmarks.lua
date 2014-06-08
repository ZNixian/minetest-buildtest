buildtest.landmarks = {
	removeBeam = function()
		
	end,
	addBeam = function()
		removeBeam()
	end,
}

minetest.register_node("buildtest:landmark", {
	description = "Buildtest Landmark",
	drawtype = "torchlike",
	--tiles = {"default_torch_on_floor.png", "default_torch_on_ceiling.png", "default_torch.png"},
	tiles = {
		"buildtest_landmark.png"
	},
	inventory_image = "buildtest_landmark.png",
	wield_image = "buildtest_landmark.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	light_source = 7,
	selection_box = {
		type = "wallmnted",
		wall_top = {-0.1, 0.5-0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5+0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5+0.3, 0.3, 0.1},
	},
	groups = {choppy=2,dig_immediate=3,attached_node=1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
	mesecons = {
		effector = {
			action_off = function (pos, node)
				local meta = minetest.get_meta(pos)
				meta:set_int("on", 0)
			end,
			action_on = function (pos, node)
				local meta = minetest.get_meta(pos)
				meta:set_int("on", 1)
			end,
		},
	},
})