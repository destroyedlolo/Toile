-- Gauge based on value

function GaugeRange(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	color,	-- graph color
	bgcolor,	-- background color
	min,max,	-- value's range
	opts
)
--[[ known options  :
--	see GaugePercent
--]]

	local self = GaugePercent( psrf, sx,sy, sw,sh, color, bgcolor, opts )
	local scale = 100 / (max - min)

	local parent_Draw = self.Draw
	function self.Draw( v )
		v = (v-min) * scale

		if v < 0 then
			v = 0
		elseif v> 100 then
			v = 100
		end

		parent_Draw(v)
	end

	return self
end

