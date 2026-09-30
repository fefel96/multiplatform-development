--
-- Playstation 5 tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("prospero_files")
	local vc2010 = p.vstudio.vc2010


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2017")
		wks = test.createWorkspace()
	end

	local function prepare()
		system "prospero"
		prj = test.getproject(wks, 1)
		vc2010.files(prj)
	end

	function suite.itemGroup_onPSSL()
		files { "hello.pssl" }
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl">
		<FileType>Document</FileType>
	</WavePsslc>
</ItemGroup>
		]]
	end

	function suite.itemGroup_onPSSL_define()
		files { "hello.pssl" }
		filter { "files:**.pssl" }
			pssldefines { "DEFINED_VALUE" }
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl">
		<FileType>Document</FileType>
		<PreprocessorDefinitions>DEFINED_VALUE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
	</WavePsslc>
</ItemGroup>
		]]
	end

	function suite.itemGroup_onPSSL_multipleDefines()
		files { "hello.pssl" }
		filter { "files:**.pssl" }
			pssldefines { "DEFINED_VALUE", "OTHER_DEFINED_VALUE" }
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl">
		<FileType>Document</FileType>
		<PreprocessorDefinitions>DEFINED_VALUE;OTHER_DEFINED_VALUE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
	</WavePsslc>
</ItemGroup>
		]]
	end

	function suite.itemGroup_onPSSL_generateHeader()
		files { "hello.pssl" }
		filter { "files:**.pssl" }
			pssloutputheader "myheader.h"
			pssloutput "Header"
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl">
		<FileType>Document</FileType>
		<GenerateHeader>true</GenerateHeader>
		<HeaderFileName>myheader.h</HeaderFileName>
	</WavePsslc>
</ItemGroup>
		]]
	end

	function suite.itemGroup_onPSSL_embed()
		files { "hello.pssl" }
		filter { "files:hello.pssl" }
			pssloutput "Embed"
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl">
		<FileType>Document</FileType>
		<Embed>true</Embed>
	</WavePsslc>
</ItemGroup>
		]]
	end

	function suite.itemGroup_onPSSL_outputFile()
		files { "hello.pssl" }
		filter { "files:**.pssl" }
			pssloutputfile "myoutput.ags"
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl">
		<FileType>Document</FileType>
		<OutputFileName>myoutput.ags</OutputFileName>
	</WavePsslc>
</ItemGroup>
		]]
	end

	function suite.itemGroup_onPSSL_entry()
		files { "hello.pssl" }
		filter { "files:**.pssl" }
			psslentry "myentry"
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl">
		<FileType>Document</FileType>
		<EntryPoint>myentry</EntryPoint>
	</WavePsslc>
</ItemGroup>
		]]
	end

	function suite.itemGroup_onPSSL_additionalOptions()
		files { "hello.pssl" }
		filter { "files:**.pssl" }
			pssloptions "-opt"
		prepare()
		test.capture [[
<ItemGroup>
	<WavePsslc Include="hello.pssl">
		<FileType>Document</FileType>
		<AdditionalOptions>-opt %(AdditionalOptions)</AdditionalOptions>
	</WavePsslc>
</ItemGroup>
		]]
	end

	function suite.itemGroup_clCompile_enablewarnings()
		files { "test.cpp" }
		filter { "files:test.cpp" }
			enablewarnings { "enable" }
		prepare()
		test.capture [[
<ItemGroup>
	<ClCompile Include="test.cpp">
		<EnableSpecificWarnings>enable;%(EnableSpecificWarnings)</EnableSpecificWarnings>
	</ClCompile>
</ItemGroup>
		]]
	end
