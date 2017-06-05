-- Receive an MQTT data and trace it

function MQTTStoreGfx(
	name, topic,
	srf,	-- surface to display the value
	sgfx,	-- surface to display the graphic
	opts
)
--[[ known options  :
--	forced_min : force the minimum value to display
--	force_max_refresh : force refresh even if the max value doesn't change
--		(usefull if Max overlap gfx with 'frozen under')
--	smax : max surface
--	smin : min surface
--	group : groups data by 'group' seconds
--
--	+ options supported by MQTTinput
--]]
	if not opts then
		opts = {}
	end

	local dt
	if opts.group then
print "***** Groupé"
		dt = SelTimedCollection.create( sgfx.get():GetWidth(), opts.group )
	else
print "***** Pas groupé"
		dt = SelTimedCollection.create( sgfx.get():GetWidth() )
	end
	local ansmax, ansmin

	local self = MQTTDisplay( name, topic, srf, opts )

	local function adddt( )
		local v = self.get()	-- Retrieve last arrived data
		dt:Push(v)
	end

	function self.getName()
		return name
	end

	function self.getCollection()
		return dt
	end

	function self.updgfx()
		sgfx.DrawGfx(dt, opts.forced_min)
		SelShared.PushTask( sgfx.refresh, SelShared.TaskOnceConst("LAST") )
	end

	local function updmaxmin()
		local min,max = dt:MinMax()

		if opts.smax and (not ansmax or max ~= ansmax or opts.force_max_refresh) then
			opts.smax.update( max, ansmax == max)
			ansmax = max
		end

		if opts.smin and (not ansmin or min ~= ansmin or opts.force_min_refresh) then
			opts.smin.update( min, ansmin == min)
			ansmin = min
		end
	end

	self.TaskOnceAdd( adddt )
	self.TaskOnceAdd( self.updgfx )

	if opts.smax or opts.smin then
		self.TaskOnceAdd( updmaxmin )
	end

	return self
end
