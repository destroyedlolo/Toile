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
--]]
	if not opts then
		opts = {}
	end
	if not opts.bgcolor then
		opts.bgcolor = COL_BLACK
	end

	local self = SubSurface(psrf, sx,sy, sw,sh )
	local csr = { x=0, y=0 }	-- Current cursor
	local srf = self.get()

	function self.Clear()
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
