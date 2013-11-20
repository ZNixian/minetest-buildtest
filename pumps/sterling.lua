--minetest.register_node("buildtest:pump_sterling", {
--	--tiles = {"buildtest_pump_mesecon.png"},
--	description = "Buildtest Sterling Pump",
--	groups = {choppy=1,oddly_breakable_by_hand=3},
--	paramtype = "light",
--	paramtype2 = "facedir",
--	sunlight_propagates = true,
--	buildtest = {
--		pipe=1,
--		connects={
--			"buildtest:pipe_wood",
--		},
--		pump = {
--			maxSpeed = 0.5,
--			moveCount = 2,
--			maxLevel = 10,
--			upTime = 20,
--			textures = {
--				"buildtest_pump_sterling.png",
--				"buildtest_pump_blue.png",
--				"buildtest_pump_green.png",
--				"buildtest_pump_orange.png",
--				"buildtest_pump_red.png",
--			}
--		}
--	},
--	on_construct = function(pos)
--		local ent = minetest.add_entity(pos, "buildtest:pump_ent")
--		if ent then
--			ent:setpos(pos)
--			ent:get_luaentity().homepos = pos
--			ent:get_luaentity().setTexture(ent, "buildtest_pump_sterling.png")
--			--ent:get_luaentity().homename = minetest.get_node(pos).name
--		end
--	end,
--	drawtype = "nodebox",
--	node_box = {
--		type = "fixed",
--		fixed = {{0,0,0,0,0,0}}
--	},
--	selection_box = {{
--		0.5,0.5,0.5,-0.5,-0.5,-0.5,
--	}},
--})
--
--minetest.register_abm({
--	nodenames = {"buildtest:pump_sterling"},
--	interval = 0.5,
--	chance = 1,
--	action = function(pos)
--		buildtest.pumps.send(pos)
--	end,
--})

buildtest.pumps.types.stirling = {
	get_pump_active_formspec = function(percent)
		local formspec =
			"size[8,9]"..
			"image[2,2;1,1;default_furnace_fire_bg.png^[lowpart:"..percent..":default_furnace_fire_fg.png]"..
			"list[context;fuel;2,3;1,1;]"..
			"list[context;heat;4,1;1,1;]"..
			"list[context;out;6,1;2,2;]"..
			"list[current_player;main;0,5;8,4;]"
		return formspec
	end,
	set_pump_active_formspec = function(pos)
		local meta = minetest.get_meta(pos)
		local fuel_level = meta:get_int("fuel")
		local max_fuel = meta:get_int("maxfuel")
		local percent = (fuel_level / max_fuel) * 100
		local formspec = buildtest.pumps.types.stirling.get_pump_active_formspec(percent)
		meta:set_string("formspec", formspec)
	end,
	handleCooling = function(pos, inv)
		if inv:get_stack("heat", 1):is_empty() then
			return false
		end
		local name = inv:get_stack("heat", 1):get_name()
		local def = minetest.registered_items[minetest.get_node(pos).name]
		if name=="bucket:bucket_lava" then
			if def.buildtest.pump.next~=nil then
				buildtest.pumps.hacky_swap_node(pos, def.buildtest.pump.next)
				inv:set_stack("heat", 1, ItemStack(nil))
				inv:add_item("out", ItemStack("bucket:bucket_empty"))
				return true
			end
		end
		if name=="bucket:bucket_water" then
			if def.buildtest.pump.prev~=nil then
				buildtest.pumps.hacky_swap_node(pos, def.buildtest.pump.prev)
				inv:set_stack("heat", 1, ItemStack(nil))
				inv:add_item("out", ItemStack("bucket:bucket_empty"))
				return true
			end
		end
		return false
	end,
}

buildtest.pumps.register_pump("buildtest:pump_stirling", "default_cobble.png", {
	description = "Buildtest Stirling Engine",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		---------------------------
--		local formspec = 
--					"size[8,9]"..
--					"image[2,2;1,1;default_furnace_fire_bg.png]"..
--					"list[context;fuel;2,3;1,1;]"..
--					"list[current_player;main;0,5;8,4;]"
		local formspec = buildtest.pumps.types.stirling.get_pump_active_formspec(0)
		---------------------------
		meta:set_string("formspec", formspec)
		---------------------------
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("heat", 1)
		inv:set_size("out", 2*2)
		buildtest.pumps.on_construct(pos)
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if not inv:is_empty("fuel") then
			return false
		end
		return true
	end,
},
{
	abm = function(pos)
		buildtest.pumps.send(pos)
	end,
	runConf = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		
		if buildtest.pumps.types.stirling.handleCooling(pos, inv)==true then
			return false
		end
		
		local fuel_level = (meta:get_int("fuel") or 0)
		if fuel_level > 0 then
			fuel_level = fuel_level - 1
			meta:set_int("fuel", fuel_level)
			buildtest.pumps.types.stirling.set_pump_active_formspec(pos)
			return true
		end
		
		if inv:get_stack("fuel", 1):is_empty() then
			return false
		end
		
		local items = inv:get_list("fuel")
--		print("item: "..inv:get_stack("fuel", 1):get_name())
		local fuel
		local sub
		fuel, sub = minetest.get_craft_result({
			method="fuel",
			width=1,
			items = items,
		})
		if fuel.time <= 0 then
			return false
		end
		meta:set_int("maxfuel", fuel.time)
		meta:set_int("fuel", fuel.time)
		inv:set_list("fuel", sub.items)
		buildtest.pumps.types.stirling.set_pump_active_formspec(pos)
--		print("pumping")
		return true
	end,
	
	moveCount = 2,
	explodes = true,
}
)