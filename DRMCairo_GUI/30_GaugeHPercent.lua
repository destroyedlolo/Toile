-- Horizontal percentage gauge

function GaugeHPercent(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	gfxcolor,	-- color for the gfx
	bgcolor,	-- background color
	bcolor,	-- border color (if nil, no border)
	opts
)
--[[ known options  :
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

		if not opts.lpattern and gfxcolor then
			self.setColor( gfxcolor )
			self.get():FillRectangle(0,0, self.get():GetWidth()*v/100, self.get():GetHight())
		end
		if bcolor then
			self.setColor( bcolor )
			self.get():DrawRectangle(0,0, self.get():GetWidth(), self.get():GetHight())
		end

		self.Refresh()
	end

	return self
end
