-- Define frequently used colors
-- (based on HTML color names)
function Color( r,g,b,a )
	local self = {}

	-- methods
	function self.get()
		return r,g,b,a
	end

	function self.fade( prc )	-- Fade the color by prc percent
		return 
			math.min(r * prc/100, 1),
			math.min(g * prc/100, 1),
			math.min(b * prc/100, 1), 
			math.min(a * prc/100, 1)
	end

	return self
end

