-- Test area
-- This widget support font changes

function TextArea(
	psrf,	-- mother surface
	sx,sy,	-- surrounding box position in the mother surface
	sw,sh,	-- its size
	font,	-- initial font to use
	color,	-- initial foreground color
	opts
)
--[[ known options  :
--	bgcolor : background color
--	ownsurface : it's not a subsurface but a real one that will be blited to
--		the parent at refresh. Need if it overlaps another one and draws
--		transparent colors
--	transparency : the surfaces below must be refreshed as this one has 
--		transparency. With this opt set, surfaces bellow are cleared first.
--		Mostly useful when it has background image.
--]]
	if not opts then
		opts = {}
	end
	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end

	local self
	if opts.ownsurface == true then
		self = Surface(psrf, sx,sy, sw,sh, opts )
		self.Visibility(true) -- always put on its mother surface as it's not the primary
	else
		self = SubSurface(psrf, sx,sy, sw,sh )
	end

	local csr = { x=0, y=0 }	-- Current cursor
	local srf = self.get()

	function self.Clear(
		clipped -- clipping area from child (optional)
	)
		if psrf.Clear and opts.transparency then
			psrf.get():SaveContext() -- In case of transparency
			if clipped then	-- Offset this surface
				clipped[1] = clipped[1]+sx
				clipped[2] = clipped[2]+sy
			else
				clipped = { sx,sy, sw,sh }
			end
			psrf.get():SetClipS( unpack(clipped) )	-- clear only this sub footprint
			psrf.Clear(clipped)
			psrf.get():RestoreContext()
		end

		srf:Clear( opts.bgcolor.get() )
		csr.x = 0; csr.y = 0
	end

	function self.getCSR()
		return csr.x, csr.y
	end

	function self.Scroll()
		self.get():SaveContext()

		local fh = self.get():GetFontExtents()
		srf:Blit( srf,
			0, -fh,
			0,0
		)

		self.setColor( opts.bgcolor )
		srf:FillRectangle( 0, sh - fh, sw, fh )

		self.get():RestoreContext()
	end

	function self.CR( withoutLF ) -- Carriage return
		if withoutLF then
			csr.x = 0
			return
		end

		csr.y = csr.y + self.get():GetFontExtents()
		csr.x = 0

		if csr.y > sh-self.get():GetFontExtents() then
			self.Scroll()
			csr.y = csr.y - self.get():GetFontExtents()
		end
	end

	function self.SmartCR()	-- CR() only if the area is not empty
		local x,y = self.getCSR()
		if x~=0 or y~=0 then	-- Scroll only if the display is not empty
			self.CR()
		end
	end

	function self.DrawString( t )
		local w = srf:GetStringExtents( t )

		if csr.x ~= 0 and csr.x + w > sw then
			self.CR()
		end

		srf:DrawStringTop( t, csr.x, csr.y )
		csr.x = csr.x + w
	
		self.Refresh()
	end

	-- init
	self.setFont( font )
	self.setColor( color )
	self.Clear()

	return self
end
