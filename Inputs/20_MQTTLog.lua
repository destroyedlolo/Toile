-- Generic class to handle incoming logs

function _MQTTLog(aname, atpc,	-- 1st topic
	srf,	-- where to display, must have a method Display(txt,user_dt)
	opts	-- Come from MQTTLog
)
	local fifo = SelFIFO.Create(aname)

	local pushmsg	-- early defintion for callback function
	local self = MQTTinput(aname, atpc, 
		function (t,m) pushmsg(t,m); return true end, -- call the callback defined afterward
	opts)

	function self.fifoname()	-- function to be redefined to declare topic name
		return nil -- name of this fifo
	end

	function self.udata()
		return nil	-- return userdata for atpc
	end	

	function self.RecvMsg(data, udt)
		local fifo = SelFIFO.Find(self.fifoname())
		SelFIFO.Push2FIFO(fifo, data, udt)
	end
	pushmsg = function(t,d) self.RecvMsg(d, self.udata()) end
	
	function self.DisplayCallBack()	-- callback to display stored values
		while true do
			local t,f = fifo:Pop()
			if not t then break end
			srf.Display( t,f )
		end
	end
	self.TaskOnceAdd( self.DisplayCallBack )

	return self
end

function MQTTLog( aname, atpc,	-- 1st topic
	srf, -- where to display
	aopts )
--[[ known options :
		udata = userdata for provided atpc (default : 0)
--]]
	if not aopts then
		aopts = {}
	end
	aopts.udata = aopts.udata or 0

	local self = _MQTTLog(aname, atpc, srf, aopts )

	function self.fifoname()
		return aname
	end

	function self.udata()
		return aopts.udata
	end

	function self.RegisterTopic( name, tpc, opts )
--[[ known options :
		udata = userdata for provided atpc (default : 0)
--]]
		if not opts then
			opts = {}
		end
		opts.udata = opts.udata or 0
		opts.taskonce = self.DisplayCallBack

		return MQTTinput( name, tpc, function (t,d) self.RecvMsg(d, opts.udata); return true end, opts)
	end

	return self
end

--[[ Example usage :

1/ Create the primary message logger

	local log = MQTTLog('marcel', 'Marcel.prod/Log/Information', Notification)

2/ Add another topic to it

	log.RegisterTopic( 'message', 'messages2', { udata=1 } )

--]]

