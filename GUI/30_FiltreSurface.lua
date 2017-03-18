-- Apply a filtre to a surface

function FiltreSurface(
	psrf,	-- mother surface
	sx,sy,	-- Surface's position
	imask,	-- mask image
	opts
)
--[[ known options :
--	bgcolor : Background color (fill transparent areas)
--]]
	if not opts then
		opts = {}
	end
	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end

	local img = SelImage.create( imask )
	local mask = img:toSurface()
	img:destroy()
	local sw,sh = mask:GetSize()

	local self = SubSurface(psrf, sx,sy, sw,sh )
	self.get():SetBlittingFlags( SelSurface.BlittingFlagsConst('BLEND_ALPHACHANNEL') )

	function self.ApplyMask()
		self.get():Blit( mask, nil, 0,0 )
	end

	function self.Clear()
		self.get():Clear( opts.bgcolor.get() )
	end

	function self.Update( color )
		self.get():Clear( color.get() )
		self.refresh()
	end

	self.Clear()
	self.ApplyMask()
	self.refresh()

	return self
end
