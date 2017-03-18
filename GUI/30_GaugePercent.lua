-- Percentage Gauge

function GaugePercent(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	color,	-- graph color
	bgcolor,	-- background color
	opts
)
--[[ known options  :
--	border_color : border color (if not set, no border)
--	vertical : if set, the gauge is vertical
--]]
	if not opts then
		opts = {}
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	self.setColor(color)

	function self.Clear()
		self.get():Clear( bgcolor.get() )
	end

	function self.Draw( v )
		self.Clear()
		
		self.ColorApply()	-- restore foreground color (if changed while drawing border)
		if not opts.vertical then
			self.get():FillRectangle( 0,0, self.get():GetWidth()*v/100, self.get():GetHeight() )
		else
			self.get():FillRectangle( 0,self.get():GetHeight()*(100-v)/100, self.get():GetWidth(), self.get():GetHeight() )
		end

		if opts.border_color then
			self.get():SetColor( opts.border_color.get() )
			self.get():DrawRectangle(0,0, self.get():GetWidth(), self.get():GetHeight())
		end
	
		self.refresh()
	end

	return self
end
