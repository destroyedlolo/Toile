-- Receive an MQTT data and trace it

function MQTTStoreGfx(
	name, topic,
	srf,	-- surface to display the value
	sgfx,	-- surface to display the graphic
	smax,	-- surface to display the maximum	(optional)
	opts
)
--[[ known options  :
--	forced_min : force the minimum value to display
--	force_max_refresh : force refresh even if the max value doesn't change
--		(usefull if Max overlap gfx with 'frozen under')
--
--	+ options supported by MQTTinput
--]]
	if not opts then
		opts = {}
	end

	local dt = SelTimedCollection.create( sgfx.get():GetWidth() )
	local ansmax

	local self = MQTTDisplay( name, topic, srf, opts )

	local function adddt( )
		local v = self.get()	-- Retrieve last arrived data
		dt:Push(v)
	end

	local function updgfx()
		sgfx.DrawGfx(dt, opts.forced_min)
		SelShared.PushTask( sgfx.refresh, SelShared.TaskOnceConst("LAST") )
	end

	local function updmax()
		local _,max = dt:MinMax()

		if not ansmax or max ~= ansmax or opts.force_max_refresh then
			smax.update( max, ansmax == max)
			ansmax = max
		end
	end

	self.TaskOnceAdd( adddt )
	self.TaskOnceAdd( updgfx )
	if smax then
		self.TaskOnceAdd( updmax )
	end

	return self
end
