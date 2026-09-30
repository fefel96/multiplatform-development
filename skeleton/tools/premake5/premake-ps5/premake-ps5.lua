--
-- Console support for premake.
-- Copyright Blizzard Entertainment, Inc
--

if not premake.modules.ps5 then
	require('vstudio')
	premake.modules.ps5 = {}

	-- sce
	include 'playstation.lua'
	include 'prospero.lua'
end
