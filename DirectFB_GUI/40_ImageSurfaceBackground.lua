-- Image with a backuped surface

function ImageSurfaceBackground(
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

	local self = ImageSurface( psrf, sx,sy, sw,sh, opts )

	local back = self.get():clone()

	function self.Update( img, transparent )
		self.get():restore(back)
		if transparent then
			self.get():SetBlittingFlags( SelSurface.BlittingFlagsConst('BLEND_ALPHACHANNEL') )
			self.get():StretchBlit( img, nil, {0,0,sw,sh} )
			self.get():SetBlittingFlags( SelSurface.BlittingFlagsConst('NONE') )
		else
			img:RenderTo( self.get(), { 0,0, sw,sh } )
		end
		self.refresh()
	end

	return self
end
