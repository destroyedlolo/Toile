-- Render an image to this surface

function ImageSurface(
	psrf,	-- mother surface
	sx,sy,	-- position
	sw,sh,	-- size
	opts
)
--[[ known options :
--]]
	if not opts then
		opts = {}
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	function self.Update( img )
		img:RenderTo( self.get(), { 0,0, sw,sh } )
		self.refresh()
	end

	return self
end
