-- First the backgound is drawn then 
-- apply given filter
-- (see ImageStencil for a better alternative)

function ImageFiltreSurface(
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

	local mask = SelDCSurfaceImage.createFromPNG( imask )
	local sw,sh = mask:GetSize()

	local self = SubSurface(psrf, sx,sy, sw,sh )

	function self.ApplyMask()
		self.get():Blit( mask, 0,0 )
	end

	function self.Clear()
		self.get():Clear( opts.bgcolor.get() )
		self.ApplyMask()
		self.Refresh()
	end

	function self.Update( color )
		self.get():Clear( color.get() )
		self.ApplyMask()
		self.Refresh()
	end

	return self
end
