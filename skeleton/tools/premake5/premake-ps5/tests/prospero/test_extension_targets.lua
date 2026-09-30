--
-- Playstation 5 tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("prospero_extension_targets")
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
		vc2010.importExtensionTargets(prj)
	end

--
-- Writes language targets.
--

	function suite.structureIsCorrect()
		files { "hello.pssl" }
		prepare()
		test.capture [[
<ImportGroup Label="ExtensionTargets">
	<Import Project="$(VCTargetsPath)\BuildCustomizations\OrbisWavePsslc.targets" />
</ImportGroup>
		]]
	end
