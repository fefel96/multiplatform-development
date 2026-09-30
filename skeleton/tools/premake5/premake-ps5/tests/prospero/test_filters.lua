--
-- Playstation 5 tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("prospero_filters")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2015")
		wks = test.createWorkspace()
	end

	local function prepare()
		system "prospero"
		prj = test.getproject(wks)
		vc2010.filterGroups(prj)
	end

	function suite.itemGroup_onPSSL()
		files { "hello.pssl" }
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl" />
</ItemGroup>
		]]
	end
