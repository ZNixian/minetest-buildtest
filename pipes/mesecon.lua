buildtest.pipes.types.mesecon = {
	base = "mesecons:wire_00000000_off",
	outname = "buildtest:pipe_meseconoff_000000_0",
}

local mesecons_rules={{x=0,y=0,z=1},{x=0,y=0,z=-1},{x=1,y=0,z=0},{x=-1,y=0,z=0},{x=0,y=1,z=0},{x=0,y=-1,z=0}}

for state, invState in pairs({off="on", on="off"}) do
	buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas, type, toverlay)
		local side = "buildtest_pipe_mesecon.png"..toverlay
		local top = "buildtest_pipe_mesecon.png^wires_"..state..".png"..toverlay
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
			description = clas.."Buildtest Mesecon Pipe",
			tiles = {top,side,side,side,side,side},
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
			mesecons={
				conductor={
					state=state,
					rules=mesecons_rules,
					[invState.."state"]="buildtest:pipe_mesecon"..invState.."_"..name
				}
			},
			drop = {
				max_items = 1,
				items = {
					{ items = {'buildtest:pipe_meseconoff_000000_'..id} }
				}
			},
			on_place = buildtest.pipes.onp_funct,
			on_dig = buildtest.pipes.ond_funct,
		}
		if count~=1 or state~="off" then
			def.groups.not_in_creative_inventory=1
		end
--		def.node_box.fixed[#def.node_box.fixed+1] = {1/16, 0.25, -1/16, 8/16, 0.25+1/16, 1/16}
--		local size = #def.node_box.fixed
--		for i=2, size do -- skip the middle bit
--			local newID = #def.node_box.fixed + 1
--			def.node_box.fixed[newID] = def.node_box.fixed[i]
--			
--			def.node_box.fixed[newID][2] = 0.25
--			def.node_box.fixed[newID][2] = 0.25 + 1/16
--		end
		
		minetest.register_node("buildtest:pipe_mesecon"..state.."_"..name, def)
	end)
end