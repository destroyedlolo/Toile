-- Reports condition

local function Condition (
	srf,	-- surface to report condition
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

	local status

	function self.Update()
		if status == 0 then -- No condition
			srf.Clear()
		elseif status < 0 then -- Everything is fine
			srf.Update( opts.ok_color )
		else	-- Error condition
			srf.Update( opts.issue_color )
		end
	end

	function self.clear()
		status = 0
		self.Update()
	end

	function self.ping()	-- Report working condition
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

