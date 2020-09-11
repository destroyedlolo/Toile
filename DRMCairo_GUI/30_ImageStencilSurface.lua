-- Fill with the color only where the given surface is transparent

function ImageStencilSurface(
	psrf,	-- mother surface
	sx,sy,	-- Surface's position
	stencil, -- stencil image
	opts
)
--[[ known options :
--	bgcolor : background color
--]]
	if not opts then
		opts = {}
	end

	if not opts.bgcolor then
		opts.bgcolor = COL_TRANSPARENT
	end

	local mask = SelDCSurfaceImage.createFromPNG( stencil )
	local sw,sh = mask:GetSize()

if opts.debug then
	opts.debug = opts.debug .. "/ImageStencilSurface"
end

	local self = Surface(psrf, sx,sy, sw,sh, { visible=true, debug=opts.debug } )

	function self.Clear()
if opts.debug then
print(opts.debug, "(ISS)clear")
end
		self.get():Clear( opts.bgcolor.get() )
		if psrf.Clear then
if opts.debug then
print(opts.debug, "clear parent")
end
			psrf.Clear( {sx,sy, sw,sh} )
if opts.debug then
print(opts.debug, "fin clear parent")
--print(psrf.get():Dump('/tmp/t', "0"))
end
elseif opts.debug then
print(opts.debug, "pas de parent.Clear())")
		end
		self.Refresh()
if opts.debug then
print(opts.debug, "(ISS)fin clear")
end
	end

	function self.Update( color )
		self.get():Clear( color.get() )
		self.get():SetOperator( SelDCSurface.OperatorConst("DEST_OUT") )
		self.get():Blit( mask, 0,0 )
		self.Refresh()
	end
	self.Clear()

	return self
end
