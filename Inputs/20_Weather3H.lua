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
	local temp = MQTTDisplay( city..'3H'..time..'temp', topic ..'/'.. city ..'/'.. time ..'/temperature', dsp.temp, { suffix='°C'} )
	local wspd = MQTTinput( city..'3H'..time..'wspd', topic ..'/'.. city ..'/'.. time ..'/wind/speed')
	local wdir = MQTTinput( city..'3H'..time..'wdir', topic ..'/'.. city ..'/'.. time ..'/wind/direction')
	local clouds = MQTTinput( city..'3H'..time..'clouds', topic ..'/'.. city ..'/'.. time ..'/clouds')
	local humidity = MQTTinput( city..'3H'..time..'humidity', topic ..'/'.. city ..'/'.. time ..'/humidity')

	dsp.setName( city..'3H'..time )
	
	function self.update()
print( city ..':' .. self.get() )
	end

	self.TaskOnceAdd( dsp.updtime )
	icn.TaskOnceAdd( self.update )
--	temp.TaskOnceAdd( self.update )
	wspd.TaskOnceAdd( self.update )
	wdir.TaskOnceAdd( self.update )
	clouds.TaskOnceAdd( self.update )
	humidity.TaskOnceAdd( self.update )

	return self
end
