-- Receive an MQTT data and display it

function MQTTDisplay(
	name, topic,
	srf,	-- surface to display the value
	opts
)
--[[ known options  :
--	vfunction : validation function
--	gradient : gradient to colorize
--	suffix : string to add to the value (i.e. : unit)
--
--	+ options supported by MQTTinput
--]]
	if not opts then
		opts = {}
	end

	local self = MQTTinput( name, topic, opts.vfunction, opts)

	function self.update()
		local v = self.get()

		if opts.gradient then
			srf.setColorRGB( opts.gradient.findgradientcolor(v) )
		end

		if opts.suffix then
			v = v .. opts.suffix
		end
		
		srf.update(v)
	end

	-- init
	self.TaskOnceAdd( self.update )

	return self
end
