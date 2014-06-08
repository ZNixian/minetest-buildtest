buildtest.pipes.types.gate = {
	base = "mesecons_luacontroller:luacontroller0000",
	outname = "buildtest:pipe_gate1_000000_0",
	types = {
		
	},
}

buildtest.pipes.types.gate.setFS = function(meta)
	--local meta = minetest.get_meta(pos)
	
	local trigger = meta:get_int("sel") or 1
	if trigger == 0 then trigger = 1 end
	
	local act = meta:get_int("act") or 1
	if act == 0 then act = 1 end
--	print("trigger: "..trigger)
	local triggers = buildtest.pipes.types.gate.triggers
	local nextTrigger = triggers[trigger + 1] or triggers[1]
	
	local acts = buildtest.pipes.types.gate.acts
	local nextAct = acts[act + 1] or acts[1]
	
	local fs =
		"invsize[8,7;]"
						.."image_button[2,1;1,1;"..triggers[trigger][3] -- texture
						..";trigset_"..nextTrigger[1]--triggers[trigger][1] -- name
						..";"--..triggers[trigger][2] -- label
						.."]"
						
						.."label[2,0.5;"..triggers[trigger][2].."]"
						
						
						.."image_button[4,1;1,1;"..acts[act][3] -- texture
						..";setact_"..nextAct[1]--triggers[trigger][1] -- name
						..";"--..triggers[trigger][2] -- label
						.."]"
						
						.."label[4,0.5;"..acts[act][2].."]"
			
			.."list[current_player;main;0,3;8,4;]"
	
	if buildtest.pipes.types.gate.triggers[meta:get_int("sel")].cont
					== buildtest.pipes.types.gate.acts[meta:get_int("act")].cont then
		fs = fs .. "image[3,1;2,1;buildtest_pipe_gate_joinok.png]"
	else
		fs = fs .. "image[3,1;2,1;buildtest_pipe_gate_joinnogo.png]"
	end
	
	if triggers[trigger][4]~=nil then
		fs = fs .. triggers[trigger][4]
		--print(triggers[trigger][4])
	end
	
	meta:set_string("formspec", fs)
end
	
buildtest.pipes.types.gate.triggers = {
	{"eng_blue",	"Engine blue",		"buildtest_pump_mask_blue_side.png",	cont=true},
	{"eng_green",	"Engine green",		"buildtest_pump_mask_green_side.png",	cont=true},
	{"eng_yellow",	"Engine yellow",	"buildtest_pump_mask_yellow_side.png",	cont=true},
	{"eng_red",		"Engine red",		"buildtest_pump_mask_red_side.png",		cont=true},
	
	{"chest_cont",	"Chest contains",	"default_chest_front.png",	"list[context;main;2,2;1,1;]",	cont=true},
	{"chest_room",	"Chest has room",	"default_chest_front.png",	"list[context;main;2,2;1,1;]",	cont=true},
	
	{"item_pass",	"Item traversing",	"default_book.png",	"list[context;main;2,2;1,1;]",	cont=false},
}

buildtest.pipes.types.gate.acts = {
	{"mesecon_on", 	"Mesecon On",		"jeija_torches_on.png",		cont=true},
	{"mesecon_off",	"Mesecon Off",		"jeija_torches_off.png",	cont=true},
	{"mesecon_tog",	"Mesecon Toggle",	"jeija_wall_lever_off.png",	cont=false},
}

if minetest.get_modpath("digilines") ~= nil then
	buildtest.pipes.types.gate.acts[#buildtest.pipes.types.gate.acts + 1] = 
		{"digiline_send",	"Digiline Send",	"jeija_wall_lever_off.png",	cont=false}
end

for m_on = 1, 2 do
	buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas, type, toverlay)
		local state = {"off", "on"}
		local mesecon_state = mesecon.state[state[m_on]]
		--print(m_on .. " = " .. mesecon_state)
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
			description = clas.."Buildtest Gate",
			tiles = {"buildtest_pipe_gate.png"..toverlay},
			groups = {choppy=1,oddly_breakable_by_hand=3},
			buildtest = {
				pipe=1,
				slowdown=0.1,
				connects={
					--"default:chest",
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
					{ items = {'buildtest:pipe_gate1_000000_'..id} }
				}
			},
			mesecons = {
				receptor = {
					state = mesecon_state,
				--rules = mesecon.rules.buttonlike_get
				}
			},
			digiline = {
		        receptor = {},
		        effector = {},
	        },
			on_place = function(itemstack, placer, pointed_thing)
				buildtest.pipes.onp_funct(itemstack, placer, pointed_thing)
	--			meta:set_string("formspec", )
			end,
			on_construct = function(pos)
				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				inv:set_size("main", 1)
				
				meta:set_string("infotext", "Gate Pipe")
				meta:set_int("sel", 1)
				meta:set_int("act", 1)
				
				buildtest.pipes.types.gate.setFS(meta)
			end,
	--		on_rightclick = function(pos, node, clicker, itemstack)
	--			local meta = minetest.get_meta(pos)
	--			
	--			local trigger = meta:get_int("sel") or 1
	--			if trigger == 0 then trigger = 1 end
	--			--print("trigger: "..trigger)
	--			local triggers = buildtest.pipes.types.gate.triggers
	--			local nextTrigger = triggers[trigger + 1] or triggers[1]
	--			
	--			local posname = "nodemeta:"..pos.x..","..pos.y..","..pos.z
	--			local formspec = "invsize[8,7;]"
	----						.."list["..posname..";main;0,0;8,2;]"
	--						
	--						.."image_button[2,1;1,1"
	--								
	--								..";"..triggers[trigger][3] -- texture
	--								
	--								..";trigset_"..triggers[trigger][1] -- name
	--								
	--								..";"..triggers[trigger][2] -- label
	--								
	--								.."]"
	--						
	--						.."list[current_player;main;0,3;8,4;]"
	--			minetest.show_formspec(clicker:get_player_name(), "buildtest:pipe_gate_"..name, formspec)
	--		end,
			on_receive_fields = function(pos, formname, fields, sender)
	--			print("ok")
	--			for name, val in pairs(fields) do
	--				print(name .. "=" .. val)
	--			end
				
				local triggers = buildtest.pipes.types.gate.triggers
				for i=1, #triggers do
					if fields["trigset_"..triggers[i][1]]~=nil then
						--print(i)
						minetest.env:get_meta(pos):set_int("sel", i)
					end
				end
				
				local acts = buildtest.pipes.types.gate.acts
				for i=1, #acts do
					if fields["setact_"..acts[i][1]]~=nil then
						--print(i)
						minetest.env:get_meta(pos):set_int("act", i)
					end
				end
				
				buildtest.pipes.types.gate.setFS(minetest.get_meta(pos))
			end,
			on_place = buildtest.pipes.onp_funct,
			on_dig = function(pos, node, digger)
				buildtest.pipes.ond_funct(pos, node, digger)
				mesecon.on_dignode(pos, node)
			end,
			
			allow_metadata_inventory_put = buildtest.libs.allow_metadata_inventory_put(nil, true),
			allow_metadata_inventory_take = buildtest.libs.allow_metadata_inventory_take(nil),
			allow_metadata_inventory_move = buildtest.libs.allow_metadata_inventory_move(nil),
		}
		if count~=1 or m_on==2 then
			def.groups.not_in_creative_inventory=1
		end
		minetest.register_node("buildtest:pipe_gate"..m_on.."_"..name, def)
		
		
		local getRunAction = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			local trig = buildtest.pipes.types.gate.triggers[meta:get_int("sel")][1]
			local action = buildtest.pipes.types.gate.acts[meta:get_int("act")][1]
			local runAction = nil
			
			if action == "mesecon_on" or action == "mesecon_off" then
				runAction = function(is_on)
					--print(is_on)
					local new_name = "buildtest:pipe_gate"
					if is_on==(action == "mesecon_on") then
						new_name = new_name .. "2"
					else
						new_name = new_name .. "1"
					end
					new_name = new_name .. "_" .. name
					
					if new_name~=minetest.get_node(pos).name then
						--print(new_name)
						buildtest.pumps.hacky_swap_node(pos, new_name)
						if is_on~=(action == "mesecon_on") then
							mesecon:receptor_off(pos)
						else
							mesecon:receptor_on(pos)
						end
					end
				end
			end
			
			if action == "mesecon_tog" then
				runAction = function(is_on)
					if is_on==false then
						return
					end
					--print(is_on)
					local def = minetest.registered_items[minetest.get_node(pos).name]
					local is_now_on = def.mesecons.receptor.state
					if is_now_on=="off" then
						is_now_on = 2
					else
						is_now_on = 1
					end
					local new_name = "buildtest:pipe_gate" .. is_now_on .. "_" .. name
					
					buildtest.pumps.hacky_swap_node(pos, new_name)
					if is_now_on==1 then
						mesecon:receptor_off(pos)
					else
						mesecon:receptor_on(pos)
					end
				end
			end
			
			if action == "digiline_send" then
				runAction = function(is_on)
					if is_on==false then
						return
					end
					local setchan = "pipe_gate"
					digiline:receptor_send(pos, digiline.rules.default, channel, "event")
				end
			end
			
			local entProcess = nil
			
			if trig=="item_pass" then
				entProcess = function(stack)
					if inv:get_stack("main", 1):is_empty() then
						runAction(true)
						return
					end
					if inv:get_stack("main", 1):get_name() == stack.name then
						runAction(true)
						return
					end
				end
			end
			
			return {act = runAction, entProcess = entProcess,}
		end
		
		local abm = function(pos)
			
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			
			if buildtest.pipes.types.gate.triggers[meta:get_int("sel")].cont
						~= buildtest.pipes.types.gate.acts[meta:get_int("act")].cont then
				return
			end
			
			local trig = buildtest.pipes.types.gate.triggers[meta:get_int("sel")][1]
			local action = buildtest.pipes.types.gate.acts[meta:get_int("act")][1]
			local runAction = getRunAction(pos).act
			
			for i=1, 6 do
				local newPos = buildtest.posADD(buildtest.toXY(i), pos)
				local posname = minetest.get_node(newPos).name
				local def = minetest.registered_items[posname]
				if strs:starts(trig, "eng_") then
					if def~=nil then
						local colour = strs:rem_from_start(trig, "eng_")
						if def.buildtest~=nil then
							if def.buildtest.pump~=nil then
								if colour==def.buildtest.pump.colour then
									if runAction~=nil then
										runAction(true)
										return
									end
								end
							end
						end
					end
				end
				
				
				if (trig=="chest_cont" or trig=="chest_room") and buildtest.canPumpInto[posname]~=nil then
					local listname = buildtest.get_listname_for_dir_in(buildtest.toXY(i), posname)
							--buildtest.canPumpInto[minetest.get_node(newPos).name][1]
					local newInv = minetest.get_meta(newPos):get_inventory()
					
					if trig=="chest_cont" then
	--					if minetest.get_node(newPos).name=="default:chest" then
						if newInv:contains_item(listname, inv:get_stack("main", 1)) then
							if runAction~=nil then
								runAction(true)
								return
							end
						end
					end
					
					if trig=="chest_room" then
						--if minetest.get_node(newPos).name=="default:chest" then
						if newInv:room_for_item(listname, inv:get_stack("main", 1)) then
							if runAction~=nil then
								runAction(true)
								return
							end
						end
					end
				end
			end
			if runAction~=nil then
				runAction(false)
			end
		end
		
		buildtest.pipes.types.gate.types["buildtest:pipe_gate"..m_on.."_"..name] = {
			abm = abm,
			getRunAction = getRunAction,
		}
		
		minetest.register_abm({
			nodenames = {"buildtest:pipe_gate"..m_on.."_"..name},
			interval = 1,
			chance = 1,
			action = abm,
		})
	end)
end
