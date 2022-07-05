-- Generic class to handle input coming from MQTT

function MQTTinput(aname, atpc, afunc, opts)
--[[ known options :
--	condition - condition to report activities
--	watchdog : watchdog associated to this topic
--	task : a task to be added in tasks table
--	taskonce : a function to be added in tasksonce table
--]]
	if not aname then	-- The name is the topic if not set
		aname = atpc
	end
	if not opts then
		opts = {}
	end
	SelShared.Set("$$name$$" .. atpc, aname)	-- Save the name for this topic

	
	local self = MQTTdata(aname, atpc, opts)

	-- Private fields
	local tasks = {}
	local tasksonce = {}

	-- methods
	function self.get()
		return SelShared.Get( SelShared.Get("$$name$$" .. atpc) )
--		return SelShared.Get( self.getName() )
	end

	function self.set( v )
		SelShared.Set( self.getName(), v )
	end

		-- Submit registered tasks
	function self.TaskSubmit()
		SubTasks( tasks )
	end

		-- Submit registered once tasks
	function self.TaskOnceSubmit()
		SubTasks( tasksonce, true )
	end

		-- Data received : submit registered tasks
	function self.received()
		self.TaskSubmit()
		self.TaskOnceSubmit()

		if opts.condition then
			opts.condition.ping()
		end
	end

	function self.TaskAdd( func )
		if TableTasksAdd( tasks, func ) == false then
			SelLog.log('E',"MQTTinput.TaskAdd( NULL )")
			return
		end
	end
	if opts.task then
		self.TaskAdd(opts.task)
	end

	function self.TaskRemove( func )
		TableTaskRemove( tasks, func )
	end

	function self.TaskOnceAdd( func )
		if TableTasksAdd( tasksonce, func ) == false then
			SelLog.log('E',"MQTTinput.TaskAdd( NULL )")
			return
		end
	end
	if opts.taskonce then
		self.TaskOnceAdd( opts.taskonce )
	end

	function self.TaskOnceRemove( func )
		TableTaskRemove( tasksonce, func )
	end

		-- Notify an object when a data is received
		-- mostly useful when more than one objects have to be notifed
		-- Its update() will be called as once task.
		-- It must retrieve by itself the value by a SelShared
		-- See VuMeter for an example
		--
		-- -> obj : object to be notified
		-- -> varname : name of the SelShared variable to query (optional)
	function self.NotifObject( obj, varname )
		if varname then
			obj.varname = varname
		end
		self.TaskOnceAdd( obj.update )
	end

	function self.list()
		SelLog.log('d', self.getName() .. " : Tasks " .. #tasks .. ' / ' .. #tasksonce)
	end

	-- initialiser
	local function rcvdt(tp, v)
		local name = SelShared.Get("$$name$$" .. tp)
		SelShared.Set( name, v )
		return true
	end

	if not afunc then
		afunc = rcvdt
	end

	table.insert( Topics, { topic=atpc, func=afunc, trigger=self.received, trigger_once=true, watchdog=opts.watchdog } )

	return self
end

