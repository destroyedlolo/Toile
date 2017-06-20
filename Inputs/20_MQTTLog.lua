-- Generic class to handle incoming logs

function MQTTLog(aname, atpc,	-- 1st topic
	srf,	-- where to display, must have a method Display(txt,udt)
	opts)
--[[ known options :
--]]
	local fifo = SelFIFO.create()
	local tpu = {}	-- Link b/w topic and userdata

	local pushmsg	-- early defintion for callback function
	local self = MQTTinput(aname, atpc, 
		function () pushmsg() end, -- call the callback defined afterward
	opts)

	function self.fifoname()
		return 'toto' -- name of this fifo, can't be a variable
	end

	pushmsg = function (topic, data)
print("aname", self.fifoname())
		fifo:Push( data, tpu[topic] )
		return true
	end

	local function display()
		while true do
		local t,f = fifo:Pop()
		if not t then break end
		srf.Display( t,f )
		end
	end

	tpu[atpc] = 0
	self.TaskOnceAdd( display )

	return self
end
