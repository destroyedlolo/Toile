-- Horizontal gauge

function HGauge(
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
--	align : align the graphic (left by defautl)
--	lpattern = table of linear pattern fix point
]]
	if not opts then
		opts = {}
	end
	if not opts.align then
		opts.align = ALIGN_LEFT
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	function self.Clear()
		self.get():Clear( bgcolor.get() )
	end

	function self.Draw( v )
		self.Clear()

		if opts.max then
			local scale = 100 / (opts.max - opts.min)
			v = (v-opts.min) * scale
			if v < 0 then
				v = 0
			elseif v> 100 then
				v = 100
			end
		end

		if not opts.lpattern and gfxcolor then
			self.setColor( gfxcolor )
			if opts.align == ALIGN_RIGHT then
				self.get():FillRectangle(self.get():GetWidth()*(1-v/100),0, self.get():GetWidth(), self.get():GetHight())
			else
				self.get():FillRectangle(0,0, self.get():GetWidth()*v/100, self.get():GetHight())
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
