-- Create linear gradient b/w given colors
-- the argument is an array where :
-- 	- the index is the input argument
-- 	- the value is the target color
--
-- 	If the argument == a value, a pure target color is returned
-- 	If the argument doesn't match, an interpolated color b/w the nearest index is returned

function Gradient( colors )
	local self = {}

	local function linearcolor( val, u1, v1, u2, v2)
		if u1 == u2 then
			return u1
		else	-- Linear function col = a*val+b
			local a,b
			a = (v2-v1)/(u2-u1)
			b = v1 - a*u1
			return (a*val + b)
		end
	end

	-- Find color b/w 2 known values
	-- key = known value
	-- value = corresponding color (table)
	function self.findgradientcolor( val )
		val = tonumber(val)
		if colors[val] then
			return colors[val].get()
		end

		local keys={}
		for k, _ in pairs( colors ) do
			table.insert(keys, k)
		end
		table.sort( keys )

		local pre, post	-- previous and next color
		for i,k in ipairs(keys) do
			if k > val then
				pre = keys[i-1]
				post = k
				break
			end
		end

		if pre and post then -- linear function
			r1, g1, b1, a1 = colors[pre].get()
			r2, g2, b2, a2 = colors[post].get()
			return 
				linearcolor( val, pre, r1, post, r2 ),
				linearcolor( val, pre, g1, post, g2 ),
				linearcolor( val, pre, b1, post, b2 ),
				linearcolor( val, pre, a1, post, a2 )
		elseif post then -- post without pre : 1st value
			return colors[keys[1]].get()
		else
			return colors[keys[#keys]].get()
		end
	end

	return self
end

