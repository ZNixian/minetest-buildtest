buildtest.landmarks = {
	removeBeam = function()
		
	end,
	addBeam = function()
		removeBeam()
	end,
	
	getNextTo = function(pos)
		local dirs = {
			{x= 1,y= 0,z= 0},
			{x=-1,y= 0,z= 0},
			{x= 0,y= 0,z= 1},
			{x= 0,y= 0,z=-1},
		}
		
		for i=1, #dirs do
			local ppos = vector.add(pos, dirs[i])
			if minetest.get_node(ppos).name=="buildtest:landmark" then
				return ppos
			end
		end
		
		return pos
	end,
	
	getMarkPositions = function(pos)
		local dirs = {
			{x= 1,y= 0,z= 0},
			{x=-1,y= 0,z= 0},
			{x= 0,y= 0,z= 1},
			{x= 0,y= 0,z=-1},
		}
		
		local marks = {}
		
		for i=1, #dirs do
			local ppos = pos
			for ii=1, 20 do
				ppos = vector.add(ppos, dirs[i])
				if minetest.get_node(ppos).name=="buildtest:landmark" then
					marks[#marks+1] = ppos
					break
				end
			end
		end
		
		return marks
	end,
	
	removeMarks = function(pos)
		local marks = buildtest.landmarks.getMarkPositions(pos)
		
		for i=1, #marks do
			local ppos = marks[i]
			minetest.remove_node(ppos)
			minetest.add_item(ppos, "buildtest:landmark")
		end
		
		if minetest.get_node(pos).name=="buildtest:landmark" then
			minetest.remove_node(pos)
			minetest.add_item(pos, "buildtest:landmark")
		end
	end,
	
	getBounds = function(pos)
		local marks = buildtest.landmarks.getMarkPositions(pos)
		
		local pmin = {x=pos.x, y=pos.y, z=pos.z}
		local pmax = {x=pos.x, y=pos.y, z=pos.z}
		
		for i=1, #marks do
			local ppos = marks[i]
			pmin.x = math.min(pmin.x, ppos.x)
			pmax.x = math.max(pmax.x, ppos.x)
			
			pmin.z = math.min(pmin.z, ppos.z)
			pmax.z = math.max(pmax.z, ppos.z)
		end
		
		return {pmin=pmin, pmax=pmax}
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