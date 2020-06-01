-- Objects that are part of another surface

function SubSurface( 
	parent_srf,			-- Parent surface
	srf_x, srf_y,		-- top left position
	srf_w, srf_h		-- size
)

	local self = metaSurface( parent_srf.get():SubSurface(srf_x,srf_y, srf_w, srf_h) )

	----
	-- Fields
	----

	----
	-- Methods
	----
	function self.Refresh()
		-- No need to refresh the parent surface, it's the same datafield
		-- but we have to check if the parent is visible. If so only OUR
		-- area need to be refreshed
		if parent_srf.getDisplayed() then
			local px, py = parent_srf:getPos()
			parent_srf.getPhysical():Blit( self.get(), px+srf_x, py+srf_y )
		end
	end

	function self.refresh()	-- During dev
		print("Call to deprecated refresh()")
		self.Refresh()
	end

	return self
end
