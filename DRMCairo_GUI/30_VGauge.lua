-- Vertical gauge

function VGauge(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	gfxcolor,	-- color for the gfx
	bgcolor,	-- background color
	bcolor,	-- border color (if nil, no border)
	opts
)
--[[ known options  :
--	min,max : border value (if not set, the value is a percentage)
--	ascend : draw from the bottom (otherwise from the top)
--	lpattern = table of linear pattern fix point
]]
	if not opts then
		opts = {}
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	function self.Clear()
		self.get():Clear( bgcolor.get() )
	end

	function self.Draw( v )
		self.Clear()

		if max then
			local scale = 100 / (opts.max - opts.min)
			v = (v-min) * scale
			if v < 0 then
				v = 0
			elseif v> 100 then
				v = 100
			end
		end

		if not opts.lpattern and gfxcolor then
			self.setColor( gfxcolor )
			if opts.ascend then
				self.get():FillRectangle(0, self.get():GetHight()*v/100, self.get():GetWidth(), self.get():GetHight())
			else
				self.get():FillRectangle(0,0, self.get():GetWidth(), self.get():GetHight()*v/100)
			end
		end
		if bcolor then
			self.setColor( bcolor )
			self.get():DrawRectangle(0,0, self.get():GetWidth(), self.get():GetHight())
		end

		self.Refresh()
	end

	return self
end
