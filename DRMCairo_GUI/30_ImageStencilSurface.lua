-- Fill with the color only where the given surface is transparent

function ImageStencilSurface(
	psrf,	-- mother surface
	sx,sy,	-- Surface's position
	stencil, -- stencil image
	opts
)
--[[ known options :
--]]
	if not opts then
		opts = {}
	end

	local mask = SelDCSurfaceImage.createFromPNG( stencil )
	local sw,sh = mask:GetSize()

if opts.debug then
	opts.debug = opts.debug .. "/ImageStencilSurface"
end

	local self = Surface(psrf, sx,sy, sw,sh, { visible=true, debug=opts.debug } )

	function self.Clear()
		self.get():Clear( COL_TRANSPARENT.get() )
		self.Refresh()
	end

	function self.Update( color )
		self.get():Clear( color.get() )
		self.get():SetOperator( SelDCSurface.OperatorConst("DEST_OUT") )
		self.get():Blit( mask, 0,0 )
		self.Refresh()
	end

	return self
end
