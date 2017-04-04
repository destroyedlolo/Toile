-- Area to graph some trends

function GfxArea(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	color,	-- initial foreground color
	bgcolor, -- background color
	opts
)
--[[ known options  :
--	align : how to align the graphic (LEFT by default, RIGHT known also)
--	stretch : if not null, enlarge the graphic to fit surface width (force left alignment)
--]]
	if not opts then
		opts = {}
	end
	if opts.align ~= ALIGN_RIGHT or opts.stretch then
		opts.align = ALIGN_LEFT
	end
	
	local self = SubSurface(psrf, sx,sy, sw,sh )
	self.setColor( color )
	self.get():SetDrawingFlags( SelSurface.DrawingFlagsConst('BLEND') )
	self.get():SetRenderOptions( SelSurface.RenderOptionsFlagsConst('ANTIALIAS') )

	local mask = 0	-- invalid
	local back

	function self.FrozeUnder()	
		-- The current content of the surface will be "under" our graphic
		self.refresh() -- Ensure the background is fresh
		back = self.get():clone()
		mask = SelSurface:create { size = { sw,sh }, pixelformat=SelSurface.PixelFormatConst('ARGB') }
		mask:SetColor( color.get() )
	end

	self.ownsrf = self.get
	function self.get()
		if mask == 0 then
			return self.ownsrf()
		else
			return mask
		end
	end

	function self.Clear()
		if mask ~= 0 then
			self.ownsrf():restore(back)
			mask:Clear( bgcolor.get() )
		else
			self.get():Clear( bgcolor.get() )
		end
	end

	function self.DrawGfx( data, amin )	-- Minimal graphics
		self.Clear()

		local min,max = data:MinMax()
		min = amin or min
		if max == min then	-- No dynamic data to draw
			self.ownsrf():Clear( bgcolor.get() ) -- Ensure empty surface if nothing as to be displayed
			return
		end
		local h = self.get():GetHeight()-1
		local sy = h/(max-min) -- vertical scale
		local sx = self.get():GetWidth()/data:GetSize()
		if opts.stretch then
			if data:HowMany() == 0 then -- No data to display
				return
			end
			sx = self.get():GetWidth()/(data:HowMany() - 1) -- -1 as the 1st one doesn't have offset
		end

		local y		-- previous value
		local x=0	-- x position
		if opts.align == ALIGN_RIGHT then
			x = self.get():GetWidth() - data:HowMany()*sx
		end

		for v in data:iData() do
			if y then
				x = x+1
				self.get():DrawLine((x-1)*sx, h - (y-min)*sy, x*sx, h - (v-min)*sy)
if opts.stretch then
print(x, self.get():GetWidth(), (x-1)*sx, x*sx)
end
			end
			y = v 
		end

		if mask ~= 0 then	-- Apply the mask
			self.ownsrf():SetBlittingFlags( SelSurface.BlittingFlagsConst('BLEND_ALPHACHANNEL') )
			self.ownsrf():Blit( mask, nil, 0,0 )
			self.ownsrf():SetBlittingFlags( SelSurface.BlittingFlagsConst('NONE') )
		end
	end

	return self
end
