-- Percentage gauge
function GaugeHPercentBg(
	psrf,	-- mother surface
	sx,sy,	-- position in the mother surface
	sw,sh,	-- its size
	bgcolor, -- background color
	bcolor	-- border color (if nil, no border)
)
	local self = SubSurface(psrf, sx,sy, sw,sh )

	local degImg = SelImage.create(SELENE_SCRIPT_DIR .. "/Images/Degrade.png")
	local degSrf = degImg:toSurface()
	degImg:destroy()
	
	if bcolor then
		self.setColor(bcolor)
	end

	function self.Clear()
		self.get():Clear( bgcolor.get() )
	end

	function self.Draw( v )
		self.Clear()

		self.get():SetClipS(0,0, self.get():GetWidth()*v/100, self.get():GetHeight())
		self.get():StretchBlit(degSrf)
	
		if bcolor then
			self.get():SetClip()
			self.get():DrawRectangle(0,0, self.get():GetWidth(), self.get():GetHeight())
		end

		self.refresh()
	end

	return self
end
