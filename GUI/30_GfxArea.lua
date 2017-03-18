-- Area to graph some trends

function GfxArea(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	color,	-- initial foreground color
	bgcolor -- background color
)
	
	local self = SubSurface(psrf, sx,sy, sw,sh )
	self.setColor( color )

	function self.Clear()
		self.get():Clear( bgcolor.get() )
	end

	function self.DrawGfx( data, amin )	-- Minimal graphics
		self.Clear()

		local min,max = data:MinMax()
		min = amin or min
		if max == min then	-- No dynamic data to draw
			return
		end
		local h = self.get():GetHeight()-1
		local sy = h/(max-min) -- vertical scale
		local sx = self.get():GetWidth()/data:GetSize()

		local y		-- previous value
		local x=0	-- x position
		for v in data:iData() do
			if y then
				x = x+1
				self.get():DrawLine((x-1)*sx, h - (y-min)*sy, x*sx, h - (v-min)*sy)
			end
			y = v 
		end
	end

	return self
end
