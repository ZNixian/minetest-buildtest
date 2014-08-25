buildtest.assembly = {
	recipies = {
		{ -- 2 wood to mesecon engine
			from={
				{name = "default:wood", count=1},
			},
			output={name="default:stick", count=8},
			energy = 10,
		},
		{ -- cobble to lava
			from={
				{name = "bucket:bucket_empty", count=1},
				{name = "default:cobble", count=2},
			},
			output={name="bucket:bucket_lava"},
			energy = 100,
		},
		{ -- water+lava to obsidian+water
			from={
				{name = "bucket:bucket_water", count=1},
				{name = "bucket:bucket_lava", count=1},
			},
			leave = {
				{name = "bucket:bucket_water", count=1},
				{name = "bucket:bucket_empty", count=1},
			},
			output={name="default:obsidian"},
			energy = 15,
		},
	},
	register_craft = function(def)
		buildtest.assembly.recipies[#buildtest.assembly.recipies+1]=def
	end,
	remove_items = function(inv, id)
		if id==0 then return end
		local rec = buildtest.assembly.recipies[buildtest.assembly.lookupId(inv, id)]
		if rec==nil then return end
		for ii=1, #rec.from do
			inv:remove_item("in", rec.from[ii])
		end
		if rec.leave~=nil then
			for ii=1, #rec.leave do
				inv:add_item("in", rec.leave[ii])
			end
		end
	end,
	lookupId = function(inv, id)
		local t = buildtest.assembly.get_recipies(inv)[id]
		if t==nil then return 0 end
		return t.id
	end,
	can_make = function(inv, id)
		if id==0 then return end
		local rec = buildtest.assembly.recipies[id]
		local ok = true
		for ii=1, #rec.from do
			if inv:contains_item("in", rec.from[ii])==false then
				ok = false
			end
		end
		return ok
	end,
	can_make_rel = function(inv, id)
		if id==0 then return end
		return buildtest.assembly.can_make(inv, buildtest.assembly.lookupId(inv, id))
	end,
	get_recipies = function(inv)
		local recipies = {}
		for i=1, #buildtest.assembly.recipies do
			if buildtest.assembly.can_make(inv, i) then
				local rec = buildtest.assembly.recipies[i]
				recipies[#recipies + 1] = {id=i, rec=rec, output = rec.output}
			end
		end
		return recipies
	end,
	get_ids = function(inv)
		local ids = {}
		for i=1, #buildtest.assembly.recipies do
			ids[i]=0
			if buildtest.assembly.can_make(inv, i) then
				local rec = buildtest.assembly.recipies[i]
				ids[#ids + 1] = {id=i, rec=rec, output = rec.output}
			end
		end
		return ids
	end,
	check_config = function(meta)
		if buildtest.assembly.can_make_rel(meta:get_inventory(), meta:get_int("selected"))==false then
			meta:set_int("selected", 0)
		end
	end,
	set_formspec_params = function(pos, meta, inv)
		buildtest.assembly.check_config(meta)
		local formspec= "size[8,9]"..
						"list[current_name;in;0,0;4,4;]"..
						"list[current_player;main;0,5;8,4;]"
		
		local selId = meta:get_int("selected")
		if selId~=0 then
			local sel = buildtest.assembly.recipies[selId]--buildtest.assembly.get_recipies(inv)[selId]
			if sel~=nil and sel.rec~=nil and sel.rec.energy~=nil and sel.output~=nil then
				local h = 4.0 * meta:get_int("power") / sel.rec.energy
				formspec = formspec .. "box[4,"..(4-h)..";0.25,"..h..";#FF0000FF]" .. "box[4,0;0.25,"..(4-h)..";#000000FF]" .. "label[4,4;"..(h*100/4).."%]"
			end
		end
		
		local recs = buildtest.assembly.get_recipies(inv)
		for i=1, #recs do
			formspec = formspec .. "item_image_button[4.5,"..i..";1,1;"..recs[i].output.name..";item_sel_"..i..";"
			if meta:get_int("selected")==i then
				formspec = formspec .. "@"
			end
			formspec = formspec .. "]"
		end
		meta:set_string("formspec", formspec)
	end,
	set_formspec = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		buildtest.assembly.set_formspec_params(pos, meta, inv)
	end,
	add_energy = function(pos, energy)
		local meta = minetest.get_meta(pos)
		meta:set_int("power", meta:get_int("power") + energy)
		buildtest.assembly.process_energy(pos)
	end,
	process_energy = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local selId = meta:get_int("selected")
		if selId~=0 then
			local sel = buildtest.assembly.recipies[selId]
			if sel~=nil and sel.rec~=nil and sel.rec.energy~=nil and sel.output~=nil then
				if meta:get_int("power") > sel.rec.energy then
					local count = math.floor(meta:get_int("power") / sel.rec.energy)
					meta:set_int("power", meta:get_int("power") % sel.rec.energy)
					buildtest.assembly.remove_items(inv, selId)
					
					--[[local ways = {
						{x= 1,y= 0,z= 0},
						{x=-1,y= 0,z= 0},
						{x= 0,y= 1,z= 0},
						{x= 0,y=-1,z= 0},
						{x= 0,y= 0,z= 1},
						{x= 0,y= 0,z=-1},
					}
					
					for i=1, #ways do
						if minetest.get_node()
					end]]--
					
					--[[local obj = minetest.add_item(vector.add(pos, {x=0, y=1, z=0}), sel.output)
					if obj ~= nil then
						obj:setvelocity({x=(math.random()-0.5),y=math.random()+1,z=(math.random()-0.5)})
					end]]--
					buildtest.makeEnt(vector.add(pos, {x=0,y=1,z=0}), sel.output, 1, pos)
				end
			end
		end
		buildtest.assembly.set_formspec_params(pos, meta, inv)
	end,
}

minetest.register_node("buildtest:assembly_table", {
	description = "Buildtest Assembly Table",
	tiles = {
		"buildtest_assembly.png"
	},
	groups = {crackey = 3, buildtest_laser = 1},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("power", 0)
		meta:set_int("selected", 0)
		local inv = meta:get_inventory()
		inv:set_size("in", 4*4)
		
		buildtest.assembly.set_formspec_params(pos, meta, inv)
	end,
	
	
	on_metadata_inventory_move = function(pos, from_list, to_list, to_list, to_index, count, player)
		buildtest.assembly.set_formspec(pos)
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		buildtest.assembly.set_formspec(pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		buildtest.assembly.set_formspec(pos)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if minetest.is_protected(pos, sender:get_player_name()) then
			minetest.record_protection_violation(pos, sender:get_player_name())
			return
		end
		local meta = minetest.get_meta(pos)
		for name, val in pairs(fields) do
			if strs:starts(name, "item_sel_") then
				local id = tonumber(strs:rem_from_start(name, "item_sel_"))
				meta:set_int("selected", id)
				buildtest.assembly.set_formspec_params(pos, meta, meta:get_inventory())
			end
		end
	end,
	buildtest = {
		on_laser = function(pos, speed)
		end,
	}
})