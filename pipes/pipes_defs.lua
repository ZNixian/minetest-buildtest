buildtest.pipes={}
buildtest.pipes.shapes={}
buildtest.pipes.types = {}
buildtest.pipes.makepipe = function(go)
	local count=0
	for wp=0, 0 do -- was for wp=0, 1 do
		for f=0,1 do
			for e=0,1 do
				for d=0,1 do
					for c=0,1 do
						for b=0,1 do
							for a=0,1 do
								count=count+1
								local set={a,b,c,d,e,f}
								buildtest.pipes.shapes[count]=set
								local nodeboxCENTERE={-0.25,-0.25,-0.25, 0.25,0.25,0.25}
								------------------------------------
								local left={-0.5,-0.25,-0.25, -0.25,0.25,0.25}
								local right={0.25,-0.25,-0.25, 0.5,0.25,0.25}
								local top={-0.25,-0.25,0.25, 0.25,0.25,0.5}
								local bttm={-0.25,-0.25,-0.25, 0.25,0.25,-0.5}
								local high={-0.25,0.25,-0.25, 0.25,0.5,0.25}
								local low={-0.25,-0.5,-0.25, 0.25,-0.25,0.25}
								local nodes={nodeboxCENTERE}
								if(set[1]==1) then
									nodes[#nodes+1]=left
								end
								if(set[2]==1) then
									nodes[#nodes+1]=top
								end
								if(set[3]==1) then
									nodes[#nodes+1]=right
								end
								if(set[4]==1) then
									nodes[#nodes+1]=bttm
								end
								if(set[5]==1) then
									nodes[#nodes+1]=high
								end
								if(set[6]==1) then
									nodes[#nodes+1]=low
								end
								-----------------------------------------
								local clas=""
								if wp==1 then
									clas="Waterproof "..clas
								end
								-----------------------------------------
								go(set, nodes, count, a..b..c..d..e..f.."_"..wp, wp, clas)
							end
						end
					end
				end
			end
		end
	count=0 -- it relly is a diffrent type of pipe
	end
end

buildtest.pipes.onp_funct = function(itemstack, placer, pointed_thing)
	
	local itemstk=minetest.item_place(itemstack, placer, pointed_thing)
	buildtest.pipes.processNode(pointed_thing.above)
	for i=1,6 do
		buildtest.pipes.processNode(buildtest.posADD(pointed_thing.above,buildtest.toXY(i)))
	end
	return itemstk
end

buildtest.pipes.getConns = function(pos)
	local oks={}
	for i=1,6 do
		local tmpPos=buildtest.posADD(pos,buildtest.toXY(i))
		if buildtest.pipeAt(tmpPos)==true then
			oks[#oks+1] = tmpPos
		end
	end
	return oks
end

buildtest.pipes.ond_funct = function(pos, node, digger)
	minetest.node_dig(pos, node, digger)
	
	for i=1,6 do
		buildtest.pipes.processNode(buildtest.posADD(pos,buildtest.toXY(i)))
	end
end

buildtest.pipes.processNode=function(pos)
	--print(minetest.get_node(pos).name)
	if buildtest.pipeAt(pos)==false then
		return
	end
	
	local j={}
	for i=1,6 do
		j[i]=buildtest.pipeConn(buildtest.posADD(pos,buildtest.toXY(i)), pos)
	end
	
	local node = minetest.get_node(pos)
	if strs:starts(node.name, "buildtest:pipe_")==true then
		local param2 = node.param2
		local type=strs:rem_from_start(minetest.get_node(pos).name,"buildtest:pipe_")
		local id=type:split("_")[3]
		type=type:split("_")[1]
		node.name = "buildtest:pipe_"..type.."_"..buildtest.arrToStr(j,"").."_"..id
		print(node.name)
		--minetest.set_node(pos, node)
		hacky_swap_node(pos, node.name)
	end
	return j
end

function hacky_swap_node(pos,name)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos)
	local meta0 = meta:to_table()
	if node.name == name then
		return
	end
	node.name = name
	local meta0 = meta:to_table()
	minetest.set_node(pos,node)
	meta = minetest.get_meta(pos)
	meta:from_table(meta0)
end

buildtest.toXY = function(i)
	local pos={x=0,y=0,z=0}
	if i==1 then pos.x=-1
	elseif i==2 then pos.z=1
	elseif i==3 then pos.x=1
	elseif i==4 then pos.z=-1
	elseif i==5 then pos.y=1
	elseif i==6 then pos.y=-1
	end
	return pos
end

buildtest.posADD = function(a,b)
	local pos={x=0,y=0,z=0}
	pos.x=a.x+b.x
	pos.y=a.y+b.y
	pos.z=a.z+b.z
	return pos
end

buildtest.posMult = function(a,b)
	local pos={x=0,y=0,z=0}
	pos.x=a.x*b
	pos.y=a.y*b
	pos.z=a.z*b
	return pos
end

buildtest.pipeAt = function(pos)
	return buildtest.pipeConn(pos, nil)
end

buildtest.pipeConn = function(pos, refpos)
	if refpos~=nil then
		local def=minetest.registered_items[minetest.get_node(refpos).name]
		if def==nil then return false end
		if def.buildtest==nil then return false end
		if def.buildtest.pipe~=1 then return false end
		if def.buildtest.connects==nil then return false end
		--if strs:inarray(minetest.get_node(pos).name,def.buildtest.connects)==false then return false end
		if def.buildtest.disconnects~=nil then
			for i=1,#def.buildtest.disconnects do
				if buildtest.pipes.pipeInArray(minetest.get_node(pos).name, def.buildtest.disconnects[i])==true then return false end
			end
		end
		
		for i=1,#def.buildtest.connects do
			if buildtest.pipes.pipeInArray(minetest.get_node(pos).name, def.buildtest.connects[i])==true then break end
			if i==#def.buildtest.connects then return false end
		end
	else
--		if strs:starts(minetest.get_node(pos).name,"buildtest:pipe_")==false then
--			--print("hv eletro : ok")
--			return false
--		end
		local def = minetest.registered_items[minetest.get_node(pos).name]
		if def==nil then return false end
		if def.buildtest==nil then return false end
		if def.buildtest.pipe~=1 then return false end
	end
	return true
end

buildtest.pipes.pipeInArray = function(node, set)
	for i=1, #set do
		local name  = set[i]
		if strs:starts(node, name) then
			return true
		end
	end
	return false
end

buildtest.arrToStr=function(t,tok)
	if t==nil then
		return ""
	end
	local str=""
	local i=0
	for i=1,#t do
		local tmpStr=t[i]
		if tmpStr==true then tmpStr="1" end
		if tmpStr==false then tmpStr="0" end
		if str~=nil and str~="" then
			str=str..tok
		end
		str=str..tmpStr
	end
	return str
end

buildtest.pipes.defaultPipes = {
	-----------  ITEST  -------------
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
	-----------
	"buildtest:pipe_meseconoff",
	"buildtest:pipe_meseconon",
	"buildtest:pipe_sandstone",
	"buildtest:pipe_obsidian",
	"buildtest:pipe_diamond",
	"buildtest:pipe_stripe",
	"buildtest:pipe_cobble",
	"buildtest:pipe_stone",
	"buildtest:pipe_iron",
	"buildtest:pipe_gold",
	"buildtest:pipe_gate",
	--"buildtest:pipe_emr",
}