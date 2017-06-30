-- Generic class to handle incoming logs

function _MQTTLog(aname, atpc,	-- 1st topic
	srf,	-- where to display, must have a method Display(txt,user_dt)
	opts)
--[[ known options :
--]]
	local fifo = SelFIFO.Create(aname)
	local tpu = {}	-- Link b/w topic and userdata

	local pushmsg	-- early defintion for callback function
	local self = MQTTinput(aname, atpc, 
		function (t,m) pushmsg(t,m); return true end, -- call the callback defined afterward
	opts)

	function self.fifoname()	-- function to be redefined to declare topic name
		return nil -- name of this fifo, can't be a variable
	end

	pushmsg = function (topic, data)
		local fifo = SelFIFO.Find(self.fifoname())
		Selene.SelFIFOPush(fifo, data, tpu[topic])
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

function MQTTLog( aname, atpc,	-- 1st topic
	srf, -- where to display
	opts )
--[[ known options :
--]]

	local self = _MQTTLog(aname, atpc, srf, opts )

	function self.fifoname()
		return aname
	end

	return self
end
