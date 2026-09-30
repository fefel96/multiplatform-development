--
-- Playstation 5 tests
-- Copyright Blizzard Entertainment, Inc
--

	local p = premake
	local suite = test.declare("prospero_psslcompile_settings")
	local vc2010 = p.vstudio.vc2010
	local ps = p.modules.consoles.playstation


--
-- Setup
--

	local wks, prj

	function suite.setup()
		p.action.set("vs2010")
		wks, prj = test.createWorkspace()
	end

	local function prepare(platform)
		system "prospero"
		local cfg = test.getconfig(prj, "Debug", platform)
		ps.psslCompile(cfg)
	end

	function suite.empty()
		prepare()
		test.capture [[

		]]
	end

	function suite.defaultSettings()
		files { "shader.pssl" }
		prepare()
		test.capture [[

		]]
	end

	function suite.onPsslCompilePreprocessorDefinition()
		files { "shader.pssl" }
		pssldefines { "DEFINED_VALUE" }

		prepare()
		test.capture [[
<WavePsslc>
	<PreprocessorDefinitions>DEFINED_VALUE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
</WavePsslc>
		]]
	end

	function suite.onPsslCompilePreprocessorDefinition_multipleDefines()
		files { "shader.pssl" }
		pssldefines { "DEFINED_VALUE", "OTHER_DEFINED_VALUE" }

		prepare()
		test.capture [[
<WavePsslc>
	<PreprocessorDefinitions>DEFINED_VALUE;OTHER_DEFINED_VALUE;%(PreprocessorDefinitions)</PreprocessorDefinitions>
</WavePsslc>
		]]
	end

	function suite.onPsslCompileGenerateHeader()
		files { "shader.pssl" }
		pssloutputheader "myheader.h"
		pssloutput "Header"

		prepare()
		test.capture [[
<WavePsslc>
	<GenerateHeader>true</GenerateHeader>
	<HeaderFileName>myheader.h</HeaderFileName>
</WavePsslc>
		]]
	end

	function suite.onPsslCompileEmbed()
		files { "shader.pssl" }
		pssloutput "Embed"

		prepare()
		test.capture [[
<WavePsslc>
	<Embed>true</Embed>
</WavePsslc>
		]]
	end

	function suite.onPsslCompileOutputFile()
		files { "shader.pssl" }
		pssloutputfile "myoutput.sb"

		prepare()
		test.capture [[
<WavePsslc>
	<OutputFileName>myoutput.sb</OutputFileName>
</WavePsslc>
		]]
	end

	function suite.onPsslCompileShaderEntry()
		files { "shader.pssl" }
		psslentry "NewEntry"

		prepare()
		test.capture [[
<WavePsslc>
	<EntryPoint>NewEntry</EntryPoint>
</WavePsslc>
		]]
	end

	function suite.onPsslCompileShaderAdditionalOptions()
		files { "shader.pssl" }
		pssloptions "-opt"

		prepare()
		test.capture [[
<WavePsslc>
	<AdditionalOptions>-opt %(AdditionalOptions)</AdditionalOptions>
</WavePsslc>
		]]
	end
