-- Manage collection of images

function ImagesCollection(
	dir,
	opts
)
--[[ known options  :
--	transparent : handle transparency
--]]

	if not opts then
		opts = {}
	end

	local self = {}
	local Imgs = {}

	function self.getImg( id )
		if not Imgs[ id ] then
			local t = SelImage.create( dir .. id .. '.png' )
			if not opts.transparent then
				Imgs[ id ] = t
			else
				Imgs[ id ] = t:toSurface()
				t:destroy()
			end
		end
		return Imgs[ id ]
	end

	function self.getTransparency()
		return opts.transparent
	end
		
	return self
end

