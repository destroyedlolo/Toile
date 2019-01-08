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
	local csr={ x=0, y=0 }	-- Current cursor
	local srf=self.get()

	function self.Clear()
		srf:Clear( opts.bgcolor.get() )
		csr.x = 0; csr.y = 0
	end

	function self.getCSR()
		return csr.x, csr.y
	end

	function self.Scroll()
		srf:SetBlittingFlags( SelSurface.BlittingFlagsConst('NONE') )
		srf:Flip(SelSurface.FlipFlagsConst("NONE"))	-- Mandatory on DBLBuff surface ( http://directfb-dev.directfb.narkive.com/H7dyGHtv/blitting-within-the-a-double-buffered-surface )
		srf:Blit( srf,
			{ 0, srf:GetFont():GetHeight(), sw, sh - srf:GetFont():GetHeight() },
			0,0
		)
		srf:SetColor( opts.bgcolor.get() ) -- Temporary set the background color
		srf:FillRectangle( 0, sh - srf:GetFont():GetHeight(), sw, srf:GetFont():GetHeight() )
		self.ColorApply() -- Restore color
	end

	function self.CR( withoutLF ) -- Carriage return
		if withoutLF then
			csr.x = 0
			return
		end

		csr.y = csr.y + srf:GetFont():GetHeight()
		csr.x = 0

		if csr.y > sh-srf:GetFont():GetHeight() then
			self.Scroll()
			csr.y = csr.y - srf:GetFont():GetHeight()
		end
	end

	function self.SmartCR()	-- CR() only if the area is not empty
		local x,y = self.getCSR()
		if x~=0 or y~=0 then	-- Scroll only if the display is not empty
			self.CR()
		end
	end

	function self.DrawString( t )
		local w = srf:GetFont():StringWidth( t )

		if csr.x ~= 0 and csr.x + w > sw then
			self.CR()
		end

		srf:DrawString( t, csr.x, csr.y )
		csr.x = csr.x + w
	
		self.refresh()
	end

	-- init
	self.get():SetFont( font )
	self.setColor( color )
	self.Clear()

	return self
end
