-- Long term weather

function Weather(
	dsp,	-- Where to display
	topic,
	city,
	time,	-- time offset
	opts
)
--[[ known options  :
--]]

	if not opts then
		opts = {}
	end

	local self = MQTTinput( city..time, topic ..'/'.. city ..'/'.. time ..'/time')
	local icn = MQTTinput( city..time..'acode', topic ..'/'.. city ..'/'.. time ..'/weather/acode')

	if dsp.tmax then
		MQTTDisplay( city..time..'tmax', topic ..'/'.. city ..'/'.. time ..'/temperature/day', dsp.tmax)
	end

	if dsp.tmin then
		MQTTDisplay( city..time..'tmin', topic ..'/'.. city ..'/'.. time ..'/temperature/night', dsp.tmin)
	end

	dsp.setName( city..time )
	
	self.TaskOnceAdd( dsp.updTime )
	icn.TaskOnceAdd( dsp.updateIcon )

	return self
end
