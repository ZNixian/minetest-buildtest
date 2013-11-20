buildtest.pumps.gfx = {
	frames = {
		{90, 60},
		{45, 45},
		{15, 30},
		{1 , 15},
	}
}

local def = {
	collisionbox = {0,0,0,0,0,0},
	visual = "mesh",
	mesh = "buildtest_pump.x",
	visual_size = {x=5, y=5},
	on_step = function(self, dtime)
		self.timer = self.timer + dtime
		if self.timer > 10 then
--			print("removing entity")
			self.object:remove()
			return
		end
		
		if self.config~=nil then  --  self.timer > 1 and
--			print("new entity")
			self:setTexture(self.config.texture)
			self:setAnim(self.config.speed)
			self.config = nil
		end
	end,
	setTexture = function(self, texture)
		prop = {
			visual_size = {x=5, y=5},
			drawtype = "front",
			visual = "mesh",
			mesh = "buildtest_pump.x",
			textures = {texture},
		}
		self.object:set_properties(prop)
	end,
	setAnim = function(self, level)
		local frameSeq = buildtest.pumps.gfx.frames[level or 1]
		self.object:set_animation(
			{
				x = frameSeq[1]  --  start
				,y = frameSeq[1] + frameSeq[2]   --  end
			},
			15  --frame rate
			, 0
		)
	end,
	get_staticdata = function(self)
		return minetest.serialize(config)
	end,
	on_activate = function(self, staticdata)
--		if staticdata~=nil and staticdata~="" then
--			self.config = minetest.deserialize(staticdata)
--			return
--		end
--		print("removeing entity")
--		self.object:remove()
	end,
	timer = 0,
	config = nil,
}

minetest.register_entity("buildtest:pump_ent", def)