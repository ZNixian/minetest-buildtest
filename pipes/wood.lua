buildtest.pipes.types.wood = {
	base = "default:wood",
}

buildtest.pipes.makepipe(function(set, nodes, count, name, id, clas, type, toverlay)
	if type=="liquid" then return end
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
		description = clas.."Buildtest Wood Pipe",
		tiles = {"buildtest_pipe_wood.png"..toverlay},
		groups = {choppy=1,oddly_breakable_by_hand=3},
		buildtest = {
			pipe=1,
			slowdown=0.1,
			connects={
				--"default:chest",
				buildtest.pipes.defaultPipes
			},
			disconnects = {{
	"itest:macerator",
	"itest:macerator_active",
	"itest:iron_furnace_active",
	"itest:iron_furnace",
	"itest:electric_furnace_active",
	"itest:electric_furnace",
	"itest:extractor_active",
	"itest:extractor",
	"itest:generator_active",
	"itest:generator",
	-----------  ITEST  -------------
	--"buildtest:pump_stirling",
	"default:furnace_active",
	"buildtest:autocraft",
	"default:furnace",
	"default:chest",
			}},
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
				{ items = {'buildtest:pipe_wood_000000_'..id} }
			}
		},
		on_place = buildtest.pipes.onp_funct,
		on_dig = buildtest.pipes.ond_funct,
	}
	if count~=1 then
		def.groups.not_in_creative_inventory=1
	end
	minetest.register_node("buildtest:pipe_wood_"..name, def)
end)