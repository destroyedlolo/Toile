-- Graphics zone with vbars

function GfxVBar(
	offx, offy,	-- Top left of the surface area
	sw, sh,	-- Size
	opts
)
--[[ known options  :
--	See GfxArea for parameters description
--	Are silently ignored :
--		align : always in LEFT mode
--		mode : always in range
--		stretch
--	GfxArea's default applies as well.
--
--	For the moment, dual data is not supported
]]
	local self = GfxArea( offx, offy, sw, sh, opts );

	function self.DrawGfx(data, amin)	-- Draw with data

		-- Ensure something has to be drawn
		local min,max = data:MinMax()
		if not min then	-- Nothing to display
			return
		elseif amin then
			if amin < min then
				min = amin
			end
		end
		if max == min then	-- No dynamic data to draw
			return
		end

		-- Scales computation
		local h = sh-1
		local sy = h/(max-min) -- vertical scale
		local sx = sw/data:GetSize()

			--
			-- Drawing
			--
		self.decoration()
		local x=0

		for v in data:iData() do
			x = x+1
			SelOLED.Line(offx + x*sx, offy + h, offx + x*sx, offy + h - (v-min)*sy, opts.fgcolor)
		end
	end

	return self
end
