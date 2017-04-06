-- Render wind direction arrow

function WindDir(
	psrf,	-- mother surface
	sx,sy,	-- position
	sw,sh,	-- size
	opts
)
--[[ known options :
--	bgcolor,	-- background color
--	darkcolor, brightcolor -- Arrow colors
--]]
	if not opts then
		opts = {}
	end
	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end
	if not opts.darkcolor then
		opts.darkcolor = COL_RED
	end
	if not opts.brightcolor then
		opts.brightcolor = COL_ORANGE
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )

	local function rot( s, a )	-- Rotate coordinates s by angle a
		return	s.x * math.cos(a) + s.y * math.sin(a),
				-s.x * math.sin(a) + s.y * math.cos(a)
	end

	local function point( pos, a, c )	-- return the coordinate of 
							-- the point 'pos'
							-- rotated by 'a'
							-- centered on 'c'
		local x = pos.x * math.cos(a) + pos.y * math.sin(a)
		local y = -pos.x * math.sin(a) + pos.y * math.cos(a)
		return 	x * c + c,
				y * c + c
	end


	function self.update(dir)
		local dir = math.rad(-dir)	-- 0° is for the north and it's anti-clockwise
		local srf = self.get()

		local w,h = srf:GetSize()
		w = math.min( w,h )
		local c = w/2	-- Center coordinate

		local s1 = { x= -.35,	y= -.5 }
		local s2 = { x=    0,	y= -.5 }
		local s3 = { x=    0, 	y=  .5 }

		srf:Clear( opts.bgcolor.get() )

		srf:SetColor( opts.brightcolor.get() )
		local x1,y1 = point( s1, dir, c)
		local x2,y2 = point( s2, dir, c)
		local x3,y3 = point( s3, dir, c)

		srf:FillTriangle( x1,y1, x2,y2, x3,y3 )

		srf:SetColor( opts.darkcolor.get() )
		s1.x = .35
		x1,y1 = point( s1, dir, c)
		x2,y2 = point( s2, dir, c)
		x3,y3 = point( s3, dir, c)

		srf:FillTriangle( x1,y1, x2,y2, x3,y3 )

		self.refresh()
	end

	return self
end
