-- Manage collection of images

function ImagesCollection(
	dir,
	opts
)
--[[ known options  :
--]]

	if not opts then
		opts = {}
	end

	local self = {}
	local Imgs = {}

	function self.getImg( id )
		if not Imgs[ id ] then
			Imgs[ id ] = SelImage.create( dir .. id .. '.png' )
		end
		return Imgs[ id ]
	end

	return self
end

