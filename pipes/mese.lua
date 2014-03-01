--buildtest.pipes.types.cobble = {
--	base = "default:cobble",
--}

buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas, type, toverlay)
	local def = {
		sunlight_propagates = true,
		paramtype = 'light',
		walkable = true,
		climbable = false,
		diggable = true,
		drawtype = "nodebox",
		node_box = {
			type = "fixed",
			fixed = nodes
		},
		--------------------------
		description = clas.."Buildtest Mese Pipe",
		tiles = {"buildtest_pipe_mese.png"..toverlay},
		groups = {choppy=1,oddly_breakable_by_hand=3},
		buildtest = {
			slowdown=0.1,
			pipe=1,
			connects={
				buildtest.pipes.defaultPipes
			},
			pipe_groups = {
				type = type,
			},
			vconnects={
				buildtest.pipes.defaultVPipes
			},
		},
		drop = {
			max_items = 1,
			items = {
				{ items = {'buildtest:pipe_mese_000000_'..id} }
			}
		},
		on_place = function(itemstack, placer, pointed_thing)
			buildtest.pipes.onp_funct(itemstack, placer, pointed_thing)
			local meta = minetest.get_meta(pointed_thing.above)
			meta:set_string("infotext", "Mese Pipe")
			local inv = meta:get_inventory()
			inv:set_size("main", 1)
		end,
		on_rightclick = function(pos, node, clicker, itemstack)
			local posname = "nodemeta:"..pos.x..","..pos.y..","..pos.z
			local formspec = "size[8,6]"..
				"list["..posname..";main;0,0;1,1;]"..
				"list[current_player;main;0,2;8,4;]"
			minetest.show_formspec(clicker:get_player_name(), "buildtest:pipe_mese_"..name, formspec)
		end,
		on_dig = buildtest.pipes.ond_funct,
		------------------------------------------------
		allow_metadata_inventory_put = buildtest.autocraft.allow_metadata_inventory_put(nil),
		allow_metadata_inventory_take = buildtest.autocraft.allow_metadata_inventory_take(nil),
		allow_metadata_inventory_move = buildtest.autocraft.allow_metadata_inventory_move(nil, true),
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_mese_"..name, def)
end)