-- Short term weather

function Weather3H(
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

	local self = MQTTinput( city..'3H'..time, topic ..'/'.. city ..'/'.. time ..'/time')
	local icn = MQTTinput( city..'3H'..time..'acode', topic ..'/'.. city ..'/'.. time ..'/weather/acode')
	local desc = MQTTDisplay( city..'3H'..time..'desc', topic ..'/'.. city ..'/'.. time ..'/weather/description', dsp.desc)
	local temp = MQTTDisplay( city..'3H'..time..'temp', topic ..'/'.. city ..'/'.. time ..'/temperature', dsp.temp )
	local wspd = MQTTDisplay( city..'3H'..time..'wspd', topic ..'/'.. city ..'/'.. time ..'/wind/speed', dsp.windspeed, { align = ALIGN_RIGHT } )
	local wdir = MQTTDisplay( city..'3H'..time..'wdir', topic ..'/'.. city ..'/'.. time ..'/wind/direction', dsp.windd)
	local clouds = MQTTDisplay( city..'3H'..time..'clouds', topic ..'/'.. city ..'/'.. time ..'/clouds', dsp.clouds)
	local humidity = MQTTDisplay( city..'3H'..time..'humidity', topic ..'/'.. city ..'/'.. time ..'/humidity', dsp.humidity)

	dsp.setName( city..'3H'..time )
	
	function self.update()
print( city ..':' .. self.get() )
	end

	self.TaskOnceAdd( dsp.updTime )
	icn.TaskOnceAdd( dsp.updateIcon )
--	wdir.TaskOnceAdd( self.update )

	return self
end
