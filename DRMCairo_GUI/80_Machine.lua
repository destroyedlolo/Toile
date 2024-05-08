-- Display a machine figures

function Machine(
	psrf,	-- parent surface
	sx, sy,	-- surface origine origine
	sw, sh,	-- size
	font,	-- name's font
	color,	-- name's color
	opts
)
--[[ known options  :
--	timeout - timeout to mark this surface as dead
--]]
	if not opts then
		opts = {}
	end

	local self = Surface( psrf, sx,sy, sw,sh )

	local name
	local ncpu
	local gradient
	local colentry	-- Entry in the machine collection

	self.setFont( font )	-- Used as well by the Title
	local offy = self.get():GetFontExtents() + 3

	local cpuld = Field( self, 
		sw-self.get():GetStringExtents("53.88")-2, 1,
		font, COL_GREEN, {
			timeout = 65,
			align = ALIGN_RIGHT,
			sample_text = "53.23",
			bgcolor = COL_TRANSPARENT,
			transparency = true
		}
	)

	local srf_max = Field( self, 
		1, offy, 
		font, COL_DIGIT, {
			align = ALIGN_RIGHT,
			sample_text = "53.23",
			bgcolor = COL_TRANSPARENT,
			included = true,
--			ownsurface = true,
		} 
	)

	local srf_trnd = GfxArea( self, 1, offy, sw-2, sh-offy-1, COL_ORANGE, COL_GFXBGT,{
		align=ALIGN_RIGHT,
		stretch = 1,
		gradient = gradient,
		heverylines={ {0.5, COL_DARKGREY, 2}, { 1, COL_GREY, 10 } },
		transparency = true
	} )

	local cpuload = StoreGfx(nil, srf_trnd, {
		forced_min = 0,
		smax = srf_max,
		force_max_refresh = true
	})

	local wdcnt	-- Watchdog counter
	function self.watchdog()	-- ensure this host is still alive
		if wdcnt > 0 then
			wdcnt = wdcnt - 1
			if wdcnt == 0 then	-- Release this host
if opts.debug then
	print(name .. " lost")
end
				colentry.surface = nil	-- Release this place
				name = nil
				cpuload.getCollection():Clear()	-- Remove previous data
				self.Clear()
				self.Refresh()
				self.Visibility(false)
				wdTimer.TaskOnceRemove(self.watchdog)
			end
		end
	end

	function self.ping()	-- Notify the value has been updated
		if opts.timeout then
			wdcnt = opts.timeout
		end		
	end

	function self.allocate(	-- Use this surface for given machine
		aname,	-- Name of the machine
		ancpu,	-- Number of cores
		aentry	-- entry in the collection that's tracking machines in parent
	)
		name = aname
		ncpu = ancpu
		colentry = aentry
		gradient = Gradient({
			[ncpu*.8] = COL_GREEN,
			[ncpu] = COL_ORANGE,
			[ncpu*1.5] = COL_RED
		})

		srf_trnd.setGradient( gradient )
		cpuld.setGradient( gradient )
		srf_max.setGradient( gradient )

		if opts.timeout then
			wdTimer.TaskOnceAdd(self.watchdog)
			wdcnt = opts.timeout
		end
	end

	function self.getName()
		return name
	end

	function self.Clear(clipped)	-- Fully remove this field
		if clipped then	-- Offset this surface
			clipped[1] = clipped[1]+sx
			clipped[2] = clipped[2]+sy
		else
			clipped = { sx,sy, sw,sh }
		end
		psrf.Clear( clipped )
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
		self.ping()
	end

	self.Visibility(false)

	return self
end

