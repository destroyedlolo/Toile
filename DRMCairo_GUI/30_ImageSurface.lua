-- Render an image to this surface

function ImageSurface(
	psrf,	-- mother surface
	sx,sy,	-- position
	sw,sh,	-- size (to be moved to opts)
	opts
)
--[[ known options :
--]]
	if not opts then
		opts = {}
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	function self.Update( img )
		self.get():Blit( img, 0,0 )
		self.Refresh()
	end

	return self
end
