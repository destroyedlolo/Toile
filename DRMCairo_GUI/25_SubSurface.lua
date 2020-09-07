-- Objects that are part of another surface

function SubSurface( 
	parent_srf,			-- Parent surface
	srf_x, srf_y,		-- top left position
	srf_w, srf_h,		-- size
	opts
)
	if not opts then
		opts = {}
	end

	opts.debug = AddStringIfExist(opts.debug, "/subSrf")

	local self = metaSurface( parent_srf.get():SubSurface(srf_x,srf_y, srf_w, srf_h), srf_x, srf_y, srf_w, srf_h )

	----
	-- Fields
	----

	function self.Clear( clipped )
		if clipped then	-- Offset this surface
			clipped[1] = clipped[1]+srf_x
			clipped[2] = clipped[2]+srf_y
		else
			clipped = table.pack(self.getExtends())
		end
	
		parent_srf.Clear(clipped)
	end

	----
	-- Methods
	----
	function self.Refresh(
		clipped -- true if drawing is already restricted
	)
		-- No need to refresh the parent surface, it's the same datafield
		-- but we have to check if the parent is visible. If so only OUR
		-- area need to be refreshed
		if parent_srf.getDisplayed() then
			if clipped then	-- Offset this surface
				clipped[1] = clipped[1]+srf_x
				clipped[2] = clipped[2]+srf_y
			else
				clipped = table.pack(self.getExtends())
			end
			parent_srf.Refresh(clipped)
elseif opts.debug then
print(opts.debug, "parent surface not visible")
		end
	end

	function self.getDisplayed()	-- A subsurface is always displayed
		return true
	end

	function self.refresh()	-- During dev
		print("Call to deprecated refresh()")
		self.Refresh()
	end

	return self
end
