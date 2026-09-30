--
-- Playstation 5 support for Visual Studio backend.
-- Copyright Blizzard Entertainment, Inc
--

local p = premake
local vstudio = p.vstudio
local vc2010 = p.vstudio.vc2010
local m = p.modules.ps5

--
-- Extensions
--

p.PROSPERO = "prospero"

if vstudio.vs2010_architectures ~= nil then
	vstudio.vs2010_architectures.prospero   = "Prospero"
	p.api.addAllowed("system", p.PROSPERO)

	os.systemTags[p.PROSPERO] = { "prospero", "ps5", "sce", "console" }

	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { p.PROSPERO,  "Playstation 5" })
	end
end

filter { "system:Prospero" }
	toolset "clang"

filter { "system:Prospero", "kind:ConsoleApp or WindowedApp" }
	targetextension ".elf"

filter { "system:Prospero", "kind:SharedLib" }
	targetextension ".prx"
	implibsuffix "_stub"
	implibextension ".a"

filter {}
