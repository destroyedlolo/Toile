-- Define frequently used colors
-- (based on HTML color names)
function Color( r,g,b,a )
	local self = {}

	-- methods
	function self.get()
		return r,g,b,a
	end
	
	return self
end

