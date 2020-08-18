-- Render an image to this surface

function ImageSurface(
	psrf,	-- mother surface
	sx,sy,	-- position
	sw,sh,	-- size (to be moved to opts)
	opts
)
--[[ known options :
	transparency : call Clear() of the parent surface at Update()
	autoscale : scale the image to fit surface
--]]
	if not opts then
		opts = {}
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	function self.Update( img )
		if opts.transparency then
			psrf.Clear( {sx,sy, sw,sh} )
		end

		if opts.autoscale then
				-- Scale calculation
			local x,y = img:GetSize()
			x = math.min(sw/x, sh/y)

			self.get():SaveContext()
			self.get():Scale(x,x)
		end

		self.get():Blit( img, 0,0 )
		self.Refresh()

		if opts.autoscale then
			self.get():RestoreContext()
		end
	end

	return self
end
