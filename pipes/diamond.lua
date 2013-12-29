buildtest.pipes.types.diamond = {
	base = "default:diamond",
	colours = {
		"green",
		"black",
		"red",
		"white",
		"blue",
		"yellow",
	},
}
--	x+ :	red
--	x- :	green
--	y+ :	blue
--	y- :	yellow
--	z+ :	black
--	z- :	white

buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas, type)
	if type=="liquid" then return end
	local top = "buildtest_pipe_diamond_top.png"
	local bttm = "buildtest_pipe_diamond_bottem.png"
	local side = "buildtest_pipe_diamond.png"
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
		description = clas.."Buildtest Diamond Pipe",
		tiles = {top,bttm,side,side,side,side},
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
				{ items = {'buildtest:pipe_diamond_000000_'..id} }
			}
		},
		on_place = function(itemstack, placer, pointed_thing)
			buildtest.pipes.onp_funct(itemstack, placer, pointed_thing)
			local meta = minetest.get_meta(pointed_thing.above)
			--meta:set_string("formspec", buildtest.pipes.diamond.formspec)
			meta:set_string("infotext", "Diamond Pipe")
			local inv = meta:get_inventory()
			--inv:set_size("main", 10*6)
			for i=1,#buildtest.pipes.types.diamond.colours do
				local name = buildtest.pipes.types.diamond.colours[i]
				inv:set_size(name, 10)
			end
		end,
		on_rightclick = function(pos, node, clicker, itemstack)
			local posname = "nodemeta:"..pos.x..","..pos.y..","..pos.z
			local formspec = "invsize[11,11;]"
						--.."list["..posname..";main;1,0;10,6;]"
						.."list[current_player;main;0,7;8,4;]"
			for i=1,#buildtest.pipes.types.diamond.colours do
				local name = buildtest.pipes.types.diamond.colours[i]
				formspec = formspec.."list["..posname..";"..name..";1,"..(i-1)..";10,1;]label[0,"..(i-1)..";"..name.."]"
			end
			minetest.show_formspec(clicker:get_player_name(), "buildtest:pipe_diamond_"..name, formspec)
		end,
		on_dig = buildtest.pipes.ond_funct,
		--------------------------------------------------------------------------------
		allow_metadata_inventory_put = buildtest.autocraft.allow_metadata_inventory_put(nil),  --  {["green"]=1, ["black"]=1, ["red"]=1, ["white"]=1, ["blue"]=1, ["yellow"]=1,}
		allow_metadata_inventory_take = buildtest.autocraft.allow_metadata_inventory_take(nil),
		allow_metadata_inventory_move = buildtest.autocraft.allow_metadata_inventory_move(nil, true),
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_diamond_"..name, def)
end)

buildtest.pipes.types.diamond.getDir = function(pos,cargo)
	local inv = minetest.get_meta(pos):get_inventory()
	for i=1,#buildtest.pipes.types.diamond.colours do
		local name = buildtest.pipes.types.diamond.colours[i]
		if inv:contains_item(name, {name=cargo.name}) then
			return buildtest.toXY(i)
		end
	end
	return nil
end