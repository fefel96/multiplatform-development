--
-- Playstation 5 tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("prospero_extension_settings")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks

	function suite.setup()
		p.action.set("vs2015")
		wks = test.createWorkspace()
	end

	local function prepare()
		system "prospero"
		local prj = test.getproject(wks)
		vc2010.importExtensionSettings(prj)
	end

--
-- Writes language targets.
--

	function suite.hasShaderFiles()
		files { "hello.pssl" }
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionSettings">
	<Import Project="$(VCTargetsPath)\BuildCustomizations\OrbisWavePsslc.props" />
</ImportGroup>
		]]
	end
