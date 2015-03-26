module(..., package.seeall)

local hashcode = {29, 58, 93, 28, 27} --> hash code

local function convert( chars, dist, inv )
	return string.char( ( string.byte( chars ) - 32 + ( inv and -dist or dist ) ) % 95 + 32 )
end

local function crypt(str,k,inv)
	local enc=""
	for i=1,#str do
		if (#str-k[5] >= i or not inv) then
			for inc=0,3 do
				if (i%4 == inc) then
					enc = enc .. convert(string.sub(str,i,i),k[inc+1],inv);
					break
				end
			end
		end
	end
	if (not inv) then
		for i=1,k[5] do
			enc = enc .. string.char(math.random(32,126));
		end
	end
	return enc
end

--local enc1 = {29, 58, 93, 28, 27};
--local str = "This is an encrypted string.";
--local crypted = crypt(str,enc1)
--print("Encryption: " .. crypted);
--print("Decryption: " .. crypt(crypted,enc1,true));

function settings.set(key, value)
	_G.__settings[key] = value
	
	settings.save()
end

function settings.get(key)
	if _G.__settings then
		return _G.__settings[key]
	else
		return nil
	end
end

function settings.save()
	local path = system.pathForFile( "settings.json", system.DocumentsDirectory )
	local fh = io.open(path, "w")
	
	local str = tostring( json.encode(_G.__settings) )
	local crypted = crypt( str, hashcode )
	fh:write( crypted )

	--fh:write(json.encode(_G.__settings))
	fh:close()
	fh = nil
end

function settings.load()
	local path = system.pathForFile( "settings.json", system.DocumentsDirectory )
	local fh, reason = io.open(path, "r")

	if fh then
		local str = fh:read("*a")
		local crypted = crypt( str, hashcode, true )
		local contents = tostring( crypted )

		-- read all contents of file into a string
		--local contents = fh:read("*a")
		
		local succ, data = pcall(function()
			return json.decode(contents)
		end)
		
		if succ then
			_G.__settings = data
		else
			_G.__settings = {}
		end

		print( "Loaded settings" )
	else
		print( "Couldn't load settings: " .. reason )
		
		_G.__settings = {}
	end
end