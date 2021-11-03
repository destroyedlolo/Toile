-- Trace data collection

function StoreGfx(
	sgfx,	-- surface to display the graphic (may be nil, opts.width must be provided)
	opts
)
--[[ known options  :
--	forced_min : force the minimum value to display
--	force_max_refresh : force refresh even if the max value doesn't change
--	force_min_refresh : force refresh even if the min value doesn't change
--	force_field : force refresh of given field
--		(usefull if Max overlap gfx with 'frozen under')
--	width : width of the gfx surface (mostly useful when sgfx can't be provided as with OLed interface)
--	smax : max surface
--	smin : min surface
--	group : groups data by 'group' seconds
--	rangeMin, rangeMax : reject data outside range
--	save_locally : flags to retrieve from local backup (to be handled externaly)
--]]
	if not opts then
		opts = {}
	end

	local dt
	if not opts.width then
		opts.width = sgfx.get():GetWidth()
	end

	if opts.group then
		dt = SelTimedWindowCollection.Create( opts.width, opts.group )
	else
		dt = SelTimedCollection.Create( opts.width )
	end

	local self = {}
	local ansmax, ansmin

	function self.getCollection()
		return dt
	end

	function self.getLocal()
		return opts.save_locally
	end

	function self.updmaxmin()	-- Update min/max fields
		local min,max
		if sgfx and sgfx.getMode() == 'delta' then
			min,max = dt:DiffMinMax()
		else
			min,max = dt:MinMax()
		end
		if not min then	-- The collection is still emtpy
			return
		end

		if opts.smax and (not ansmax or max ~= ansmax or opts.force_max_refresh) then
			opts.smax.update( max, ansmax == max)
			ansmax = max
		end

		if opts.smin and (not ansmin or min ~= ansmin or opts.force_min_refresh) then
			opts.smin.update( min, ansmin == min)
			ansmin = min
		end
	end

	function self.updgfx()	-- Update graphics
		if sgfx then	-- Only if a gfx surface is provided
			sgfx.DrawGfx(dt, opts.forced_min)
		end
		self.updmaxmin()	-- Update min/max fields
	
		if sgfx then	-- Only if a gfx surface is provided
			sgfx.Refresh()
		end
	
		if opts.force_field then
if opts.debug then
print(opts.debug, "field upd")
end
			opts.force_field.updtxt()
		end

	end

	function self.adddtv( v )
if opts.debug then
print("adddtv", v)
end
		if opts.rangeMin then
			if v < opts.rangeMin then
				return;
			end
		end
		if opts.rangeMax then
			if v > opts.rangeMax then
				return;
			end
		end
		dt:Push(v)

			-- Submit gfx refreshing tasks
			-- don't do it in this function to avoir race condition
			-- if data are received in too fast way
		SelShared.PushTask( self.updgfx, SelShared.TaskOnceConst("LAST") )
	end

	return self
end
