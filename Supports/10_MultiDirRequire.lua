-- Implement inclusions of multiple directories
-- filenames are stored before they are loaded
-- This is allowing to prioritise required files among several directories

function MultiDirRequire(
	path	-- Root of directories
)
	local self = {}

	local files = {}	-- files to load

	function self.loaddir( dir )
		for f in lfs.dir(path..dir) do
			local attr = lfs.attributes( path..dir ..'/'.. f )
			local found, len, res = f:find("^(.*)%.[^%.]*$")
			if found and attr.mode == 'file' and res:sub(1,1) ~= '.' and f:match("^.+(%..+)$") ~= '.md' and string.len(res) ~= 0 then
				if files[res] then
					SelLog.Log('E', res .. ' erasing "' .. files[res] ..'"')
				end
				files[res] = dir ..'/'.. res
			end
		end
	end

	function self.requirefiles()
		local keys = {}

		for k,v in pairs(files) do
			table.insert( keys, k )
		end
		table.sort(keys)

		for _,k in ipairs(keys) do
			SelLog.Log('L', files[k] .. ' loading')
			require( files[k] )
			SelLog.Log('L', files[k] .. ' loaded')
		end
	end

	return self
end
