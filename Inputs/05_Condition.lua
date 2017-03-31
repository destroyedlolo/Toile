-- Reports condition

function Condition (
	srf,	-- surface to report condition
	keep,	-- Duration to report ok condition
	opts
)
--[[ known options :
--	ok_color - color to report ok
--	issue_color - color to report issue
--]]
	if not opts then
		opts = {}
	end
	if not opts.ok_color then
		opts.ok_color = COL_GREEN
	end
	if not opts.issue_color then
		opts.issue_color = COL_ORANGE
	end

	local self = bipTimer( keep )
	local status

	function self.turnoff() -- Timeout to report condition
		status = 0
		srf.Clear()
		self.TaskOnceRemove(self.turnoff)
	end

	function self.Update()
		self.TaskOnceRemove(self.turnoff)
		if status == 0 then -- No condition
			srf.Clear()
		elseif status < 0 then -- Everything is fine
			srf.Update( opts.ok_color )
			self.TaskOnceAdd(self.turnoff)
		else	-- Error condition
			srf.Update( opts.issue_color )
		end
	end

	function self.clear()
		status = 0
		self.Update()
	end

	function self.ping()	-- Report working condition
		self.getTimer():Reset()
		if status == 0 then
			status = -1
			self.Update()
		end
	end

	function self.report_issue()
		status = status + 1
		self.Update()
	end

	function self.issue_corrected()
		status = status - 1
		if status < 0 then
			status = 0
		end
		self.Update()
	end

	self.clear()
	return self
end

