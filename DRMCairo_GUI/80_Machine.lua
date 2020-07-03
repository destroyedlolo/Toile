-- Display a machine figures

function Machine(
	psrf,	-- parent surface
	sx, sy,	-- surface origine origine
	sw, sh,	-- size
	font,	-- name's font
	color,	-- name's color
	opts
)
	if not opts then
		opts = {}
	end

	local self = Surface( psrf, sx,sy, sw,sh )

	local name
	local ncpu
	local gradient

	self.setFont( font )	-- Used as well by the Title
	local offy = self.get():GetFontExtents() + 3

	local cpuld = Field( self, 
		sw-self.get():GetStringExtents("53.88")-2, 1,
		font, COL_GREEN, {
			gradient = gradient,
			timeout = 65,
			align = ALIGN_RIGHT,
			sample_text = "53.23",
		}
	)

	local srf_max = FieldBlink( self, animTimer, 1, offy, font, COL_DIGIT, {
		align = ALIGN_RIGHT,
		sample_text = "53.23",
		bgcolor = COL_TRANSPARENT,
		ownsurface = true,
		gradient = gradient
	} )

	local srf_trnd = GfxArea( self, 1, offy, sw-2, sh-offy-1, COL_ORANGE, COL_GFXBGT,{
		align=ALIGN_RIGHT,
		stretch = 1,
		gradient = gradient,
		heverylines={ {0.5, COL_DARKGREY, 2}, { 1, COL_GREY, 10 } }
	} )

	local cpuload = StoreGfx( srf_trnd, {
		forced_min = 0,
		smax = srf_max,
		force_max_refresh = true
	})

	function self.allocate(	-- Use this surface for given machine
		aname,	-- Name of the machine
		ancpu	-- Number of cores
	)
		name = aname
		ncpu = ancpu
		gradient = Gradient({
			[ncpu*.8] = COL_GREEN,
			[ncpu] = COL_ORANGE,
			[ncpu*1.5] = COL_RED
		})

		srf_trnd.setGradient( gradient )
	end

	function self.getName()
		return name
	end

	function self.Clear()	-- Fully remove this field
		psrf.get():SaveContext()
		psrf.get():SetClipS(sx,sy, sw,sh )	-- clear only this sub footprint
		psrf.Clear()
		psrf.get():RestoreContext()
	end

	function self.Decoration()	-- Clear then draw decorations
		self.Clear()
		self.get():Clear( 0,0,0,.2 )
		self.setColor( COL_BORDER )
		self.get():DrawRectangle( 0,0, sw,sh )
		if name then
			self.setColor( color )
			self.get():DrawStringTop( name.." :", 2,2 )
		end
	end

	function self.Add(val)
		if self.getDisplayed() == false then
			self.Decoration()
			self.Visibility(true)
		end
		cpuld.update(val)
		cpuload.adddtv(val)
	end

	self.Visibility(false)

	return self
end

