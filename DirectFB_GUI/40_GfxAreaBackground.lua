-- Graph area with transparent background

function GfxAreaBackground(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	color	-- initial foreground color
)
	local self = GfxArea( psrf, sx,sy, sw,sh, color, COL_BLACK )

	local back = self.get():clone()

	function self.Clear()
		self.get():restore(back)
	end

	return self
end
